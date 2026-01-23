import 'package:flutter/material.dart';
import '../services/firebase_user_service.dart';
import '../services/firebase_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final FirebaseUserService _userService = FirebaseUserService();
  final FirebaseService _firebase = FirebaseService();

  // User Profile Data
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Notification Settings
  bool pushNotificationsFn = true;
  bool emailNotificationsFn = true;
  bool smsNotificationsFn = false;

  // Security Settings
  bool biometricEnabled = false;
  bool twoFactorEnabled = false;

  // Getters
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Legacy getters for backward compatibility
  String get name => _userProfile?['fullName'] ?? 'Nguyen Van A';
  String get email => _userProfile?['email'] ?? 'nguyenvana@email.com';
  String get phone => _userProfile?['phoneNumber'] ?? '+84 0398882xxx';
  String get address => _userProfile?['address'] ?? '123 Hai Trieu Minh City';
  String get idNumber => _userProfile?['nationalId'] ?? '079xxxxxxxx';
  String get dob {
    if (_userProfile?['dateOfBirth'] != null) {
      final dateTime = (_userProfile!['dateOfBirth'] as dynamic).toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    return '15/03/1990';
  }

  // Load user profile
  Future<void> loadUserProfile() async {
    final userId = _firebase.currentUserId;
    if (userId == null) return;

    try {
      _setLoading(true);
      _userProfile = await _userService.getUserProfile(userId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
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

  void updateNotifications({
    bool? push,
    bool? email,
    bool? sms,
  }) {
    if (push != null) pushNotificationsFn = push;
    if (email != null) emailNotificationsFn = email;
    if (sms != null) smsNotificationsFn = sms;
    notifyListeners();
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
