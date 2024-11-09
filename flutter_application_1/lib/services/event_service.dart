import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
          'events': FieldValue.arrayUnion([eventID]),
        });
      });
    } on FirebaseException catch (e) {
      throw Exception('Error during handling friend request: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return success;
  }

  Future<List<Map<String, dynamic>>> getAllUserEvents(
      {required String userID}) async {
    List<Map<String, dynamic>> events = [];
    try {
      DocumentSnapshot userDoc =
          await _db.collection('users').doc(userID).get();

      if (userDoc.exists) {
        // Safely cast or convert the field to a List<String>
        List<dynamic> eventIDsDynamic = userDoc['events'];
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
    } on FirebaseException catch (e) {
      throw Exception('Error during handling event data: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return events;
  }
}
