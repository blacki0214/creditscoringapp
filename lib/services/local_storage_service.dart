import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyPersonalInfo = 'personal_info_draft';
  static const String _keyApplicationHistory = 'application_history';
  static const String _keyLastSaved = 'last_saved_timestamp';
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Save personal info draft
  static Future<bool> saveDraft(Map<String, dynamic> data) async {
    try {
      final json = jsonEncode(data);
      await prefs.setString(_keyPersonalInfo, json);
      await prefs.setString(_keyLastSaved, DateTime.now().toIso8601String());
      return true;
    } catch (e) {
      print('Error saving draft: $e');
      return false;
    }
  }

  // Load personal info draft
  static Map<String, dynamic>? loadDraft() {
    try {
      final json = prefs.getString(_keyPersonalInfo);
      if (json == null) return null;
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      print('Error loading draft: $e');
      return null;
    }
  }

  // Clear draft
  static Future<bool> clearDraft() async {
    try {
      await prefs.remove(_keyPersonalInfo);
      await prefs.remove(_keyLastSaved);
      return true;
    } catch (e) {
      print('Error clearing draft: $e');
      return false;
    }
  }

  // Get last saved timestamp
  static DateTime? getLastSavedTime() {
    final timestamp = prefs.getString(_keyLastSaved);
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  // Save application to history
  static Future<bool> saveApplicationHistory(Map<String, dynamic> application) async {
    try {
      final history = getApplicationHistory();
      history.insert(0, {
        ...application,
        'submitted_at': DateTime.now().toIso8601String(),
      });
      
      // Keep only last 20 applications
      if (history.length > 20) {
        history.removeRange(20, history.length);
      }
      
      final json = jsonEncode(history);
      await prefs.setString(_keyApplicationHistory, json);
      return true;
    } catch (e) {
      print('Error saving application history: $e');
      return false;
    }
  }

  // Get application history
  static List<Map<String, dynamic>> getApplicationHistory() {
    try {
      final json = prefs.getString(_keyApplicationHistory);
      if (json == null) return [];
      final list = jsonDecode(json) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading application history: $e');
      return [];
    }
  }

  // Clear all data
  static Future<bool> clearAll() async {
    try {
      await prefs.clear();
      return true;
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }

  /// Check if user has already completed onboarding on first app launch
  /// Returns true if onboarding was seen, false for first-time users
  static bool hasSeenOnboarding() {
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  /// Mark onboarding as completed when user finishes the splash screens
  /// This flag prevents showing onboarding again after logout
  static Future<bool> markOnboardingAsSeen() async {
    try {
      await prefs.setBool(_keyHasSeenOnboarding, true);
      return true;
    } catch (e) {
      print('Error marking onboarding as seen: $e');
      return false;
    }
  }
}
