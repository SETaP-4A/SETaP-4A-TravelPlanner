import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/models/user.dart' as local_model;
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<local_model.User> getCurrentUserFromSQLite() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on Web.');
    }

    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('active_uid');

    if (uid == null) throw Exception('No active UID set.');

    print("🔍 UID from SharedPreferences: $uid");

    final db = await DatabaseHelper.instance.database;
    final result = await db.query('user', where: 'uid = ?', whereArgs: [uid]);

    if (result.isEmpty) throw Exception('No matching user in SQLite.');
    return local_model.User.fromMap(result.first);
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
    if (kIsWeb) {
      print("🌐 Skipping SQLite sync on web.");
      return;
    }

    print("📦 Syncing user to SQLite: ${user.uid}");

    try {
      List<Map<String, dynamic>> users =
          await DatabaseHelper.instance.loadUsers();
      print("🧠 Existing users in SQLite: ${users.length}");

      if (users.isEmpty) {
        print("🔨 Inserting user into SQLite...");
        await DatabaseHelper.instance.insertUser(user);
      } else {
        final existing = users.firstWhere(
          (u) => u['uid'] == user.uid,
          orElse: () => {},
        );
        if (existing.isEmpty) {
          print("🆕 New user, inserting...");
          await DatabaseHelper.instance.insertUser(user);
        } else {
          print("✅ User already exists in SQLite.");
        }
      }

      print("✅ User profile synced to SQLite");
    } catch (e) {
      print("❌ Error syncing user profile to SQLite: $e");
    }
  }

  // Get all users from local SQLite
  Future<List<local_model.User>> getAllLocalUsers() async {
    if (kIsWeb) {
      print("Skipping SQLite load on web.");
      return [];
    }

    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('user');
      return result.map((row) => local_model.User.fromMap(row)).toList();
    } catch (e) {
      print("Error loading users from SQLite: $e");
      return [];
    }
  }
}
