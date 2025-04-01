import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/models/user.dart' as local_model;

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add user profile data to Firestore
  Future<void> createUserProfile(String uid, String name, String email) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error creating user profile: $e");
    }
  }

  // Fetch user profile data from Firestore
  Future<DocumentSnapshot> getUserProfile(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      print("Error fetching user profile: $e");
      return Future.error("Error fetching user profile");
    }
  }

  // Sync user profile to SQLite
  Future<void> syncUserProfileToSQLite(local_model.User user) async {
    try {
      // Load existing users from SQLite
      List<Map<String, dynamic>> users =
          await DatabaseHelper.instance.loadUsers();

      // If no users exist, insert the new user profile
      if (users.isEmpty) {
        await DatabaseHelper.instance.insertUser(user);
      }

      print("User profile synced to SQLite");
    } catch (e) {
      print("Error syncing user profile to SQLite: $e");
    }
  }
}
