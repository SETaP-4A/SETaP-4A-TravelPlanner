import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SetUsernamePage extends StatefulWidget {
  @override
  _SetUsernamePageState createState() => _SetUsernamePageState();
}

class _SetUsernamePageState extends State<SetUsernamePage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isChecking = false;
  String? errorText;

  Future<void> _submitUsername() async {
    final username = _controller.text.trim();

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
      print("🔐 FirebaseAuth UID: ${user?.uid}");

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

      if (user == null) {
        print("❌ No authenticated user found.");
        setState(() {
          errorText = 'User is not signed in.';
          isChecking = false;
        });
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': username,
        'username_lowercase': username.toLowerCase(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('usernames')
          .doc(username)
          .set({'uid': user.uid});

      if (context.mounted) {
        Navigator.pushReplacementNamed(
            context, '/home'); // or pop if you came from register
      }
    } catch (e) {
      print("❌ Username submission error: $e");
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
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Username",
                  errorText: errorText,
                ),
              ),
              const SizedBox(height: 30),
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
