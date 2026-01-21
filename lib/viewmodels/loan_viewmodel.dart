import 'package:flutter/material.dart';
import '../services/firebase_loan_service.dart';
import '../services/firebase_service.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class LoanViewModel extends ChangeNotifier {
  final FirebaseLoanService _loanService = FirebaseLoanService();
  final FirebaseService _firebase = FirebaseService();

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
  Map<String, dynamic>? _currentOffer;
  String? _errorMessage;
  List<Map<String, dynamic>> _applications = [];

  // Getters
  bool get step1Completed => _step1Completed;
  bool get step2Completed => _step2Completed;
  bool get step3Completed => _step3Completed;
  bool get isProcessing => _isProcessing;
  Map<String, dynamic>? get currentOffer => _currentOffer;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get applications => _applications;

  // Legacy getter for backward compatibility
  LoanOfferResponse? get currentOfferLegacy {
    if (_currentOffer == null) return null;
    return LoanOfferResponse.fromJson(_currentOffer!);
  }

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
    final userId = _firebase.currentUserId;
    if (userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

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
      // Artificial delay for UX
      await Future.delayed(const Duration(seconds: 2));
      
      // Submit to Firebase (which calls API and stores results)
      final result = await _loanService.submitLoanApplication(
        userId: userId,
        loanRequest: request,
      );
      
      _currentOffer = {
        'applicationId': result['applicationId'],
        'offerId': result['offerId'],
        'approved': (result['loanOffer'] as LoanOfferResponse).approved,
        'creditScore': (result['loanOffer'] as LoanOfferResponse).creditScore,
        'loanAmountVnd': (result['loanOffer'] as LoanOfferResponse).loanAmountVnd,
        'maxAmountVnd': (result['loanOffer'] as LoanOfferResponse).maxAmountVnd,
        'interestRate': (result['loanOffer'] as LoanOfferResponse).interestRate,
        'monthlyPaymentVnd': (result['loanOffer'] as LoanOfferResponse).monthlyPaymentVnd,
        'loanTermMonths': (result['loanOffer'] as LoanOfferResponse).loanTermMonths,
        'riskLevel': (result['loanOffer'] as LoanOfferResponse).riskLevel,
        'approvalMessage': (result['loanOffer'] as LoanOfferResponse).approvalMessage,
        'loanTier': (result['loanOffer'] as LoanOfferResponse).loanTier,
        'tierReason': (result['loanOffer'] as LoanOfferResponse).tierReason,
      };
      
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

  // Load user applications from Firebase
  Future<void> loadApplications() async {
    final userId = _firebase.currentUserId;
    if (userId == null) return;

    try {
      _applications = await _loanService.getUserApplications(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Accept loan offer
  Future<bool> acceptOffer(String offerId) async {
    try {
      await _loanService.acceptLoanOffer(offerId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearCurrentOffer() {
    _currentOffer = null;
    notifyListeners();
  }

  // Demo mode: Call API without storage/state management (sandbox)
  Future<LoanOfferResponse?> getDemoCalculation(SimpleLoanRequest request) async {
    try {
      final apiService = ApiService();
      final response = await apiService.applyForLoan(request);
      return response;
    } catch (e) {
      return null;
    }
  }
}
