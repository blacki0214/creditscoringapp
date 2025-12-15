import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  int _signupStep = 0;

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

  // Placeholder for Login logic
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    // TODO: Integrate actual API service
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    _setLoading(false);
    
    // Simulate successful login
    return true; 
  }

  // Placeholder for Signup logic
  Future<bool> signup(String name, String email, String phone, String password) async {
     _setLoading(true);
    // TODO: Integrate actual API service
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    _setLoading(false);
    
    // Simulate successful signup
    return true;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
