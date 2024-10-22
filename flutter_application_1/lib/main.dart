import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/authentication/login.dart';
import 'package:flutter_application_1/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login()
    );
  }
}



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