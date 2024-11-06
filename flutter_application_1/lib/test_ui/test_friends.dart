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
  List<String> outgoingFriends = [];

  @override
  void initState() {
    super.initState();
    _loadOutgoingFriends();
  }

  void _loadOutgoingFriends() async {
    try {
      List<String> friendList =
          await friendService.displayOutgoingFriends(userID: widget.userID);
      setState(() {
        outgoingFriends = friendList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading friends: $e')));
    }
  }

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
            Text('Outgoing Friend Requests:'),
            Expanded(
              child: ListView.builder(
                itemCount: outgoingFriends.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(outgoingFriends[index]),
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
