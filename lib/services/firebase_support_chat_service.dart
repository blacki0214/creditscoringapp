import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class FirebaseSupportChatService {
  final FirebaseService _firebase = FirebaseService();

  Future<CollectionReference<Map<String, dynamic>>>
  _staffChatsCollection() async {
    final isSupport = await _firebase.isCurrentUserSupportStaff();
    if (!isSupport) {
      throw Exception('Only support accounts can access all support chats');
    }
    return _firebase.firestore.collection('support_chats');
  }

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
      await _firebase.firestore.collection('support_chats').doc(chatId).update({
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
          print(
            '[SupportChatService] Received ${snapshot.docs.length} messages',
          );

          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  Stream<List<Map<String, dynamic>>> getSupportChats({String status = 'open'}) {
    // TabBarView may rebuild/mount child trees more than once, so expose a
    // broadcast stream here to avoid single-subscription errors.
    return Stream.fromFuture(_staffChatsCollection())
        .asyncExpand((collection) {
          Query<Map<String, dynamic>> query = collection;
          if (status != 'all') {
            query = query.where('status', isEqualTo: status);
          }

          return query.snapshots().map((snapshot) {
            final docs = snapshot.docs.toList();

            // Sort in memory to avoid requiring a composite index while it is
            // still building in Firestore.
            docs.sort((a, b) {
              final aData = a.data();
              final bData = b.data();
              final aTime = aData['lastMessageAt'] as Timestamp?;
              final bTime = bData['lastMessageAt'] as Timestamp?;

              if (aTime == null && bTime == null) {
                return b.id.compareTo(a.id);
              }
              if (aTime == null) return 1;
              if (bTime == null) return -1;

              final timeCompare = bTime.compareTo(aTime);
              if (timeCompare != 0) return timeCompare;

              return b.id.compareTo(a.id);
            });

            return docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList();
          });
        })
        .asBroadcastStream();
  }

  Future<void> sendAgentReply({
    required String chatId,
    required String message,
    required String staffId,
    required String staffName,
  }) async {
    final isSupport = await _firebase.isCurrentUserSupportStaff();
    if (!isSupport) {
      throw Exception('Only support accounts can reply as agent');
    }

    await sendMessage(
      chatId: chatId,
      message: message,
      senderId: staffId,
      senderType: 'agent',
      senderName: staffName,
    );

    await _firebase.firestore.collection('support_chats').doc(chatId).set({
      'assignedSupportId': staffId,
      'assignedSupportName': staffName,
      'assignedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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

      await _firebase.firestore.collection('support_chats').doc(chatId).update({
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
