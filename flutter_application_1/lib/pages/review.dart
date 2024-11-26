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
  //all the data we need from previous planner pages
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
    List<String?> inviteList = [];
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
                friendType:
                    'current',
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
                      return ListTile(
                        title: Text(friend['name'] ?? 'No Name'),
                        subtitle: Text(friend['id'] ?? ''),
                        trailing: ElevatedButton(
                          onPressed: () {
                            inviteList.add(friend['name']);//TODO change to ID later
                            print("List: $inviteList");
                          },
                          child: Text(
                            inviteList.contains(friend['id'])
                                ? 'Invited'
                                : 'Invite',
                          ),
                        ),
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
                //create the event in the database
                eventID = await eventService.createEvent(
                  userID: userID,
                  eventName: eventName,
                  locationIDs: locationIDs,
                  date: formattedDate,
                  time: formattedTime,
                );
                inviteList.forEach((name){
                  eventService.sendEventRequest(friendName: name as String, eventID: eventID.values.first);
                });
                
              },
              style: ElevatedButton.styleFrom(
                minimumSize:
                    Size(double.infinity, 60),
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
