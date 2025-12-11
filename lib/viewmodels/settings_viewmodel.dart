import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  // User Profile Data
  String name = 'Nguyen Van A';
  String email = 'nguyenvana@email.com';
  String phone = '+84 0398882xxx';
  String address = '123 Hai Trieu Minh City';
  String idNumber = '079xxxxxxxx';
  String dob = '15/03/1990';
  
  // Notification Settings
  bool pushNotificationsFn = true;
  bool emailNotificationsFn = true;
  bool smsNotificationsFn = false;

  // Security Settings
  bool biometricEnabled = false;
  bool twoFactorEnabled = false;

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? idNumber,
    String? dob,
  }) {
    if (name != null) this.name = name;
    if (email != null) this.email = email;
    if (phone != null) this.phone = phone;
    if (address != null) this.address = address;
    if (idNumber != null) this.idNumber = idNumber;
    if (dob != null) this.dob = dob;
    notifyListeners();
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
}
