import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../test_views/friend_page.dart';
import '../test_views/event_page.dart'; // Import the EventScreen

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userID;

  @override
  void initState() {
    super.initState();
    _getCurrentUserID();
  }

  Future<void> _getCurrentUserID() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userID = user.uid;
      });
    } else {
      // Redirect to login page or show a warning if no user is logged in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No user is currently logged in.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: _userID == null
            ? CircularProgressIndicator() // Show a loading indicator while fetching userID
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendScreen(userID: _userID!),
                        ),
                      );
                    },
                    child: Text('Manage Friends'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventScreen(
                              userID: _userID!), // Navigate to EventScreen
                        ),
                      );
                    },
                    child: Text('Manage Events'),
                  ),
                ],
              ),
      ),
    );
  }
}
