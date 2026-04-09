import 'package:flutter/material.dart';
import '../services/firebase_user_service.dart';

class HomeViewModel extends ChangeNotifier {
  final FirebaseUserService _userService = FirebaseUserService();

  int _selectedIndex = 0;
  String _selectedPeriod = 'Overall';
  int _currentApplicationPage = 1;
  static const int _applicationsPerPage = 5;
  int _currentInstallmentPage = 1;
  static const int _installmentsPerPage = 3;
  
  // User profile data
  String? _userName;
  String? _userAvatar;
  int? _creditScore;
  String? _riskLevel;
  DateTime? _lastCreditCheckDate;
  int? _startingScore;
  bool _isLoadingUserData = false;
  
  // Getters
  int get selectedIndex => _selectedIndex;
  String get selectedPeriod => _selectedPeriod;
  String? get userName => _userName;
  String? get userAvatar => _userAvatar;
  int? get creditScore => _creditScore;
  String? get riskLevel => _riskLevel;
  DateTime? get lastCreditCheckDate => _lastCreditCheckDate;
  int? get startingScore => _startingScore;
  bool get isLoadingUserData => _isLoadingUserData;
  int get currentApplicationPage => _currentApplicationPage;
  int get applicationsPerPage => _applicationsPerPage;
  int get currentInstallmentPage => _currentInstallmentPage;
  int get installmentsPerPage => _installmentsPerPage;
  int get scoreChange => _creditScore != null && _startingScore != null 
      ? _creditScore! - _startingScore! 
      : 0;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setPeriod(String period) {
    _selectedPeriod = period;
    // Reset pagination when changing period
    if (period == 'Application History') {
      _currentApplicationPage = 1;
    } else if (period == 'Installment') {
      _currentInstallmentPage = 1;
    }
    notifyListeners();
  }

  void nextApplicationPage(int totalApplications) {
    final totalPages = (totalApplications / _applicationsPerPage).ceil();
    if (_currentApplicationPage < totalPages) {
      _currentApplicationPage++;
      notifyListeners();
    }
  }

  void previousApplicationPage() {
    if (_currentApplicationPage > 1) {
      _currentApplicationPage--;
      notifyListeners();
    }
  }

  void nextInstallmentPage(int totalInstallments) {
    final totalPages = (totalInstallments / _installmentsPerPage).ceil();
    if (_currentInstallmentPage < totalPages) {
      _currentInstallmentPage++;
      notifyListeners();
    }
  }

  void previousInstallmentPage() {
    if (_currentInstallmentPage > 1) {
      _currentInstallmentPage--;
      notifyListeners();
    }
  }

  // Load user profile data
  Future<void> loadUserProfile(String userId) async {
    try {
      _isLoadingUserData = true;
      notifyListeners();

      final profile = await _userService.getUserProfile(userId);
      
      if (profile != null) {
        _userName = profile['fullName'] as String?;
        _userAvatar = profile['avatarUrl'] as String?;
      }

      _isLoadingUserData = false;
      notifyListeners();
    } catch (e) {
      _isLoadingUserData = false;
      notifyListeners();
    }
  }

  // Load user's credit score from latest application
  Future<void> loadUserCreditScore(String userId) async {
    try {
      print('HomeViewModel: Loading credit score for user $userId');
      final scoreData = await _userService.getUserCreditScore(userId);
      
      if (scoreData != null) {
        print('HomeViewModel: Credit score data found: $scoreData');
        final newScore = scoreData['creditScore'] as int?;
        _creditScore = newScore;
        _riskLevel = scoreData['riskLevel'] as String?;
        
        if (scoreData['createdAt'] != null) {
          _lastCreditCheckDate = (scoreData['createdAt'] as dynamic).toDate();
        }
        
        // Update cached score in user document
        if (newScore != null) {
          print('HomeViewModel: Caching score $newScore to user document');
          await _userService.updateCachedCreditScore(userId, newScore);
        }
        
        // Set starting score if this is the first load
        if (_startingScore == null && newScore != null) {
          _startingScore = newScore;
        }
        
        notifyListeners();
      } else {
        print('HomeViewModel: No credit score data found');
      }
    } catch (e) {
      print('HomeViewModel: Error loading credit score: $e');
      // Silently fail - user might not have applied yet
    }
  }

  // Refresh credit score
  Future<void> refreshCreditScore(String userId) async {
    await loadUserCreditScore(userId);
  }

  // Load all user data (profile + credit score)
  Future<void> loadAllUserData(String userId) async {
    await loadUserProfile(userId);
    await loadUserCreditScore(userId);
  }
}
