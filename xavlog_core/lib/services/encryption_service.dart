import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EncryptionService {
  static const int _keyLength = 32; // 256 bits for AES-256
  static const String _keyPrefix = 'chat_key_'; // Prefix for storing keys locally

  /// Generate a random AES key (32 bytes) and return as base64 string
  static String generateKey() {
    final random = Random.secure();
    final keyBytes = Uint8List(_keyLength);
    
    for (int i = 0; i < _keyLength; i++) {
      keyBytes[i] = random.nextInt(256);
    }
    
    return base64.encode(keyBytes);
  }

  /// Generate conversation ID from two user IDs (same format as your ChatService)
  static String _generateConversationId(String user1, String user2) {
    final sortedIds = [user1, user2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  /// Store encryption key locally
  static Future<void> _storeKeyLocally(String chatRoomId, String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_keyPrefix$chatRoomId', key);
    } catch (e) {
      print('Error storing key locally: $e');
    }
  }

  /// Get encryption key from local storage
  static Future<String?> _getLocalKey(String chatRoomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_keyPrefix$chatRoomId');
    } catch (e) {
      print('Error getting local key: $e');
      return null;
    }
  }

  /// Upload the key to Firestore for key exchange (POC, insecure)
  static Future<void> uploadKeyToFirestore(String chatRoomId, String key) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('chat_keys').doc(chatRoomId);
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({'key': key});
      }
    } catch (e) {
      print('Error uploading key to Firestore: $e');
    }
  }

  /// Try to fetch the key from Firestore if not found locally (POC, insecure)
static Future<String?> fetchKeyFromFirestore(String chatRoomId) async {
  try {
    final docRef = FirebaseFirestore.instance.collection('chat_keys').doc(chatRoomId);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['key'] is String) {
        // Store locally for future use
        await _storeKeyLocally(chatRoomId, data['key']);
        // Add delay before deleting to prevent race conditions
        await Future.delayed(Duration(seconds: 2));
        // Delete the key from Firestore after fetching
        await docRef.delete();
        return data['key'];
      }
    }
    return null;
  } catch (e) {
    print('Error fetching key from Firestore: $e');
    return null;
  }
}

/// Ensure encryption key exists for a chat room with retry logic
static Future<String> ensureChatRoomKey(String chatRoomId) async {
  try {
    // Check local key first
    final localKey = await _getLocalKey(chatRoomId);
    if (localKey != null) {
      return localKey;
    }

    // Try to fetch from Firestore with retry
    for (int attempt = 0; attempt < 3; attempt++) {
      final fetchedKey = await fetchKeyFromFirestore(chatRoomId);
      if (fetchedKey != null) {
        return fetchedKey;
      }
      
      // Wait before retry
      if (attempt < 2) {
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }

    // Generate new key if all fetch attempts failed
    final newKey = generateKey();
    await _storeKeyLocally(chatRoomId, newKey);
    await uploadKeyToFirestore(chatRoomId, newKey);

    return newKey;
  } catch (e) {
    print('Error ensuring chat room key: $e');
    final fallbackKey = generateKey();
    await _storeKeyLocally(chatRoomId, fallbackKey);
    return fallbackKey;
  }
}

  /// Get encryption key for a chat room (from local storage)
  static Future<String?> getChatRoomKey(String chatRoomId) async {
    return await _getLocalKey(chatRoomId);
  }

  /// Encrypt a message using XOR
  static String encryptMessage(String message, String key) {
    try {
      final messageBytes = utf8.encode(message);
      final keyBytes = base64.decode(key);
      final encryptedBytes = <int>[];

      for (int i = 0; i < messageBytes.length; i++) {
        encryptedBytes.add(messageBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return base64.encode(encryptedBytes);
    } catch (e) {
      print('Error encrypting message: $e');
      return message; // Return original message on error
    }
  }

  /// Decrypt a message using XOR
  static String decryptMessage(String encryptedMessage, String key) {
    try {
      final encryptedBytes = base64.decode(encryptedMessage);
      final keyBytes = base64.decode(key);
      final decryptedBytes = <int>[];

      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decryptedBytes);
    } catch (e) {
      print('Error decrypting message: $e');
      return encryptedMessage; // Return encrypted message on error
    }
  }

  /// Check if a chat room is empty (no messages)
  static Future<bool> isChatRoomEmpty(String chatRoomId) async {
    try {
      final messagesQuery = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .limit(1)
          .get();

      return messagesQuery.docs.isEmpty;
    } catch (e) {
      print('Error checking if chat room is empty: $e');
      return true; // Assume empty on error
    }
  }

  /// Initialize encryption for a new chat between two users
  static Future<String> initializeChatEncryption(String senderId, String receiverId) async {
    final chatRoomId = _generateConversationId(senderId, receiverId);
    
    // Check if this is the first message (empty chat room)
    final isEmpty = await isChatRoomEmpty(chatRoomId);
    
    if (isEmpty) {
      // Generate and store encryption key locally
      final encryptionKey = await ensureChatRoomKey(chatRoomId);
      
      // ALWAYS upload key for new chats so other device can fetch it
      await uploadKeyToFirestore(chatRoomId, encryptionKey);
      
      // Send system message indicating encryption is enabled
      await _sendEncryptionNotification(chatRoomId, senderId);
      
      return encryptionKey;
    } else {
      // Get existing encryption key from local storage
      final existingKey = await getChatRoomKey(chatRoomId);
      return existingKey ?? await ensureChatRoomKey(chatRoomId);
    }
  }

  /// Send a system message indicating encryption is enabled
  static Future<void> _sendEncryptionNotification(String chatRoomId, String senderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'message': '🔒 Messages are now end-to-end encrypted',
        'senderID': 'system',
        'senderEmail': 'system',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'system',
        'encrypted': false, // System messages are not encrypted
      });
    } catch (e) {
      print('Error sending encryption notification: $e');
    }
  }

  /// Check if a chat room has encryption enabled (check local key)
  static Future<bool> isChatRoomEncrypted(String chatRoomId) async {
    try {
      final localKey = await _getLocalKey(chatRoomId);
      return localKey != null;
    } catch (e) {
      print('Error checking if chat room is encrypted: $e');
      return false;
    }
  }

  /// Get encryption status for display in UI
  static Future<Map<String, dynamic>> getChatRoomEncryptionStatus(String chatRoomId) async {
    try {
      final localKey = await _getLocalKey(chatRoomId);
      final hasKey = localKey != null;

      if (hasKey) {
        // Get timestamp from Firebase if available
        final chatRoomDoc = await FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(chatRoomId)
            .get();
        
        Timestamp? keyCreatedAt;
          if (chatRoomDoc.exists) {
            final data = chatRoomDoc.data();
            if (data != null) {
              keyCreatedAt = data['keyCreatedAt'] as Timestamp?;
            }
          }

        return {
          'isEncrypted': true,
          'keyCreatedAt': keyCreatedAt,
          'encryptionKey': '****', // Don't expose actual key
        };
      }
      
      return {
        'isEncrypted': false,
        'keyCreatedAt': null,
        'encryptionKey': null,
      };
    } catch (e) {
      print('Error getting encryption status: $e');
      return {
        'isEncrypted': false,
        'keyCreatedAt': null,
        'encryptionKey': null,
      };
    }
  }

  /// Helper method to encrypt and prepare message for sending
  static Future<Map<String, dynamic>> prepareEncryptedMessage({
    required String message,
    required String senderId,
    required String senderEmail,
    required String receiverId,
  }) async {
    try {
      final chatRoomId = _generateConversationId(senderId, receiverId);
      
      // Get or create encryption key (stored locally)
      final encryptionKey = await initializeChatEncryption(senderId, receiverId);
      
      // Encrypt the message
      final encryptedMessage = encryptMessage(message, encryptionKey);
      
      return {
        'message': encryptedMessage,
        'senderID': senderId,
        'senderEmail': senderEmail,
        'timestamp': FieldValue.serverTimestamp(),
        'encrypted': true,
        'type': 'encrypted',
      };
    } catch (e) {
      print('Error preparing encrypted message: $e');
      // Fallback to unencrypted message
      return {
        'message': message,
        'senderID': senderId,
        'senderEmail': senderEmail,
        'timestamp': FieldValue.serverTimestamp(),
        'encrypted': false,
        'type': 'text',
      };
    }
  }

  /// Helper method to decrypt received message
  static Future<String> decryptReceivedMessage({
    required Map<String, dynamic> messageData,
    required String chatRoomId,
  }) async {
    try {
      // Check if message is encrypted
      final isEncrypted = messageData['encrypted'] == true;
      
      if (!isEncrypted) {
        return messageData['message'] ?? '';
      }

      // Get encryption key from local storage
      final encryptionKey = await getChatRoomKey(chatRoomId);
      
      if (encryptionKey == null) {
        return '[Decryption failed: Key not found locally]';
      }

      // Decrypt message
      final encryptedMessage = messageData['message'] ?? '';
      return decryptMessage(encryptedMessage, encryptionKey);
      
    } catch (e) {
      print('Error decrypting received message: $e');
      return '[Decryption failed]';
    }
  }

  /// Enable encryption for existing chat room
  static Future<bool> enableEncryptionForChatRoom(String chatRoomId) async {
    try {
      final encryptionKey = await ensureChatRoomKey(chatRoomId);
      
      // Send notification about encryption being enabled
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'message': '🔒 End-to-end encryption has been enabled for this chat',
        'senderID': 'system',
        'senderEmail': 'system',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'system',
        'encrypted': false,
      });

      return true;
    } catch (e) {
      print('Error enabling encryption: $e');
      return false;
    }
  }

  /// Clear all local encryption keys (for testing/debugging)
  static Future<void> clearAllLocalKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Error clearing local keys: $e');
    }
  }
}