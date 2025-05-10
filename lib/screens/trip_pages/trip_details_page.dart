import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:setap4a/models/accommodation.dart';
import 'package:setap4a/models/activity.dart';
import 'package:setap4a/models/flight.dart';
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/screens/trip_detail_pages.dart/edit_accommodation_page.dart';
import 'package:setap4a/screens/trip_detail_pages.dart/edit_activity_page.dart';
import 'package:setap4a/screens/trip_pages/edit_trip_page.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/services/auth_service.dart';
import 'package:setap4a/screens/trip_detail_pages.dart/edit_flight_page.dart';

class TripDetailsPage extends StatefulWidget {
  final Itinerary trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  List<Map<String, dynamic>> flights = [];
  List<Map<String, dynamic>> accommodations = [];
  List<Map<String, dynamic>> activities = [];

  @override
  void initState() {
    super.initState();
    _loadSubData();
  }

  void _editFlight(Map<String, dynamic> flight) {
    print("🛫 RAW flight map: $flight");

    final String? docId = flight['id']?.toString(); // safer
    if (docId == null) {
      print("❌ ERROR: Flight document ID is null");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flight document ID is missing.')),
      );
      return;
    }

    final flightModel = Flight.fromMap(flight, id: docId);
    print("✅ Parsed flight model: ${flightModel.airline}");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditFlightPage(flight: flightModel, docId: docId),
      ),
    );
  }

  void _deleteFlight(Map<String, dynamic> flight) async {
    final confirmed = await _confirmDelete("flight");
    if (!confirmed) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final itineraryId = widget.trip.firestoreId!;
    final docId = flight['id'];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('itineraries')
        .doc(itineraryId)
        .collection('flights')
        .doc(docId)
        .delete();

    _loadSubData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Flight deleted successfully')),
    );
  }

  void _editAccommodation(Map<String, dynamic> accommodation) {
    final String? docId = accommodation['id']?.toString();
    if (docId == null) {
      print("❌ ERROR: Accommodation document ID is null");
      return;
    }

    final accommodationModel = Accommodation.fromMap(accommodation, id: docId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAccommodationPage(
          accommodation: accommodationModel,
          docId: docId,
        ),
      ),
    );
  }

  void _deleteAccommodation(Map<String, dynamic> accommodation) async {
    final confirmed = await _confirmDelete("accommodation");
    if (!confirmed) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final itineraryId = widget.trip.firestoreId!;
    final docId = accommodation['id'];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('itineraries')
        .doc(itineraryId)
        .collection('accommodations')
        .doc(docId)
        .delete();

    _loadSubData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Accommodation deleted successfully')),
    );
  }

  void _editActivity(Map<String, dynamic> activity) {
    final String? docId = activity['id']?.toString();
    if (docId == null) {
      print("❌ ERROR: Activity document ID is null");
      return;
    }

    final activityModel = Activity.fromMap(activity, id: docId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditActivityPage(
          activity: activityModel,
          docId: docId,
        ),
      ),
    );
  }

  void _deleteActivity(Map<String, dynamic> activity) async {
    final confirmed = await _confirmDelete("activity");
    if (!confirmed) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final itineraryId = widget.trip.firestoreId!;
    final docId = activity['id'];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('itineraries')
        .doc(itineraryId)
        .collection('activities')
        .doc(docId)
        .delete();

    _loadSubData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity deleted successfully')),
    );
  }

  Future<bool> _confirmDelete(String type) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete $type'),
            content: Text('Are you sure you want to delete this $type?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete')),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _loadSubData() async {
    final uid = AuthService().getCurrentUser()?.uid;
    final itineraryId = widget.trip.firestoreId;

    if (uid == null || itineraryId == null) return;

    final firestore = FirebaseFirestore.instance;
    final basePath = firestore
        .collection('users')
        .doc(uid)
        .collection('itineraries')
        .doc(itineraryId);

    final flightsSnap = await basePath.collection('flights').get();
    final accommodationsSnap =
        await basePath.collection('accommodations').get();
    final activitiesSnap = await basePath.collection('activities').get();

    setState(() {
      flights =
          flightsSnap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      accommodations = accommodationsSnap.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      activities = activitiesSnap.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;

    return Scaffold(
      appBar: AppBar(
        title: Text(trip.title ?? "Trip Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditTripPage(trip: trip)),
              );
              if (updated == true) Navigator.pop(context, true);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSection(Icons.calendar_month, "Start Date", trip.startDate),
            _buildSection(Icons.event, "End Date", trip.endDate),
            _buildSection(Icons.place, "Destination", trip.location),
            _buildSection(Icons.description, "Description", trip.description),
            _buildSection(Icons.comment, "Comments", trip.comments),
            const SizedBox(height: 30),
            _buildListSection(
              "Flights",
              flights,
              (flight) =>
                  "${flight['airline']} - ${flight['flightNumber']} (${flight['departureAirport']} → ${flight['arrivalAirport']})",
              _editFlight,
              _deleteFlight,
            ),
            _buildListSection(
              "Accommodations",
              accommodations,
              (a) =>
                  "${a['name']} in ${a['location']} (${a['checkInDate']} → ${a['checkOutDate']})",
              _editAccommodation,
              _deleteAccommodation,
            ),
            _buildListSection(
              "Activities",
              activities,
              (a) => "${a['name']} - ${a['location']} at ${a['dateTime']}",
              _editActivity,
              _deleteActivity,
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete Trip"),
                      content: const Text(
                          "Are you sure you want to delete this trip?"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel")),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Delete",
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      await DatabaseHelper.instance.deleteItinerary(trip);
                      Navigator.pop(context, true);
                    } catch (e) {
                      print('❌ Failed to delete trip: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete trip: $e')));
                    }
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Text("Delete Trip"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(IconData icon, String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                      text: "$label: ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(
    String title,
    List<Map<String, dynamic>> items,
    String Function(Map<String, dynamic>) formatter,
    void Function(Map<String, dynamic>) onEdit,
    void Function(Map<String, dynamic>) onDelete,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...items.map((item) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(formatter(item),
                      style: const TextStyle(fontSize: 16)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            size: 20, color: Colors.blueAccent),
                        tooltip: "Edit",
                        onPressed: () => onEdit(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 20, color: Colors.redAccent),
                        tooltip: "Delete",
                        onPressed: () => onDelete(item),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
