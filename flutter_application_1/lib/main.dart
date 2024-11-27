import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_navbar.dart';
import 'package:flutter_application_1/pages/event_setup.dart';
import 'pages/login.dart';
import 'pages/signup.dart';
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

class Mainscreen extends StatefulWidget {
  const Mainscreen({Key? key}) : super(key: key); // Add const constructor

  @override
  _MainscreenState createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  int _selectedIndex = 0;

  // these are where pages for the navigation bar are stored. 
  final List<Widget> _pages = <Widget>[
    EventPage(),
    //Planner(),
    HomePage(),
  ];

  // method so that _selectedIndex can be changed to switch between pages
  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : Center(
        child: _pages.elementAt(_selectedIndex),
      ), 
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: _selectedIndex, onItemTapped: onItemTapped),
      );
  }
}
