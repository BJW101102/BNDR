import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/friend_service.dart';
import 'event_dashboard.dart';
import 'event_setup.dart';
import 'account.dart';
import 'home.dart';
import 'friends.dart';
import '../services/event_service.dart';
import 'package:intl/intl.dart';

class ReviewPage extends StatelessWidget {
  final List<dynamic> selectedLocations;
  final List<String> locationIDs;
  final String eventName;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;

  const ReviewPage({
    Key? key,
    required this.selectedLocations,
    required this.eventName,
    required this.selectedDate,
    required this.selectedTime,
    required this.locationIDs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    final FriendService friendService = FriendService();
    final EventService eventService = EventService();
    Set<String> inviteList = {}; // Use a set to track invited friends
    final formattedDate = DateFormat.yMMMd().format(selectedDate);
    final formattedTime = selectedTime.format(context);
    Map<bool, String> eventID = {false: ''};

    return Scaffold(
      appBar: AppBar(
        title: Text('Invite Friends'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
              future: friendService.getFriendTypes(
                userID: userID,
                friendType: 'current',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final friends = snapshot.data!;
                  return ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      final friendId = friend['id'] ?? '';
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return ListTile(
                            title: Text(friend['name'] ?? 'No Name'),
                            subtitle: Text(friendId),
                            trailing: inviteList.contains(friendId)
                                ? Icon(Icons.check, color: Colors.green)
                                : ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        inviteList.add(friendId);
                                      });
                                      print("Invited: $inviteList");
                                    },
                                    child: Text('Invite'),
                                  ),
                          );
                        },
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No friends found'));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                // Create the event in the database
                eventID = await eventService.createEvent(
                  userID: userID,
                  eventName: eventName,
                  locationIDs: locationIDs,
                  date: formattedDate,
                  time: formattedTime,
                );

                // Send event requests to invited friends
                inviteList.forEach((friendId) {
                  eventService.sendEventRequest(
                    friendName:
                        friendId, // Change to the appropriate friend identifier
                    eventID: eventID.values.first,
                  );
                });

                // Navigate back to the home page
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Home()), // Replace `Home()` with your home page widget
                  (route) => false, // Remove all previous routes
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
              ),
              child: Text(
                'Start Your BNDR',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
