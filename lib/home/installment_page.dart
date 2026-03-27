import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodels/home_viewmodel.dart';
import '../services/local_storage_service.dart';
import '../services/installment_service.dart';
import '../utils/app_localization.dart';
import 'application_contract_status_page.dart';

class InstallmentPage extends StatefulWidget {
  const InstallmentPage({super.key});

  @override
  State<InstallmentPage> createState() => _InstallmentPageState();
}

class _InstallmentPageState extends State<InstallmentPage> {
  final InstallmentService _installmentService = InstallmentService();
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A57F8),
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.t('Installment', 'Lịch thanh toán'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildInstallmentContent(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallmentContent(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: ' VND',
    );

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final applicationHistory = LocalStorageService.getApplicationHistory(
      userId: userId,
    );
    final approvedApplications = applicationHistory
        .where((app) => app['approved'] == true)
        .toList();

    if (approvedApplications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                context.t('No Active Loans', 'Chưa có khoản vay hoạt động'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.t(
                  'Accepted loans will show payment schedule.',
                  'Các khoản vay được chấp nhận sẽ hiển thị lịch thanh toán.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate pagination
    final totalInstallments = approvedApplications.length;
    final totalPages = (totalInstallments / viewModel.installmentsPerPage)
        .ceil();
    final startIndex =
        (viewModel.currentInstallmentPage - 1) * viewModel.installmentsPerPage;
    final endIndex = (startIndex + viewModel.installmentsPerPage).clamp(
      0,
      totalInstallments,
    );
    final paginatedInstallments = approvedApplications.sublist(
      startIndex,
      endIndex,
    );

    final totalMonthlyDue = approvedApplications.fold<num>(0, (sum, app) {
      final amount = app['monthlyPayment'] ?? app['monthlyPaymentVnd'] ?? 0;
      if (amount is num) return sum + amount;
      return sum;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEEF0FF), Color(0xFFF8F9FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDDE1FF)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  context.t('Active Loans', 'Khoản vay hoạt động'),
                  '$totalInstallments',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryMetric(
                  context.t('Monthly Due', 'Tổng trả/tháng'),
                  currencyFormat.format(totalMonthlyDue),
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.t('Payment Schedule', 'Lịch thanh toán'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1F3F),
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paginatedInstallments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final app = paginatedInstallments[index];
            final monthlyPayment =
                app['monthlyPayment'] ?? app['monthlyPaymentVnd'] ?? 0;
            final fallbackContractId = _getFallbackContractId(app);

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.t('Monthly Repayment', 'Thanh toán hàng tháng'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        currencyFormat.format(monthlyPayment),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1F3F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<String>(
                    future: _getContractIdFromFirestore(app),
                    builder: (context, snapshot) {
                      final resolvedId = snapshot.data;
                      final contractId =
                          (resolvedId != null && resolvedId.isNotEmpty)
                          ? resolvedId
                          : fallbackContractId;

                      return _buildMetaRow(
                        context.t('Contract ID', 'Mã hợp đồng'),
                        contractId.isEmpty ? '--' : contractId,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.t('Next Due Date', 'Ngày thanh toán kế tiếp'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FutureBuilder<DateTime?>(
                            future: _getSyncedNextDueDateForApplication(app),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                final nextDueDate = snapshot.data!;
                                final daysUntilDue = nextDueDate
                                    .difference(DateTime.now())
                                    .inDays;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatDate(nextDueDate),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF4C40F7),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: daysUntilDue <= 7
                                            ? const Color(0xFFFFEBEE)
                                            : const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        daysUntilDue <= 0
                                            ? context.t('Overdue', 'Quá hạn')
                                            : daysUntilDue == 1
                                            ? context.t(
                                                'Due tomorrow',
                                                'Đến hạn ngày mai',
                                              )
                                            : context
                                                  .t(
                                                    'Due in {days} days',
                                                    'Đến hạn trong {days} ngày',
                                                  )
                                                  .replaceAll(
                                                    '{days}',
                                                    '$daysUntilDue',
                                                  ),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: daysUntilDue <= 7
                                              ? const Color(0xFFEF5350)
                                              : const Color(0xFF4CAF50),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Text(
                                  context.t('Pending', 'Chưa xác định'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ApplicationContractStatusPage(
                              application: Map.from(app),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C40F7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        context.t('View Details', 'Xem chi tiết'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        // Pagination controls (if multiple pages)
        if (totalPages > 1) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: viewModel.currentInstallmentPage > 1
                    ? () {
                        viewModel.previousInstallmentPage();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
                label: Text(context.t('Previous', 'Trước')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C40F7),
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.grey.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${viewModel.currentInstallmentPage} / $totalPages',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: viewModel.currentInstallmentPage < totalPages
                    ? () {
                        viewModel.nextInstallmentPage(totalInstallments);
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
                label: Text(context.t('Next', 'Tiếp')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C40F7),
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.grey.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
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

  Future<DateTime?> _getSyncedNextDueDateForApplication(
    Map<String, dynamic> application,
  ) async {
    final submittedAt = _getSubmissionDate(application);
    if (submittedAt == null) return null;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final offerId = await _resolveOfferIdForApplication(application, userId);

    if (offerId == null ||
        offerId.isEmpty ||
        userId == null ||
        userId.isEmpty) {
      return _getNextDueDateFromSubmission(application);
    }

    try {
      final installments = await _installmentService.getInstallmentsForLoan(
        userId: userId,
        loanOfferId: offerId,
      );
      final unpaid = installments.where((item) => !item.isPaid).toList();
      if (unpaid.isEmpty) return null;

      final paidCount = installments.where((item) => item.isPaid).length;
      final currentInstallmentNumber =
          await _getInstallmentNumberFromCreditApplication(
            application: application,
            userId: userId,
            fallbackValue: paidCount + 1,
          );
      return _addMonthsSafe(
        DateTime(submittedAt.year, submittedAt.month, submittedAt.day),
        currentInstallmentNumber,
      );
    } catch (_) {
      return _getNextDueDateFromSubmission(application);
    }
  }

  Future<int> _getInstallmentNumberFromCreditApplication({
    required Map<String, dynamic> application,
    required String userId,
    required int fallbackValue,
  }) async {
    final normalizedFallback = fallbackValue < 1 ? 1 : fallbackValue;
    final applicationId = _extractApplicationId(application);
    final offerId = _extractOfferId(application);

    try {
      DocumentSnapshot<Map<String, dynamic>>? appDoc;

      if (applicationId != null && applicationId.isNotEmpty) {
        final byId = await FirebaseFirestore.instance
            .collection('credit_applications')
            .doc(applicationId)
            .get();
        if (byId.exists) {
          appDoc = byId;
        }
      }

      if (appDoc == null && offerId != null && offerId.isNotEmpty) {
        final byOffer = await FirebaseFirestore.instance
            .collection('credit_applications')
            .where('userId', isEqualTo: userId)
            .where('offerId', isEqualTo: offerId)
            .limit(1)
            .get();

        if (byOffer.docs.isNotEmpty) {
          appDoc = byOffer.docs.first;
        }
      }

      final data = appDoc?.data();
      if (data == null) return normalizedFallback;

      final firestoreInstallmentNumber =
          _asNullableInt(data['installmentNumber']) ??
          _asNullableInt(data['currentInstallment']) ??
          _asNullableInt(data['currentInstallmentNumber']) ??
          _asNullableInt(data['installmentNo']) ??
          _asNullableInt(data['installment_no']);

      if (firestoreInstallmentNumber == null || firestoreInstallmentNumber < 1) {
        return normalizedFallback;
      }

      return firestoreInstallmentNumber;
    } catch (_) {
      return normalizedFallback;
    }
  }

  String? _extractApplicationId(Map<String, dynamic> application) {
    final raw =
        application['applicationId'] ??
        application['creditApplicationId'] ??
        application['id'];
    final parsed = raw?.toString();
    if (parsed == null || parsed.isEmpty) return null;
    return parsed;
  }

  String? _extractOfferId(Map<String, dynamic> application) {
    final raw = application['offerId'] ?? application['loanOfferId'];
    final parsed = raw?.toString();
    if (parsed == null || parsed.isEmpty) return null;
    return parsed;
  }

  Future<String?> _resolveOfferIdForApplication(
    Map<String, dynamic> application,
    String? userId,
  ) async {
    final offerIdRaw = application['offerId'] ?? application['loanOfferId'];
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
        application['loanAmount'] ?? application['loanAmountVnd'],
      );
      final appTenorMonths = _asNullableInt(application['loanTermMonths']);
      final appMonthlyPayment = _asNullableDouble(
        application['monthlyPayment'] ?? application['monthlyPaymentVnd'],
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
    final day = _min(date.day, _daysInMonth(year, month));

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

  int _min(int a, int b) => a < b ? a : b;

  Widget _buildSummaryMetric(
    String label,
    String value, {
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF60678A),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1A1F3F),
            fontWeight: FontWeight.w700,
          ),
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF60678A),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1A1F3F),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final format = DateFormat('dd/MM/yyyy');
    return format.format(date);
  }

  String _getFallbackContractId(Map<String, dynamic> application) {
    return (application['contractId'] ??
            application['offerId'] ??
            application['loanOfferId'] ??
            application['applicationId'] ??
            application['id'] ??
            '')
        .toString();
  }

  Future<String> _getContractIdFromFirestore(
    Map<String, dynamic> application,
  ) async {
    final fallback = _getFallbackContractId(application);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || userId.isEmpty) return fallback;

    final offerId = await _resolveOfferIdForApplication(application, userId);
    if (offerId == null || offerId.isEmpty) return fallback;

    try {
      final offerDoc = await FirebaseFirestore.instance
          .collection('loan_offers')
          .doc(offerId)
          .get();

      if (!offerDoc.exists) {
        return fallback;
      }

      final data = offerDoc.data();
      final contractId =
          _asNullableString(data?['contractId']) ?? offerDoc.id;

      if (contractId.isNotEmpty) {
        return contractId;
      }
    } catch (_) {
      return fallback;
    }

    return fallback;
  }

  String? _asNullableString(dynamic value) {
    if (value == null) return null;
    final parsed = value.toString().trim();
    if (parsed.isEmpty) return null;
    return parsed;
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
}
