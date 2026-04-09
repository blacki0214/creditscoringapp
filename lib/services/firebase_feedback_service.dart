import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class FirebaseFeedbackService {
  final FirebaseService _firebase = FirebaseService();

  Future<CollectionReference> _staffFeedbackCollection() async {
    final isSupport = await _firebase.isCurrentUserSupportStaff();
    if (!isSupport) {
      throw Exception('Only support accounts can access all feedback');
    }
    return _firebase.feedbackCollection;
  }

  // Submit feedback
  Future<String> submitFeedback({
    required String userId,
    required String userName,
    required String userEmail,
    required String category,
    required String subject,
    required String message,
  }) async {
    try {
      print('[FeedbackService] Submitting feedback for user $userId');

      final docRef = await _firebase.feedbackCollection.add({
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'category': category,
        'subject': subject,
        'message': message,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('[FeedbackService] Feedback submitted successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('[FeedbackService] Error submitting feedback: $e');
      throw Exception('Failed to submit feedback: $e');
    }
  }

  // Get user's feedback (real-time stream)
  Stream<List<Map<String, dynamic>>> getUserFeedback(String userId) {
    print('[FeedbackService] Getting feedback stream for user $userId');

    return _firebase.feedbackCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print(
            '[FeedbackService] Received ${snapshot.docs.length} feedback items',
          );

          // Sort in memory instead of using orderBy (to avoid index requirement)
          final docs = snapshot.docs.toList();
          docs.sort((a, b) {
            final aTime =
                (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final bTime =
                (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime); // Descending order
          });

          return docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  // Update feedback status (admin function)
  Future<void> updateFeedbackStatus(String feedbackId, String status) async {
    try {
      await _firebase.feedbackCollection.doc(feedbackId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('[FeedbackService] Updated feedback $feedbackId status to $status');
    } catch (e) {
      print('[FeedbackService] Error updating feedback status: $e');
      throw Exception('Failed to update feedback status: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getAllFeedbackForSupport() {
    // Expose broadcast stream so repeated widget subscriptions are safe.
    return Stream.fromFuture(_staffFeedbackCollection())
        .asyncExpand((collection) {
          return collection.snapshots().map((snapshot) {
            final docs = snapshot.docs.toList();
            docs.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aTime = aData['updatedAt'] as Timestamp?;
              final bTime = bData['updatedAt'] as Timestamp?;
              if (aTime == null || bTime == null) return 0;
              return bTime.compareTo(aTime);
            });

            return docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }).toList();
          });
        })
        .asBroadcastStream();
  }

  Future<void> resolveFeedbackAsCompleted({
    required String feedbackId,
    required String supportId,
    required String supportName,
    String? supportReply,
  }) async {
    await _staffFeedbackCollection();

    await _firebase.feedbackCollection.doc(feedbackId).update({
      'status': 'completed',
      'resolvedById': supportId,
      'resolvedByName': supportName,
      'supportReply': supportReply,
      'resolvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
