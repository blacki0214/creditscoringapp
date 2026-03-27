import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'api_service.dart';
import 'notification_service.dart';

class FirebaseLoanService {
  final FirebaseService _firebase = FirebaseService();
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  // Create pending application (for async processing)
  Future<String> createPendingApplication({
    required String userId,
    required SimpleLoanRequest loanRequest,
  }) async {
    try {
      final applicationRef = await _firebase.creditApplicationsCollection.add({
        'userId': userId,
        'status': 'processing',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        
        // Application data
        'fullName': loanRequest.fullName,
        'age': loanRequest.age,
        'monthlyIncome': loanRequest.monthlyIncome,
        'employmentStatus': loanRequest.employmentStatus,
        'yearsEmployed': loanRequest.yearsEmployed,
        'homeOwnership': loanRequest.homeOwnership,
        'loanPurpose': loanRequest.loanPurpose,
        'yearsCreditHistory': loanRequest.yearsCreditHistory,
        'hasPreviousDefaults': loanRequest.hasPreviousDefaults,
        'currentlyDefaulting': loanRequest.currentlyDefaulting,
      });

      return applicationRef.id;
    } catch (e) {
      throw Exception('Failed to create pending application: $e');
    }
  }

  // Submit loan application using two-step API flow
  Future<Map<String, dynamic>> submitLoanApplication({
    required String userId,
    required SimpleLoanRequest loanRequest,
    String? pendingApplicationId,
  }) async {
    try {
      // Step 1: Calculate credit score and loan limit
      final limitRequest = CalculateLimitRequest(
        fullName: loanRequest.fullName,
        age: loanRequest.age,
        monthlyIncome: loanRequest.monthlyIncome,
        employmentStatus: loanRequest.employmentStatus,
        yearsEmployed: loanRequest.yearsEmployed,
        homeOwnership: loanRequest.homeOwnership,
        loanPurpose: loanRequest.loanPurpose,
        yearsCreditHistory: loanRequest.yearsCreditHistory,
        hasPreviousDefaults: loanRequest.hasPreviousDefaults,
        currentlyDefaulting: loanRequest.currentlyDefaulting,
      );

      print('[FirebaseLoanService] Calling API Step 1: /calculate-limit...');
      final limitResponse = await _apiService.calculateLimit(limitRequest);
      print('[FirebaseLoanService] Step 1 completed. Score: ${limitResponse.creditScore}, Approved: ${limitResponse.approved}');

      // If not approved, return early
      if (!limitResponse.approved) {
        final applicationId = pendingApplicationId ??
            await createPendingApplication(userId: userId, loanRequest: loanRequest);

        await _firebase.creditApplicationsCollection.doc(applicationId).set({
          'userId': userId,
          'status': 'rejected',
          'updatedAt': FieldValue.serverTimestamp(),

          // Application data
          'fullName': loanRequest.fullName,
          'age': loanRequest.age,
          'monthlyIncome': loanRequest.monthlyIncome,
          'employmentStatus': loanRequest.employmentStatus,
          'yearsEmployed': loanRequest.yearsEmployed,
          'homeOwnership': loanRequest.homeOwnership,
          'loanPurpose': loanRequest.loanPurpose,
          'yearsCreditHistory': loanRequest.yearsCreditHistory,
          'hasPreviousDefaults': loanRequest.hasPreviousDefaults,
          'currentlyDefaulting': loanRequest.currentlyDefaulting,

          // Result data
          'creditScore': limitResponse.creditScore,
          'riskLevel': limitResponse.riskLevel,
          'approved': false,
          'loanLimitVnd': limitResponse.loanLimitVnd,

          // Flow state
          'step2Completed': true,
          'step3Completed': false,
          'step4Completed': false,
          'step5Completed': false,
          'step6Completed': false,
        }, SetOptions(merge: true));

        // Create rejected offer document
        final offerRef = await _firebase.loanOffersCollection.add({
          'userId': userId,
          'applicationId': applicationId,
          'createdAt': FieldValue.serverTimestamp(),
          'expiresAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 30)),
          ),
          
          'approved': false,
          'loanAmountVnd': 0,
          'maxAmountVnd': limitResponse.loanLimitVnd,
          'creditScore': limitResponse.creditScore,
          'riskLevel': limitResponse.riskLevel,
          'approvalMessage': limitResponse.message,
          'accepted': false,
          'step4Completed': false,
          'step5Completed': false,
          'step6Completed': false,
        });

        await _firebase.loanOffersCollection.doc(offerRef.id).set({
          'contractId': offerRef.id,
        }, SetOptions(merge: true));

        await _firebase.creditApplicationsCollection.doc(applicationId).set({
          'offerId': offerRef.id,
          'contractId': offerRef.id,
        }, SetOptions(merge: true));

        // Create notification for rejected loan
        await _notificationService.createLoanNotification(
          userId: userId,
          applicationId: applicationId,
          approved: false,
          creditScore: limitResponse.creditScore,
          loanAmount: limitResponse.loanLimitVnd,
        );

        return {
          'applicationId': applicationId,
          'offerId': offerRef.id,
          'limitResponse': limitResponse,
          'termsResponse': null,
        };
      }

      // Step 2: Calculate loan terms for approved applications
      // Use the loan limit as the approved amount
      final termsRequest = CalculateTermsRequest(
        loanAmount: limitResponse.loanLimitVnd,
        loanPurpose: loanRequest.loanPurpose,
        creditScore: limitResponse.creditScore,
      );

      print('[FirebaseLoanService] Calling API Step 2: /calculate-terms...');
      final termsResponse = await _apiService.calculateTerms(termsRequest);
      print('[FirebaseLoanService] Step 2 completed. Interest rate: ${termsResponse.interestRate}%, Term: ${termsResponse.loanTermMonths} months');

      final applicationId = pendingApplicationId ??
          await createPendingApplication(userId: userId, loanRequest: loanRequest);

      print('[FirebaseLoanService] Updating application document: $applicationId');
      await _firebase.creditApplicationsCollection.doc(applicationId).set({
        'userId': userId,
        'status': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),

        // Application data
        'fullName': loanRequest.fullName,
        'age': loanRequest.age,
        'monthlyIncome': loanRequest.monthlyIncome,
        'employmentStatus': loanRequest.employmentStatus,
        'yearsEmployed': loanRequest.yearsEmployed,
        'homeOwnership': loanRequest.homeOwnership,
        'loanPurpose': loanRequest.loanPurpose,
        'yearsCreditHistory': loanRequest.yearsCreditHistory,
        'hasPreviousDefaults': loanRequest.hasPreviousDefaults,
        'currentlyDefaulting': loanRequest.currentlyDefaulting,

        // Result data
        'creditScore': limitResponse.creditScore,
        'riskLevel': limitResponse.riskLevel,
        'approved': true,
        'loanLimitVnd': limitResponse.loanLimitVnd,

        // Flow state
        'step2Completed': true,
        'step3Completed': false,
        'step4Completed': false,
        'step5Completed': false,
        'step6Completed': false,
      }, SetOptions(merge: true));
      print('[FirebaseLoanService] Application document updated: $applicationId');

      // Create loan offer document
      print('[FirebaseLoanService] Creating loan offer document...');
      final offerRef = await _firebase.loanOffersCollection.add({
        'userId': userId,
        'applicationId': applicationId,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 30)),
        ),
        
        // Offer details
        'approved': true,
        'loanAmountVnd': limitResponse.loanLimitVnd,
        'maxAmountVnd': limitResponse.loanLimitVnd,
        'interestRate': termsResponse.interestRate,
        'monthlyPaymentVnd': termsResponse.monthlyPaymentVnd,
        'loanTermMonths': termsResponse.loanTermMonths,
        'totalPaymentVnd': termsResponse.totalPaymentVnd,
        'totalInterestVnd': termsResponse.totalInterestVnd,
        'creditScore': limitResponse.creditScore,
        'riskLevel': limitResponse.riskLevel,
        'approvalMessage': limitResponse.message,
        
        // Acceptance status
        'accepted': false,
        'step4Completed': false,
        'step5Completed': false,
        'step6Completed': false,
      });
      print('[FirebaseLoanService] Loan offer document created: ${offerRef.id}');

      await _firebase.loanOffersCollection.doc(offerRef.id).set({
        'contractId': offerRef.id,
      }, SetOptions(merge: true));

      await _firebase.creditApplicationsCollection.doc(applicationId).set({
        'offerId': offerRef.id,
        'contractId': offerRef.id,
      }, SetOptions(merge: true));

      // Add to application history
      print('[FirebaseLoanService] Creating application history...');
      await _firebase.applicationHistoryCollection.add({
        'userId': userId,
        'applicationId': applicationId,
        'action': 'created',
        'timestamp': FieldValue.serverTimestamp(),
        'details': {
          'creditScore': limitResponse.creditScore,
          'approved': true,
          'loanLimitVnd': limitResponse.loanLimitVnd,
        },
        'performedBy': userId,
      });
      print('[FirebaseLoanService] Application history created');
      print('[FirebaseLoanService] All Firestore operations completed successfully!');

      // Create notification for approved loan
      await _notificationService.createLoanNotification(
        userId: userId,
        applicationId: applicationId,
        approved: true,
        creditScore: limitResponse.creditScore,
        loanAmount: limitResponse.loanLimitVnd,
      );

      return {
        'applicationId': applicationId,
        'offerId': offerRef.id,
        'limitResponse': limitResponse,
        'termsResponse': termsResponse,
      };
    } catch (e) {
      throw Exception('Failed to submit loan application: $e');
    }
  }

  // Get user's loan applications
  Future<List<Map<String, dynamic>>> getUserApplications(String userId) async {
    try {
      final querySnapshot = await _firebase.creditApplicationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user applications: $e');
    }
  }

  // Get user's loan applications stream
  Stream<QuerySnapshot> getUserApplicationsStream(String userId) {
    return _firebase.creditApplicationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get loan offer by application ID
  Future<Map<String, dynamic>?> getLoanOfferByApplicationId(
    String applicationId,
  ) async {
    try {
      final querySnapshot = await _firebase.loanOffersCollection
          .where('applicationId', isEqualTo: applicationId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        data['id'] = querySnapshot.docs.first.id;
        return data;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get loan offer: $e');
    }
  }

  // Accept loan offer
  Future<void> acceptLoanOffer(String offerId) async {
    try {
      await _firebase.loanOffersCollection.doc(offerId).update({
        'contractId': offerId,
        'accepted': true,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to accept loan offer: $e');
    }
  }

  // Get application history
  Future<List<Map<String, dynamic>>> getApplicationHistory(
    String applicationId,
  ) async {
    try {
      final querySnapshot = await _firebase.applicationHistoryCollection
          .where('applicationId', isEqualTo: applicationId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get application history: $e');
    }
  }

  Future<void> saveStep3AdditionalInfo({
    required String applicationId,
    required String userId,
    required Map<String, dynamic> step3Data,
  }) async {
    await _firebase.creditApplicationsCollection.doc(applicationId).set({
      'userId': userId,
      'step3Completed': true,
      'step3Data': step3Data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveStep4OfferSelection({
    required String applicationId,
    required String offerId,
    required String userId,
    required Map<String, dynamic> selection,
  }) async {
    await _firebase.loanOffersCollection.doc(offerId).set({
      'userId': userId,
      'applicationId': applicationId,
      ...selection,
      'step4Completed': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firebase.creditApplicationsCollection.doc(applicationId).set({
      'step4Completed': true,
      'loanPurpose': selection['loanPurpose'],
      'requestedLoanAmountVnd': selection['loanAmountVnd'],
      'requestedLoanTermMonths': selection['loanTermMonths'],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveStep5ContractSignature({
    required String applicationId,
    required String offerId,
    required String userId,
    required Map<String, dynamic> contractData,
  }) async {
    await _firebase.loanOffersCollection.doc(offerId).set({
      'userId': userId,
      'applicationId': applicationId,
      'accepted': true,
      'acceptedAt': FieldValue.serverTimestamp(),
      'step5Completed': true,
      'contract': contractData,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firebase.creditApplicationsCollection.doc(applicationId).set({
      'step5Completed': true,
      'contractSigned': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveStep6DisbursementInfo({
    required String applicationId,
    required String offerId,
    required String userId,
    required Map<String, dynamic> disbursementData,
  }) async {
    await _firebase.loanOffersCollection.doc(offerId).set({
      'userId': userId,
      'applicationId': applicationId,
      'step6Completed': true,
      'disbursement': disbursementData,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firebase.creditApplicationsCollection.doc(applicationId).set({
      'step6Completed': true,
      'status': 'completed',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getLatestApplication(String userId) async {
    try {
      final querySnapshot = await _firebase.creditApplicationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
    } catch (_) {
      // Fallback below.
    }

    try {
      final fallbackByCreatedAt = await _firebase.creditApplicationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (fallbackByCreatedAt.docs.isNotEmpty) {
        final doc = fallbackByCreatedAt.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
    } catch (_) {
      // Final fallback below.
    }

    final noOrderFallback = await _firebase.creditApplicationsCollection
        .where('userId', isEqualTo: userId)
        .limit(20)
        .get();

    if (noOrderFallback.docs.isEmpty) return null;

    final docs = noOrderFallback.docs.toList();
    docs.sort((a, b) {
      final aMap = a.data() as Map<String, dynamic>;
      final bMap = b.data() as Map<String, dynamic>;

      final aUpdated = aMap['updatedAt'];
      final bUpdated = bMap['updatedAt'];
      if (aUpdated is Timestamp && bUpdated is Timestamp) {
        return bUpdated.compareTo(aUpdated);
      }

      final aCreated = aMap['createdAt'];
      final bCreated = bMap['createdAt'];
      if (aCreated is Timestamp && bCreated is Timestamp) {
        return bCreated.compareTo(aCreated);
      }

      return b.id.compareTo(a.id);
    });

    final latest = docs.first;
    final latestData = latest.data() as Map<String, dynamic>;
    latestData['id'] = latest.id;
    return latestData;
  }

  Future<Map<String, dynamic>?> getLoanOfferById(String offerId) async {
    final doc = await _firebase.loanOffersCollection.doc(offerId).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return data;
  }
}
