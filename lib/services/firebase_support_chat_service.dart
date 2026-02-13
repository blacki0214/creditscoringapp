import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class FirebaseSupportChatService {
  final FirebaseService _firebase = FirebaseService();

  // Get or create chat for user
  Future<String> getOrCreateChat({
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    try {
      print('[SupportChatService] Getting/creating chat for user $userId');
      
      // Check if user already has an open chat
      final existingChats = await _firebase.firestore
          .collection('support_chats')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'open')
          .limit(1)
          .get();
      
      if (existingChats.docs.isNotEmpty) {
        final chatId = existingChats.docs.first.id;
        print('[SupportChatService] Found existing chat: $chatId');
        return chatId;
      }
      
      // Create new chat
      final chatData = {
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
      };
      
      final chatRef = await _firebase.firestore
          .collection('support_chats')
          .add(chatData);
      
      print('[SupportChatService] Created new chat: ${chatRef.id}');
      
      // Send welcome message
      await sendMessage(
        chatId: chatRef.id,
        message: 'Hello! How can we help you today?',
        senderId: 'system',
        senderType: 'agent',
        senderName: 'Support Team',
      );
      
      return chatRef.id;
    } catch (e) {
      print('[SupportChatService] Error getting/creating chat: $e');
      throw Exception('Failed to create chat: $e');
    }
  }

  // Send message
  Future<void> sendMessage({
    required String chatId,
    required String message,
    required String senderId,
    required String senderType,
    required String senderName,
  }) async {
    try {
      print('[SupportChatService] Sending message to chat $chatId');
      
      final messageData = {
        'senderId': senderId,
        'senderType': senderType, // 'user' or 'agent'
        'senderName': senderName,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': senderType == 'user', // User messages are auto-marked as read
      };
      
      await _firebase.firestore
          .collection('support_chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData);
      
      // Update chat's lastMessageAt
      await _firebase.firestore
          .collection('support_chats')
          .doc(chatId)
          .update({
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
      
      print('[SupportChatService] Message sent successfully');
    } catch (e) {
      print('[SupportChatService] Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages stream
  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    print('[SupportChatService] Getting messages stream for chat $chatId');
    
    return _firebase.firestore
        .collection('support_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      print('[SupportChatService] Received ${snapshot.docs.length} messages');
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Mark messages as read
  Future<void> markAsRead(String chatId, String messageId) async {
    try {
      await _firebase.firestore
          .collection('support_chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'read': true});
    } catch (e) {
      print('[SupportChatService] Error marking message as read: $e');
    }
  }

  // Close chat
  Future<void> closeChat(String chatId) async {
    try {
      print('[SupportChatService] Closing chat $chatId');
      
      await _firebase.firestore
          .collection('support_chats')
          .doc(chatId)
          .update({
        'status': 'closed',
        'closedAt': FieldValue.serverTimestamp(),
      });
      
      print('[SupportChatService] Chat closed successfully');
    } catch (e) {
      print('[SupportChatService] Error closing chat: $e');
      throw Exception('Failed to close chat: $e');
    }
  }
}
