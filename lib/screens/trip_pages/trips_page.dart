import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:setap4a/screens/trip_pages/trip_details_page.dart';
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/screens/trip_pages/add_trip_page.dart';
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

    _tripSub?.cancel();

    _tripSub = FirebaseFirestore.instance
        .collectionGroup('itineraries')
        .where(
          Filter.or(
            Filter('ownerUid', isEqualTo: uid),
            Filter('collaborators', arrayContains: uid),
          ),
        )
        .snapshots()
        .listen((snapshot) async {
      final List<Itinerary> updatedTrips = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final isOwner = data['ownerUid'] == uid;
        final tripId = doc.id;

        String permission = 'viewer';

        if (isOwner) {
          permission = 'editor';
        } else {
          final permDoc =
              await doc.reference.collection('permissions').doc(uid).get();
          if (permDoc.exists) {
            permission = permDoc.data()?['permission'] ?? 'viewer';
          }
        }

        final itinerary = Itinerary.fromMap(
          {...data, 'permission': permission},
          firestoreId: tripId,
        );

        updatedTrips.add(itinerary);
      }

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
        .where('status', isEqualTo: 'pending') // ✅ Only listen to pending
        .snapshots()
        .listen((snapshot) async {
      final List<Map<String, dynamic>> pendingWithNames = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final inviterUid = data['inviterUid'];
        String inviterName = 'Unknown';

        if (inviterUid != null) {
          final inviterDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(inviterUid)
              .get();

          inviterName = inviterDoc.data()?['name'] ?? 'Unnamed';
        }

        pendingWithNames.add({
          ...data,
          'docId': doc.id,
          'inviterName': inviterName,
        });
      }

      setState(() {
        incomingInvites = pendingWithNames;
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

      await tripRef
          .collection('permissions')
          .doc(user.uid)
          .set({'permission': invite['permission'] ?? 'viewer'});
    }

// ✅ Mark invite as resolved
    await inviteRef.update({'status': accept ? 'accepted' : 'declined'});

    setState(() {
      incomingInvites
          .removeWhere((i) => i['docId'] == docId || i['id'] == docId);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept ? 'Joined trip!' : 'Invite declined.'),
        ),
      );
    }

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
          bottom: TabBar(
            tabs: [
              Tab(text: "My Trips ($myTripsCount)"),
              Tab(text: "Friends' Trips ($friendTripsCount)"),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Upcoming Trips',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (incomingInvites.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Trip Invites",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        )),
                    const SizedBox(height: 8),
                    ...incomingInvites.map((invite) => Card(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  invite['tripTitle'] ?? 'Unnamed Trip',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        size: 16, color: Colors.blueGrey),
                                    const SizedBox(width: 6),
                                    Text(
                                      "From: ${invite['inviterName'] ?? 'Unknown'}",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Permission: ${invite['permission']}",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.65),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => _respondToInvite(invite,
                                          accept: true),
                                      child: const Text("Accept"),
                                    ),
                                    TextButton(
                                      onPressed: () => _respondToInvite(invite,
                                          accept: false),
                                      child: const Text("Decline"),
                                    ),
                                  ],
                                )
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTripPage()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Trip'),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
