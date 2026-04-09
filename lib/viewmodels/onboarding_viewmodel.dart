import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';

class OnboardingViewModel extends ChangeNotifier {
  int _currentPage = 0;
  bool _apiHealthy = true;
  String? _apiHealthMessage;

  // Getters
  int get currentPage => _currentPage;
  bool get apiHealthy => _apiHealthy;
  String? get apiHealthMessage => _apiHealthMessage;

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

    final apiService = ApiService();
    final healthy = await apiService.checkHealth();
    _apiHealthy = healthy;
    _apiHealthMessage = healthy
        ? null
        : 'Kết nối tạm thời gián đoạn. Vui lòng thử lại.';
    notifyListeners();
  }

  /// Mark onboarding as completed and persist the flag
  /// Called when user finishes splash screens or clicks "Get Started"
  Future<void> completeOnboarding() async {
    await LocalStorageService.markOnboardingAsSeen();
  }
}
