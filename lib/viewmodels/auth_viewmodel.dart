import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_user_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseUserService _userService = FirebaseUserService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  int _signupStep = 0;
  String? _verificationId;
  File? _selectedAvatar;
  
  // Phone authentication state
  String _phoneNumber = '';
  int _otpResendTime = 0;
  bool _isOtpSent = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  int get signupStep => _signupStep;
  File? get selectedAvatar => _selectedAvatar;
  String get phoneNumber => _phoneNumber;
  int get otpResendTime => _otpResendTime;
  bool get isOtpSent => _isOtpSent;

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
    _selectedAvatar = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Pick avatar from gallery
  Future<void> pickAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedAvatar = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to pick image: $e');
    }
  }

  // Clear selected avatar
  void clearAvatar() {
    _selectedAvatar = null;
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
      
      String? avatarUrl;
      
      // Upload avatar if selected
      if (_selectedAvatar != null) {
        // Create user first to get userId
        final credential = await _authService.signUpWithEmail(
          email: email,
          password: password,
          fullName: fullName,
          phoneNumber: phoneNumber,
        );
        
        final userId = credential.user!.uid;
        
        // Upload avatar
        avatarUrl = await _userService.uploadUserAvatar(userId, _selectedAvatar!);
        
        // Update user document with avatar URL
        await _userService.updateUserAvatar(userId, avatarUrl);
      } else {
        // Create user without avatar
        await _authService.signUpWithEmail(
          email: email,
          password: password,
          fullName: fullName,
          phoneNumber: phoneNumber,
        );
      }
      
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

  // Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      _setLoading(true);
      await _authService.sendEmailVerification();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
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

  // Check if email is verified
  Future<bool> checkEmailVerified() async {
    try {
      return await _authService.isEmailVerified();
    } catch (e) {
      _setError(e.toString());
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
    
    // Auto-dismiss error after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (_errorMessage == message) {
        _errorMessage = null;
        notifyListeners();
      }
    });
  }

  // === PHONE AUTHENTICATION ===
  
  // Send OTP to phone number
  Future<bool> sendPhoneOTP(String phoneNumber) async {
    try {
      _setLoading(true);
      _phoneNumber = phoneNumber;
      
      await _authService.sendPhoneOTP(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) {
          _verificationId = verificationId;
          _isOtpSent = true;
          _startOtpTimer();
          _setLoading(false);
          notifyListeners();
        },
        onError: (errorMessage) {
          _setError(errorMessage);
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

  // Verify OTP code (during phone signup)
  Future<bool> verifyOTP(String otpCode, {String? fullName}) async {
    if (_verificationId == null) {
      _setError('No verification ID found. Please request OTP again.');
      return false;
    }

    try {
      _setLoading(true);
      
      await _authService.verifyPhoneOTP(
        verificationId: _verificationId!,
        smsCode: otpCode,
        fullName: fullName,
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Complete phone signup with profile information
  Future<bool> completePhoneSignup({
    required String fullName,
    String? email,
  }) async {
    try {
      _setLoading(true);
      
      // Get current user (already authenticated via phone)
      final user = _authService.currentUser;
      if (user == null) {
        _setError('No authenticated user found');
        _setLoading(false);
        return false;
      }

      // Upload avatar if selected
      String? avatarUrl;
      if (_selectedAvatar != null) {
        avatarUrl = await _userService.uploadUserAvatar(
          user.uid,
          _selectedAvatar!,
        );
      }

      // Update user document with profile info
      final updateData = <String, dynamic>{
        'fullName': fullName,
      };
      
      if (email != null && email.isNotEmpty) {
        updateData['email'] = email;
      }
      
      if (avatarUrl != null) {
        updateData['avatarUrl'] = avatarUrl;
      }
      
      await _userService.updateUserProfile(user.uid, updateData);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Resend OTP
  Future<void> resendOTP() async {
    if (_phoneNumber.isEmpty) {
      _setError('Phone number not found');
      return;
    }
    
    _isOtpSent = false;
    notifyListeners();
    
    await sendPhoneOTP(_phoneNumber);
  }

  // Start OTP timer (60 seconds countdown)
  void _startOtpTimer() {
    _otpResendTime = 60;
    notifyListeners();
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_otpResendTime > 0) {
        _otpResendTime--;
        notifyListeners();
        return true;
      }
      return false;
    });
  }

  // === GOOGLE SIGN-IN ===
  
  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      
      final result = await _authService.signInWithGoogle();
      
      _setLoading(false);
      
      if (result == null) {
        // User canceled
        return false;
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
}
