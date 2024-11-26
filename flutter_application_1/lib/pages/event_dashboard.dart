import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/event_service.dart'; // Import the EventService
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter_application_1/pages/event_setup.dart'; // Import the EventPage
import 'package:flutter_application_1/pages/friends.dart'; // Import the FriendsPage
import 'package:flutter_application_1/pages/account.dart'; // Import the AccountPage
import 'package:flutter_application_1/pages/home.dart'; // Import the HomePage

class EventDashboard extends StatefulWidget {
  const EventDashboard({Key? key}) : super(key: key);

  @override
  _EventDashboardState createState() => _EventDashboardState();
}

class _EventDashboardState extends State<EventDashboard> {
  final EventService _eventService = EventService();
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    Home(),
    EventDashboard(),
    EventPage(),
    FriendPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = 0;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Dashboard'),
      ),
      body: StreamBuilder<List<Map<String,dynamic>>>(
        stream: Stream.fromFuture(_eventService.getAllUserEvents(userID: FirebaseAuth.instance.currentUser!.uid, eventType: 'accepted')),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data ?? [];
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                leading: Icon(Icons.event),
                title: Text(event['eventName']),
                subtitle: Text('${event['date']} at ${event['time']}'),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}