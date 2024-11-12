import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/signup.dart';
import 'pages/event_setup.dart';
import 'test_views/home_page.dart'; // Home page after login/signup
import 'firebase_options.dart'; // Required for Firebase initialization

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the current platform options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Add const constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Authentication',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => Login(), // Login page route
        '/signup': (context) => Signup(), // Signup page route
        '/home': (context) => EventPage(), // Home page after login/signup
      },
    );
  }
}
