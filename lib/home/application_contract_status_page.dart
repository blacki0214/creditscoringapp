import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_localization.dart';
import 'payment_page.dart';
import '../services/installment_service.dart';
import '../services/local_storage_service.dart';
import '../models/installment_model.dart';

class ApplicationContractStatusPage extends StatefulWidget {
  final Map<String, dynamic> application;

  const ApplicationContractStatusPage({super.key, required this.application});

  @override
  State<ApplicationContractStatusPage> createState() =>
      _ApplicationContractStatusPageState();
}

class _ApplicationContractStatusPageState
    extends State<ApplicationContractStatusPage> {
  static const bool _demoAllowOutOfWindowPayment = true;
  bool _paymentSuccessThisMonth = false;
  DateTime? _nextDueDateSynced;
  int _paidInstallmentCount = 0;
  final InstallmentService _installmentService = InstallmentService();
  StreamSubscription<List<Installment>>? _installmentsSubscription;
  late final bool _isTestAccountMode;

  @override
  void initState() {
    super.initState();
    _isTestAccountMode = LocalStorageService.isTestAccountMode();
    if (!_isTestAccountMode) {
      _syncNextDueDateWithPaymentPage();
      _startRealtimeDueDateSync();
    }
  }

  @override
  void dispose() {
    _installmentsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final compactScale = (screenWidth / 390).clamp(0.82, 1.0);

    final contractTitleSize = 24 * compactScale;
    final submittedAtValueSize = 26 * compactScale;
    final timelineTitleSize = 22 * compactScale;
    final scheduleTitleSize = 22 * compactScale;
    final totalCountSize = 30 * compactScale;
    final currentInstallmentSize = 26 * compactScale;

    final isVietnamese = context.isVietnamese;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final application = widget.application;
    final isApproved = application['approved'] == true;
    final submittedAtRaw =
        application['timestamp'] ?? application['submitted_at'];
    final submittedAt = submittedAtRaw != null
        ? DateTime.tryParse(submittedAtRaw.toString())
        : null;

    final tenorMonths = _asInt(application['loanTermMonths']);
    final monthlyPayment = _asDouble(application['monthlyPaymentVnd']);
    final interestRate = _asDouble(application['interestRate']);
    final loanAmount = _asDouble(application['loanAmount']);

    final firstDueDate = submittedAt != null
        ? _calculateShopeeFirstDueDate(submittedAt)
        : null;
    final firstWindowStart = firstDueDate != null
        ? _getPaymentWindowStart(firstDueDate)
        : null;
    final nextDueDate = _nextDueDateSynced ?? firstDueDate;
    final nextWindowStart = nextDueDate != null
        ? _getPaymentWindowStart(nextDueDate)
        : null;
    final finalDueDate = (firstDueDate != null && tenorMonths != null)
        ? _addMonthsSafe(firstDueDate, (tenorMonths - 1).clamp(0, 600))
        : null;
    final canPayNow = _isTestAccountMode ? true : _canPayOnDate(nextDueDate);
    final canProceedToPayment = canPayNow || _demoAllowOutOfWindowPayment;
    final paymentWindowStart = nextDueDate != null
        ? _getPaymentWindowStart(nextDueDate)
        : null;

    final statusText = isApproved
        ? context.t('Active', 'Đang hiệu lực')
        : context.t('Rejected', 'Từ chối');

    final dateTimePattern = isVietnamese
        ? 'dd/MM/yyyy HH:mm'
        : 'dd/MM/yyyy HH:mm';
    final datePattern = isVietnamese ? 'dd/MM/yyyy' : 'dd/MM/yyyy';
    final naText = context.t('N/A', 'Không có');
    final totalInstallments = tenorMonths ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F5FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3C54F8)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.t('SwinCredit', 'SwinCredit'),
          style: const TextStyle(
            color: Color(0xFF3C54F8),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t('CONTRACT DETAILS', 'THÔNG TIN HỢP ĐỒNG'),
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A8F9C),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.t('Contract Status', 'Trạng thái HĐ'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: contractTitleSize,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF171A22),
                        height: 1.02,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isApproved
                          ? const Color(0xFF68E4A7)
                          : const Color(0xFFFCA5A5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isApproved ? Icons.circle : Icons.cancel,
                          size: isApproved ? 10 : 14,
                          color: const Color(0xFF0E5132),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0E5132),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEFF4),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('Submitted At', 'Ngày nộp hồ sơ'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6D727D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      submittedAt != null
                          ? DateFormat(dateTimePattern).format(submittedAt)
                          : naText,
                      style: TextStyle(
                        fontSize: submittedAtValueSize,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF151922),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.02,
                children: [
                  _buildMetricTile(
                    label: context.t('LOAN AMOUNT', 'SỐ TIỀN VAY'),
                    value: loanAmount != null
                        ? currencyFormat.format(loanAmount)
                        : naText,
                  ),
                  _buildMetricTile(
                    label: context.t('INTEREST RATE', 'LÃI SUẤT'),
                    value: interestRate != null
                        ? context.t(
                            '${interestRate.toStringAsFixed(2)}% / year',
                            '${interestRate.toStringAsFixed(2)}% / năm',
                          )
                        : naText,
                    valueColor: const Color(0xFF3344F7),
                    highlightBorder: true,
                  ),
                  _buildMetricTile(
                    label: context.t('TENOR', 'KỲ HẠN'),
                    value: tenorMonths != null
                        ? context.t('$tenorMonths months', '$tenorMonths tháng')
                        : naText,
                  ),
                  _buildMetricTile(
                    label: context.t('MONTHLY PAYMENT', 'THANH TOÁN THÁNG'),
                    value: monthlyPayment != null
                        ? currencyFormat.format(monthlyPayment)
                        : naText,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  const Icon(
                    Icons.event_repeat,
                    color: Color(0xFF3E4BFF),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.t('Repayment Timeline', 'Lịch trả nợ'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: timelineTitleSize,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF151922),
                        height: 1.02,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTimelineItem(
                icon: Icons.check,
                filled: _paidInstallmentCount > 0,
                title: context.t('First Payment', 'Kỳ thanh toán đầu'),
                date: (firstWindowStart != null && firstDueDate != null)
                    ? _formatPaymentWindow(
                        startDate: firstWindowStart,
                        dueDate: firstDueDate,
                        isVietnamese: isVietnamese,
                      )
                    : naText,
                dimmed: false,
              ),
              _buildTimelineConnector(),
              _buildTimelineItem(
                icon: Icons.circle,
                filled: false,
                title: context.t('Next Due Date', 'Kỳ đến hạn tiếp theo'),
                date: (nextWindowStart != null && nextDueDate != null)
                    ? _formatPaymentWindow(
                        startDate: nextWindowStart,
                        dueDate: nextDueDate,
                        isVietnamese: isVietnamese,
                      )
                    : naText,
                trailingTag: _canPayOnDate(nextDueDate)
                    ? context.t('Due', 'Đến hạn')
                    : context.t('Upcoming', 'Sắp đến hạn'),
                dimmed: false,
              ),
              _buildTimelineConnector(),
              _buildTimelineItem(
                icon: Icons.circle,
                filled: false,
                title: context.t('Final Payment', 'Kỳ thanh toán cuối'),
                date: finalDueDate != null
                    ? DateFormat('MMMM d, yyyy').format(finalDueDate)
                    : naText,
                dimmed: true,
              ),

              if (isApproved &&
                  tenorMonths != null &&
                  monthlyPayment != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.t(
                                    'Installment Schedule',
                                    'Lịch trả góp',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: scheduleTitleSize,
                                    fontWeight: FontWeight.w800,
                                    height: 1.05,
                                    color: Color(0xFF151922),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _paymentSuccessThisMonth
                                      ? context.t(
                                          'Status: Payment received',
                                          'Trạng thái: Đã thanh toán kỳ này',
                                        )
                                      : context.t(
                                          'Status: On Track',
                                          'Trạng thái: Đúng hạn',
                                        ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF666C78),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                context.t('TOTAL', 'TỔNG'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF8A8F9C),
                                ),
                              ),
                              Text(
                                totalInstallments.toString(),
                                style: TextStyle(
                                  fontSize: totalCountSize,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF151922),
                                ),
                              ),
                              Text(
                                context.t('pmts', 'kỳ'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF666C78),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEFF4),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.t(
                                      'CURRENT INSTALLMENT',
                                      'KỲ THANH TOÁN HIỆN TẠI',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      letterSpacing: 1.4,
                                      color: Color(0xFF858B99),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currencyFormat.format(monthlyPayment),
                                    style: TextStyle(
                                      fontSize: currentInstallmentSize,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF151922),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3D4AF5),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (!_isTestAccountMode &&
                          !canPayNow &&
                          paymentWindowStart != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            nextDueDate != null
                                ? context.t(
                                    'Payment window: ${DateFormat(datePattern).format(paymentWindowStart)} - ${DateFormat(datePattern).format(nextDueDate)}',
                                    'Kỳ thanh toán: ${DateFormat(datePattern).format(paymentWindowStart)} - ${DateFormat(datePattern).format(nextDueDate)}',
                                  )
                                : context.t(
                                    'Payment window opens on ${DateFormat(datePattern).format(paymentWindowStart)}',
                                    'Kỳ thanh toán mở từ ${DateFormat(datePattern).format(paymentWindowStart)}',
                                  ),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF4D4AF9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: canProceedToPayment
                              ? () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PaymentPage(
                                        application: widget.application,
                                      ),
                                    ),
                                  );

                                  if (result is Map &&
                                      result['paymentSuccess'] == true &&
                                      mounted) {
                                    setState(() {
                                      _paymentSuccessThisMonth = true;
                                    });
                                    if (!_isTestAccountMode) {
                                      await _syncNextDueDateWithPaymentPage();
                                    }
                                  }
                                }
                              : null,
                          child: Text(
                            context.t('PAY NOW', 'THANH TOÁN NGAY'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (!canPayNow && _demoAllowOutOfWindowPayment)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            context.t(
                              'Demo mode: you can proceed before the payment window opens.',
                              'Chế độ demo: bạn vẫn có thể tiếp tục trước khi đến kỳ thanh toán.',
                            ),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    Color valueColor = const Color(0xFF151922),
    bool highlightBorder = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFF4),
        borderRadius: BorderRadius.circular(12),
        border: highlightBorder
            ? Border.all(color: const Color(0xFFC5CAF9), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1.0,
              color: Color(0xFF8A8F9C),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineConnector() {
    return Container(
      margin: const EdgeInsets.only(left: 15),
      width: 2,
      height: 22,
      color: const Color(0xFFD7DBE6),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required bool filled,
    required String title,
    required String date,
    String? trailingTag,
    bool dimmed = false,
  }) {
    final titleColor = dimmed
        ? const Color(0xFF8A8F9C)
        : const Color(0xFF151922);
    final dateColor = dimmed
        ? const Color(0xFF8A8F9C)
        : const Color(0xFF6B7280);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: filled ? const Color(0xFF3C4BFF) : const Color(0xFFF3F5FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: filled ? const Color(0xFF3C4BFF) : const Color(0xFF3C4BFF),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: filled ? Colors.white : const Color(0xFF3C4BFF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(date, style: TextStyle(fontSize: 13, color: dateColor)),
            ],
          ),
        ),
        if (trailingTag != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2E8D8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailingTag,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5E3D1B),
              ),
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

  DateTime _addMonthsSafe(DateTime base, int monthsToAdd) {
    final targetYear = base.year + ((base.month - 1 + monthsToAdd) ~/ 12);
    final targetMonth = ((base.month - 1 + monthsToAdd) % 12) + 1;
    final daysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    final safeDay = base.day > daysInTargetMonth ? daysInTargetMonth : base.day;

    return DateTime(
      targetYear,
      targetMonth,
      safeDay,
      base.hour,
      base.minute,
      base.second,
      base.millisecond,
      base.microsecond,
    );
  }

  DateTime? _getSubmissionDate(Map<String, dynamic> application) {
    final candidates = [
      application['acceptedAt'],
      application['timestamp'],
      application['submitted_at'],
      application['submittedAt'],
      application['createdAt'],
    ];

    for (final candidate in candidates) {
      final parsed = _parseDate(candidate);
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.tryParse(value.toString());
  }

  bool _canPayOnDate(DateTime? dueDate) {
    if (dueDate == null) return _isTestAccountMode;
    if (_isTestAccountMode) return true;
    final windowStart = _getPaymentWindowStart(dueDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !today.isBefore(windowStart);
  }

  DateTime _getPaymentWindowStart(DateTime dueDate) {
    final prevMonth = _addMonthsSafe(
      DateTime(dueDate.year, dueDate.month, 1),
      -1,
    );
    return DateTime(prevMonth.year, prevMonth.month, 24);
  }

  DateTime _calculateShopeeFirstDueDate(DateTime purchaseDate) {
    final normalized = DateTime(
      purchaseDate.year,
      purchaseDate.month,
      purchaseDate.day,
    );
    final monthsToAdd = normalized.day <= 23 ? 1 : 2;
    final shifted = _addMonthsSafe(normalized, monthsToAdd);
    return DateTime(shifted.year, shifted.month, 10);
  }

  String _formatPaymentWindow({
    required DateTime startDate,
    required DateTime dueDate,
    required bool isVietnamese,
  }) {
    final pattern = isVietnamese ? 'dd/MM/yyyy' : 'MMM d, yyyy';
    final formatter = DateFormat(pattern);
    return '${formatter.format(startDate)} - ${formatter.format(dueDate)}';
  }

  Future<void> _startRealtimeDueDateSync() async {
    final submittedAt = _getSubmissionDate(widget.application);
    if (submittedAt == null) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final offerId = await _resolveOfferId(userId);
    if (offerId == null ||
        offerId.isEmpty ||
        userId == null ||
        userId.isEmpty) {
      return;
    }

    await _installmentsSubscription?.cancel();
    _installmentsSubscription = _installmentService
        .getInstallmentsStream(userId: userId, loanOfferId: offerId)
        .listen((installments) {
          _updateDueDateFromInstallments(installments, submittedAt);
        });
  }

  void _updateDueDateFromInstallments(
    List<Installment> installments,
    DateTime submittedAt,
  ) {
    if (!mounted) return;

    final unpaid = installments.where((item) => !item.isPaid).toList();
    if (unpaid.isEmpty) {
      setState(() {
        _nextDueDateSynced = null;
        _paymentSuccessThisMonth = true;
        _paidInstallmentCount = installments.length;
      });
      return;
    }

    final paidCount = installments.where((item) => item.isPaid).length;
    final dueDate = unpaid.first.dueDate;

    setState(() {
      _nextDueDateSynced = dueDate;
      _paymentSuccessThisMonth = false;
      _paidInstallmentCount = paidCount;
    });
  }

  int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _asNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Future<void> _syncNextDueDateWithPaymentPage() async {
    final submittedAt = _getSubmissionDate(widget.application);
    if (submittedAt == null) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final offerId = await _resolveOfferId(userId);

    if (offerId == null ||
        offerId.isEmpty ||
        userId == null ||
        userId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _nextDueDateSynced = _calculateShopeeFirstDueDate(submittedAt);
      });
      return;
    }

    try {
      final installments = await _installmentService.getInstallmentsForLoan(
        userId: userId,
        loanOfferId: offerId,
      );

      final unpaid = installments.where((item) => !item.isPaid).toList();
      if (unpaid.isEmpty) {
        if (!mounted) return;
        setState(() {
          _nextDueDateSynced = null;
          _paidInstallmentCount = installments.length;
        });
        return;
      }

      final paidCount = installments.where((item) => item.isPaid).length;
      final dueDate = unpaid.first.dueDate;

      if (!mounted) return;
      setState(() {
        _nextDueDateSynced = dueDate;
        _paidInstallmentCount = paidCount;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _nextDueDateSynced = _calculateShopeeFirstDueDate(submittedAt);
      });
    }
  }

  Future<String?> _resolveOfferId(String? userId) async {
    final offerIdRaw =
        widget.application['offerId'] ?? widget.application['loanOfferId'];
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

      final appLoanAmount = _asNullableDouble(
        widget.application['loanAmount'] ?? widget.application['loanAmountVnd'],
      );
      final appTenorMonths = _asNullableInt(
        widget.application['loanTermMonths'],
      );
      final appMonthlyPayment = _asNullableDouble(
        widget.application['monthlyPayment'] ??
            widget.application['monthlyPaymentVnd'],
      );

      QueryDocumentSnapshot<Map<String, dynamic>>? bestDoc;
      int bestScore = -1;

      for (final doc in query.docs) {
        final data = doc.data();
        int score = 0;

        final offerLoanAmount = _asNullableDouble(data['loanAmountVnd']);
        final offerTenorMonths = _asNullableInt(data['loanTermMonths']);
        final offerMonthlyPayment = _asNullableDouble(
          data['monthlyPaymentVnd'],
        );

        if (appLoanAmount != null && offerLoanAmount != null) {
          if ((appLoanAmount - offerLoanAmount).abs() < 1) score += 2;
        }
        if (appTenorMonths != null &&
            offerTenorMonths != null &&
            appTenorMonths == offerTenorMonths) {
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
}
