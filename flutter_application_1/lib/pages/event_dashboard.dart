import 'package:flutter/material.dart';
import 'home.dart';
import 'event_setup.dart';
import 'account.dart';
import 'friends.dart';
import 'package:flutter_application_1/services/event_service.dart';

class EventDashboard extends StatefulWidget {
  const EventDashboard({Key? key}) : super(key: key);

  @override
  _EventDashboardState createState() => _EventDashboardState();
}

class _EventDashboardState extends State<EventDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    Home(),
    EventDashboard(),
    EventPage(),
    FriendsPage(),
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
  return Scaffold(
    appBar: AppBar(
      title: Text('Event Dashboard'),
    ),
    body: ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.event),
          title: Text('Event 1'),
          subtitle: Text('Online'),
        ),
        ListTile(
          leading: Icon(Icons.event),
          title: Text('Event 2'),
          subtitle: Text('Offline'),
        ),
        ListTile(
          leading: Icon(Icons.event),
          title: Text('Event 3'),
          subtitle: Text('Online'),
        ),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Events',
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
        currentIndex: 1, // Pass the selected index
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // Pass the onItemTapped function
      ),
  );
}
}