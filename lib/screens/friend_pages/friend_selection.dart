import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:setap4a/models/itinerary.dart';

class FriendSelectionPage extends StatefulWidget {
  final Itinerary trip;

  const FriendSelectionPage({super.key, required this.trip});

  @override
  _FriendSelectionPageState createState() => _FriendSelectionPageState();
}

class _FriendSelectionPageState extends State<FriendSelectionPage> {
  List<Map<String, dynamic>> allFriends = [];
  Map<String, String> selectedInvites =
      {}; // uid -> permission ("viewer" or "editor")

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final List<dynamic> friendUids = userDoc.data()?['friends'] ?? [];

    final List<Map<String, dynamic>> fetchedFriends = [];
    for (final uid in friendUids) {
      final friendDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (friendDoc.exists) {
        fetchedFriends.add({
          'uid': uid,
          'name': friendDoc['name'] ?? 'Unnamed',
        });
      }
    }

    setState(() {
      allFriends = fetchedFriends;
    });
  }

  void _toggleSelection(String uid) {
    setState(() {
      if (selectedInvites.containsKey(uid)) {
        selectedInvites.remove(uid);
      } else {
        selectedInvites[uid] = 'viewer';
      }
    });
  }

  void _setPermission(String uid, String permission) {
    setState(() {
      selectedInvites[uid] = permission;
    });
  }

  Future<void> _sendInvites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    for (final entry in selectedInvites.entries) {
      final uid = entry.key;
      final permission = entry.value;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tripInvites')
          .doc(widget.trip.firestoreId)
          .set({
        'tripId': widget.trip.firestoreId,
        'tripTitle': widget.trip.title,
        'inviterUid': user.uid,
        'permission': permission,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    Navigator.pop(context, true); // Indicate completion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invite Friends to Trip")),
      body: allFriends.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: allFriends.length,
              itemBuilder: (context, index) {
                final friend = allFriends[index];
                final uid = friend['uid'];
                final isSelected = selectedInvites.containsKey(uid);
                final currentPermission = selectedInvites[uid] ?? 'viewer';

                return ListTile(
                  title: Text(friend['name']),
                  trailing: isSelected
                      ? DropdownButton<String>(
                          value: currentPermission,
                          items: const [
                            DropdownMenuItem(
                                value: 'viewer', child: Text('Viewer')),
                            DropdownMenuItem(
                                value: 'editor', child: Text('Editor')),
                          ],
                          onChanged: (value) {
                            if (value != null) _setPermission(uid, value);
                          },
                        )
                      : const Icon(Icons.circle_outlined),
                  onTap: () => _toggleSelection(uid),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendInvites,
        icon: const Icon(Icons.send),
        label: const Text("Send Invites"),
      ),
    );
  }
}
