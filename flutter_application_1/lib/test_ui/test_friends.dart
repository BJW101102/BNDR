import 'package:flutter/material.dart';
import '../services/friend_service.dart'; // Import your FriendService

class FriendsPage extends StatefulWidget {
  final String userID; // Pass the current userID to the FriendsPage

  FriendsPage({required this.userID});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController searchController = TextEditingController();
  final FriendService friendService = FriendService();

  List<Map<String, String>> outgoingFriends = [];
  List<Map<String, String>> incomingFriends = [];
  List<Map<String, String>> currentFriends = [];

  @override
  void initState() {
    super.initState();
    _loadOutgoingFriends();
    _loadIncomingFriends();
    _loadCurrentFriends();
  }

  // Load outgoing friends
  void _loadOutgoingFriends() async {
    try {
      List<Map<String, String>> friendList = await friendService.getFriendTypes(
          userID: widget.userID, friendType: 'outgoing');
      setState(() {
        outgoingFriends = friendList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading outgoing friends: $e')));
    }
  }

  // Load incoming friends
  void _loadIncomingFriends() async {
    try {
      List<Map<String, String>> friendList = await friendService.getFriendTypes(
          userID: widget.userID, friendType: 'incoming');
      setState(() {
        incomingFriends = friendList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading incoming friends: $e')));
    }
  }

  // Load current friends
  void _loadCurrentFriends() async {
    try {
      List<Map<String, String>> friendList = await friendService.getFriendTypes(
          userID: widget.userID, friendType: 'current');
      setState(() {
        currentFriends = friendList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading current friends: $e')));
    }
  }

  // Handle send friend request
  void _sendFriendRequest() async {
    if (searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a username to search')),
      );
      return;
    }

    try {
      bool success = await friendService.sendFriendRequest(
        userID: widget.userID,
        friendName: searchController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend request sent!')),
        );
        _loadOutgoingFriends(); // Reload outgoing friends list after sending request
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send friend request.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Accept friend request
  void _acceptFriendRequest(String friendID) async {
    try {
      bool success = await friendService.handleFriendRequest(
          userID: widget.userID, friendID: friendID, accept: true);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend request accepted!')),
        );
        _loadIncomingFriends(); // Reload incoming friends list
        _loadCurrentFriends(); // Reload current friends list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept friend request.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting friend request: $e')),
      );
    }
  }

  // Decline friend request
  void _declineFriendRequest(String friendID) async {
    try {
      bool success = await friendService.handleFriendRequest(
          userID: widget.userID, friendID: friendID, accept: false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend request declined.')),
        );
        _loadIncomingFriends(); // Reload incoming friends list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to decline friend request.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error declining friend request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Friends Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search for a friend',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendFriendRequest,
              child: Text('Send Friend Request'),
            ),
            SizedBox(height: 20),

            // Display Outgoing Friends
            Text('Outgoing Friend Requests:'),
            Expanded(
              child: ListView.builder(
                itemCount: outgoingFriends.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(outgoingFriends[index]['name'] ?? 'Unnamed'),
                  );
                },
              ),
            ),

            // Display Incoming Friend Requests
            Text('Incoming Friend Requests:'),
            Expanded(
              child: ListView.builder(
                itemCount: incomingFriends.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(incomingFriends[index]['name'] ?? 'Unnamed'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () => _acceptFriendRequest(
                              incomingFriends[index]['id']!),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => _declineFriendRequest(
                              incomingFriends[index]['id']!),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Display Current Friends
            Text('Current Friends:'),
            Expanded(
              child: ListView.builder(
                itemCount: currentFriends.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(currentFriends[index]['name'] ?? 'Unnamed'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
