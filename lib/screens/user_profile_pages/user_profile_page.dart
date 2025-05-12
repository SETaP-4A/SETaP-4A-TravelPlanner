import 'package:flutter/material.dart';
import 'package:setap4a/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  final user = AuthService().getCurrentUser();
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsernameFromUID();
  }

  Future<void> _fetchUsernameFromUID() async {
    if (user == null) return;

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

    // Fallback if UID not found in usernames
    setState(() {
      username = 'No username';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(username ?? 'Unknown User'),
        actions: [IconButton(onPressed: null, icon: Icon(Icons.settings))],
        automaticallyImplyLeading: false,
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
            Text(
              username ?? 'No username',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user!.email ?? 'No email',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 10,
                width: MediaQuery.of(context).size.width / 5 * 4,
                child: const DecoratedBox(
                  decoration:
                      BoxDecoration(color: Color.fromARGB(255, 228, 227, 227)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
