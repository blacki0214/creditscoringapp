import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class LoanViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Step progress
  bool _step1Completed = false;
  bool _step2Completed = false;
  bool _step3Completed = false;
  bool _isProcessing = false;

  // Personal Information Data
  String fullName = 'Nguyen Van A';
  DateTime? dob;
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

  // Load saved draft on init
  LoanViewModel() {
    _loadDraft();
  }

  void _loadDraft() {
    final draft = LocalStorageService.loadDraft();
    if (draft != null) {
      fullName = draft['fullName'] ?? fullName;
      if (draft['dob'] != null) {
        dob = DateTime.parse(draft['dob']);
      }
      phoneNumber = draft['phoneNumber'] ?? phoneNumber;
      idNumber = draft['idNumber'] ?? idNumber;
      address = draft['address'] ?? address;
      employmentStatus = draft['employmentStatus'] ?? employmentStatus;
      yearsEmployed = draft['yearsEmployed'] ?? yearsEmployed;
      monthlyIncome = draft['monthlyIncome'] ?? monthlyIncome;
      homeOwnership = draft['homeOwnership'] ?? homeOwnership;
      loanPurpose = draft['loanPurpose'] ?? loanPurpose;
      yearsCreditHistory = draft['yearsCreditHistory'] ?? yearsCreditHistory;
      hasPreviousDefaults = draft['hasPreviousDefaults'] ?? hasPreviousDefaults;
      currentlyDefaulting = draft['currentlyDefaulting'] ?? currentlyDefaulting;
      notifyListeners();
    }
  }

  void _saveDraft() {
    LocalStorageService.saveDraft({
      'fullName': fullName,
      'dob': dob?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'idNumber': idNumber,
      'address': address,
      'employmentStatus': employmentStatus,
      'yearsEmployed': yearsEmployed,
      'monthlyIncome': monthlyIncome,
      'homeOwnership': homeOwnership,
      'loanPurpose': loanPurpose,
      'yearsCreditHistory': yearsCreditHistory,
      'hasPreviousDefaults': hasPreviousDefaults,
      'currentlyDefaulting': currentlyDefaulting,
    });
  }

  // Actions
  void completeStep1() {
    _step1Completed = true;
    notifyListeners();
  }

  void updatePersonalInfo({
    String? name,
    DateTime? dob,
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
    if (dob != null) this.dob = dob;
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
    
    _saveDraft(); // Auto-save on every change
    notifyListeners();
  }

  Future<bool> submitApplication() async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    // Create request object
    // Calculate age from DOB
    int age = 0;
    if (dob != null) {
      final today = DateTime.now();
      age = today.year - dob!.year;
      if (today.month < dob!.month || (today.month == dob!.month && today.day < dob!.day)) {
        age--;
      }
    }

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
      
      // Save to history
      await LocalStorageService.saveApplicationHistory({
        'fullName': fullName,
        'age': age,
        'loanPurpose': loanPurpose,
        'approved': _currentOffer?.approved ?? false,
        'creditScore': _currentOffer?.creditScore ?? 0,
        'loanAmount': _currentOffer?.loanAmountVnd ?? 0,
      });
      
      // Clear draft after successful submission
      await LocalStorageService.clearDraft();
      
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

  // Demo mode: Call API without storage/state management (sandbox)
  Future<LoanOfferResponse?> getDemoCalculation(SimpleLoanRequest request) async {
    try {
      // Call same API, but don't modify any state
      final response = await _apiService.applyForLoan(request);
      return response;
    } catch (e) {
      return null;
    }
  }
}