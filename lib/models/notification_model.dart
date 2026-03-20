import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification Model for real-time notifications
class NotificationModel {
  final String id;
  final String userId;
  final String? applicationId;
  final String type; // 'loan_approved', 'loan_rejected', 'credit_score_updated', 'payment_reminder'
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    this.applicationId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  /// Create from Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] as String,
      applicationId: data['applicationId'] as String?,
      type: data['type'] as String,
      title: data['title'] as String,
      body: data['body'] as String,
      data: data['data'] as Map<String, dynamic>?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'applicationId': applicationId,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? applicationId,
    String? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      applicationId: applicationId ?? this.applicationId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get icon based on notification type (for reference, not used in UI)
  String get iconType {
    switch (type) {
      case 'ekyc_completed':
        return 'verified_user';
      case 'step3_completed':
        return 'assignment_turned_in';
      case 'step4_completed':
        return 'calculate';
      case 'step5_completed':
        return 'description';
      case 'loan_approved':
        return 'check_circle';
      case 'loan_rejected':
        return 'cancel';
      case 'credit_score_updated':
        return 'trending_up';
      case 'payment_reminder':
        return 'payment';
      default:
        return 'notifications';
    }
  }

  /// Get color based on notification type
  int get colorValue {
    switch (type) {
      case 'ekyc_completed':
        return 0xFF26A69A; // Teal
      case 'step3_completed':
        return 0xFF42A5F5; // Blue
      case 'step4_completed':
        return 0xFF5C6BC0; // Indigo
      case 'step5_completed':
        return 0xFF8D6E63; // Brown
      case 'loan_approved':
        return 0xFF4CAF50; // Green
      case 'loan_rejected':
        return 0xFFEF5350; // Red
      case 'credit_score_updated':
        return 0xFF4C40F7; // Purple
      case 'payment_reminder':
        return 0xFFFFA726; // Orange
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7} week${difference.inDays ~/ 7 > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
