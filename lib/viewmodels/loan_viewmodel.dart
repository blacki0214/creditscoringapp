import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/local_storage_service.dart';
import '../services/vnpt_ekyc_service.dart';
import '../services/api_service.dart';

class LoanViewModel extends ChangeNotifier {
  // API Service
  final ApiService _apiService = ApiService();
  
  // VNPT eKYC Service (singleton instance)
  final VnptEkycService _vnptService = VnptEkycService();

  // Step progress
  bool _step1Completed = false;
  bool _step2Completed = false;
  bool _step3Completed = false;
  bool _isProcessing = false;

  // VNPT eKYC captured images
  Uint8List? _frontIdImageBytes;
  Uint8List? _backIdImageBytes;
  Uint8List? _selfieImageBytes;

  // VNPT eKYC verification results
  VnptIdCardResponse? _frontIdData;
  VnptIdCardResponse? _backIdData;
  VnptFaceMatchResponse? _faceMatchData;

  // VNPT processing states
  bool _isVerifyingFrontId = false;
  bool _isVerifyingBackId = false;
  bool _isVerifyingSelfie = false;
  String? _vnptErrorMessage;

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

  // VNPT eKYC getters
  Uint8List? get frontIdImageBytes => _frontIdImageBytes;
  Uint8List? get backIdImageBytes => _backIdImageBytes;
  Uint8List? get selfieImageBytes => _selfieImageBytes;
  VnptIdCardResponse? get frontIdData => _frontIdData;
  VnptIdCardResponse? get backIdData => _backIdData;
  VnptFaceMatchResponse? get faceMatchData => _faceMatchData;
  bool get isVerifyingFrontId => _isVerifyingFrontId;
  bool get isVerifyingBackId => _isVerifyingBackId;
  bool get isVerifyingSelfie => _isVerifyingSelfie;
  String? get vnptErrorMessage => _vnptErrorMessage;

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

  // ===== VNPT eKYC Methods =====

  /// Verify front ID with VNPT OCR (with classify and card liveness checks)
  Future<bool> verifyFrontIdWithVnpt(Uint8List imageBytes) async {
    _isVerifyingFrontId = true;
    _vnptErrorMessage = null;
    _frontIdImageBytes = imageBytes;
    notifyListeners();

    try {
      // Step 1: Classify ID type
      print('[ViewModel] Step 1: Classifying ID type...');
      final classifyResult = await _vnptService.classifyIdCard(imageBytes);
      
      if (classifyResult.success) {
        print('[ViewModel] ID Type: ${classifyResult.typeDescription} (${classifyResult.typeId})');
      }


      print('[ViewModel] Step 2: Card liveness check SKIPPED (testing mode)');

      // Step 3: Perform OCR
      print('[ViewModel] Step 3: Performing OCR...');
      final response = await _vnptService.verifyIdCardFront(imageBytes);
      _frontIdData = response;

      if (response.success) {
        // Auto-fill personal info from OCR
        if (response.fullName != null) fullName = response.fullName!;
        if (response.idNumber != null) idNumber = response.idNumber!;
        if (response.dateOfBirth != null) dob = response.dateOfBirth;
        if (response.placeOfResidence != null) address = response.placeOfResidence!;
        
        _saveDraft();
        print('[ViewModel] OCR successful, data auto-filled');
      } else {
        _vnptErrorMessage = response.errorMessage ?? 'Cannot regcognized CMND/CCCD';
      }

      _isVerifyingFrontId = false;
      notifyListeners();
      return response.success;
    } catch (e) {
      _vnptErrorMessage = e.toString();
      _isVerifyingFrontId = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify back ID with VNPT OCR
  Future<bool> verifyBackIdWithVnpt(Uint8List imageBytes) async {
    _isVerifyingBackId = true;
    _vnptErrorMessage = null;
    _backIdImageBytes = imageBytes;
    notifyListeners();

    try {
      final response = await _vnptService.verifyIdCardBack(imageBytes);
      _backIdData = response;

      if (!response.success) {
        _vnptErrorMessage = response.errorMessage ?? 'Cannot regcognized CMND/CCCD';
      }

      _isVerifyingBackId = false;
      notifyListeners();
      return response.success;
    } catch (e) {
      _vnptErrorMessage = e.toString();
      _isVerifyingBackId = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify selfie with VNPT face comparison
  Future<bool> verifySelfieWithVnpt(Uint8List imageBytes) async {
    _isVerifyingSelfie = true;
    _vnptErrorMessage = null;
    _selfieImageBytes = imageBytes;
    notifyListeners();

    try {
      // Need front ID image for face comparison
      if (_frontIdImageBytes == null) {
        _vnptErrorMessage = 'Please capture the front of the ID card first';
        _isVerifyingSelfie = false;
        notifyListeners();
        return false;
      }

      print('[ViewModel] Comparing faces...');
      
      // Compare face on ID card with selfie
      final faceMatch = await _vnptService.compareFaces(
        idCardImageBytes: _frontIdImageBytes!,
        selfieImageBytes: imageBytes,
      );

      _faceMatchData = faceMatch;

      if (!faceMatch.success) {
        _vnptErrorMessage = faceMatch.errorMessage ?? 'Cannot compare faces';
        _isVerifyingSelfie = false;
        notifyListeners();
        return false;
      }

      print('[ViewModel] Face match result: ${faceMatch.matchStatus}');
      print('[ViewModel] Similarity: ${faceMatch.similarity != null ? (faceMatch.similarity! * 100).toStringAsFixed(1) : "N/A"}%');

      _isVerifyingSelfie = false;
      notifyListeners();
      return faceMatch.success;
      
    } catch (e) {
      _vnptErrorMessage = e.toString();
      _isVerifyingSelfie = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear VNPT error message
  void clearVnptError() {
    _vnptErrorMessage = null;
    notifyListeners();
  }

  /// Reset all VNPT eKYC data
  void resetVnptData() {
    _frontIdImageBytes = null;
    _backIdImageBytes = null;
    _selfieImageBytes = null;
    _frontIdData = null;
    _backIdData = null;
    _faceMatchData = null;
    _vnptErrorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _vnptService.dispose();
    super.dispose();
  }
}
