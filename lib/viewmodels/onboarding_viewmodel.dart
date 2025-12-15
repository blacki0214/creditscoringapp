import 'package:flutter/material.dart';

class OnboardingViewModel extends ChangeNotifier {
  int _currentPage = 0;
  
  // Getters
  int get currentPage => _currentPage;

  // Actions
  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  Future<void> initializeApp() async {
    // Simulate initialization (e.g., check login status, load configs)
    await Future.delayed(const Duration(seconds: 3));
  }
}
