import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../models/installment_model.dart';
import 'firebase_service.dart';

class InstallmentService {
  final FirebaseService _firebase = FirebaseService();

  /// Generate installments for an accepted loan offer
  /// Called when user accepts the loan in Step 6
  Future<List<String>> generateInstallmentsForLoan({
    required String userId,
    required String loanOfferId,
    required double loanAmountVnd,
    required double interestRate, // annual percentage
    required int loanTermMonths,
    required double monthlyPaymentVnd,
    required double totalInterestVnd,
    required DateTime firstDueDate,
  }) async {
    try {
      final List<String> installmentIds = [];
      final batch = _firebase.firestore.batch();

      // Calculate principal and interest components per month
      final totalPrincipal = loanAmountVnd;
      final principalPerMonth = totalPrincipal / loanTermMonths;
      final interestPerMonth = totalInterestVnd / loanTermMonths;

      // Generate each installment
      for (int i = 1; i <= loanTermMonths; i++) {
        final dueDate = _addMonthsSafe(firstDueDate, i - 1);

        final installment = Installment(
          id: '', // Will be set by Firestore
          loanOfferId: loanOfferId,
          installmentNumber: i,
          dueDate: dueDate,
          amountVnd: monthlyPaymentVnd,
          principalVnd: principalPerMonth,
          interestVnd: interestPerMonth,
          status: _calculateInitialStatus(dueDate),
          paidAt: null,
          lateDays: 0,
          createdAt: DateTime.now(),
          updatedAt: null,
        );

        final docRef = _firebase.firestore
          .collection('loan_offers')
            .doc(loanOfferId)
            .collection('installments')
            .doc();

        batch.set(docRef, {
          ...installment.toFirestore(),
          'id': docRef.id,
        });

        installmentIds.add(docRef.id);
      }

      await batch.commit();
      print('[InstallmentService] Generated $loanTermMonths installments for loan $loanOfferId');
      return installmentIds;
    } catch (e) {
      print('[InstallmentService] Error generating installments: $e');
      throw Exception('Failed to generate installments: $e');
    }
  }

  /// Get all installments for a specific loan
  Future<List<Installment>> getInstallmentsForLoan({
    required String userId,
    required String loanOfferId,
  }) async {
    try {
      final snapshot = await _firebase.firestore
          .collection('loan_offers')
          .doc(loanOfferId)
          .collection('installments')
          .orderBy('installmentNumber')
          .get();

      return snapshot.docs
          .map((doc) => Installment.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('[InstallmentService] Error fetching installments: $e');
      return [];
    }
  }

  /// Get installments stream (real-time updates)
  Stream<List<Installment>> getInstallmentsStream({
    required String userId,
    required String loanOfferId,
  }) {
    return _firebase.firestore
      .collection('loan_offers')
        .doc(loanOfferId)
        .collection('installments')
        .orderBy('installmentNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Installment.fromFirestore(doc))
            .toList());
  }

  /// Mark an installment as paid
  Future<void> markInstallmentAsPaid({
    required String userId,
    required String loanOfferId,
    required String installmentId,
    bool bypassDueDateCheck = false,
  }) async {
    try {
      final installmentRef = _firebase.firestore
          .collection('loan_offers')
          .doc(loanOfferId)
          .collection('installments')
          .doc(installmentId);

      await _firebase.firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(installmentRef);
        if (!snapshot.exists || snapshot.data() == null) {
          throw Exception('Installment not found');
        }

        final data = snapshot.data()!;
        final status = (data['status'] as String? ?? '').toLowerCase();
        if (status == 'paid') {
          return;
        }

        final dueTimestamp = data['dueDate'] as Timestamp?;
        if (dueTimestamp == null) {
          throw Exception('Installment due date is missing');
        }

        final dueDate = dueTimestamp.toDate();
        final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        if (!bypassDueDateCheck && dueDateOnly.isAfter(today)) {
          throw Exception('Installment is not due yet');
        }

        transaction.update(installmentRef, {
          'status': 'paid',
          'paidAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      print('[InstallmentService] Marked installment $installmentId as paid');
    } catch (e) {
      print('[InstallmentService] Error marking installment as paid: $e');
      rethrow;
    }
  }

  /// Update installment status (for scheduled status updates)
  Future<void> updateInstallmentStatus({
    required String userId,
    required String loanOfferId,
    required String installmentId,
    required String newStatus,
    int? lateDays,
  }) async {
    try {
      final updates = {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (lateDays != null) {
        updates['lateDays'] = lateDays;
      }

      await _firebase.firestore
          .collection('loan_offers')
          .doc(loanOfferId)
          .collection('installments')
          .doc(installmentId)
          .update(updates);

      print('[InstallmentService] Updated installment $installmentId status to $newStatus');
    } catch (e) {
      print('[InstallmentService] Error updating installment status: $e');
      rethrow;
    }
  }

  /// Get payment summary for a user's all loans
  Future<Map<String, dynamic>> getPaymentSummary(String userId) async {
    try {
      final offers = await _firebase.firestore
          .collection('loan_offers')
          .where('userId', isEqualTo: userId)
          .where('accepted', isEqualTo: true)
          .get();

      int totalInstallments = 0;
      int paidInstallments = 0;
      int overdueInstallments = 0;
      int upcomingInstallments = 0;
      double totalAmountVnd = 0;
      double paidAmountVnd = 0;
      double overdueAmountVnd = 0;

      for (var offerDoc in offers.docs) {
        final installments = await getInstallmentsForLoan(
          userId: userId,
          loanOfferId: offerDoc.id,
        );

        for (var installment in installments) {
          totalInstallments++;
          totalAmountVnd += installment.amountVnd;

          if (installment.isPaid) {
            paidInstallments++;
            paidAmountVnd += installment.amountVnd;
          } else if (installment.isLate) {
            overdueInstallments++;
            overdueAmountVnd += installment.amountVnd;
          } else {
            upcomingInstallments++;
          }
        }
      }

      return {
        'totalInstallments': totalInstallments,
        'paidInstallments': paidInstallments,
        'overdueInstallments': overdueInstallments,
        'upcomingInstallments': upcomingInstallments,
        'totalAmountVnd': totalAmountVnd,
        'paidAmountVnd': paidAmountVnd,
        'overdueAmountVnd': overdueAmountVnd,
        'paymentProgress': totalInstallments > 0 ? paidInstallments / totalInstallments : 0.0,
      };
    } catch (e) {
      print('[InstallmentService] Error getting payment summary: $e');
      return {
        'totalInstallments': 0,
        'paidInstallments': 0,
        'overdueInstallments': 0,
        'upcomingInstallments': 0,
        'totalAmountVnd': 0.0,
        'paidAmountVnd': 0.0,
        'overdueAmountVnd': 0.0,
        'paymentProgress': 0.0,
      };
    }
  }

  /// Calculate initial status based on due date
  String _calculateInitialStatus(DateTime dueDate) {
    final now = DateTime.now();
    final daysUntilDue = dueDate.difference(now).inDays;

    if (daysUntilDue < 0) {
      return 'overdue';
    } else if (daysUntilDue == 0) {
      return 'due';
    } else {
      return 'incoming';
    }
  }

  DateTime _addMonthsSafe(DateTime date, int monthsToAdd) {
    final totalMonths = (date.month - 1) + monthsToAdd;
    final year = date.year + (totalMonths ~/ 12);
    final month = (totalMonths % 12) + 1;
    final day = math.min(date.day, _daysInMonth(year, month));

    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
