import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ///Sends a friend request to a user and returns a boolean for the transaction.
  Future<bool> sendFriendRequest({
    required String userID,
    required String friendName,
  }) async {
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
          // Get the user document and friend document
          DocumentReference userRef = _db.collection('users').doc(userID);
          DocumentReference friendRef = _db.collection('users').doc(friendID);

          // Get current data of both users
          DocumentSnapshot userSnapshot = await transaction.get(userRef);
          DocumentSnapshot friendSnapshot = await transaction.get(friendRef);

          if (!userSnapshot.exists || !friendSnapshot.exists) {
            throw Exception('User or Friend not found');
          }

          // Update user's outgoing request
          transaction.update(userRef, {
            'friends.outgoing': FieldValue.arrayUnion([friendID]),
          });

          //Updating user's incoming request
          transaction.update(friendRef, {
            'friends.incoming': FieldValue.arrayUnion([userID]),
          });
        });
        success = true;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('Error during friend request: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return success;
  }

  ///Handles a friend request (accept or decline), returns bool for transaction.
  Future<bool> handleFriendRequest(
      {required String userID,
      required String friendID,
      required bool accept}) async {
    bool success = false;
    try {
      await _db.runTransaction((transaction) async {
        // Get the user document and friend document
        DocumentReference userRef = _db.collection('users').doc(userID);
        DocumentReference friendRef = _db.collection('users').doc(friendID);

        // Get current data of both users
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        DocumentSnapshot friendSnapshot = await transaction.get(friendRef);

        if (!userSnapshot.exists || !friendSnapshot.exists) {
          throw Exception('User or Friend not found');
        }

        // Updating both parties current friends
        if (accept) {
          transaction.update(userRef, {
            'friends.current': FieldValue.arrayUnion([friendID]),
          });

          transaction.update(friendRef, {
            'friends.current': FieldValue.arrayUnion([userID]),
          });
        }

        // Removing friend from user's incoming array
        transaction.update(userRef, {
          'friends.incoming': FieldValue.arrayRemove([friendID]),
        });

        // Removing user from friend's outgoing array
        transaction.update(friendRef, {
          'friends.outgoing': FieldValue.arrayRemove([userID]),
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

  ///Returns a Map of the desired friends, (current, incoming, outgoing)
  Future<List<Map<String, String>>> getFriendTypes(
      {required String userID, required String friendType}) async {
    try {
      if (friendType != 'current' &&
          friendType != 'incoming' &&
          friendType != 'outgoing') {
        throw Exception('Invalid friend type');
      }
      DocumentSnapshot userDoc =
          await _db.collection('users').doc(userID).get();

      if (userDoc.exists) {
        var friends = userDoc['friends'];

        List<Map<String, String>> friendInfos = [];

        // Fetching outgoing friends' usernames
        List<dynamic> friendTypes = friends[friendType] ?? [];
        for (String friendID in friendTypes) {
          DocumentSnapshot friendDoc =
              await _db.collection('users').doc(friendID).get();
          if (friendDoc.exists) {
            friendInfos.add(
                {'id': friendID, 'name': friendDoc['username'] ?? 'noName'});
          }
        }
        return friendInfos;
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Error fetching friends: $e');
    }
  }
}
