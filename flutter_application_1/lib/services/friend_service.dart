import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> sendFriendRequest({
    required String userID,
    required String friendName,
  }) async {
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

          // Update outgoing and incoming arrays
          transaction.update(userRef, {
            'friends.outgoing': FieldValue.arrayUnion([friendID]),
          });
          transaction.update(friendRef, {
            'friends.incoming': FieldValue.arrayUnion([userID]),
          });
        });
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase exceptions
      throw Exception('Error during friend request: ${e.message}');
    } catch (e) {
      // Handle any other errors
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<String>> displayOutgoingFriends({required String userID}) async {
    try {
      DocumentSnapshot userDoc =
          await _db.collection('users').doc(userID).get();

      if (userDoc.exists) {
        var friends = userDoc['friends'];

        List<String> friendUsernames = [];

        // Fetching outgoing friends' usernames
        List<dynamic> outgoingFriends = friends['outgoing'] ?? [];
        for (String friendID in outgoingFriends) {
          DocumentSnapshot friendDoc =
              await _db.collection('users').doc(friendID).get();
          if (friendDoc.exists) {
            friendUsernames.add(friendDoc['username']);
          }
        }

        return friendUsernames;
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Error fetching friends: $e');
    }
  }
}
