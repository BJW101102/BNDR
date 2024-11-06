import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore package
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

//the signup fields that a user fills out with their info
  Future<UserCredential> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    try {
      // Create user with Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userID = userCredential.user!.uid;

      // Store additional user info in Firestore
      await _db.collection('users').doc(userID).set({
        'userID': userID,
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'friends': {'incoming': [], 'outgoing': [], 'current': []},
        'events': []
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase exceptions if needed
      throw Exception('Error during signup: ${e.message}');
    } catch (e) {
      // Handle any other errors
      throw Exception('Unexpected error: $e');
    }
  }

  Future<UserCredential> signin({
    required String email,
    required String password,
  }) async {
    try {
      // Attempt to sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle specific errors
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      } else {
        throw Exception('Failed to sign in: ${e.message}');
      }
    } catch (e) {
      // Handle any other errors
      throw Exception('Unexpected error: $e');
    }
  }
}
