import 'package:cloud_firestore/cloud_firestore.dart';

class RecentChatsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get recent chats for a user
  static Future<List<Map<String, dynamic>>> getRecentChats(String currentUserId) async {
    try {
      final doc = await _firestore
          .collection('recent_chats')
          .doc(currentUserId)
          .get();
      
      if (!doc.exists) return [];
      
      final data = doc.data() as Map<String, dynamic>;
      final chatPartners = data['chatPartners'] as List? ?? [];
      
      if (chatPartners.isEmpty) return [];
      
      // Get user details for all chat partners
      final userIds = chatPartners.map((c) => c['partnerId']).toList();
      
      // Split into batches of 10 (Firestore limit for 'whereIn')
      List<Map<String, dynamic>> allUsers = [];
      for (int i = 0; i < userIds.length; i += 10) {
        final batch = userIds.skip(i).take(10).toList();
        final userDocs = await _firestore
            .collection('Users')
            .where('uid', whereIn: batch)
            .get();
        
        allUsers.addAll(userDocs.docs.map((doc) => doc.data()));
      }
      
      // Combine user data with chat data
      final result = allUsers.map((userData) {
        final chatData = chatPartners.firstWhere(
          (c) => c['partnerId'] == userData['uid'],
          orElse: () => {},
        );
        
        return {
          ...userData,
          'hasHistory': true,
          'lastMessage': chatData['lastMessage'] ?? '',
          'lastMessageTime': chatData['lastMessageTime'],
          'unreadCount': chatData['unreadCount'] ?? 0,
        };
      }).toList();
      
      // Sort by last message time (most recent first)
      result.sort((a, b) {
        final timeA = a['lastMessageTime'] as Timestamp?;
        final timeB = b['lastMessageTime'] as Timestamp?;
        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1;
        if (timeB == null) return -1;
        return timeB.compareTo(timeA);
      });
      
      return result;
    } catch (e) {
      print('Error getting recent chats: $e');
      return [];
    }
  }

  // Update recent chats when a message is sent
  static Future<void> updateRecentChats({
    required String senderId,
    required String receiverId,
    required String lastMessage,
    required Timestamp timestamp,
  }) async {
    try {
      // Update for sender
      await _updateUserRecentChats(
        userId: senderId,
        partnerId: receiverId,
        lastMessage: lastMessage,
        timestamp: timestamp,
        incrementUnread: false,
      );
      
      // Update for receiver
      await _updateUserRecentChats(
        userId: receiverId,
        partnerId: senderId,
        lastMessage: lastMessage,
        timestamp: timestamp,
        incrementUnread: true,
      );
    } catch (e) {
      print('Error updating recent chats: $e');
    }
  }

  static Future<void> _updateUserRecentChats({
    required String userId,
    required String partnerId,
    required String lastMessage,
    required Timestamp timestamp,
    required bool incrementUnread,
  }) async {
    final docRef = _firestore.collection('recent_chats').doc(userId);
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      
      if (!doc.exists) {
        // Create new document
        transaction.set(docRef, {
          'chatPartners': [
            {
              'partnerId': partnerId,
              'lastMessage': lastMessage,
              'lastMessageTime': timestamp,
              'unreadCount': incrementUnread ? 1 : 0,
            }
          ],
          'lastUpdated': timestamp,
        });
      } else {
        // Update existing document
        final data = doc.data() as Map<String, dynamic>;
        final chatPartners = List<Map<String, dynamic>>.from(data['chatPartners'] ?? []);
        
        // Find existing partner
        final existingIndex = chatPartners.indexWhere((c) => c['partnerId'] == partnerId);
        
        if (existingIndex != -1) {
          // Update existing partner
          chatPartners[existingIndex] = {
            'partnerId': partnerId,
            'lastMessage': lastMessage,
            'lastMessageTime': timestamp,
            'unreadCount': incrementUnread 
                ? (chatPartners[existingIndex]['unreadCount'] ?? 0) + 1
                : 0,
          };
        } else {
          // Add new partner
          chatPartners.add({
            'partnerId': partnerId,
            'lastMessage': lastMessage,
            'lastMessageTime': timestamp,
            'unreadCount': incrementUnread ? 1 : 0,
          });
        }
        
        transaction.update(docRef, {
          'chatPartners': chatPartners,
          'lastUpdated': timestamp,
        });
      }
    });
  }
}