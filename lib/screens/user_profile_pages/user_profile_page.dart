import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:setap4a/services/auth_service.dart'; // Adjust path if needed

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  final user = AuthService().getCurrentUser();

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user!.displayName ?? 'Unknown User'),
        actions: [
          IconButton(onPressed: null, icon: Icon(Icons.settings)),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_placeholder.png'),
            ),
            const SizedBox(height: 16),
            Text(
              user!.displayName ?? 'No username',
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
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 228, 227, 227),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// Call signUpWithEmailPassword() when you need to create a new user account with an email and password.

// Call sendEmailVerification() to send a verification email to the user after signing up.

// Call signInWithEmailPassword() when you need to log the user in with their email and password.

// Call signOut() when you need to log the user out of the app.

// Call getCurrentUser() to retrieve the currently authenticated user.

// Call resetPassword() to send a password reset email to the user.

// These are created in auth_service.dart and used in the UI layer of the app.




// After the user is signed in, you can update the AccountPage to display the real user’s name and email.

// For example:

// Text('Name: ${authService.getCurrentUser()?.displayName ?? 'N/A'}'),
// Text('Email: ${authService.getCurrentUser()?.email ?? 'N/A'}'),

// In this case, authService.getCurrentUser() fetches the currently logged-in user, and if they are not logged in or do not have the displayName, it shows 'N/A'.