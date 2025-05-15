import 'package:flutter/material.dart';
import 'package:setap4a/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  final user = AuthService().getCurrentUser(); // Currently authenticated user
  String? username; // Stores the user's username
  bool isLoading = true; // Controls loading state

  @override
  void initState() {
    super.initState();
    _fetchUsernameFromUID(); // Load username when page initializes
  }

  // Retrieves username from Firestore based on current user's UID
  Future<void> _fetchUsernameFromUID() async {
    if (user == null) return;

    // The usernames collection uses usernames as doc IDs and maps them to UIDs
    final snapshot =
        await FirebaseFirestore.instance.collection('usernames').get();

    for (final doc in snapshot.docs) {
      if (doc.data()['uid'] == user!.uid) {
        setState(() {
          username = doc.id;
          isLoading = false;
        });
        return;
      }
    }

    // Fallback if no username found for current UID
    setState(() {
      username = 'No username';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If the user is not logged in
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    // Show a loading spinner while fetching username
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show user profile once username and data are loaded
    return Scaffold(
      appBar: AppBar(
        title: Text(username ?? 'Unknown User'),
        automaticallyImplyLeading: false, // Hides default back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purpleAccent,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Display the username (or fallback if missing)
            Text(
              username ?? 'No username',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Show user’s email (Firebase Auth email)
            Text(
              user!.email ?? 'No email',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            // Spacer that could be used to separate content visually
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 10,
                width: MediaQuery.of(context).size.width / 5 * 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
