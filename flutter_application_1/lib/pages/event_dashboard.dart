import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/event_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/event_setup.dart';
import 'package:flutter_application_1/pages/friends.dart';
import 'package:flutter_application_1/pages/account.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EventDashboard extends StatefulWidget {
  const EventDashboard({Key? key}) : super(key: key);

  @override
  _EventDashboardState createState() => _EventDashboardState();
}

class _EventDashboardState extends State<EventDashboard> {
  final EventService _eventService = EventService();
  int _selectedIndex = 1;

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

  //function to get loction names from google maps by location ID
  Future<List<String>> getLocationNames(List<String> locationIDs) async {
  const String apiKey = "AIzaSyD_eIXoIx5zyyzehtsKDcjiaAyjaZm5A0A";
  const String baseUrl = "https://maps.googleapis.com/maps/api/place/details/json";
  List<String> locationNames = [];

  try {
    for (String locationID in locationIDs) {
      String requestUrl = '$baseUrl?place_id=$locationID&key=$apiKey';
      var response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK') {
          String name = data['result']['name'] ?? 'Unknown Location';
          locationNames.add(name);
        } else {
          locationNames.add('Unknown Location (Error: ${data['status']})');
        }
      } else {
        throw Exception("Failed to fetch location details for ID $locationID");
      }
    }
  } catch (e) {
    print("Error fetching location names: $e");
  }
  return locationNames;
}

@override
Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Event Dashboard',
          style: theme.appBarTheme.titleTextStyle,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: FutureBuilder(
        future: Future.wait([
          _eventService.getAllUserEvents(
            userID: FirebaseAuth.instance.currentUser!.uid,
            eventType: 'accepted',
          ),
          _eventService.getAllUserEvents(
            userID: FirebaseAuth.instance.currentUser!.uid,
            eventType: 'requested',
          ),
        ]),
        builder: (context,
            AsyncSnapshot<List<List<Map<String, dynamic>>>> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final acceptedEvents = snapshot.data?[0] ?? [];
          final requestedEvents = snapshot.data?[1] ?? [];

          return ListView(
            children: [
              if (acceptedEvents.isNotEmpty)
                ListTile(
                  title: Text(
                    'Accepted Events',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              if (acceptedEvents.isNotEmpty)
                ...acceptedEvents.map((event) {
                  return ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(
                      event['eventName'],
                      style: theme.textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      '${event['date']} at ${event['time']}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    onTap: () async {
                      // Fetch location names
                      List<String> locationNames =
                          await getLocationNames(event['locations']);

                      // Show the popup dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(event['eventName']),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date: ${event['date']}'),
                                  Text('Time: ${event['time']}'),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'Locations:',
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  ...locationNames.map<Widget>((name) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Text(name,
                                          style: theme.textTheme.bodyMedium),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close dialog
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }).toList(),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Event',
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}