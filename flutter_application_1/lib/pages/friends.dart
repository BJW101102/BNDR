import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/friend_service.dart';
import 'event_dashboard.dart';
import 'event_setup.dart';
import 'account.dart';
import 'home.dart';

class FriendPage extends StatefulWidget {
  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final FriendService _friendService = FriendService();
  late Future<List<Map<String, String>>> _currentFriends;
  late Future<List<Map<String, String>>> _incomingFriends;
  late Future<List<Map<String, String>>> _outgoingFriends;
  final TextEditingController _friendUsernameController = TextEditingController();
  String _friendRequestStatus = '';

  int _selectedIndex = 3;

  final List<Widget> _pages = <Widget>[
    Home(),
    EventDashboard(),
    EventPage(),
    FriendPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _pages[index]),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadFriendData();
  }

  void loadFriendData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userID = user.uid;
      _currentFriends = _friendService.getFriendTypes(userID: userID, friendType: 'current').then((friends) {
        friends.sort((a, b) => a['name']!.compareTo(b['name']!)); // Sort alphabetically
        return friends;
      });
      _incomingFriends = _friendService.getFriendTypes(userID: userID, friendType: 'incoming');
      _outgoingFriends = _friendService.getFriendTypes(userID: userID, friendType: 'outgoing');
    }
  }

  Future<void> _sendFriendRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String friendUsername = _friendUsernameController.text.trim();
    if (friendUsername.isEmpty) {
      setState(() {
        _friendRequestStatus = 'Please enter a valid username.';
      });
      return;
    }

    try {
      bool success = await _friendService.sendFriendRequest(
        userID: user.uid,
        friendName: friendUsername,
      );
      setState(() {
        _friendRequestStatus = success
            ? 'Friend request sent successfully!'
            : 'Failed to send friend request.';
        _outgoingFriends = _friendService.getFriendTypes(userID: user.uid, friendType: 'outgoing');
      });
    } catch (e) {
      setState(() {
        _friendRequestStatus = 'Error: $e';
      });
    }
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add a Friend',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: TextField(
          controller: _friendUsernameController,
          decoration: InputDecoration(
            labelText: 'Enter friend\'s username',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: Theme.of(context).textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              _sendFriendRequest();
              Navigator.of(context).pop();
            },
            child: const Text('Add Friend'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'User not logged in. Please sign in first.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Incoming Friend Requests',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            _buildFriendCards(futureList: _incomingFriends, isIncoming: true),
            const SizedBox(height: 20),
            Text(
              'Outgoing Friend Requests',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            _buildFriendCards(futureList: _outgoingFriends, isOutgoing: true),
            const SizedBox(height: 20),
            Text(
              'Current Friends',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            _buildFriendCards(futureList: _currentFriends),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add a Friend',
      ),
      bottomNavigationBar: BottomNavigationBar(
  items: const <BottomNavigationBarItem>[
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
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
  // Use the theme colors for selected and unselected items
  selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
  unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
  backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
  type: BottomNavigationBarType.fixed, // Ensure icons and labels align
),
    );
  }

  Widget _buildFriendCards({
    required Future<List<Map<String, String>>> futureList,
    bool isIncoming = false,
    bool isOutgoing = false,
  }) {
    return FutureBuilder<List<Map<String, String>>>(
      future: futureList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium);
        } else if (snapshot.data!.isEmpty) {
          return Text(
            'No ${isIncoming ? 'incoming' : isOutgoing ? 'outgoing' : 'current'} friend requests.',
            style: Theme.of(context).textTheme.bodyMedium,
          );
        } else {
          return Column(
            children: snapshot.data!.map((friend) {
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      friend['name']![0].toUpperCase(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  title: Text(friend['name']!, style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text(
                    isIncoming
                        ? 'Incoming request'
                        : isOutgoing
                            ? 'Outgoing request'
                            : 'Friend',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: isIncoming
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _handleFriendRequest(friend['id']!, true),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _handleFriendRequest(friend['id']!, false),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Future<void> _handleFriendRequest(String friendID, bool accept) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool success = await _friendService.handleFriendRequest(
      userID: user.uid,
      friendID: friendID,
      accept: accept,
    );
    if (success) {
      setState(() {
        loadFriendData();
      });
    }
  }
}
