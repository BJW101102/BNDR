import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Fetch friends list
  Future<List<Map<String, dynamic>>> getFriends() async {
    final doc = await _firestore.collection('users').doc(currentUserId).get();
    return List<Map<String, dynamic>>.from(doc['friends'] ?? []);
  }

  // Fetch incoming friend requests
  Future<List<String>> getIncomingFriendRequests() async {
    final doc = await _firestore.collection('users').doc(currentUserId).get();
    return List<String>.from(doc['incoming friends'] ?? []);
  }

  // Send friend request
  Future<void> sendFriendRequest(String username) async {
    // Get recipient user ID by their username
    final query = await _firestore.collection('users').where('username', isEqualTo: username).get();
    if (query.docs.isNotEmpty) {
      final recipientId = query.docs.first.id;

      // Add outgoing request to current user
      await _firestore.collection('users').doc(currentUserId).update({
        'outgoing friends': FieldValue.arrayUnion([recipientId])
      });

      // Add incoming request to recipient user
      await _firestore.collection('users').doc(recipientId).update({
        'incoming friends': FieldValue.arrayUnion([currentUserId])
      });
    }
  }

  // Accept friend request
  Future<void> acceptFriendRequest(String userId) async {
    // Add friend to both users
    await _firestore.collection('users').doc(currentUserId).update({
      'friends': FieldValue.arrayUnion([userId]),
      'incoming friends': FieldValue.arrayRemove([userId])
    });

    await _firestore.collection('users').doc(userId).update({
      'friends': FieldValue.arrayUnion([currentUserId]),
      'outgoing friends': FieldValue.arrayRemove([currentUserId])
    });
  }

  // Decline friend request
  Future<void> declineFriendRequest(String userId) async {
    await _firestore.collection('users').doc(currentUserId).update({
      'incoming friends': FieldValue.arrayRemove([userId])
    });

    await _firestore.collection('users').doc(userId).update({
      'outgoing friends': FieldValue.arrayRemove([currentUserId])
    });
  }

  // Search users by username
  Future<List<Map<String, dynamic>>> searchUsers(String username) async {
    final query = await _firestore.collection('users').where('username', isGreaterThanOrEqualTo: username).get();
    return query.docs.map((doc) => doc.data()).toList();
  }
}
