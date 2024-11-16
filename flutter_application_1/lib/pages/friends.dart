import 'package:flutter/material.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
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