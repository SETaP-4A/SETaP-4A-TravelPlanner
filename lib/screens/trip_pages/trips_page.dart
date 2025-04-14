import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'trip_details_page.dart';
import 'package:intl/intl.dart'; // To format and compare dates

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});
  _TripsPageState createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  List<Map<String, dynamic>> trips = [
    {
      "destination": "Paris, France",
      "date": "April 10, 2025",
      "duration": "7 days",
      "name": "Springtime in Paris",
      "image": "assets/paris.jpg",
      "friends": ["Alice", "Bob"],
      "start_date": "April 10, 2025",
      "end_date": "April 17, 2025",
      "vibe": "Romantic",
      "location": "Paris, France",
      "description":
          "Exploring the city of love, visiting the Eiffel Tower, and enjoying French cuisine.",
      "comments":
          "Excited for this trip! Need to book the Louvre tickets in advance.",
      "activities": ["Eiffel Tower", "Louvre Museum", "Seine River Cruise"]
    },
    {
      "destination": "New York, USA",
      "date": "May 15, 2025",
      "duration": "5 days",
      "name": "NYC Adventure",
      "image": "assets/nyc.jpg",
      "friends": ["Charlie", "Dana"],
      "start_date": "May 15, 2025",
      "end_date": "May 20, 2025",
      "vibe": "Exciting",
      "location": "New York, USA",
      "description":
          "Exploring Times Square, Central Park, and Broadway shows.",
      "comments": "Book Broadway tickets in advance!",
      "activities": ["Times Square", "Central Park", "Broadway Show"]
    },
    {
      "destination": "Tokyo, Japan",
      "date": "June 20, 2025",
      "duration": "10 days",
      "name": "Tokyo Discovery",
      "image": "assets/tokyo.jpg",
      "friends": ["Emily", "Frank"],
      "start_date": "June 20, 2025",
      "end_date": "June 30, 2025",
      "vibe": "Cultural",
      "location": "Tokyo, Japan",
      "description":
          "Exploring temples, shopping in Shibuya, and tasting sushi.",
      "comments": "Check out TeamLab Borderless Museum!",
      "activities": ["Shibuya", "Meiji Shrine", "Akihabara"]
    }
  ];

  void _addNewTrip(Map<String, dynamic> newTrip) {
    setState(() {
      trips.add(newTrip);
      _sortTripsByDate(); // Re-sort after adding a new trip
    });
  }

  void _sortTripsByDate() {
    trips.sort((a, b) {
      DateTime dateA = DateFormat('MMMM dd, yyyy').parse(a["date"]);
      DateTime dateB = DateFormat('MMMM dd, yyyy').parse(b["date"]);
      return dateA.compareTo(dateB); // Sort trips by date
    });
  }

  @override
  void initState() {
    super.initState();
    _sortTripsByDate(); // Sort trips by date when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Upcoming Trips',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          if (trips.isNotEmpty)
            FeaturedTripCard(
                trip: trips[0]), // Display the next trip as featured
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: trips.length > 1
                  ? trips.length - 1
                  : 0, // Skip the first trip (featured)
              itemBuilder: (context, index) {
                return TripCard(
                    trip: trips[index + 1]); // Display the rest of the trips
              },
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     final newTrip = await Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => AddTripPage()),
      //     );
      //     if (newTrip != null) {
      //       _addNewTrip(newTrip);
      //     }
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

class TripCard extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(Icons.flight_takeoff, color: Colors.blueAccent, size: 30),
        title: Text(trip["destination"],
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(trip["date"]),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TripDetailsPage(trip: trip)),
          );
        },
      ),
    );
  }
}

class FeaturedTripCard extends StatelessWidget {
  final Map<String, dynamic> trip;

  const FeaturedTripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TripDetailsPage(trip: trip)),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4.0,
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flight_takeoff,
                      color: Colors.redAccent, size: 50),
                  const SizedBox(width: 10),
                  Text(trip["destination"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24)),
                ],
              ),
              const SizedBox(height: 10),
              Text(trip["date"], style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.star, color: Colors.amber, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
