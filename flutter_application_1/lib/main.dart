import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'test_views/login_page.dart';
import 'test_views/signup_page.dart';
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
        '/': (context) => LoginPage(), // Login page route
        '/signup': (context) => SignUpPage(), // Signup page route
        '/home': (context) => HomePage(), // Home page after login/signup
      },
    );
  }
}
