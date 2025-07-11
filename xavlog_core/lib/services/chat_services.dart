import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xavlog_core/features/market_place/models/message.dart';
import 'package:xavlog_core/services/encryption_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get users as a stream of List<Map<String, dynamic>>
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // 🔒 Updated sendMessage with encryption
  Future<void> sendMessage(String receiverID, String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;

    try {
      // 🎯 Prepare encrypted message
      final messageData = await EncryptionService.prepareEncryptedMessage(
        message: message,
        senderId: currentUserID,
        senderEmail: currentUserEmail,
        receiverId: receiverID,
      );

      // Generate chat room ID (same as before)
      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      String chatRoomID = ids.join('_');

      // 🔒 Send encrypted message
      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .add(messageData);

    } catch (e) {
      print('Error sending encrypted message: $e');
      
      // 🛡️ Fallback: Send unencrypted message
      Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        timestamp: Timestamp.now(),
      );

      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      String chatRoomID = ids.join('_');

      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .add(newMessage.toMap());
    }
  }

  // 🔒 Updated getMessages with decryption
  Stream<List<Map<String, dynamic>>> getMessages(String userID, String otherUserId) {
    List<String> ids = [userID, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
      
      // 🔓 Decrypt messages
      List<Map<String, dynamic>> decryptedMessages = [];
      
      for (var doc in snapshot.docs) {
        final messageData = doc.data() as Map<String, dynamic>;
        
        // Add document ID for reference
        messageData['id'] = doc.id;
        
        // Check if message is encrypted
        if (messageData['encrypted'] == true) {
          try {
            // 🔓 Decrypt the message
            final decryptedText = await EncryptionService.decryptReceivedMessage(
              messageData: messageData,
              chatRoomId: chatRoomID,
            );
            
            // Replace encrypted message with decrypted text
            messageData['message'] = decryptedText;
            messageData['decrypted'] = true;
          } catch (e) {
            print('Error decrypting message: $e');
            messageData['message'] = '[Decryption failed]';
            messageData['decrypted'] = false;
          }
        } else {
          // Mark as unencrypted for UI indication
          messageData['decrypted'] = false;
        }
        
        decryptedMessages.add(messageData);
      }
      
      return decryptedMessages;
    });
  }

  // 🔒 Get encryption status for a chat
  Future<Map<String, dynamic>> getChatEncryptionStatus(String otherUserId) async {
    final String currentUserID = _auth.currentUser!.uid;
    
    List<String> ids = [currentUserID, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');
    
    return await EncryptionService.getChatRoomEncryptionStatus(chatRoomID);
  }

  // 🔒 Enable encryption for existing chat
  Future<bool> enableEncryption(String otherUserId) async {
    final String currentUserID = _auth.currentUser!.uid;
    
    List<String> ids = [currentUserID, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');
    
    return await EncryptionService.enableEncryptionForChatRoom(chatRoomID);
  }

  // 🔒 Check if chat is encrypted
  Future<bool> isChatEncrypted(String otherUserId) async {
    final String currentUserID = _auth.currentUser!.uid;
    
    List<String> ids = [currentUserID, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');
    
    return await EncryptionService.isChatRoomEncrypted(chatRoomID);
  }

  // 🔒 Get chat room ID (helper method)
  String getChatRoomId(String otherUserId) {
    final String currentUserID = _auth.currentUser!.uid;
    
    List<String> ids = [currentUserID, otherUserId];
    ids.sort();
    return ids.join('_');
  }

  getUserTypingStatus(String receiverID) {}
}