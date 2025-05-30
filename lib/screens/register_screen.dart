import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:setap4a/main.dart';
import 'package:setap4a/screens/home_screen.dart';
import 'package:setap4a/screens/user_profile_pages/set_username_page.dart';
import 'package:setap4a/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService authService = AuthService();

  String? errorMessage; // To display user-facing validation or Firebase errors

  // Dark background gradient for consistent theming
  final _darkGradient = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0f2027),
        Color(0xFF203a43),
        Color(0xFF2c5364),
      ],
    ),
  );

  // Wrapper for consistent card styling
  Widget _authCard({required Widget child}) => Card(
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: child,
        ),
      );

  // Reusable button styling
  ButtonStyle get btnStyle => ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  // Input validation for username, email, and password
  bool _isValidInput(String username, String email, String password) {
    final usernameValid = RegExp(r'^[a-zA-Z0-9_]{3,}$').hasMatch(username);
    final emailValid = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email);
    final passwordValid = password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password);

    if (!usernameValid) {
      errorMessage =
          'Username must be at least 3 characters and only contain letters, numbers, or underscores.';
      return false;
    }
    if (!emailValid) {
      errorMessage = 'Please enter a valid email address.';
      return false;
    }
    if (!passwordValid) {
      errorMessage =
          'Password must be at least 8 characters, include uppercase, lowercase, and a number.';
      return false;
    }
    return true;
  }

  // Register user with email and password
  Future<void> register() async {
    final username = usernameController.text.trim().toLowerCase();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!_isValidInput(username, email, password)) {
      setState(() {}); // Trigger rebuild to show validation error
      return;
    }

    try {
      // Check Firestore for existing username
      final existing =
          await FirebaseFirestore.instance.doc('usernames/$username').get();

      if (existing.exists) {
        setState(() => errorMessage = 'Username is already taken.');
        return;
      }

      // Attempt to register using AuthService
      final user = await authService.signUpWithEmailPassword(
        email,
        password,
        username,
      );

      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;

      if (user != null && currentUser != null) {
        final originalUsername = usernameController.text.trim();

        // Save user profile data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({
          'email': currentUser.email,
          'uid': currentUser.uid,
          'name': originalUsername,
          'username': originalUsername,
          'username_lowercase': originalUsername.toLowerCase(),
          'friends': [],
          'incomingRequests': [],
          'outgoingRequests': [],
        });

        // Add entry to usernames lookup
        await FirebaseFirestore.instance
            .collection('usernames')
            .doc(originalUsername.toLowerCase())
            .set({'uid': currentUser.uid});

        // Navigate to the Home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(themeNotifier: themeNotifier),
          ),
        );
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
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
      setState(() => errorMessage = 'Unexpected error: $e');
    }
  }

  // Google sign-up flow
  Future<void> registerWithGoogle() async {
    try {
      final result = await authService.signInWithGoogleAndCheckUsername();
      if (result == null) return;

      final hasUsername = result['hasUsername'] == true;

      // If user doesn’t have a username yet, redirect them to SetUsernamePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => hasUsername
              ? HomeScreen(themeNotifier: themeNotifier)
              : SetUsernamePage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign‑in failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _darkGradient,
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _authCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Register',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // Show error message if validation or Firebase error occurs
                    if (errorMessage != null) ...[
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Username input
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email input
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password input
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Register button
                    ElevatedButton(
                      style: btnStyle,
                      onPressed: register,
                      child: const Text('Register'),
                    ),
                    const SizedBox(height: 12),

                    // Google register button
                    ElevatedButton.icon(
                      style: btnStyle,
                      onPressed: registerWithGoogle,
                      icon: const Icon(Icons.login),
                      label: const Text('Register with Google'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Clean up controllers when screen is disposed
  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
