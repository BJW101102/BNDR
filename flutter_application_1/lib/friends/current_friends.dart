import 'package:flutter/material.dart';
import '../friends/firends_service.dart';  // Assuming the service is imported

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final FriendService _friendService = FriendService();
  List<Map<String, dynamic>> _friends = [];
  List<String> _incomingRequests = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final friends = await _friendService.getFriends();
    final incomingRequests = await _friendService.getIncomingFriendRequests();

    setState(() {
      _friends = friends;
      _incomingRequests = incomingRequests;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Friends')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(hintText: 'Search friends...'),
              onChanged: (text) {
                setState(() {
                  _searchText = text;
                });
              },
            ),
          ),
          if (_incomingRequests.isNotEmpty) ...[
            Text('Incoming Friend Requests'),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _incomingRequests.length,
              itemBuilder: (context, index) {
                final requestId = _incomingRequests[index];
                return ListTile(
                  title: Text('User $requestId'), // You'd want to replace this with their actual username
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () => _friendService.acceptFriendRequest(requestId),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () => _friendService.declineFriendRequest(requestId),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          Text('Friends'),
          Expanded(
            child: ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                if (_searchText.isEmpty || friend['username'].contains(_searchText)) {
                  return ListTile(
                    title: Text(friend['username']),
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
