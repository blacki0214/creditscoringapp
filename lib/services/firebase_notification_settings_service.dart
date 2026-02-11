import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class FirebaseNotificationSettingsService {
  final FirebaseService _firebase = FirebaseService();

  // Save notification settings to Firestore
  Future<void> saveNotificationSettings({
    required String userId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      print('[NotificationSettingsService] Saving settings for user $userId');
      
      await _firebase.firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .set(settings, SetOptions(merge: true));
      
      print('[NotificationSettingsService] Settings saved successfully');
    } catch (e) {
      print('[NotificationSettingsService] Error saving settings: $e');
      throw Exception('Failed to save notification settings: $e');
    }
  }

  // Get notification settings from Firestore
  Future<Map<String, dynamic>?> getNotificationSettings(String userId) async {
    try {
      print('[NotificationSettingsService] Loading settings for user $userId');
      
      final doc = await _firebase.firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .get();
      
      if (doc.exists) {
        print('[NotificationSettingsService] Settings loaded successfully');
        return doc.data();
      } else {
        print('[NotificationSettingsService] No settings found, using defaults');
        return null;
      }
    } catch (e) {
      print('[NotificationSettingsService] Error loading settings: $e');
      throw Exception('Failed to load notification settings: $e');
    }
  }

  // Update snooze timestamp
  Future<void> updateSnooze(String userId, DateTime? snoozeUntil) async {
    try {
      print('[NotificationSettingsService] Updating snooze for user $userId');
      
      await _firebase.firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .set({
        'snoozeUntil': snoozeUntil != null ? Timestamp.fromDate(snoozeUntil) : null,
      }, SetOptions(merge: true));
      
      print('[NotificationSettingsService] Snooze updated successfully');
    } catch (e) {
      print('[NotificationSettingsService] Error updating snooze: $e');
      throw Exception('Failed to update snooze: $e');
    }
  }
}
