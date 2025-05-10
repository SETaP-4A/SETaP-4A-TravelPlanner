import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:setap4a/services/auth_service.dart';
import 'package:setap4a/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();
  String? errorMessage;

  bool _isValidInput(String username, String email, String password) {
    final usernameValid = RegExp(r'^[a-zA-Z0-9_]{3,}$').hasMatch(username);
    final emailValid = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email);
    final passwordValid = password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password);

    if (!usernameValid) {
      errorMessage =
          "Username must be at least 3 characters and only contain letters, numbers, or underscores.";
      return false;
    }

    if (!emailValid) {
      errorMessage = "Please enter a valid email address.";
      return false;
    }

    if (!passwordValid) {
      errorMessage =
          "Password must be at least 8 characters, include uppercase, lowercase, and a number.";
      return false;
    }

    return true;
  }

  Future<void> register() async {
    final username = usernameController.text.trim().toLowerCase();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!_isValidInput(username, email, password)) {
      setState(() {}); // update errorMessage
      return;
    }

    try {
      // 🔍 Step 1: Check if username is taken
      final existing =
          await FirebaseFirestore.instance.doc('usernames/$username').get();

      if (existing.exists) {
        setState(() {
          errorMessage = "Username is already taken.";
        });
        return;
      }

      // ✅ Step 2: Register user
      final user = await authService.signUpWithEmailPassword(
        email,
        password,
        username,
      );

      // 🔐 Step 3: Store username link if registration was successful
      if (user != null) {
        await FirebaseFirestore.instance
            .doc('usernames/$username')
            .set({'uid': user.uid});

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already registered.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Please enter a valid email address.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Password is too weak.';
        } else {
          errorMessage = 'Firebase error: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Unexpected error: $e';
      });
    }
  }

  Future<void> registerWithGoogle() async {
    try {
      final user = await authService.signInWithGoogle();

      if (user != null &&
          (user.displayName == null || user.displayName!.isEmpty)) {
        String? username = await _promptForUsername();
        if (username != null && username.isNotEmpty) {
          await user.updateDisplayName(username);
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
    }
  }

  Future<String?> _promptForUsername() async {
    String? username;
    await showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Choose a username'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter a username'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                username = controller.text.trim();
                Navigator.of(context).pop();
              },
              child: Text('Continue'),
            )
          ],
        );
      },
    );
    return username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Register'),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child:
                      Text(errorMessage!, style: TextStyle(color: Colors.red)),
                ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: register,
                child: Text('Register'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: registerWithGoogle,
                child: Text('Register with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
