import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:setap4a/models/user.dart' as local_model;
import 'user_profile_service.dart';

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
    try {
      firebase_auth.UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      firebase_auth.User? user = userCredential.user;
      if (user != null) {
        // Save user profile to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': user.email,
        });

        // Save user profile to SQLite
        await _userProfileService.syncUserProfileToSQLite(local_model.User(
            uid: user.uid, name: name, email: user.email ?? ""));

        return user;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("Sign up error: ${e.message}");
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
      return userCredential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("Sign in error: ${e.message}");
    }
    return null;
  }

  // Sign in user with Google
  Future<firebase_auth.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
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

      // First time login? Store profile in Firestore + SQLite
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          final displayName = user.displayName ?? "";
          final email = user.email ?? "";

          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': displayName,
            'email': email,
          });

          await _userProfileService.syncUserProfileToSQLite(
            local_model.User(uid: user.uid, name: displayName, email: email),
          );
        }
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

  // Get the currently signed-in user
  firebase_auth.User? getCurrentUser() {
    return _auth.currentUser;
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
