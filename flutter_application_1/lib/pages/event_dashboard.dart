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
  int _selectedIndex = 1;

  final List<Widget> _pages = <Widget>[
    Home(),
    EventDashboard(),
    EventPage(),
    FriendPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Event Dashboard',
          style: theme.appBarTheme.titleTextStyle,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Stream.fromFuture(
          _eventService.getAllUserEvents(
            userID: FirebaseAuth.instance.currentUser!.uid,
            eventType: 'accepted',
          ),
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final events = snapshot.data ?? [];
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                leading: const Icon(Icons.event),
                title: Text(
                  event['eventName'],
                  style: theme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  '${event['date']} at ${event['time']}',
                  style: theme.textTheme.bodyMedium,
                ),
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
