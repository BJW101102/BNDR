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
      _selectedIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
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
        title: const Text('Add a Friend'),
        content: TextField(
          controller: _friendUsernameController,
          decoration: const InputDecoration(
            labelText: 'Enter friend\'s username',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
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
          child: Text('User not logged in. Please sign in first.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Incoming Friend Requests',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            _buildFriendCards(futureList: _incomingFriends, isIncoming: true),
            const SizedBox(height: 20),
            const Text(
              'Outgoing Friend Requests',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            _buildFriendCards(futureList: _outgoingFriends, isOutgoing: true),
            const SizedBox(height: 20),
            const Text(
              'Current Friends',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
        currentIndex: 3,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
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
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data!.isEmpty) {
          return Text('No ${isIncoming ? 'incoming' : isOutgoing ? 'outgoing' : 'current'} friend requests.');
        } else {
          return Column(
            children: snapshot.data!.map((friend) {
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(friend['name']![0].toUpperCase()),
                    backgroundColor: Colors.blueAccent,
                  ),
                  title: Text(friend['name']!),
                  subtitle: isIncoming
                      ? const Text('Incoming request')
                      : isOutgoing
                          ? const Text('Outgoing request')
                          : const Text('Friend'),
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
