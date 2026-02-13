import 'package:flutter/foundation.dart';
import '../services/firebase_support_chat_service.dart';
import '../services/firebase_service.dart';

class SupportViewModel extends ChangeNotifier {
  final FirebaseSupportChatService _chatService = FirebaseSupportChatService();
  final FirebaseService _firebase = FirebaseService();

  String? _chatId;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String? get chatId => _chatId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize chat for current user
  Future<void> initializeChat() async {
    final userId = _firebase.currentUserId;
    if (userId == null) {
      _setError('User not authenticated');
      return;
    }

    try {
      _setLoading(true);
      
      // Get user info
      final userDoc = await _firebase.usersCollection.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      
      final userName = userData?['fullName'] ?? 'User';
      final userEmail = userData?['email'] ?? '';
      
      // Get or create chat
      _chatId = await _chatService.getOrCreateChat(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
      );
      
      print('SupportViewModel: Chat initialized: $_chatId');
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      print('SupportViewModel: Error initializing chat: $e');
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Get messages stream
  Stream<List<Map<String, dynamic>>> getMessagesStream() {
    if (_chatId == null) {
      return Stream.value([]);
    }
    return _chatService.getMessages(_chatId!);
  }

  // Send message
  Future<void> sendMessage(String message) async {
    if (_chatId == null) {
      _setError('Chat not initialized');
      return;
    }

    final userId = _firebase.currentUserId;
    if (userId == null) {
      _setError('User not authenticated');
      return;
    }

    try {
      // Get user info
      final userDoc = await _firebase.usersCollection.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final userName = userData?['fullName'] ?? 'User';
      
      await _chatService.sendMessage(
        chatId: _chatId!,
        message: message,
        senderId: userId,
        senderType: 'user',
        senderName: userName,
      );
      
      print('SupportViewModel: Message sent');
    } catch (e) {
      print('SupportViewModel: Error sending message: $e');
      _setError(e.toString());
    }
  }

  // Close chat
  Future<void> closeChat() async {
    if (_chatId == null) return;

    try {
      await _chatService.closeChat(_chatId!);
      _chatId = null;
      notifyListeners();
    } catch (e) {
      print('SupportViewModel: Error closing chat: $e');
      _setError(e.toString());
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
