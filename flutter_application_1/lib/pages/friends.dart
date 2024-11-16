import 'package:flutter/material.dart';
import 'event_dashboard.dart';
import 'event_setup.dart';
import 'account.dart';
import 'friends.dart';
import 'home.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
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
        title: Text('Friends'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Friend 1'),
            subtitle: Text('Online'),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Friend 2'),
            subtitle: Text('Offline'),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Friend 3'),
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
        currentIndex: 3, // Pass the selected index
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // Pass the onItemTapped function
      ),
    );
  }
}

// class FriendsPage extends StatefulWidget {
//   @override
//   _FriendsPageState createState() => _FriendsPageState();
// }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Friends'),
//       ),
//       body: ListView(
//         children: <Widget>[
//           ListTile(
//             leading: Icon(Icons.person),
//             title: Text('Friend 1'),
//             subtitle: Text('Online'),
//           ),
//           ListTile(
//             leading: Icon(Icons.person),
//             title: Text('Friend 2'),
//             subtitle: Text('Offline'),
//           ),
//           ListTile(
//             leading: Icon(Icons.person),
//             title: Text('Friend 3'),
//             subtitle: Text('Online'),
//           ),
//         ],
//       ),
//     );
//   }
// }