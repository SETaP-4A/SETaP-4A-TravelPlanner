import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:setap4a/screens/trip_pages/trip_details_page.dart';
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/screens/trip_pages/add_trip_page.dart';
import 'package:setap4a/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Make sure this path is correct

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});
  _TripsPageState createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  List<Itinerary> trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      final user = AuthService().getCurrentUser();
      if (user == null) {
        print('No authenticated user found.');
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('itineraries')
          .get();

      setState(() {
        trips = snapshot.docs
            .map((doc) => Itinerary.fromMap(doc.data(), firestoreId: doc.id))
            .toList();
        _sortTripsByDate();
      });
    } catch (e) {
      print('Failed to load trips: $e');
    }
  }

  void _sortTripsByDate() {
    DateTime? parseDate(String? date) {
      if (date == null || date.isEmpty) return null;
      try {
        return DateFormat('MMMM dd, yyyy').parse(date);
      } catch (_) {
        return null;
      }
    }

    trips.sort((a, b) {
      final dateA = parseDate(a.startDate) ?? DateTime.now();
      final dateB = parseDate(b.startDate) ?? DateTime.now();
      return dateA.compareTo(dateB);
    });
  }

  void _confirmAndDeleteTrip(Itinerary trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Trip"),
        content: const Text("Are you sure you want to delete this trip?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteItinerary(trip);
      _loadTrips();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trip deleted successfully.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Upcoming Trips',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          if (trips.isNotEmpty)
            TripCard(
              trip: trips[0],
              isFeatured: true,
              onDelete: () => _confirmAndDeleteTrip(trips[0]),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: trips.length > 1 ? trips.length - 1 : 0,
              itemBuilder: (context, index) {
                final trip = trips[index + 1];
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TripDetailsPage(trip: trip)),
                    );
                    if (result == true) {
                      _loadTrips(); // ✅ Refresh UI properly
                    }
                  },
                  child: TripCard(
                    trip: trip,
                    onDelete: () => _confirmAndDeleteTrip(trip),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTripPage()),
          );
          if (result == true) {
            _loadTrips();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final Itinerary trip;
  final bool isFeatured;
  final VoidCallback? onDelete;

  const TripCard({
    super.key,
    required this.trip,
    this.isFeatured = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: isFeatured ? 20.0 : 12.0,
        ),
        leading: Icon(
          Icons.flight_takeoff,
          color: Colors.blueAccent,
          size: isFeatured ? 32 : 24,
        ),
        title: Text(
          trip.title ?? 'Unnamed Trip',
          style: TextStyle(
            fontSize: isFeatured ? 18 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(trip.startDate ?? ''),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDelete,
              )
            : null,
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripDetailsPage(trip: trip),
            ),
          );
          if (result == true) {
            final state = context.findAncestorStateOfType<State<TripsPage>>();
            (state as dynamic)?._loadTrips();
          }
        },
      ),
    );
  }
}
