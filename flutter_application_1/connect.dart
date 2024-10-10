import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  FirebaseDatabase database = FirebaseDatabase.instance;
  final firebaseApp = Firebase.app();
  final rtdb = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://bndr-45287-default-rtdb.firebaseio.com/');
  
}