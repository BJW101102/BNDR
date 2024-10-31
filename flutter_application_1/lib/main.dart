import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/pages/event_setup.dart';
import 'package:flutter_application_1/pages/planner.dart';
import 'package:flutter_application_1/pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    EventPage(),
    Planner(),
    Home(),
  ];

  void on_ItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: on_ItemTapped,
      ),
    );
  }
}

// class Planner extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Planner Page'),
//     );
//   }
// }

// class Home extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Home Page'),
//     );
//   }
// }

//all of this is to show how to connect to 
//database

// void main() {
//   runApp(MaterialApp(home: MyApp(),));
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final Future<FirebaseApp> _fApp = Firebase.initializeApp();
//   String realtime = '0';
//   String onceVal = '0';
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Testing")),
//       body: FutureBuilder(
//           future: _fApp,
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Text("something is bad w firebase");
//             } else if (snapshot.hasData) {
//               return content();
//             } else {
//               return CircularProgressIndicator();
//             }
//           }),
//     );
//   }

//   Widget content() {
//     DatabaseReference _testRef = FirebaseDatabase.instance.ref().child("count");

//     _testRef.onValue.listen(
//       (event) {
//         setState(() {
//           realtime = event.snapshot.value.toString();
//         });
//       },
//     );

//     return Container(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Center(child: Text("realtime counter: $realtime")),
//           SizedBox(
//             height: 50,
//           ),
//           GestureDetector(
//             onTap: () async {
//               final snapshot = await _testRef.get();
//               if (snapshot.exists) {
//                 setState(() {
//                   onceVal = snapshot.value.toString();
//                 });
//               } else {
//                 print("No Data");
//               }
//             },
//             child: Container(
//                 height: 50,
//                 width: 150,
//                 decoration: BoxDecoration(color: Colors.blue),
//                 child: Center(
//                   child: Text("Get Once"),
//                 )),
//           ),
//           SizedBox(
//             height: 50,
//           ),
//           Center(
//             child: Text("once val: $onceVal"),
//           )
//         ],
//       ),
//     );
//   }