import 'package:flutter/material.dart';
import '../services/friend_service.dart';

class FriendScreen extends StatefulWidget {
  final String userID;

  FriendScreen({required this.userID});

  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  final FriendService _friendService = FriendService();
  late Future<List<Map<String, String>>> _currentFriends;
  late Future<List<Map<String, String>>> _incomingFriends;
  late Future<List<Map<String, String>>> _outgoingFriends;
  final TextEditingController _friendUsernameController =
      TextEditingController();
  String _friendRequestStatus = '';

  @override
  void initState() {
    super.initState();
    _loadFriendData();
  }

  void _loadFriendData() {
    _currentFriends = _friendService.getFriendTypes(
        userID: widget.userID, friendType: 'current');
    _incomingFriends = _friendService.getFriendTypes(
        userID: widget.userID, friendType: 'incoming');
    _outgoingFriends = _friendService.getFriendTypes(
        userID: widget.userID, friendType: 'outgoing');
  }

  Future<void> _sendFriendRequest() async {
    String friendUsername = _friendUsernameController.text.trim();
    if (friendUsername.isEmpty) {
      setState(() {
        _friendRequestStatus = 'Please enter a valid username.';
      });
      return;
    }

    try {
      bool success = await _friendService.sendFriendRequest(
        userID: widget.userID,
        friendName: friendUsername,
      );
      setState(() {
        _friendRequestStatus = success
            ? 'Friend request sent successfully!'
            : 'Failed to send friend request.';
        _outgoingFriends = _friendService.getFriendTypes(
            userID: widget.userID, friendType: 'outgoing');
      });
    } catch (e) {
      setState(() {
        _friendRequestStatus = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Friends')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _friendUsernameController,
                    decoration: InputDecoration(
                      labelText: 'Enter friend\'s username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _sendFriendRequest,
                    child: Text('Send Friend Request'),
                  ),
                  if (_friendRequestStatus.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _friendRequestStatus,
                        style: TextStyle(
                          color: _friendRequestStatus.contains('successfully')
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Divider(),
            // Incoming Friends
            FutureBuilder<List<Map<String, String>>>(
              future: _incomingFriends,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.data!.isEmpty) {
                  return Text('No incoming friend requests.');
                } else {
                  return ExpansionTile(
                    title: Text('Incoming Friends'),
                    children: snapshot.data!.map((friend) {
                      return ListTile(
                        title: Text(friend['name']!),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () async {
                                bool success =
                                    await _friendService.handleFriendRequest(
                                  userID: widget.userID,
                                  friendID: friend['id']!,
                                  accept: true,
                                );
                                if (success) {
                                  setState(() {
                                    _loadFriendData();
                                  });
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () async {
                                bool success =
                                    await _friendService.handleFriendRequest(
                                  userID: widget.userID,
                                  friendID: friend['id']!,
                                  accept: false,
                                );
                                if (success) {
                                  setState(() {
                                    _loadFriendData();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            // Outgoing Friends
            FutureBuilder<List<Map<String, String>>>(
              future: _outgoingFriends,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.data!.isEmpty) {
                  return Text('No outgoing friend requests.');
                } else {
                  return ExpansionTile(
                    title: Text('Outgoing Friends'),
                    children: snapshot.data!.map((friend) {
                      return ListTile(
                        title: Text(friend['name']!),
                        trailing: IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () async {
                            // Optional: Add logic to cancel outgoing friend requests
                          },
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            // Current Friends
            FutureBuilder<List<Map<String, String>>>(
              future: _currentFriends,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.data!.isEmpty) {
                  return Text('No current friends.');
                } else {
                  return ExpansionTile(
                    title: Text('Current Friends'),
                    children: snapshot.data!.map((friend) {
                      return ListTile(
                        title: Text(friend['name']!),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
