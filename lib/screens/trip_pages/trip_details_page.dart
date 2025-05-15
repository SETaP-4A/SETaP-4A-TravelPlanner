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
import 'package:setap4a/utils/formatters.dart';
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
  StreamSubscription? _tripDocSub;

  @override
  void initState() {
    super.initState();
    trip = widget.trip;
    _listenToTripDoc();
    _loadLatestTripDetails();
    _listenToSubcollections();
    _listenToCollaborators();
  }

  @override
  void dispose() {
    _tripDocSub?.cancel();
    _flightSub?.cancel();
    _accommodationSub?.cancel();
    _activitySub?.cancel();
    _collaboratorsSub?.cancel();
    super.dispose();
  }

  void _listenToTripDoc() {
    final uid = trip.ownerUid;
    final tripId = trip.firestoreId;
    if (uid == null || tripId == null) return;

    _tripDocSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('itineraries')
        .doc(tripId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final updated = Itinerary.fromMap(doc.data()!, firestoreId: tripId);
        setState(() {
          trip = updated.copyWith(permission: trip.permission); // maintain role
        });
      }
    });
  }

  Future<void> _loadLatestTripDetails() async {
    final uid = trip.ownerUid;
    final tripId = trip.firestoreId;
    if (uid == null || tripId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('itineraries')
        .doc(tripId)
        .get();

    if (snapshot.exists) {
      final latestTrip =
          Itinerary.fromMap(snapshot.data()!, firestoreId: tripId);
      setState(() {
        trip = latestTrip.copyWith(permission: trip.permission); // Preserve
      });
    }
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
        builder: (_) => EditFlightPage(
          flight: flightModel,
          docId: docId,
          isViewer: trip.permission == 'viewer',
          ownerUid: trip.ownerUid!,
        ),
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
      print("ERROR: Accommodation document ID is null");
      return;
    }

    final accommodationModel = Accommodation.fromMap(accommodation, id: docId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAccommodationPage(
          accommodation: accommodationModel,
          docId: docId,
          isViewer: trip.permission == 'viewer',
          ownerUid: trip.ownerUid!,
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
      print("ERROR: Activity document ID is null");
      return;
    }

    final activityModel = Activity.fromMap(activity, id: docId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditActivityPage(
          activity: activityModel,
          docId: docId,
          ownerUid: trip.ownerUid!,
          isViewer: trip.permission == 'viewer',
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

      final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

// If current user has been removed from collaborators, show dialog & pop
      if (trip.ownerUid != currentUserUid &&
          !collaboratorUids.contains(currentUserUid)) {
        if (mounted) {
          await Future.delayed(Duration.zero); // ensure context is valid
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Removed from Trip"),
              content: const Text(
                  "You have been removed from this trip by the owner."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .popUntil((route) => route.isFirst), // go back safely
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
        return;
      }

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
        title: Text(trip.title ?? 'Trip Details'),

        // Only show the edit icon if the user is not a 'viewer'
        actions: [
          if ((trip.permission ?? 'viewer') != 'viewer')
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Trip',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditTripPage(trip: trip),
                  ),
                );
                if (result == true) {
                  _loadLatestTripDetails(); // Reload trip data after editing
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Trip metadata sections (date, location, etc.)
            _buildSection(Icons.calendar_month, "Start Date", trip.startDate),
            _buildSection(Icons.event, "End Date", trip.endDate),
            _buildSection(Icons.place, "Destination", trip.location),
            _buildSection(Icons.description, "Description", trip.description),
            _buildSection(Icons.comment, "Comments", trip.comments),

            // List of collaborators shown only if trip is shared
            if (collaborators.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.group, color: Colors.blueAccent),
                        const SizedBox(width: 12),
                        Text(
                          "Shared with:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // List of collaborator names with remove option (if current user is the owner)
                    ...collaborators.map((c) {
                      final isOwner = trip.ownerUid ==
                          FirebaseAuth.instance.currentUser?.uid;
                      final currentUserUid =
                          FirebaseAuth.instance.currentUser?.uid;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            c['name'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (isOwner && c['uid'] != currentUserUid)
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              tooltip: 'Remove from trip',
                              onPressed: () => _removeCollaborator(c['uid']),
                            ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),

            // Sections for flights, accommodations, activities
            SectionedItemList(
              title: "Flights",
              icon: Icons.flight,
              items: flights,
              formatter: formatFlight,
              onEdit: trip.permission == 'editor' ? _editFlight : null,
              onDelete: _deleteFlight,
              isViewer: trip.permission == 'viewer',
            ),
            SectionedItemList(
              title: "Accommodations",
              icon: Icons.hotel,
              items: accommodations,
              formatter: formatAccommodation,
              onEdit: trip.permission == 'editor' ? _editAccommodation : null,
              onDelete: _deleteAccommodation,
              isViewer: trip.permission == 'viewer',
            ),
            SectionedItemList(
              title: "Activities",
              icon: Icons.place,
              items: activities,
              formatter: formatActivity,
              onEdit: trip.permission == 'editor' ? _editActivity : null,
              onDelete: _deleteActivity,
              isViewer: trip.permission == 'viewer',
            ),

            const SizedBox(height: 30),

            // Action buttons: visible only to users with edit rights
            if (trip.permission != 'viewer') ...[
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Invite friends as collaborators
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

                          // Refresh trip after collaborators are added
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

                    // Owner-only: Delete trip
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
                              print('Failed to delete trip: $e');
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

                    // Editor-level users: Option to leave trip
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

            // Separate logic for viewer-only users who can leave trip
            if (trip.permission == 'viewer' &&
                trip.ownerUid != FirebaseAuth.instance.currentUser?.uid &&
                (trip.collaborators ?? [])
                    .contains(FirebaseAuth.instance.currentUser?.uid))
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Leave Trip"),
                        content: const Text(
                            "Are you sure you want to leave this trip?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
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
                      final currentUid = FirebaseAuth.instance.currentUser?.uid;
                      if (currentUid != null && trip.firestoreId != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(trip.ownerUid)
                            .collection('itineraries')
                            .doc(trip.firestoreId)
                            .update({
                          'collaborators': FieldValue.arrayRemove([currentUid])
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
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
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
