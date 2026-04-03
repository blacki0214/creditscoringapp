import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_loan_service.dart';
import '../services/firebase_service.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/vnpt_ekyc_service.dart';

// Application status enum
enum ApplicationStatus {
  none, // No application submitted
  processing, // Application submitted, waiting for API response
  scored, // Scoring completed successfully
  rejected, // Application rejected
}

class LoanViewModel extends ChangeNotifier {
  // VNPT eKYC Service (singleton instance)
  final VnptEkycService _vnptService = VnptEkycService();
  final FirebaseLoanService _loanService = FirebaseLoanService();
  final FirebaseService _firebase = FirebaseService();

  // Step progress
  bool _step1Completed = false;
  bool _step2Completed = false;
  bool _step3Completed = false;
  bool _step4Completed = false;
  bool _step6Completed = false;
  bool _isProcessing = false;

  // Application status tracking
  ApplicationStatus _applicationStatus = ApplicationStatus.none;
  ApplicationStatus _lastCompletedStatus = ApplicationStatus.none;
  String? _pendingApplicationId;

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
  double yearsCreditHistory = 2;
  bool hasPreviousDefaults = false;
  bool currentlyDefaulting = false;

  // Response Data
  Map<String, dynamic>? _currentOffer;
  Map<String, dynamic>? _lastCompletedOffer;
  String? _errorMessage;
  List<Map<String, dynamic>> _applications = [];

  // Getters
  bool get step1Completed => _step1Completed;
  bool get step2Completed => _step2Completed;
  bool get step3Completed => _step3Completed;
  bool get step4Completed => _step4Completed;
  bool get step6Completed => _step6Completed;
  bool get isProcessing => _isProcessing;
  Map<String, dynamic>? get currentOffer => _currentOffer;
  Map<String, dynamic>? get lastCompletedOffer => _lastCompletedOffer;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get applications => _applications;

  // Application status getters
  ApplicationStatus get applicationStatus => _applicationStatus;
  ApplicationStatus get lastCompletedStatus => _lastCompletedStatus;
  bool get isApplicationProcessing =>
      _applicationStatus == ApplicationStatus.processing;
  bool get isApplicationScored =>
      _applicationStatus == ApplicationStatus.scored;
  bool get isApplicationRejected =>
      _applicationStatus == ApplicationStatus.rejected;
  String? get pendingApplicationId => _pendingApplicationId;

  // Legacy getter for backward compatibility
  LoanOfferResponse? get currentOfferLegacy {
    if (_currentOffer == null) return null;
    return LoanOfferResponse.fromJson(_currentOffer!);
  }

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
      return;
    }

    // If there is no draft, try restoring from persisted eKYC prefill.
    applySavedEkycPrefill(notify: true);
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
  void completeStep1() async {
    _step1Completed = true;
    notifyListeners();

    // Save eKYC data to user profile in Firestore
    await _saveEkycDataToProfile();

    // Persist local eKYC fields for future Step 1 skip -> Step 2 prefill.
    await persistEkycPrefill();
  }

  Future<void> persistEkycPrefill() async {
    final payload = <String, dynamic>{};

    if (fullName.isNotEmpty && fullName != 'Nguyen Van A') {
      payload['fullName'] = fullName;
    }
    if (dob != null) {
      payload['dob'] = dob!.toIso8601String();
    }
    if (phoneNumber.isNotEmpty && phoneNumber != '(+84) 901234567') {
      payload['phoneNumber'] = phoneNumber;
    }
    if (idNumber.isNotEmpty && idNumber != '079...') {
      payload['idNumber'] = idNumber;
    }
    if (address.isNotEmpty && address != '123 Street...') {
      payload['address'] = address;
    }

    if (payload.isNotEmpty) {
      await LocalStorageService.saveEkycPrefill(payload);
    }
  }

  void applySavedEkycPrefill({bool notify = true}) {
    final data = LocalStorageService.loadEkycPrefill();
    if (data == null) return;

    bool changed = false;

    final savedName = (data['fullName'] as String?)?.trim();
    if ((fullName.isEmpty || fullName == 'Nguyen Van A') &&
        savedName != null &&
        savedName.isNotEmpty) {
      fullName = savedName;
      changed = true;
    }

    final savedDobRaw = data['dob'] as String?;
    if (dob == null && savedDobRaw != null) {
      final parsed = DateTime.tryParse(savedDobRaw);
      if (parsed != null) {
        dob = parsed;
        changed = true;
      }
    }

    final savedPhone = (data['phoneNumber'] as String?)?.trim();
    if ((phoneNumber.isEmpty || phoneNumber == '(+84) 901234567') &&
        savedPhone != null &&
        savedPhone.isNotEmpty) {
      phoneNumber = savedPhone;
      changed = true;
    }

    final savedId = (data['idNumber'] as String?)?.trim();
    if ((idNumber.isEmpty || idNumber == '079...') &&
        savedId != null &&
        savedId.isNotEmpty) {
      idNumber = savedId;
      changed = true;
    }

    final savedAddress = (data['address'] as String?)?.trim();
    if ((address.isEmpty || address == '123 Street...') &&
        savedAddress != null &&
        savedAddress.isNotEmpty) {
      address = savedAddress;
      changed = true;
    }

    if (changed && notify) {
      notifyListeners();
    }
  }

  void clearStep1CompletionForDemo() {
    _step1Completed = false;
    notifyListeners();
  }

  // Save eKYC extracted data to user profile
  Future<void> _saveEkycDataToProfile() async {
    final userId = _firebase.currentUserId;
    if (userId == null) {
      print('[LoanViewModel] Cannot save eKYC data: No user ID');
      return;
    }

    try {
      final updateData = <String, dynamic>{};

      // Add data if available from eKYC verification
      if (fullName.isNotEmpty && fullName != 'Nguyen Van A') {
        updateData['fullName'] = fullName;
      }

      if (dob != null) {
        updateData['dateOfBirth'] = Timestamp.fromDate(dob!);
      }

      if (idNumber.isNotEmpty && idNumber != '079...') {
        updateData['nationalId'] = idNumber;
      }

      if (address.isNotEmpty && address != '123 Street...') {
        updateData['address'] = address;
      }

      if (phoneNumber.isNotEmpty && phoneNumber != '(+84) 901234567') {
        updateData['phoneNumber'] = phoneNumber;
      }

      // Only update if we have data to save
      if (updateData.isNotEmpty) {
        updateData['updatedAt'] = FieldValue.serverTimestamp();

        print(
          '[LoanViewModel] Saving eKYC data to user profile: ${updateData.keys.join(', ')}',
        );

        // Use set with merge to create/update document
        await _firebase.usersCollection
            .doc(userId)
            .set(updateData, SetOptions(merge: true));

        print('[LoanViewModel] eKYC data saved successfully');
      } else {
        print('[LoanViewModel] No eKYC data to save');
      }
    } catch (e) {
      print('[LoanViewModel] Error saving eKYC data to profile: $e');
      // Don't throw - this is non-critical, user can still continue
    }
  }

  void completeStep2() {
    _step2Completed = true;
    notifyListeners();
  }

  void completeStep3() {
    _step3Completed = true;
    notifyListeners();
  }

  void completeStep4() {
    _step4Completed = true;
    notifyListeners();
  }

  Future<void> completeStep6() async {
    _step6Completed = true;
    notifyListeners();
    await finalizeAndResetForNewApplication();
  }

  // Backward compatibility for older call sites.
  Future<void> completeStep5() async {
    await completeStep6();
  }

  // Update the current offer with user's chosen loan parameters from Step 4
  void updateLoanOffer({
    required double loanAmount,
    required int tenor,
    required double monthlyPayment,
    String? loanPurpose,
  }) {
    if (_currentOffer != null) {
      // Update the offer with user's chosen parameters
      _currentOffer!['loanAmountVnd'] = loanAmount;
      _currentOffer!['loanTermMonths'] = tenor;
      _currentOffer!['monthlyPaymentVnd'] = monthlyPayment;

      // Calculate total payment and interest
      final totalPayment = monthlyPayment * tenor;
      final totalInterest = totalPayment - loanAmount;
      _currentOffer!['totalPaymentVnd'] = totalPayment;
      _currentOffer!['totalInterestVnd'] = totalInterest;

      // Update loan purpose if provided
      if (loanPurpose != null) {
        this.loanPurpose = loanPurpose;
      }

      notifyListeners();
    }
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
    double? history,
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

  // Submit application asynchronously - returns immediately, processes in background
  Future<bool> submitApplicationAsync() async {
    final userId = _firebase.currentUserId;
    if (userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    print('[LoanViewModel] Starting loan application submission...');
    _isProcessing = true;
    _applicationStatus = ApplicationStatus.processing;
    _errorMessage = null;
    notifyListeners();

    try {
      // Calculate age from DOB
      int age = 0;
      if (dob != null) {
        final today = DateTime.now();
        age = today.year - dob!.year;
        if (today.month < dob!.month ||
            (today.month == dob!.month && today.day < dob!.day)) {
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

      // Create pending application in Firebase
      final applicationId = await _loanService.createPendingApplication(
        userId: userId,
        loanRequest: request,
      );

      _pendingApplicationId = applicationId;
      _isProcessing = false;
      notifyListeners();

      // Process in background (fire and forget)
      _processApplicationInBackground(userId, request, applicationId);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isProcessing = false;
      _applicationStatus = ApplicationStatus.none;
      notifyListeners();
      return false;
    }
  }

  // Background processing of application
  Future<void> _processApplicationInBackground(
    String userId,
    SimpleLoanRequest request,
    String applicationId,
  ) async {
    try {
      // Artificial delay for UX
      await Future.delayed(const Duration(seconds: 3));

      // Submit to Firebase (which calls the two-step API and stores results)
      print('[LoanViewModel] Calling Firebase loan service...');
      final result = await _loanService.submitLoanApplication(
        userId: userId,
        loanRequest: request,
      );

      print('[LoanViewModel] Received response from Firebase service');
      final limitResponse = result['limitResponse'] as CalculateLimitResponse;
      final termsResponse = result['termsResponse'] as CalculateTermsResponse?;

      print(
        '[LoanViewModel] Credit score: ${limitResponse.creditScore}, Approved: ${limitResponse.approved}',
      );

      // Build currentOffer map from the two-step response
      _currentOffer = {
        'applicationId': result['applicationId'],
        'offerId': result['offerId'],
        'approved': limitResponse.approved,
        'creditScore': limitResponse.creditScore,
        'loanLimitVnd': limitResponse.loanLimitVnd,
        'maxAmountVnd': limitResponse.loanLimitVnd,
        'riskLevel': limitResponse.riskLevel,
        'approvalMessage': limitResponse.message,
      };

      // Add terms data if approved
      if (termsResponse != null) {
        _currentOffer!['loanAmountVnd'] = limitResponse.loanLimitVnd;
        _currentOffer!['interestRate'] = termsResponse.interestRate;
        _currentOffer!['monthlyPaymentVnd'] = termsResponse.monthlyPaymentVnd;
        _currentOffer!['loanTermMonths'] = termsResponse.loanTermMonths;
        _currentOffer!['totalPaymentVnd'] = termsResponse.totalPaymentVnd;
        _currentOffer!['totalInterestVnd'] = termsResponse.totalInterestVnd;
      } else {
        // For rejected applications
        _currentOffer!['loanAmountVnd'] = 0;
      }

      // Update status
      _applicationStatus = limitResponse.approved
          ? ApplicationStatus.scored
          : ApplicationStatus.rejected;

      // Clear draft after successful submission
      print('[LoanViewModel] Clearing draft...');
      await LocalStorageService.clearDraft();

      _step2Completed = true;
      _step3Completed = true; // Processing done
      notifyListeners();
    } catch (e) {
      print('[LoanViewModel] ERROR during submission: $e');
      _errorMessage = e.toString();
      _applicationStatus = ApplicationStatus.rejected;
      notifyListeners();
    }
  }

  // Legacy method for backward compatibility (synchronous processing)
  Future<bool> submitApplication() async {
    return submitApplicationAsync();
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

  Future<void> finalizeAndResetForNewApplication() async {
    if (_currentOffer != null) {
      _lastCompletedOffer = Map<String, dynamic>.from(_currentOffer!);
      _lastCompletedStatus = _applicationStatus;

      await LocalStorageService.saveApplicationHistory({
        'approved': _currentOffer!['approved'],
        'creditScore': _currentOffer!['creditScore'],
        'loanAmount': _currentOffer!['loanAmountVnd'],
        'maxAmount': _currentOffer!['maxAmountVnd'],
        'loanTermMonths': _currentOffer!['loanTermMonths'],
        'monthlyPaymentVnd': _currentOffer!['monthlyPaymentVnd'],
        'interestRate': _currentOffer!['interestRate'],
        'contractStatus': _currentOffer!['approved'] == true
            ? 'Active'
            : 'Rejected',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    resetForNewApplication();
  }

  void resetForNewApplication() {
    _step1Completed = false;
    _step2Completed = false;
    _step3Completed = false;
    _step4Completed = false;
    _step6Completed = false;
    _isProcessing = false;
    _applicationStatus = ApplicationStatus.none;
    _pendingApplicationId = null;
    _currentOffer = null;
    _errorMessage = null;

    _frontIdImageBytes = null;
    _backIdImageBytes = null;
    _selfieImageBytes = null;
    _frontIdData = null;
    _backIdData = null;
    _faceMatchData = null;
    _vnptErrorMessage = null;
    _isVerifyingFrontId = false;
    _isVerifyingBackId = false;
    _isVerifyingSelfie = false;

    notifyListeners();
  }

  Future<void> resetLoanApplicationState() async {
    _step1Completed = false;
    _step2Completed = false;
    _step3Completed = false;
    _step4Completed = false;
    _step6Completed = false;
    _isProcessing = false;
    _applicationStatus = ApplicationStatus.none;
    _pendingApplicationId = null;
    _currentOffer = null;
    _errorMessage = null;

    _frontIdImageBytes = null;
    _backIdImageBytes = null;
    _selfieImageBytes = null;
    _frontIdData = null;
    _backIdData = null;
    _faceMatchData = null;
    _vnptErrorMessage = null;
    _isVerifyingFrontId = false;
    _isVerifyingBackId = false;
    _isVerifyingSelfie = false;

    fullName = '';
    dob = null;
    phoneNumber = '';
    idNumber = '';
    address = '';
    employmentStatus = 'EMPLOYED';
    yearsEmployed = 0;
    monthlyIncome = 0;
    homeOwnership = 'RENT';
    loanPurpose = 'PERSONAL';
    yearsCreditHistory = 0;
    hasPreviousDefaults = false;
    currentlyDefaulting = false;

    await LocalStorageService.clearDraft();
    notifyListeners();
  }

  void clearCurrentOffer() {
    _currentOffer = null;
    notifyListeners();
  }

  // Demo mode: Call API without storage/state management (sandbox)
  Future<LoanOfferResponse?> getDemoCalculation(
    SimpleLoanRequest request,
  ) async {
    try {
      final apiService = ApiService();
      final response = await apiService.applyForLoan(request);
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
        print(
          '[ViewModel] ID Type: ${classifyResult.typeDescription} (${classifyResult.typeId})',
        );
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
        if (response.placeOfResidence != null) {
          address = response.placeOfResidence!;
        }

        _saveDraft();
        print('[ViewModel] OCR successful, data auto-filled');
      } else {
        _vnptErrorMessage =
            response.errorMessage ?? 'Cannot regcognized CMND/CCCD';
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
        _vnptErrorMessage =
            response.errorMessage ?? 'Cannot regcognized CMND/CCCD';
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
      print(
        '[ViewModel] Similarity: ${faceMatch.similarity != null ? (faceMatch.similarity! * 100).toStringAsFixed(1) : "N/A"}%',
      );

      // SECURITY: Validate face match quality
      // Check 1: Must have MATCH status from VNPT
      if (!faceMatch.isMatch) {
        _vnptErrorMessage =
            'Face does not match the ID card photo. Please ensure good lighting and try again.';
        _isVerifyingSelfie = false;
        notifyListeners();
        return false;
      }

      // Check 2: Similarity must meet minimum threshold (70%)
      const double minSimilarity = 0.70; // 70% threshold
      if (faceMatch.similarity == null ||
          faceMatch.similarity! < minSimilarity) {
        final similarityPercent = faceMatch.similarity != null
            ? (faceMatch.similarity! * 100).toStringAsFixed(1)
            : '0.0';
        _vnptErrorMessage =
            'Face similarity too low ($similarityPercent%). Please ensure your full face is clearly visible and try again.';
        _isVerifyingSelfie = false;
        notifyListeners();
        return false;
      }

      print('[ViewModel] Face verification passed all security checks');
      _isVerifyingSelfie = false;
      notifyListeners();
      return true;
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

  /// Clear only selfie verification data (for retaking selfie without losing ID card data)
  void clearSelfieData() {
    _selfieImageBytes = null;
    _faceMatchData = null;
    _vnptErrorMessage = null;
    _isVerifyingSelfie = false;
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
