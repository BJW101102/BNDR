import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore package
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../pages/home.dart';
import '../authentication/login.dart';

class AuthService {
  final _firestore = FirebaseFirestore.instance;

//the signup fields that a user fills out with their info
  Future<void> signup(
      {required String email,
      required String password,
      required String firstName,
      required String lastName,
      required String username,
      required BuildContext context}) async {
    try {
      final userinfo = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'friends': [], //no friends
        'incoming friends' : [],
        'outgoing friends' : []
      };
      //simple method to check if there is alr a user with that username
      Future<bool> isUsernameTaken(String username) async {
        final QuerySnapshot result = await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .get();
        return result.docs.isNotEmpty;
      }
      //the bool of if the username exists
      bool usernameExists = await isUsernameTaken(username);
      //if username doesnt exist
      if (!usernameExists) {
        //make the fire auth user in the authentication database
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        //user that is returned with their UID
        final user = userCredential.user;

        //check to see if the authenticaiton worked and they had a unique email
        if (user?.uid != null) {
          //add the user to the firestore database
          await _firestore
              .collection('users')
              .doc(user?.uid.toString())
              .set(userinfo);
          //adding the event collection to a user
          _firestore
              .collection('users')
              .doc(user?.uid.toString()).collection('event list');
          //everything worked correctly so lets go to the homepage
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const Home()));
        }
        //if something goes wrong throw all these errors
      } else {
        String message = 'Username is already in use. Please try again.';
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      // Handle other errors
      Fluttertoast.showToast(
        msg: "An error occurred. Please try again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }
  //sign in method thing that gets the fields needed to signin 
  Future<void> signin(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => const Home()));
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  //simple signout
  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => Login()));
  }
}
