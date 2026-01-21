import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  int _signupStep = 0;
  String? _verificationId;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  int get signupStep => _signupStep;

  // Actions
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setSignupStep(int step) {
    _signupStep = step;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _obscurePassword = true;
    _signupStep = 0;
    notifyListeners();
  }

  // Sign up with email
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      _setLoading(true);
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign in with email
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Send OTP
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      _setLoading(true);
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _setLoading(false);
        },
        verificationFailed: (e) {
          _setError(e.message ?? 'Verification failed');
          _setLoading(false);
        },
        verificationCompleted: (credential) async {
          // Auto-verification completed
          _setLoading(false);
        },
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String smsCode) async {
    if (_verificationId == null) {
      _setError('No verification in progress');
      return false;
    }

    try {
      _setLoading(true);
      await _authService.verifyOTP(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Legacy methods for backward compatibility
  Future<bool> login(String email, String password) async {
    return signInWithEmail(email: email, password: password);
  }

  Future<bool> signup(String name, String email, String phone, String password) async {
    return signUpWithEmail(
      email: email,
      password: password,
      fullName: name,
      phoneNumber: phone,
    );
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
