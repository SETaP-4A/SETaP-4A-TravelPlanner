import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User sign-in
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch(e) {
      if (e.code == 'user-not-found') {
        print('No User Found For That Email');  // Might be worth returning Error Messages, rather than printing to console.
      } else if (e.code == 'Wrong Password') {
        print('No User Found For That Email');  // NOTE - Reusing Same Message to avoid providing potential hackers with info
      }
    } catch (e) {
      print("Error signing in: $e");
    }
      return null;
    }

  // User sign-up
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch(e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('An account already exists with that email.');
      }
    } catch (e) {
      print("Error signing up: $e");
    }
    return null;
  }

  // User sign-out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
