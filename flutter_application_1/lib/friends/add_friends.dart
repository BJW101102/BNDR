import 'package:flutter/material.dart';
import '../friends/firends_service.dart';  // Assuming the service is imported

class SearchFriendsPage extends StatefulWidget {
  @override
  _SearchFriendsPageState createState() => _SearchFriendsPageState();
}

class _SearchFriendsPageState extends State<SearchFriendsPage> {
  final FriendService _friendService = FriendService();
  List<Map<String, dynamic>> _searchResults = [];
  String _searchText = '';

  void _searchUsers() async {
    if (_searchText.isNotEmpty) {
      final results = await _friendService.searchUsers(_searchText);
      setState(() {
        _searchResults = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Friends')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(hintText: 'Enter username'),
              onChanged: (text) {
                setState(() {
                  _searchText = text;
                });
              },
              onSubmitted: (_) => _searchUsers(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  title: Text(user['username']),
                  trailing: IconButton(
                    icon: Icon(Icons.person_add),
                    onPressed: () => _friendService.sendFriendRequest(user['username']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
