import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Creates an Event and stores within Firebase under, the 'events' collection.
  Future<bool> createEvent(
      {required String userID,
      required String eventName,
      required List<String> locationIDs,
      required String time,
      required String date}) async {
    bool success = false;

    try {
      await _db.runTransaction((transaction) async {
        Map<String, dynamic> eventData = {
          'owner': userID,
          'eventName': eventName,
          'locations': locationIDs,
          'time': time,
          'date': date,
          'participants': {
            'requested': [],
            'accepted': [],
            'declined': [],
          },
        };

        // Adding Event & Getting user information.
        DocumentReference eventRef =
            await _db.collection('events').add(eventData);
        DocumentReference userRef = _db.collection('users').doc(userID);

        // Getting current user information
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) {
          throw Exception('User not found');
        }

        success = true;

        String eventID = eventRef.id;

        // Adding event to the user
        transaction.update(userRef, {
          'events.accepted': FieldValue.arrayUnion([eventID]),
        });
      });
    } on FirebaseException catch (e) {
      throw Exception('Error during handling friend request: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return success;
  }

  /// Handles an event request for a user. The user can either accept or decline the request. If accepted, the
  /// 'eventID' is stored within the events.accepted list, otherwise, the eventID is ignored.
  Future<bool> handleEventRequest(
      {required String userID,
      required String eventID,
      required bool accept}) async {
    bool success = false;
    try {
      await _db.runTransaction((transaction) async {
        DocumentReference userRef = _db.collection('users').doc(userID);
        DocumentReference eventRef = _db.collection('events').doc(eventID);

        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        DocumentSnapshot eventSnapshot = await transaction.get(eventRef);

        if (!userSnapshot.exists || !eventSnapshot.exists) {
          throw Exception('User or Event not found');
        }

        if (accept) {
          // Updating the Event's accepted list
          transaction.update(eventRef, {
            'participants.accepted': FieldValue.arrayUnion([userID]),
          });

          // Updating the User's events.accepted list
          transaction.update(userRef, {
            'events.accepted': FieldValue.arrayUnion([eventID]),
          });
        }

        // Removing the eventID from the user's request list
        transaction.update(userRef, {
          'events.requested': FieldValue.arrayRemove([eventID]),
        });
        success = true;
      });
    } on FirebaseException catch (e) {
      throw Exception('Error during handling friend request: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return success;
  }

  /// Sends an event request to the friends events.requested list.
  Future<bool> sendEventRequest(
      {required String friendName, required String eventID}) async {
    bool success = false;
    try {
      // Fetching Friend
      QuerySnapshot friendSnapshot = await _db
          .collection('users')
          .where('username', isEqualTo: friendName)
          .get();

      if (friendSnapshot.docs.isNotEmpty) {
        DocumentSnapshot friend = friendSnapshot.docs.first;
        String friendID = friend['userID'];

        // Firestore transaction to update both users' friend lists atomically
        await _db.runTransaction((transaction) async {
          DocumentReference friendRef = _db.collection('users').doc(friendID);
          DocumentReference eventRef = _db.collection('events').doc(eventID);

          DocumentSnapshot friendSnapshot = await transaction.get(friendRef);
          DocumentSnapshot eventSnapshot = await transaction.get(eventRef);

          if (!friendSnapshot.exists || !eventSnapshot.exists) {
            throw Exception('User or Friend not found');
          }

          // Updating Event's request with friend
          transaction.update(eventRef, {
            'participants.requested': FieldValue.arrayUnion([friendID]),
          });

          //Updating Friend's incoming request
          transaction.update(friendRef, {
            'events.requested': FieldValue.arrayUnion([eventID]),
          });
        });
        success = true;
      }
    } on FirebaseException catch (e) {
      throw Exception('Error during friend request: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return success;
  }

  /// Returns all the user's events.
  Future<List<Map<String, dynamic>>> getAllUserEvents(
      {required String userID, required String eventType}) async {
    List<Map<String, dynamic>> events = [];

    if (eventType != 'accepted' && eventType != 'requested') {
      throw Exception('Invalid event type');
    }
    try {
      DocumentSnapshot userDoc =
          await _db.collection('users').doc(userID).get();

      if (userDoc.exists) {
        // Safely check if 'events' is null or doesn't contain the eventType
        var eventsData = userDoc['events'];
        if (eventsData != null && eventsData[eventType] != null) {
          List<dynamic> eventIDsDynamic = eventsData[eventType];

          List<String> eventIDs =
              eventIDsDynamic.map((e) => e.toString()).toList();

          for (String eventID in eventIDs) {
            DocumentSnapshot eventDoc =
                await _db.collection('events').doc(eventID).get();

            if (eventDoc.exists) {
              events.add({
                'id': eventDoc.id,
                'eventName': eventDoc['eventName'] ?? '',
                'locations': List<String>.from(eventDoc['locations'] ?? []),
                'participants': {
                  'accepted': List<String>.from(
                      eventDoc['participants']['accepted'] ?? []),
                  'declined': List<String>.from(
                      eventDoc['participants']['declined'] ?? []),
                  'requested': List<String>.from(
                      eventDoc['participants']['requested'] ?? []),
                },
                'time': eventDoc['time'] ?? '',
                'date': eventDoc['date'] ?? '',
              });
            }
          }
        }
      }
    } on FirebaseException catch (e) {
      throw Exception('Error during handling event data: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return events;
  }
}
