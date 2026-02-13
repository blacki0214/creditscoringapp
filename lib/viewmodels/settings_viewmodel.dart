import 'package:flutter/material.dart';
import '../services/firebase_user_service.dart';
import '../services/firebase_service.dart';
import '../services/firebase_notification_settings_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final FirebaseUserService _userService = FirebaseUserService();
  final FirebaseService _firebase = FirebaseService();
  final FirebaseNotificationSettingsService _notificationService = FirebaseNotificationSettingsService();

  // User Profile Data
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Credit Score Data
  int? _latestCreditScore;
  String? _riskLevel;
  DateTime? _lastCreditCheckDate;
  int _totalApplications = 0;

  // Notification Settings
  bool _pushEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _loanUpdates = true;
  bool _creditScoreUpdates = true;
  bool _paymentReminders = true;
  bool _promotionalOffers = false;
  DateTime? _snoozeUntil;

  // Notification Getters
  bool get pushEnabled => _pushEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get emailNotifications => _emailNotifications;
  bool get smsNotifications => _smsNotifications;
  bool get loanUpdates => _loanUpdates;
  bool get creditScoreUpdates => _creditScoreUpdates;
  bool get paymentReminders => _paymentReminders;
  bool get promotionalOffers => _promotionalOffers;
  DateTime? get snoozeUntil => _snoozeUntil;

  // Security Settings
  bool biometricEnabled = false;
  bool twoFactorEnabled = false;

  // Getters
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Credit Score Getters
  int? get latestCreditScore => _latestCreditScore;
  String? get riskLevel => _riskLevel;
  DateTime? get lastCreditCheckDate => _lastCreditCheckDate;
  int get totalApplications => _totalApplications;
  DateTime? get memberSince => _userProfile?['createdAt']?.toDate();

  // Legacy getters for backward compatibility
  String get name => _userProfile?['fullName'] ?? '';
  String get email => _userProfile?['email'] ?? '';
  String get phone => _userProfile?['phoneNumber'] ?? '';
  String get address => _userProfile?['address'] ?? '';
  String get idNumber => _userProfile?['nationalId'] ?? '';
  String? get avatarUrl => _userProfile?['avatarUrl'] as String?;
  String get dob {
    if (_userProfile?['dateOfBirth'] != null) {
      final dateTime = (_userProfile!['dateOfBirth'] as dynamic).toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    return '';
  }

  // Load user profile
  Future<void> loadUserProfile() async {
    final userId = _firebase.currentUserId;
    if (userId == null) {
      print('SettingsViewModel: No userId found');
      return;
    }

    try {
      print('SettingsViewModel: Loading profile for user $userId');
      _setLoading(true);
      _userProfile = await _userService.getUserProfile(userId);
      print('SettingsViewModel: Profile loaded: name=${_userProfile?['fullName']}, email=${_userProfile?['email']}');
      
      // Also load credit score data
      await loadCreditScoreData();
      
      _setLoading(false);
    } catch (e) {
      print('SettingsViewModel: Error loading profile: $e');
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load credit score data
  Future<void> loadCreditScoreData() async {
    final userId = _firebase.currentUserId;
    if (userId == null) return;

    try {
      print('SettingsViewModel: Loading credit score data for user $userId');
      
      // Get latest credit score
      final scoreData = await _userService.getUserCreditScore(userId);
      if (scoreData != null) {
        _latestCreditScore = scoreData['creditScore'];
        _riskLevel = scoreData['riskLevel'];
        if (scoreData['createdAt'] != null) {
          _lastCreditCheckDate = (scoreData['createdAt'] as dynamic).toDate();
        }
        print('SettingsViewModel: Credit score loaded: $_latestCreditScore, risk: $_riskLevel');
      } else {
        print('SettingsViewModel: No credit score data found');
      }

      // Get total applications count
      _totalApplications = await _userService.getTotalApplicationsCount(userId);
      print('SettingsViewModel: Total applications: $_totalApplications');
      
      notifyListeners();
    } catch (e) {
      print('SettingsViewModel: Error loading credit score data: $e');
      // Don't throw - this is non-critical data
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? idNumber,
    String? dob,
  }) async {
    final userId = _firebase.currentUserId;
    if (userId == null) {
      _setError('User not authenticated');
      return false;
    }

    try {
      _setLoading(true);
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['fullName'] = name;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phoneNumber'] = phone;
      if (address != null) updateData['address'] = address;
      if (idNumber != null) updateData['nationalId'] = idNumber;
      // Note: DOB parsing would need to be handled properly
      
      await _userService.updateUserProfile(userId, updateData);
      await loadUserProfile(); // Reload profile
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Listen to user profile changes
  void listenToProfileChanges() {
    final userId = _firebase.currentUserId;
    if (userId == null) return;

    _userService.getUserProfileStream(userId).listen((snapshot) {
      if (snapshot.exists) {
        _userProfile = snapshot.data() as Map<String, dynamic>?;
        notifyListeners();
      }
    });
  }

  // Load notification settings from Firestore
  Future<void> loadNotificationSettings() async {
    final userId = _firebase.currentUserId;
    if (userId == null) return;

    try {
      print('SettingsViewModel: Loading notification settings');
      final settings = await _notificationService.getNotificationSettings(userId);
      
      if (settings != null) {
        _pushEnabled = settings['pushEnabled'] ?? true;
        _soundEnabled = settings['soundEnabled'] ?? true;
        _vibrationEnabled = settings['vibrationEnabled'] ?? true;
        _emailNotifications = settings['emailNotifications'] ?? true;
        _smsNotifications = settings['smsNotifications'] ?? false;
        _loanUpdates = settings['loanUpdates'] ?? true;
        _creditScoreUpdates = settings['creditScoreUpdates'] ?? true;
        _paymentReminders = settings['paymentReminders'] ?? true;
        _promotionalOffers = settings['promotionalOffers'] ?? false;
        
        if (settings['snoozeUntil'] != null) {
          _snoozeUntil = (settings['snoozeUntil'] as dynamic).toDate();
        }
        
        print('SettingsViewModel: Notification settings loaded');
        notifyListeners();
      }
    } catch (e) {
      print('SettingsViewModel: Error loading notification settings: $e');
    }
  }

  // Save notification settings to Firestore
  Future<void> saveNotificationSettings() async {
    final userId = _firebase.currentUserId;
    if (userId == null) return;

    try {
      print('SettingsViewModel: Saving notification settings');
      
      final settings = {
        'pushEnabled': _pushEnabled,
        'soundEnabled': _soundEnabled,
        'vibrationEnabled': _vibrationEnabled,
        'emailNotifications': _emailNotifications,
        'smsNotifications': _smsNotifications,
        'loanUpdates': _loanUpdates,
        'creditScoreUpdates': _creditScoreUpdates,
        'paymentReminders': _paymentReminders,
        'promotionalOffers': _promotionalOffers,
        'snoozeUntil': _snoozeUntil,
      };
      
      await _notificationService.saveNotificationSettings(
        userId: userId,
        settings: settings,
      );
      
      print('SettingsViewModel: Notification settings saved');
    } catch (e) {
      print('SettingsViewModel: Error saving notification settings: $e');
    }
  }

  // Update individual notification settings
  Future<void> updateNotificationSetting(String key, bool value) async {
    switch (key) {
      case 'pushEnabled':
        _pushEnabled = value;
        break;
      case 'soundEnabled':
        _soundEnabled = value;
        break;
      case 'vibrationEnabled':
        _vibrationEnabled = value;
        break;
      case 'emailNotifications':
        _emailNotifications = value;
        break;
      case 'smsNotifications':
        _smsNotifications = value;
        break;
      case 'loanUpdates':
        _loanUpdates = value;
        break;
      case 'creditScoreUpdates':
        _creditScoreUpdates = value;
        break;
      case 'paymentReminders':
        _paymentReminders = value;
        break;
      case 'promotionalOffers':
        _promotionalOffers = value;
        break;
    }
    notifyListeners();
    await saveNotificationSettings();
  }

  // Update snooze
  Future<void> updateSnooze(DateTime? snoozeUntil) async {
    final userId = _firebase.currentUserId;
    if (userId == null) return;

    try {
      _snoozeUntil = snoozeUntil;
      notifyListeners();
      
      await _notificationService.updateSnooze(userId, snoozeUntil);
      print('SettingsViewModel: Snooze updated');
    } catch (e) {
      print('SettingsViewModel: Error updating snooze: $e');
    }
  }

  void updateSecurity({
    bool? biometric,
    bool? twoFactor,
  }) {
    if (biometric != null) biometricEnabled = biometric;
    if (twoFactor != null) twoFactorEnabled = twoFactor;
    notifyListeners();
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
