import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:setap4a/main.dart';
import 'package:setap4a/screens/home_screen.dart';

class SetUsernamePage extends StatefulWidget {
  @override
  _SetUsernamePageState createState() => _SetUsernamePageState();
}

class _SetUsernamePageState extends State<SetUsernamePage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isChecking =
      false; // Tracks loading state while checking/setting username
  String? errorText; // Stores error messages shown below the text field

  // Handles validation and submission of the chosen username
  Future<void> _submitUsername() async {
    final username = _controller.text.trim();

    // Validate non-empty
    if (username.isEmpty) {
      setState(() => errorText = 'Username can’t be empty');
      return;
    }

    setState(() {
      isChecking = true;
      errorText = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      print("FirebaseAuth UID: ${user?.uid}");

      // Check if the username already exists in Firestore
      final existing = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(username)
          .get();

      if (existing.exists) {
        setState(() {
          errorText = 'Username already taken';
          isChecking = false;
        });
        return;
      }

      // Handle case where user is not logged in (shouldn’t happen ideally)
      if (user == null) {
        print("No authenticated user found.");
        setState(() {
          errorText = 'User is not signed in.';
          isChecking = false;
        });
        return;
      }

      // Save username to the user document
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': username,
        'username_lowercase':
            username.toLowerCase(), // For case-insensitive search
      }, SetOptions(merge: true));

      // Also register the username in a dedicated lookup collection
      await FirebaseFirestore.instance
          .collection('usernames')
          .doc(username)
          .set({'uid': user.uid});

      // Navigate to Home screen once everything is saved
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(themeNotifier: themeNotifier),
          ),
        );
      }
    } catch (e) {
      print("Username submission error: $e");
      setState(() {
        errorText = 'Unexpected error: $e';
        isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose a Username")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Pick a unique username so friends can find you.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Username input field
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Username",
                  errorText:
                      errorText, // Shows error if username is invalid/taken
                ),
              ),
              const SizedBox(height: 30),

              // Show loading spinner while checking, otherwise show submit button
              isChecking
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitUsername,
                      child: const Text("Confirm Username"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
