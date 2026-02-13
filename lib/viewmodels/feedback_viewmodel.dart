import 'package:flutter/foundation.dart';
import '../services/firebase_feedback_service.dart';
import '../services/firebase_service.dart';

class FeedbackViewModel extends ChangeNotifier {
  final FirebaseFeedbackService _feedbackService = FirebaseFeedbackService();
  final FirebaseService _firebase = FirebaseService();

  bool _isSubmitting = false;
  String? _errorMessage;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  // Get user's feedback stream
  Stream<List<Map<String, dynamic>>> getUserFeedbackStream() {
    final userId = _firebase.currentUserId;
    if (userId == null) {
      print('[FeedbackViewModel] No user ID, returning empty stream');
      return Stream.value([]);
    }
    return _feedbackService.getUserFeedback(userId);
  }

  // Submit feedback
  Future<bool> submitFeedback({
    required String userName,
    required String userEmail,
    required String category,
    required String subject,
    required String message,
  }) async {
    final userId = _firebase.currentUserId;
    if (userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      print('[FeedbackViewModel] Submitting feedback...');
      _isSubmitting = true;
      _errorMessage = null;
      notifyListeners();

      await _feedbackService.submitFeedback(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        category: category,
        subject: subject,
        message: message,
      );

      print('[FeedbackViewModel] Feedback submitted successfully');
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('[FeedbackViewModel] Error submitting feedback: $e');
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
