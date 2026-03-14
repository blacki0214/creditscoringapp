import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyPersonalInfo = 'personal_info_draft';
  static const String _keyApplicationHistory = 'application_history';
  static const String _keyLastSaved = 'last_saved_timestamp';
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyHasAcceptedTos = 'has_accepted_tos';
  static const String _keyOtpThrottle = 'otp_throttle_map';
  static const String _keyHasCompletedEkyc = 'has_completed_ekyc';
  static const String _keyEkycPrefill = 'ekyc_prefill_data';
  static const String _keyIsTestAccountMode = 'is_test_account_mode';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'LocalStorageService not initialized. Call init() first.',
      );
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
  static Future<bool> saveApplicationHistory(
    Map<String, dynamic> application,
  ) async {
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

  /// Check if user has accepted the Terms of Service
  /// Returns true if accepted, false otherwise
  static bool hasAcceptedTos() {
    return prefs.getBool(_keyHasAcceptedTos) ?? false;
  }

  /// Persist Terms of Service acceptance
  static Future<bool> markTosAccepted() async {
    try {
      await prefs.setBool(_keyHasAcceptedTos, true);
      return true;
    } catch (e) {
      print('Error marking TOS as accepted: $e');
      return false;
    }
  }

  static Future<void> clearTosAccepted() async {
    await prefs.remove(_keyHasAcceptedTos);
  }

  static Map<String, dynamic> getOtpThrottle(String phoneNumber) {
    final raw = prefs.getString(_keyOtpThrottle);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final entry = decoded[phoneNumber];
        if (entry is Map<String, dynamic>) return entry;
      }
      return {};
    } catch (e) {
      print('Error reading OTP throttle: $e');
      return {};
    }
  }

  static Future<void> setOtpThrottle(
    String phoneNumber, {
    required int count,
    int? blockedUntilMs,
  }) async {
    try {
      final raw = prefs.getString(_keyOtpThrottle);
      final map = raw == null || raw.isEmpty
          ? <String, dynamic>{}
          : (jsonDecode(raw) as Map<String, dynamic>);
      map[phoneNumber] = {'count': count, 'blocked_until': blockedUntilMs};
      await prefs.setString(_keyOtpThrottle, jsonEncode(map));
    } catch (e) {
      print('Error writing OTP throttle: $e');
    }
  }

  static Future<void> clearOtpThrottle(String phoneNumber) async {
    try {
      final raw = prefs.getString(_keyOtpThrottle);
      if (raw == null || raw.isEmpty) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      map.remove(phoneNumber);
      await prefs.setString(_keyOtpThrottle, jsonEncode(map));
    } catch (e) {
      print('Error clearing OTP throttle: $e');
    }
  }

  // Add password prompt tracking
  static const String _addPasswordPromptKey = 'add_password_prompt_seen';

  static Future<void> setAddPasswordPromptSeen() async {
    await prefs.setBool(_addPasswordPromptKey, true);
  }

  static Future<bool> hasSeenAddPasswordPrompt() async {
    return prefs.getBool(_addPasswordPromptKey) ?? false;
  }

  static Future<void> clearAddPasswordPromptFlag() async {
    await prefs.remove(_addPasswordPromptKey);
  }

  // eKYC completion tracking for skipping Step 2 on future applications
  static Future<bool> markEkycCompleted() async {
    return await prefs.setBool(_keyHasCompletedEkyc, true);
  }

  static bool hasCompletedEkyc() {
    return prefs.getBool(_keyHasCompletedEkyc) ?? false;
  }

  static Future<bool> clearEkycCompletion() async {
    return await prefs.remove(_keyHasCompletedEkyc);
  }

  // Persist minimal eKYC profile data for Step 2 prefill when Step 1 is skipped.
  static Future<bool> saveEkycPrefill(Map<String, dynamic> data) async {
    try {
      await prefs.setString(_keyEkycPrefill, jsonEncode(data));
      return true;
    } catch (e) {
      print('Error saving eKYC prefill: $e');
      return false;
    }
  }

  static Map<String, dynamic>? loadEkycPrefill() {
    try {
      final raw = prefs.getString(_keyEkycPrefill);
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      print('Error loading eKYC prefill: $e');
      return null;
    }
  }

  static Future<bool> clearEkycPrefill() async {
    try {
      return await prefs.remove(_keyEkycPrefill);
    } catch (e) {
      print('Error clearing eKYC prefill: $e');
      return false;
    }
  }

  // Test account mode tracking to safely isolate test-only bypasses.
  static Future<bool> setTestAccountMode(bool enabled) async {
    try {
      return await prefs.setBool(_keyIsTestAccountMode, enabled);
    } catch (e) {
      print('Error setting test account mode: $e');
      return false;
    }
  }

  static bool isTestAccountMode() {
    return prefs.getBool(_keyIsTestAccountMode) ?? false;
  }

  static Future<bool> clearTestAccountMode() async {
    try {
      return await prefs.remove(_keyIsTestAccountMode);
    } catch (e) {
      print('Error clearing test account mode: $e');
      return false;
    }
  }
}
