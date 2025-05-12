import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:setap4a/screens/trip_pages/trip_details_page.dart';
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/screens/trip_pages/add_trip_page.dart';
import 'package:setap4a/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setap4a/widgets/trip_card.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});
  _TripsPageState createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  List<Itinerary> trips = [];
  List<Map<String, dynamic>> incomingInvites = [];
  StreamSubscription? _tripSub;

  @override
  void initState() {
    super.initState();
    _listenToTripInvites();
    _listenToTrips();
  }

  @override
  void dispose() {
    _tripSub?.cancel();
    super.dispose();
  }

  void _listenToTrips() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _tripSub?.cancel(); // Cancel old subscription if exists

    _tripSub = FirebaseFirestore.instance
        .collectionGroup('itineraries')
        .where(
          Filter.or(
            Filter('ownerUid', isEqualTo: uid),
            Filter('collaborators', arrayContains: uid),
          ),
        )
        .snapshots()
        .listen((snapshot) {
      final updatedTrips = snapshot.docs.map((doc) {
        final data = doc.data();
        final isOwner = data['ownerUid'] == uid;

        // Look up permission from accepted invites (you can also cache this in Firestore)
        final matchingInvite = incomingInvites.firstWhere(
          (invite) => invite['tripId'] == doc.id,
          orElse: () => {},
        );

        final permission =
            isOwner ? 'editor' : matchingInvite['permission'] ?? 'viewer';

        return Itinerary.fromMap(
          {...data, 'permission': permission},
          firestoreId: doc.id,
        );
      }).toList();

      setState(() {
        trips = updatedTrips;
        _sortTripsByDate();
      });
    });
  }

  void _listenToTripInvites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tripInvites')
        .snapshots()
        .listen((snapshot) {
      final pendingOnly = snapshot.docs
          .where((doc) => doc.data()['status'] == 'pending')
          .map((doc) => {...doc.data(), 'docId': doc.id})
          .toList();

      setState(() {
        incomingInvites = pendingOnly;
      });
    });
  }

  String _getPermissionForTrip(String tripId) {
    final invite = incomingInvites.firstWhere(
      (i) => i['tripId'] == tripId && i['status'] == 'accepted',
      orElse: () => {},
    );
    return invite['permission'] ?? 'viewer';
  }

  Future<Map<String, List<String>>> _getCollaboratorNames(
      List<Itinerary> ownerTrips) async {
    final firestore = FirebaseFirestore.instance;
    final Map<String, List<String>> result = {};

    for (final trip in ownerTrips) {
      final tripDoc = await firestore
          .collection('users')
          .doc(trip.ownerUid)
          .collection('itineraries')
          .doc(trip.firestoreId)
          .get();

      final collaboratorUids =
          List<String>.from(tripDoc.data()?['collaborators'] ?? []);

      final names = <String>[];
      for (final uid in collaboratorUids) {
        final userDoc = await firestore.collection('users').doc(uid).get();
        final name = userDoc.data()?['name'] ?? 'Unnamed';
        names.add(name);
      }

      result[trip.firestoreId ?? ''] = names;
    }

    return result;
  }

  Future<void> _respondToInvite(Map<String, dynamic> invite,
      {required bool accept}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docId = invite['docId'] ?? invite['id']; // ensure both are checked
    final tripId = invite['tripId'];
    final inviterUid = invite['inviterUid'];

    final inviteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tripInvites')
        .doc(docId);

    if (accept) {
      final tripRef = FirebaseFirestore.instance
          .collection('users')
          .doc(inviterUid)
          .collection('itineraries')
          .doc(tripId);

      await tripRef.update({
        'collaborators': FieldValue.arrayUnion([user.uid])
      });
    }

    // First update the invite
    await inviteRef.update({'status': accept ? 'accepted' : 'declined'});

    // Then remove from local state and show feedback
    setState(() {
      incomingInvites.removeWhere(
          (i) => i['docId'] == docId || i['id'] == docId); // Handle both keys
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept ? 'Joined trip!' : 'Invite declined.'),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trip deleted successfully.")),
      );
    }
  }

  Widget _buildTripList({required bool isOwnerView}) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final filteredTrips = trips
        .where(
            (trip) => isOwnerView ? trip.ownerUid == uid : trip.ownerUid != uid)
        .toList();

    if (filteredTrips.isEmpty) {
      return const Center(child: Text("No trips to show."));
    }

    return FutureBuilder<Map<String, List<String>>>(
      future:
          isOwnerView ? _getCollaboratorNames(filteredTrips) : Future.value({}),
      builder: (context, snapshot) {
        final collaboratorMap = snapshot.data ?? {};

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: filteredTrips.length,
          itemBuilder: (context, index) {
            final trip = filteredTrips[index];
            final names = collaboratorMap[trip.firestoreId] ?? [];

            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TripDetailsPage(trip: trip)),
                );
              },
              child: TripCard(
                trip: trip,
                onDelete:
                    isOwnerView ? () => _confirmAndDeleteTrip(trip) : null,
                collaboratorNames: isOwnerView ? names : null,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final myTripsCount = trips
        .where(
            (trip) => trip.ownerUid == FirebaseAuth.instance.currentUser?.uid)
        .length;
    final friendTripsCount = trips
        .where(
            (trip) => trip.ownerUid != FirebaseAuth.instance.currentUser?.uid)
        .length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Travel App'),
          bottom: TabBar(
            tabs: [
              Tab(text: "My Trips ($myTripsCount)"),
              Tab(text: "Friends' Trips ($friendTripsCount)"),
            ],
          ),
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Upcoming Trips',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            if (incomingInvites.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Trip Invites",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...incomingInvites.map((invite) => Card(
                          child: ListTile(
                            title: Text(invite['tripTitle'] ?? 'Unnamed Trip'),
                            subtitle: Text(
                                "Permission: ${invite['permission']}",
                                style: TextStyle(color: Colors.grey[600])),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      _respondToInvite(invite, accept: true),
                                  child: const Text("Accept"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      _respondToInvite(invite, accept: false),
                                  child: const Text("Decline"),
                                ),
                              ],
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTripList(isOwnerView: true),
                  _buildTripList(isOwnerView: false),
                ],
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
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
