import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoanViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Step progress
  bool _step1Completed = false;
  bool _step2Completed = false;
  bool _step3Completed = false;
  bool _isProcessing = false;

  // Personal Information Data
  String fullName = 'Nguyen Van A';
  int age = 30;
  String phoneNumber = '(+84) 901234567';
  String idNumber = '079...';
  String address = '123 Street...';
  
  String employmentStatus = 'EMPLOYED';
  double yearsEmployed = 5;
  double monthlyIncome = 15000000;
  
  String homeOwnership = 'RENT';
  String loanPurpose = 'PERSONAL';
  int yearsCreditHistory = 2;
  bool hasPreviousDefaults = false;
  bool currentlyDefaulting = false;

  // Response Data
  LoanOfferResponse? _currentOffer;
  String? _errorMessage;

  // Getters
  bool get step1Completed => _step1Completed;
  bool get step2Completed => _step2Completed;
  bool get step3Completed => _step3Completed;
  bool get isProcessing => _isProcessing;
  LoanOfferResponse? get currentOffer => _currentOffer;
  String? get errorMessage => _errorMessage;

  // Actions
  void completeStep1() {
    _step1Completed = true;
    notifyListeners();
  }

  void updatePersonalInfo({
    String? name,
    int? ageVal,
    String? phone,
    String? id,
    String? addr,
    String? employment,
    double? yearsEmp,
    double? income,
    String? home,
    String? purpose,
    int? history,
    bool? defaults,
    bool? currentDefault,
  }) {
    if (name != null) fullName = name;
    if (ageVal != null) age = ageVal;
    if (phone != null) phoneNumber = phone;
    if (id != null) idNumber = id;
    if (addr != null) address = addr;
    if (employment != null) employmentStatus = employment;
    if (yearsEmp != null) yearsEmployed = yearsEmp;
    if (income != null) monthlyIncome = income;
    if (home != null) homeOwnership = home;
    if (purpose != null) loanPurpose = purpose;
    if (history != null) yearsCreditHistory = history;
    if (defaults != null) hasPreviousDefaults = defaults;
    if (currentDefault != null) currentlyDefaulting = currentDefault;
    notifyListeners();
  }

  Future<bool> submitApplication() async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    // Create request object
    final request = SimpleLoanRequest(
      fullName: fullName,
      age: age,
      monthlyIncome: monthlyIncome,
      employmentStatus: employmentStatus,
      yearsEmployed: yearsEmployed,
      homeOwnership: homeOwnership,
      loanPurpose: loanPurpose,
      yearsCreditHistory: yearsCreditHistory,
      hasPreviousDefaults: hasPreviousDefaults,
      currentlyDefaulting: currentlyDefaulting,
    );

    try {
      // Call API
      // Artificial delay for UX
     await Future.delayed(const Duration(seconds: 2));
     
      _currentOffer = await _apiService.applyForLoan(request);
      
      _step2Completed = true;
      _step3Completed = true; // Processing done
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }
  
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
}
