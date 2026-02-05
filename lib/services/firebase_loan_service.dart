import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'api_service.dart';
import 'notification_service.dart';

class FirebaseLoanService {
  final FirebaseService _firebase = FirebaseService();
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  // Submit loan application using two-step API flow
  Future<Map<String, dynamic>> submitLoanApplication({
    required String userId,
    required SimpleLoanRequest loanRequest,
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

      final limitResponse = await _apiService.calculateLimit(limitRequest);

      // If not approved, return early
      if (!limitResponse.approved) {
        // Create application document for rejected application
        final applicationRef = await _firebase.creditApplicationsCollection.add({
          'userId': userId,
          'status': 'rejected',
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
          
          // Result data
          'creditScore': limitResponse.creditScore,
          'riskLevel': limitResponse.riskLevel,
          'approved': false,
          'loanLimitVnd': limitResponse.loanLimitVnd,
        });

        // Create rejected offer document
        final offerRef = await _firebase.loanOffersCollection.add({
          'userId': userId,
          'applicationId': applicationRef.id,
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
        });

        // Create notification for rejected loan
        await _notificationService.createLoanNotification(
          userId: userId,
          applicationId: applicationRef.id,
          approved: false,
          creditScore: limitResponse.creditScore,
          loanAmount: limitResponse.loanLimitVnd,
        );

        return {
          'applicationId': applicationRef.id,
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

      final termsResponse = await _apiService.calculateTerms(termsRequest);

      // Create application document
      final applicationRef = await _firebase.creditApplicationsCollection.add({
        'userId': userId,
        'status': 'approved',
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
        
        // Result data
        'creditScore': limitResponse.creditScore,
        'riskLevel': limitResponse.riskLevel,
        'approved': true,
        'loanLimitVnd': limitResponse.loanLimitVnd,
      });

      // Create loan offer document
      final offerRef = await _firebase.loanOffersCollection.add({
        'userId': userId,
        'applicationId': applicationRef.id,
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
      });

      // Add to application history
      await _firebase.applicationHistoryCollection.add({
        'userId': userId,
        'applicationId': applicationRef.id,
        'action': 'created',
        'timestamp': FieldValue.serverTimestamp(),
        'details': {
          'creditScore': limitResponse.creditScore,
          'approved': true,
          'loanLimitVnd': limitResponse.loanLimitVnd,
        },
        'performedBy': userId,
      });

      // Create notification for approved loan
      await _notificationService.createLoanNotification(
        userId: userId,
        applicationId: applicationRef.id,
        approved: true,
        creditScore: limitResponse.creditScore,
        loanAmount: limitResponse.loanLimitVnd,
      );

      return {
        'applicationId': applicationRef.id,
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
}
