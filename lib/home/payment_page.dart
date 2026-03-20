import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/installment_service.dart';
import '../utils/app_localization.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> application;

  const PaymentPage({
    super.key,
    required this.application,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const List<String> _paymentMethodKeys = <String>[
    'bank_transfer',
    'e_wallet',
    'credit_debit_card',
    'cash_at_branch',
  ];

  String _selectedMethod = _paymentMethodKeys.first;
  final InstallmentService _installmentService = InstallmentService();
  late final Future<_PaymentSummary> _paymentSummaryFuture;

  @override
  void initState() {
    super.initState();
    _paymentSummaryFuture = _buildPaymentSummary();
  }

  @override
  Widget build(BuildContext context) {
    final title = context.t('Payment Page', 'Trang thanh toán');
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: ' VND');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<_PaymentSummary>(
                future: _paymentSummaryFuture,
                builder: (context, snapshot) {
                  final summary = snapshot.data;

                  if (snapshot.connectionState == ConnectionState.waiting && summary == null) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE3E8F4)),
                      ),
                      child: const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  final amountDue = summary?.amountDue;
                  final dueDate = summary?.dueDate;
                  final remainingAfterPayment = summary?.remainingAfterPayment;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE3E8F4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryRow(
                          context.t('Amount Due', 'Số tiền đến hạn'),
                          amountDue != null ? currencyFormat.format(amountDue) : '-',
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          context.t('Due Date', 'Ngày đến hạn'),
                          dueDate != null ? DateFormat('dd/MM/yyyy').format(dueDate) : '-',
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          context.t(
                            'Remaining After This Payment',
                            'Số tiền còn lại sau lần thanh toán này',
                          ),
                          remainingAfterPayment != null
                              ? currencyFormat.format(remainingAfterPayment)
                              : '-',
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                context.t(
                  'Select a payment method',
                  'Chọn phương thức thanh toán',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(height: 12),
              ..._paymentMethodKeys.map((method) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE3E8F4)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: RadioListTile<String>(
                    value: method,
                    groupValue: _selectedMethod,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedMethod = value;
                      });
                    },
                    activeColor: const Color(0xFF4C40F7),
                    title: Text(
                      _localizedMethod(method, context),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1F3F),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C40F7),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.t(
                            'Payment method selected: ${_localizedMethod(_selectedMethod, context)}',
                            'Đã chọn phương thức thanh toán: ${_localizedMethod(_selectedMethod, context)}',
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    context.t('Continue', 'Tiếp tục'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF667085),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1A1F3F),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  DateTime? _getNextDueDateFromSubmission(Map<String, dynamic> application) {
    final submittedAt = _getSubmissionDate(application);
    if (submittedAt == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var nextDueDate = _addMonthsSafe(
      DateTime(submittedAt.year, submittedAt.month, submittedAt.day),
      1,
    );

    while (nextDueDate.isBefore(today)) {
      nextDueDate = _addMonthsSafe(nextDueDate, 1);
    }

    return nextDueDate;
  }

  DateTime? _getSubmissionDate(Map<String, dynamic> application) {
    final candidates = [
      application['submitted_at'],
      application['submittedAt'],
      application['timestamp'],
    ];

    for (final candidate in candidates) {
      if (candidate == null) continue;
      final parsed = DateTime.tryParse(candidate.toString());
      if (parsed != null) return parsed;
    }

    return null;
  }

  DateTime _addMonthsSafe(DateTime date, int monthsToAdd) {
    final totalMonths = (date.month - 1) + monthsToAdd;
    final year = date.year + (totalMonths ~/ 12);
    final month = (totalMonths % 12) + 1;
    final day = date.day <= _daysInMonth(year, month)
        ? date.day
        : _daysInMonth(year, month);

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

  Future<_PaymentSummary> _buildPaymentSummary() async {
    final fallback = _buildEstimatedSummary();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final offerId = await _resolveOfferId(userId);

    if (offerId == null || offerId.isEmpty || userId == null || userId.isEmpty) {
      return fallback;
    }

    try {
      final installments = await _installmentService.getInstallmentsForLoan(
        userId: userId,
        loanOfferId: offerId,
      );

      if (installments.isEmpty) {
        return fallback;
      }

      final loanAmount = await _resolveLoanAmount(offerId);
      final unpaid = installments.where((item) => !item.isPaid).toList();
      if (unpaid.isEmpty) {
        return _PaymentSummary(
          amountDue: 0,
          dueDate: null,
          remainingAfterPayment: 0,
        );
      }

      final amountDue = unpaid.first.amountVnd;
      final paidInstallmentsCount = installments.where((item) => item.isPaid).length;
      final paidAmountAfterCurrent = (paidInstallmentsCount + 1) * amountDue;
      final remainingAfterPayment = loanAmount != null
          ? (loanAmount - paidAmountAfterCurrent).clamp(0, double.infinity).toDouble()
          : null;
      final submittedAt = _getSubmissionDate(widget.application);
      final dueDate = submittedAt != null
          ? _addMonthsSafe(
              DateTime(submittedAt.year, submittedAt.month, submittedAt.day),
              paidInstallmentsCount + 1,
            )
          : unpaid.first.dueDate;

      return _PaymentSummary(
        amountDue: amountDue,
        dueDate: dueDate,
        remainingAfterPayment: remainingAfterPayment,
      );
    } catch (_) {
      return fallback;
    }
  }

  Future<String?> _resolveOfferId(String? userId) async {
    final offerIdRaw = widget.application['offerId'] ?? widget.application['loanOfferId'];
    final directOfferId = offerIdRaw?.toString();
    if (directOfferId != null && directOfferId.isNotEmpty) {
      return directOfferId;
    }

    if (userId == null || userId.isEmpty) return null;

    try {
      final query = await FirebaseFirestore.instance
          .collection('loan_offers')
          .where('userId', isEqualTo: userId)
          .where('accepted', isEqualTo: true)
          .get();

      if (query.docs.isEmpty) return null;

      final appLoanAmount = _asDouble(
        widget.application['loanAmount'] ?? widget.application['loanAmountVnd'],
      );
      final appTenorMonths = _asInt(widget.application['loanTermMonths']);
      final appMonthlyPayment = _asDouble(
        widget.application['monthlyPayment'] ?? widget.application['monthlyPaymentVnd'],
      );

      QueryDocumentSnapshot<Map<String, dynamic>>? bestDoc;
      int bestScore = -1;

      for (final doc in query.docs) {
        final data = doc.data();
        int score = 0;

        final offerLoanAmount = _asDouble(data['loanAmountVnd']);
        final offerTenorMonths = _asInt(data['loanTermMonths']);
        final offerMonthlyPayment = _asDouble(data['monthlyPaymentVnd']);

        if (appLoanAmount != null && offerLoanAmount != null) {
          if ((appLoanAmount - offerLoanAmount).abs() < 1) score += 2;
        }
        if (appTenorMonths != null && offerTenorMonths != null && appTenorMonths == offerTenorMonths) {
          score += 2;
        }
        if (appMonthlyPayment != null && offerMonthlyPayment != null) {
          if ((appMonthlyPayment - offerMonthlyPayment).abs() < 1) score += 2;
        }

        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt != null) score += 1;

        if (score > bestScore) {
          bestScore = score;
          bestDoc = doc;
        }
      }

      return bestDoc?.id;
    } catch (_) {
      return null;
    }
  }

  _PaymentSummary _buildEstimatedSummary() {
    final loanAmount = _asDouble(
      widget.application['loanAmount'] ?? widget.application['loanAmountVnd'],
    );
    final amountDue = _asDouble(
      widget.application['monthlyPayment'] ?? widget.application['monthlyPaymentVnd'],
    );
    final dueDate = _getNextDueDateFromSubmission(widget.application);

    final remainingAfterPayment = (loanAmount != null && amountDue != null)
        ? (loanAmount - amountDue).clamp(0, double.infinity).toDouble()
        : null;

    return _PaymentSummary(
      amountDue: amountDue,
      dueDate: dueDate,
      remainingAfterPayment: remainingAfterPayment,
    );
  }

  Future<double?> _resolveLoanAmount(String offerId) async {
    final appLoanAmount = _asDouble(
      widget.application['loanAmount'] ?? widget.application['loanAmountVnd'],
    );
    if (appLoanAmount != null) return appLoanAmount;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('loan_offers')
          .doc(offerId)
          .get();
      return _asDouble(doc.data()?['loanAmountVnd']);
    } catch (_) {
      return null;
    }
  }

  String _localizedMethod(String key, BuildContext context) {
    switch (key) {
      case 'bank_transfer':
        return context.t('Bank Transfer', 'Chuyển khoản ngân hàng');
      case 'e_wallet':
        return context.t('E-Wallet', 'Ví điện tử');
      case 'credit_debit_card':
        return context.t('Credit / Debit Card', 'Thẻ tín dụng / ghi nợ');
      case 'cash_at_branch':
        return context.t('Cash at Branch', 'Tiền mặt tại quầy');
      default:
        return key;
    }
  }
}

class _PaymentSummary {
  final double? amountDue;
  final DateTime? dueDate;
  final double? remainingAfterPayment;

  const _PaymentSummary({
    required this.amountDue,
    required this.dueDate,
    required this.remainingAfterPayment,
  });
}
