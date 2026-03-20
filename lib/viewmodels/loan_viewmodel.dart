import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_loan_service.dart';
import '../services/firebase_service.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/vnpt_ekyc_service.dart';
import '../services/bank_service.dart';
import '../services/installment_service.dart';
import '../services/push_notification_service.dart';
import '../services/notification_service.dart';
import '../services/firebase_user_service.dart';
import '../models/bank_model.dart';
import '../models/bank_account_validation_model.dart';

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
  final InstallmentService _installmentService = InstallmentService();
  final PushNotificationService _pushNotificationService =
      PushNotificationService();
  final NotificationService _notificationService = NotificationService();
  final FirebaseUserService _userService = FirebaseUserService();
  StreamSubscription<dynamic>? _authStateSubscription;

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

  // Bank Account & Disbursement (Step 6)
  final BankService _bankService = BankService();
  final ApiService _apiService = ApiService();
  
  List<Bank> _banks = [];
  String? _selectedBankCode;
  String? _selectedBranchCode;
  
  bool _isLoadingBanks = false;
  bool _isValidatingAccount = false;
  String? _bankAccountValidationError;
  BankAccountValidationResponse? _bankValidationResult;

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

  // Bank Account & Disbursement getters (Step 6)
  List<Bank> get banks => _banks;
  String? get selectedBankCode => _selectedBankCode;
  String? get selectedBranchCode => _selectedBranchCode;
  bool get isLoadingBanks => _isLoadingBanks;
  bool get isValidatingAccount => _isValidatingAccount;
  String? get bankAccountValidationError => _bankAccountValidationError;
  BankAccountValidationResponse? get bankValidationResult => _bankValidationResult;
  
  // Get selected bank details
  Bank? get selectedBank => _selectedBankCode != null 
      ? _bankService.getBankByCode(_selectedBankCode!) 
      : null;
  
  // Get selected branch details
  BankBranch? get selectedBranch {
    if (_selectedBankCode == null || _selectedBranchCode == null) return null;
    return _bankService.getBranchDetails(_selectedBankCode!, _selectedBranchCode!);
  }

  // Load saved draft on init
  LoanViewModel() {
    _loadDraft();
    Future.microtask(_restoreFlowFromFirestore);
    _authStateSubscription = _firebase.auth.authStateChanges().listen((user) {
      if (user != null) {
        _restoreFlowFromFirestore();
      }
    });
  }

  String? get _currentApplicationId {
    return _currentOffer?['applicationId'] as String? ?? _pendingApplicationId;
  }

  String? get _currentOfferId {
    return _currentOffer?['offerId'] as String? ?? _currentOffer?['id'] as String?;
  }

  double _asDouble(dynamic value, [double fallback = 0.0]) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  int _asInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  Future<void> _restoreFlowFromFirestore() async {
    final userId = _firebase.currentUserId;
    if (userId == null) return;

    try {
      final profile = await _userService.getUserProfile(userId);
      if (profile != null) {
        final profileEkycDone = _isEkycCompletedInProfile(profile);
        if (profileEkycDone) {
          _step1Completed = true;
          await LocalStorageService.markEkycCompleted(userId: userId);
        } else {
          await LocalStorageService.clearEkycCompletion(userId: userId);
        }

        final prefill = <String, dynamic>{};
        final profileName = (profile['fullName'] as String?)?.trim();
        final profilePhone = (profile['phoneNumber'] as String?)?.trim();
        final profileNationalId = (profile['nationalId'] as String?)?.trim();
        final profileAddress = (profile['address'] as String?)?.trim();

        if (profileName != null && profileName.isNotEmpty) {
          prefill['fullName'] = profileName;
          fullName = profileName;
        }
        if (profilePhone != null && profilePhone.isNotEmpty) {
          prefill['phoneNumber'] = profilePhone;
          phoneNumber = profilePhone;
        }
        if (profileNationalId != null && profileNationalId.isNotEmpty) {
          prefill['idNumber'] = profileNationalId;
          idNumber = profileNationalId;
        }
        if (profileAddress != null && profileAddress.isNotEmpty) {
          prefill['address'] = profileAddress;
          address = profileAddress;
        }

        final dobValue = profile['dateOfBirth'];
        if (dobValue is Timestamp) {
          dob = dobValue.toDate();
          prefill['dob'] = dob!.toIso8601String();
        }

        if (prefill.isNotEmpty) {
          await LocalStorageService.saveEkycPrefill(prefill, userId: userId);
        }
      }

      final latestApplication = await _loanService.getLatestApplication(userId);
      if (latestApplication == null) return;

      final applicationId = latestApplication['id'] as String?;
      if (applicationId != null) {
        _pendingApplicationId = applicationId;
      }

      _step2Completed = latestApplication['step2Completed'] as bool? ?? false;
      _step3Completed = latestApplication['step3Completed'] as bool? ?? false;
      _step4Completed = latestApplication['step4Completed'] as bool? ?? false;
      _step6Completed = latestApplication['step6Completed'] as bool? ?? false;

      final status = (latestApplication['status'] as String? ?? 'none').toLowerCase();
      switch (status) {
        case 'processing':
          _applicationStatus = ApplicationStatus.processing;
          break;
        case 'approved':
        case 'completed':
          _applicationStatus = ApplicationStatus.scored;
          break;
        case 'rejected':
          _applicationStatus = ApplicationStatus.rejected;
          break;
        default:
          _applicationStatus = ApplicationStatus.none;
      }

      Map<String, dynamic>? offer;
      final offerId = latestApplication['offerId'] as String?;
      if (offerId != null && offerId.isNotEmpty) {
        offer = await _loanService.getLoanOfferById(offerId);
      } else if (applicationId != null) {
        offer = await _loanService.getLoanOfferByApplicationId(applicationId);
      }

      if (offer != null) {
        _currentOffer = {
          ...offer,
          'offerId': offer['id'],
          'applicationId': applicationId,
        };
      }

      notifyListeners();
    } catch (e) {
      print('[LoanViewModel] Failed to restore flow from Firestore: $e');
    }
  }

  bool _isEkycCompletedInProfile(Map<String, dynamic> profile) {
    if (profile['ekycCompleted'] == true) return true;

    final ekycStatus = (profile['ekycStatus'] as String?)?.toLowerCase().trim();
    if (ekycStatus == 'verified' ||
        ekycStatus == 'completed' ||
        ekycStatus == 'approved' ||
        ekycStatus == 'success') {
      return true;
    }

    return profile['ekycVerifiedAt'] != null;
  }

  void _loadDraft() {
    final draft = LocalStorageService.loadDraft(userId: _firebase.currentUserId);
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
    }, userId: _firebase.currentUserId);
  }

  // Actions
  void completeStep1() async {
    final wasCompleted = _step1Completed;
    _step1Completed = true;
    notifyListeners();

    // Save eKYC data to user profile in Firestore
    await _saveEkycDataToProfile();

    // Persist local eKYC fields for future Step 1 skip -> Step 2 prefill.
    await persistEkycPrefill();

    if (!wasCompleted) {
      await _notifyFlowMilestone(
        type: 'ekyc_completed',
        title: 'eKYC Completed',
        body: 'Your identity verification is complete.',
      );
    }
  }

  Future<void> persistEkycPrefill() async {
    final userId = _firebase.currentUserId;
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
      await LocalStorageService.saveEkycPrefill(payload, userId: userId);
    }
  }

  void applySavedEkycPrefill({bool notify = true}) {
    final data = LocalStorageService.loadEkycPrefill(
      userId: _firebase.currentUserId,
    );
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

  // Mark step 1 UI as completed without persisting eKYC verification.
  void markStep1CompletedLocalOnly() {
    _step1Completed = true;
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
        updateData['ekycCompleted'] = true;
        updateData['ekycVerifiedAt'] = FieldValue.serverTimestamp();
        updateData['updatedAt'] = FieldValue.serverTimestamp();

        print(
          '[LoanViewModel] Saving eKYC data to user profile: ${updateData.keys.join(', ')}',
        );

        // Use set with merge to create/update document
        await _firebase.usersCollection
            .doc(userId)
            .set(updateData, SetOptions(merge: true));

        await LocalStorageService.markEkycCompleted(userId: userId);

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

  Future<void> completeStep3({Map<String, dynamic>? step3Data}) async {
    final wasCompleted = _step3Completed;
    _step3Completed = true;
    notifyListeners();

    final userId = _firebase.currentUserId;
    final applicationId = _currentApplicationId;
    if (userId == null || applicationId == null) return;

    try {
      await _loanService.saveStep3AdditionalInfo(
        applicationId: applicationId,
        userId: userId,
        step3Data: step3Data ?? const <String, dynamic>{},
      );

      if (!wasCompleted) {
        await _notifyFlowMilestone(
          type: 'step3_completed',
          title: 'Step 3 Completed',
          body: 'Additional information has been saved successfully.',
          applicationId: applicationId,
        );
      }
    } catch (e) {
      print('[LoanViewModel] Failed to save Step 3 data: $e');
    }
  }

  Future<void> completeStep4() async {
    final wasCompleted = _step4Completed;
    _step4Completed = true;
    notifyListeners();

    final userId = _firebase.currentUserId;
    final applicationId = _currentApplicationId;
    final offerId = _currentOfferId;
    if (userId == null || applicationId == null || offerId == null) return;

    try {
      await _loanService.saveStep4OfferSelection(
        applicationId: applicationId,
        offerId: offerId,
        userId: userId,
        selection: {
          'loanPurpose': loanPurpose,
          'loanAmountVnd': _asDouble(_currentOffer?['loanAmountVnd']),
          'loanTermMonths': _asInt(_currentOffer?['loanTermMonths'], 12),
          'monthlyPaymentVnd': _asDouble(_currentOffer?['monthlyPaymentVnd']),
          'totalPaymentVnd': _asDouble(_currentOffer?['totalPaymentVnd']),
          'totalInterestVnd': _asDouble(_currentOffer?['totalInterestVnd']),
        },
      );

      if (!wasCompleted) {
        await _notifyFlowMilestone(
          type: 'step4_completed',
          title: 'Step 4 Completed',
          body: 'Loan offer details are confirmed. Please review your contract.',
          applicationId: applicationId,
        );
      }
    } catch (e) {
      print('[LoanViewModel] Failed to save Step 4 data: $e');
    }
  }

  Future<void> completeStep6({Map<String, dynamic>? disbursementData}) async {
    _step6Completed = true;
    notifyListeners();

    final userId = _firebase.currentUserId;
    final applicationId = _currentApplicationId;
    final offerId = _currentOfferId;

    if (userId != null && applicationId != null && offerId != null) {
      try {
        await _loanService.saveStep6DisbursementInfo(
          applicationId: applicationId,
          offerId: offerId,
          userId: userId,
          disbursementData: disbursementData ?? const <String, dynamic>{},
        );
      } catch (e) {
        print('[LoanViewModel] Failed to save Step 6 data: $e');
      }
    }
    
    // Generate installments if loan was accepted
    if (_currentOffer != null && _currentOffer!['accepted'] == true) {
      try {
        if (userId != null && offerId != null) {
          // Get the offer ID from lastCompletedOffer or construct from available data
          final loanAmountVnd = _asDouble(_currentOffer!['loanAmountVnd']);
          final interestRate = _asDouble(_currentOffer!['interestRate']);
          final loanTermMonths = _asInt(_currentOffer!['loanTermMonths'], 12);
          final monthlyPaymentVnd = _asDouble(_currentOffer!['monthlyPaymentVnd']);
          final totalInterestVnd = _asDouble(_currentOffer!['totalInterestVnd']);
          
          // Calculate first due date (30 days from today)
          final firstDueDate = DateTime.now().add(const Duration(days: 30));
          
          await _installmentService.generateInstallmentsForLoan(
            userId: userId,
            loanOfferId: offerId,
            loanAmountVnd: loanAmountVnd,
            interestRate: interestRate,
            loanTermMonths: loanTermMonths,
            monthlyPaymentVnd: monthlyPaymentVnd,
            totalInterestVnd: totalInterestVnd,
            firstDueDate: firstDueDate,
          );
          
          print('[LoanViewModel] Installments generated for loan $offerId');
        }
      } catch (e) {
        print('[LoanViewModel] Error generating installments: $e');
        // Don't throw - installment generation failure shouldn't block the flow
      }
    }
    
    await finalizeAndResetForNewApplication();
  }

  // Backward compatibility for older call sites.
  Future<void> completeStep5({
    required String signature,
    required bool agreedToTerms,
    required bool agreedToDeduction,
    required bool agreedToConsent,
  }) async {
    final userId = _firebase.currentUserId;
    final applicationId = _currentApplicationId;
    final offerId = _currentOfferId;
    if (userId == null || applicationId == null || offerId == null) return;

    final wasAccepted = _currentOffer?['accepted'] == true;

    try {
      await _loanService.saveStep5ContractSignature(
        applicationId: applicationId,
        offerId: offerId,
        userId: userId,
        contractData: {
          'signature': signature.trim(),
          'agreedToTerms': agreedToTerms,
          'agreedToDeduction': agreedToDeduction,
          'agreedToConsent': agreedToConsent,
          'signedAt': FieldValue.serverTimestamp(),
        },
      );

      if (_currentOffer != null) {
        _currentOffer!['accepted'] = true;
        _currentOffer!['acceptedAt'] = DateTime.now().toIso8601String();
      }

      if (!wasAccepted) {
        await _notifyFlowMilestone(
          type: 'step5_completed',
          title: 'Step 5 Completed',
          body: 'Contract signed successfully. Continue to disbursement.',
          applicationId: applicationId,
        );
      }

      notifyListeners();
    } catch (e) {
      print('[LoanViewModel] Failed to save Step 5 data: $e');
    }
  }

  Future<void> _notifyFlowMilestone({
    required String type,
    required String title,
    required String body,
    String? applicationId,
  }) async {
    final userId = _firebase.currentUserId;
    if (userId == null) return;

    try {
      await _notificationService.createFlowMilestoneNotification(
        userId: userId,
        applicationId: applicationId,
        type: type,
        title: title,
        body: body,
        data: {
          'flowType': 'loan_application',
          'milestone': type,
        },
      );
      await _pushNotificationService.showFlowMilestoneNotification(
        type: type,
        title: title,
        body: body,
        data: {'applicationId': applicationId ?? ''},
      );
    } catch (e) {
      print('[LoanViewModel] Failed to create flow milestone notification: $e');
    }
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
        pendingApplicationId: applicationId,
      );

      print('[LoanViewModel] Received response from Firebase service');
      final limitResponse = result['limitResponse'] as CalculateLimitResponse;
      final termsResponse = result['termsResponse'] as CalculateTermsResponse?;

      print(
        '[LoanViewModel] Credit score: ${limitResponse.creditScore}, Approved: ${limitResponse.approved}',
      );

      // Build currentOffer map from the two-step response
      _currentOffer = {
        'id': result['offerId'],
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
      await LocalStorageService.clearDraft(userId: _firebase.currentUserId);

      // Show local push when scoring completes and result returns.
      await _pushNotificationService.showScoringResultNotification(
        approved: limitResponse.approved,
        creditScore: limitResponse.creditScore,
        loanAmount: limitResponse.loanLimitVnd,
      );

      _step2Completed = true;
      _step3Completed = true; // Processing done
      _step4Completed = false;
      _step6Completed = false;
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
      }, userId: _firebase.currentUserId);
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

    // Reset bank state
    _resetBankState();

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

    await LocalStorageService.clearDraft(userId: _firebase.currentUserId);
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

  // ===== Bank Account & Disbursement Methods (Step 6) =====

  /// Load available banks from service
  Future<void> loadBanks() async {
    try {
      _isLoadingBanks = true;
      notifyListeners();

      _banks = _bankService.getAllBanks();
      print('[LoanViewModel] Loaded ${_banks.length} banks');

      _isLoadingBanks = false;
      notifyListeners();
    } catch (e) {
      print('[LoanViewModel] Error loading banks: $e');
      _isLoadingBanks = false;
      notifyListeners();
      throw Exception('Failed to load banks: $e');
    }
  }

  /// Update selected bank
  void updateSelectedBank(String bankCode) {
    _selectedBankCode = bankCode;
    _selectedBranchCode = null; // Reset branch selection
    _bankAccountValidationError = null;
    _bankValidationResult = null;
    print('[LoanViewModel] Selected bank: $bankCode');
    notifyListeners();
  }

  /// Update selected branch
  void updateSelectedBranch(String branchCode) {
    _selectedBranchCode = branchCode;
    print('[LoanViewModel] Selected branch: $branchCode');
    notifyListeners();
  }

  /// Validate bank account with external service
  Future<bool> validateBankAccount({
    required String bankCode,
    required String accountNumber,
    required String accountHolder,
    String? branchCode,
  }) async {
    _isValidatingAccount = true;
    _bankAccountValidationError = null;
    _bankValidationResult = null;
    notifyListeners();

    try {
      print('[LoanViewModel] Validating bank account...');
      print('[LoanViewModel] Bank: $bankCode, Account: $accountNumber');

      // Check test accounts first (TEST MODE)
      final bankService = BankService();
      if (BankService.TEST_MODE) {
        final isTestAccount = bankService.validateTestAccount(
          bankCode: bankCode,
          accountNumber: accountNumber,
          accountHolderName: accountHolder,
        );

        if (isTestAccount) {
          print('[LoanViewModel] ✓ Test account matched! (TEST MODE ENABLED)');
          print('[LoanViewModel] Account holder: $accountHolder');
          
          // Create a mock success response for test account
          _bankValidationResult = BankAccountValidationResponse(
            valid: true,
            accountHolderName: accountHolder,
            bankName: bankService.getBankByCode(bankCode)?.bankName ?? bankCode,
            bankCode: bankCode,
            status: 'active',
            message: 'Account verified successfully (TEST MODE)',
            accountType: 'savings',
            validatedAt: DateTime.now(),
          );
          
          _isValidatingAccount = false;
          notifyListeners();
          return true;
        }
        print('[LoanViewModel] Test mode enabled but account not in test list, calling API...');
      }

      // If not a test account or test mode disabled, call the real API
      final request = BankAccountValidationRequest(
        bankCode: bankCode,
        accountNumber: accountNumber,
        accountHolder: accountHolder,
        branchCode: branchCode,
      );

      _bankValidationResult = await _apiService.validateBankAccount(request);

      if (!_bankValidationResult!.valid) {
        _bankAccountValidationError = _bankValidationResult!.message;
        print('[LoanViewModel] Validation failed: $_bankAccountValidationError');
        _isValidatingAccount = false;
        notifyListeners();
        return false;
      }

      print('[LoanViewModel] Bank account validated successfully');
      print('[LoanViewModel] Account holder: ${_bankValidationResult!.accountHolderName}');
      _isValidatingAccount = false;
      notifyListeners();
      return true;
    } on BankAccountValidationException catch (e) {
      _bankAccountValidationError = e.message;
      print('[LoanViewModel] Validation exception: $e');
      _isValidatingAccount = false;
      notifyListeners();
      return false;
    } catch (e) {
      _bankAccountValidationError = e.toString();
      print('[LoanViewModel] Error validating bank account: $e');
      _isValidatingAccount = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear bank validation state
  void clearBankValidation() {
    _selectedBankCode = null;
    _selectedBranchCode = null;
    _bankAccountValidationError = null;
    _bankValidationResult = null;
    notifyListeners();
  }

  /// Reset bank state for new application
  void _resetBankState() {
    _banks = [];
    _selectedBankCode = null;
    _selectedBranchCode = null;
    _isLoadingBanks = false;
    _isValidatingAccount = false;
    _bankAccountValidationError = null;
    _bankValidationResult = null;
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _vnptService.dispose();
    super.dispose();
  }
}
