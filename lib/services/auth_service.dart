import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:setap4a/models/user.dart' as local_model;
import 'user_profile_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final UserProfileService _userProfileService;

  // Constructor with dependency injection for easier testing
  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    UserProfileService? userProfileService,
  })  : _auth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _userProfileService = userProfileService ?? UserProfileService();

  // Sign up user with email and password
  Future<firebase_auth.User?> signUpWithEmailPassword(
      String email, String password, String name) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      // Save user profile to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': user.email,
      });

      // Only sync to SQLite on non-web platforms
      if (!kIsWeb) {
        await _userProfileService.syncUserProfileToSQLite(local_model.User(
          uid: user.uid,
          name: name,
          email: user.email ?? "",
        ));
      }

      // ✅ Store current UID in shared preferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('active_uid', user.uid);

      return user;
    }

    return null;
  }

  // Sign in user with email and password
  Future<firebase_auth.User?> signInWithEmailPassword(
      String email, String password) async {
    try {
      firebase_auth.UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // ✅ Store UID
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('active_uid', user.uid);

        // ✅ Also sync user to SQLite
        if (!kIsWeb) {
          await _userProfileService.syncUserProfileToSQLite(
            local_model.User(
              uid: user.uid,
              name: user.displayName ?? "",
              email: user.email ?? "",
            ),
          );
        }
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("Sign in error: ${e.message}");
      return null;
    }
  }

  Future<firebase_auth.User?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        clientId: kIsWeb
            ? '788597551090-eg0p7kfppi5rmhqfcvftfgi4tpjncpdi.apps.googleusercontent.com'
            : null,
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase_auth.UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        final displayName = user.displayName ?? "";
        final email = user.email ?? "";

        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': displayName,
          'email': email,
        });

        if (!kIsWeb) {
          await _userProfileService.syncUserProfileToSQLite(
            local_model.User(uid: user.uid, name: displayName, email: email),
          );
        }

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('active_uid', user.uid);
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("Google sign-in error: ${e.message}");
      rethrow;
    }
  }

  // Sign out user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get the currently signed-in user (firebase)
  firebase_auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get the currently signed-in user (sqlite)
  static Future<local_model.User> getCurrentLocalUser() async {
    if (kIsWeb) {
      throw UnsupportedError('getCurrentLocalUser() is not available on Web.');
    }
    return await UserProfileService().getCurrentUserFromSQLite();
  }

  // Reset password for a given email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("Reset password error: ${e.message}");
    }
  }
}
