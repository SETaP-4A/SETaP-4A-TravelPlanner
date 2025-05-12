import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:setap4a/models/accommodation.dart';
import 'package:setap4a/models/activity.dart';
import 'package:setap4a/models/flight.dart';
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/screens/friend_pages/friend_selection.dart';
import 'package:setap4a/screens/trip_detail_pages.dart/edit_accommodation_page.dart';
import 'package:setap4a/screens/trip_detail_pages.dart/edit_activity_page.dart';
import 'package:setap4a/screens/trip_pages/edit_trip_page.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/services/auth_service.dart';
import 'package:setap4a/screens/trip_detail_pages.dart/edit_flight_page.dart';
import 'package:setap4a/widgets/trip_card.dart';
import 'package:setap4a/utils/dialog_utils.dart';
import 'package:setap4a/widgets/sectioned_item_list.dart';

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
  List<Map<String, dynamic>> collaborators = [];
  late Itinerary trip;
  StreamSubscription? _flightSub;
  StreamSubscription? _accommodationSub;
  StreamSubscription? _activitySub;
  StreamSubscription? _collaboratorsSub;

  @override
  void initState() {
    super.initState();
    trip = widget.trip;
    _listenToSubcollections();
    _listenToCollaborators();
  }

  @override
  void dispose() {
    _flightSub?.cancel();
    _accommodationSub?.cancel();
    _activitySub?.cancel();
    _collaboratorsSub?.cancel();
    super.dispose();
  }

  void _listenToSubcollections() {
    final uid = trip.ownerUid ?? FirebaseAuth.instance.currentUser?.uid;
    final itineraryId = trip.firestoreId;

    if (uid == null || itineraryId == null) return;

    final basePath = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('itineraries')
        .doc(itineraryId);

    _flightSub = basePath.collection('flights').snapshots().listen((snapshot) {
      setState(() {
        flights =
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      });
    });

    _accommodationSub =
        basePath.collection('accommodations').snapshots().listen((snapshot) {
      setState(() {
        accommodations =
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      });
    });

    _activitySub =
        basePath.collection('activities').snapshots().listen((snapshot) {
      setState(() {
        activities =
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      });
    });
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
    final confirmed = await confirmDeleteDialog(context, "flight");
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

  Future<void> _removeCollaborator(String uid) async {
    final itineraryId = trip.firestoreId;
    final ownerUid = trip.ownerUid;

    if (itineraryId == null || ownerUid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(ownerUid)
        .collection('itineraries')
        .doc(itineraryId)
        .update({
      'collaborators': FieldValue.arrayRemove([uid])
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Collaborator removed')),
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
    final confirmed = await confirmDeleteDialog(context, "accommodation");
    if (!confirmed) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final itineraryId = trip.firestoreId!;
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
    final confirmed = await confirmDeleteDialog(context, "activity");
    if (!confirmed) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final itineraryId = trip.firestoreId!;
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

  Future<void> _loadSubData() async {
    final uid = trip.ownerUid ?? AuthService().getCurrentUser()?.uid;
    final itineraryId = trip.firestoreId;

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

  void _listenToCollaborators() {
    final itineraryId = trip.firestoreId;
    final ownerUid = trip.ownerUid;

    if (ownerUid == null || itineraryId == null) return;

    _collaboratorsSub = FirebaseFirestore.instance
        .collection('users')
        .doc(ownerUid)
        .collection('itineraries')
        .doc(itineraryId)
        .snapshots()
        .listen((doc) async {
      final List<String> collaboratorUids =
          List<String>.from(doc.data()?['collaborators'] ?? []);

      final List<Map<String, dynamic>> fetched = [];

      for (final uid in collaboratorUids) {
        final friendDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (friendDoc.exists) {
          fetched.add({
            'uid': uid,
            'name': friendDoc['name'] ?? 'Unnamed',
          });
        }
      }

      setState(() {
        collaborators = fetched;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  builder: (context) => EditTripPage(trip: trip),
                ),
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
            if (collaborators.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.group, color: Colors.blueAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                          children: [
                            const TextSpan(
                              text: "Shared with: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: collaborators
                                  .map((c) => c['name'])
                                  .join(', '),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SectionedItemList(
              title: "Flights",
              items: flights,
              formatter: (flight) =>
                  "${flight['airline']} - ${flight['flightNumber']} (${flight['departureAirport']} → ${flight['arrivalAirport']})",
              onEdit: _editFlight,
              onDelete: _deleteFlight,
              isViewer: trip.permission == 'viewer',
            ),
            SectionedItemList(
              title: "Accommodations",
              items: accommodations,
              formatter: (a) =>
                  "${a['name']} in ${a['location']} (${a['checkInDate']} → ${a['checkOutDate']})",
              onEdit: _editAccommodation,
              onDelete: _deleteAccommodation,
              isViewer: trip.permission == 'viewer',
            ),
            SectionedItemList(
              title: "Activities",
              items: activities,
              formatter: (a) =>
                  "${a['name']} - ${a['location']} at ${a['dateTime']}",
              onEdit: _editActivity,
              onDelete: _deleteActivity,
              isViewer: trip.permission == 'viewer',
            ),
            const SizedBox(height: 30),
            if (trip.permission != 'viewer') ...[
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (trip.ownerUid == FirebaseAuth.instance.currentUser?.uid)
                      ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Delete Trip"),
                              content: const Text(
                                  "Are you sure you want to delete this trip?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              await DatabaseHelper.instance
                                  .deleteItinerary(trip);
                              Navigator.pop(context, true);
                            } catch (e) {
                              print('❌ Failed to delete trip: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to delete trip: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text("Delete Trip"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FriendSelectionPage(trip: trip),
                          ),
                        );

                        if (result == true) {
                          final user = FirebaseAuth.instance.currentUser;
                          final tripId = trip.firestoreId;

                          if (user != null && tripId != null) {
                            final updatedDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('itineraries')
                                .doc(tripId)
                                .get();

                            final updatedTrip = Itinerary.fromMap(
                              updatedDoc.data()!,
                              firestoreId: tripId,
                            );

                            setState(() {
                              trip = updatedTrip;
                              _listenToCollaborators();
                            });
                          }
                        }
                      },
                      icon: const Icon(Icons.group_add),
                      label: const Text("Add Collaborators"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (trip.ownerUid !=
                            FirebaseAuth.instance.currentUser?.uid &&
                        (trip.collaborators ?? [])
                            .contains(FirebaseAuth.instance.currentUser?.uid))
                      ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Leave Trip"),
                              content: const Text(
                                  "Are you sure you want to leave this trip?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Leave",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final currentUid =
                                FirebaseAuth.instance.currentUser?.uid;
                            if (currentUid != null &&
                                trip.firestoreId != null) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(trip.ownerUid)
                                  .collection('itineraries')
                                  .doc(trip.firestoreId)
                                  .update({
                                'collaborators':
                                    FieldValue.arrayRemove([currentUid])
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('You have left the trip.')),
                              );
                              Navigator.pop(context, true);
                            }
                          }
                        },
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text("Leave Trip"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ],
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
}
