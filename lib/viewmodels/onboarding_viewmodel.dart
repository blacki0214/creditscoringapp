import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class OnboardingViewModel extends ChangeNotifier {
  int _currentPage = 0;
  
  // Getters
  int get currentPage => _currentPage;

  // Actions
  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  /// Initialize app and prepare for navigation
  /// Simulates loading app configs and services
  Future<void> initializeApp() async {
    // Simulate initialization (e.g., check login status, load configs)
    await Future.delayed(const Duration(seconds: 3));
  }

  /// Mark onboarding as completed and persist the flag
  /// Called when user finishes splash screens or clicks "Get Started"
  Future<void> completeOnboarding() async {
    await LocalStorageService.markOnboardingAsSeen();
  }
}
