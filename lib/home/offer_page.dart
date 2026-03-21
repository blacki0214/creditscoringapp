import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/loan_viewmodel.dart';
import '../loan/step3_personal_info.dart';
import '../loan/loan_application_page.dart';
import '../utils/app_localization.dart';

class OfferPage extends StatelessWidget {
  const OfferPage({super.key});

  @override
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
                      context.t('Offer', 'Đề nghị'),
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
                    child: _buildOfferContent(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferContent(BuildContext context) {
    final loanViewModel = context.watch<LoanViewModel>();
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: ' VND',
    );
    final activeOffer = loanViewModel.currentOffer;
    final activeStatus = loanViewModel.applicationStatus;
    final showScoreStatus =
        loanViewModel.currentOffer != null ||
        activeStatus == ApplicationStatus.processing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Loan Status Box
        if (showScoreStatus) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: activeStatus == ApplicationStatus.processing
                  ? const Color(0xFFFFF3E0)
                  : activeStatus == ApplicationStatus.scored
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: activeStatus == ApplicationStatus.processing
                    ? const Color(0xFFFFA726)
                    : activeStatus == ApplicationStatus.scored
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFEF5350),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  activeStatus == ApplicationStatus.processing
                      ? Icons.hourglass_empty
                      : activeStatus == ApplicationStatus.scored
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: activeStatus == ApplicationStatus.processing
                      ? const Color(0xFFFFA726)
                      : activeStatus == ApplicationStatus.scored
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF5350),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeStatus == ApplicationStatus.processing
                            ? context.t(
                                'Processing Application',
                                'Đang xử lý hồ sơ',
                              )
                            : activeStatus == ApplicationStatus.scored
                            ? context.t('Offer Ready', 'Đã có đề nghị')
                            : context.t(
                                'Application Rejected',
                                'Hồ sơ bị từ chối',
                              ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: activeStatus == ApplicationStatus.processing
                              ? const Color(0xFFFFA726)
                              : activeStatus == ApplicationStatus.scored
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFEF5350),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeStatus == ApplicationStatus.processing
                            ? context.t(
                                'Please wait while we complete scoring and prepare your offer.',
                                'Vui lòng chờ trong khi chúng tôi hoàn tất chấm điểm và chuẩn bị đề nghị.',
                              )
                            : activeStatus == ApplicationStatus.scored
                            ? context.t(
                                'Your result is ready. Review the offer details and continue.',
                                'Kết quả đã sẵn sàng, Hãy xem chi tiết đề nghị và tiếp tục',
                              )
                            : context.t(
                                'Scoring is complete and this application was not approved.',
                                'Quá trình chấm điểm đã hoàn tất và hồ sơ này không được duyệt.',
                              ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      // Show loan amount in the scored box
                      if (activeStatus == ApplicationStatus.scored &&
                          activeOffer != null &&
                          activeOffer['approved'] as bool) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  context.t('Limit Amount', 'Hạn mức'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: const Color(0xFF1A1F3F),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      currencyFormat.format(
                                        activeOffer['maxAmountVnd'] as num,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF4CAF50),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Continue button to Step 3
                        if (!loanViewModel.step3Completed ||
                            !loanViewModel.step4Completed)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const Step3PersonalInfoPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4C40F7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                context.t(
                                  'Continue To Complete Profile',
                                  'Tiếp tục để hoàn tất hồ sơ',
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                      // Show re-apply guidance for rejected applications
                      if (activeStatus == ApplicationStatus.rejected) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.t(
                                  'You can submit a new application after updating your profile details.',
                                  'Bạn có thể nộp hồ sơ mới sau khi cập nhật thông tin hồ sơ.',
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await loanViewModel
                                        .finalizeAndResetForNewApplication();
                                    if (!context.mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const LoanApplicationPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4C40F7),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    context.t('Apply Again', 'Nộp hồ sơ mới'),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
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
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Current Loan Offer Section (only show full details after Step 3 & 4 completion)
        if (activeOffer != null &&
            activeStatus == ApplicationStatus.scored &&
            (loanViewModel.step3Completed && loanViewModel.step4Completed)) ...[
          Text(
            context.t('Current Offer', 'Đề nghị hiện tại'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1F3F),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (activeOffer['approved'] as bool? ?? true)
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (activeOffer['approved'] as bool? ?? true)
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFEF5350),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (activeOffer['approved'] as bool? ?? true)
                          ? context.t('APPROVED', 'ĐÃ DUYỆT')
                          : context.t('REJECTED', 'TỪ CHỐI'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: (activeOffer['approved'] as bool? ?? true)
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFEF5350),
                      ),
                    ),
                    Icon(
                      (activeOffer['approved'] as bool? ?? true)
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: (activeOffer['approved'] as bool? ?? true)
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFEF5350),
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (activeOffer['approved'] as bool) ...[
                  // Show the actual loan amount user chose
                  if (activeOffer['loanAmountVnd'] != null)
                    Column(
                      children: [
                        _buildLoanDetailRow(
                          context.t('Loan Amount', 'Số tiền vay'),
                          currencyFormat.format(
                            activeOffer['loanAmountVnd'] as num,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  if (activeOffer['interestRate'] != null)
                    Column(
                      children: [
                        _buildLoanDetailRow(
                          context.t('Interest Rate', 'Lãi suất'),
                          context.t(
                            '${(activeOffer['interestRate'] as num).toStringAsFixed(2)}% / year',
                            '${(activeOffer['interestRate'] as num).toStringAsFixed(2)}% / năm',
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  if (activeOffer['monthlyPaymentVnd'] != null)
                    Column(
                      children: [
                        _buildLoanDetailRow(
                          context.t('Monthly Payment', 'Thanh toán hàng tháng'),
                          currencyFormat.format(
                            activeOffer['monthlyPaymentVnd'] as num,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  if (activeOffer['loanTermMonths'] != null)
                    Column(
                      children: [
                        _buildLoanDetailRow(
                          context.t('Loan Term', 'Kỳ hạn vay'),
                          context.t(
                            '${activeOffer['loanTermMonths']} months',
                            '${activeOffer['loanTermMonths']} tháng',
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  _buildLoanDetailRow(
                    context.t('Credit Score', 'Điểm tín dụng'),
                    '${activeOffer['creditScore']}',
                  ),
                ] else ...[
                  Center(
                    child: Column(
                      children: [
                        Text(
                          activeOffer['approvalMessage'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFEF5350),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        _buildLoanDetailRow(
                          context.t('Credit Score', 'Điểm tín dụng'),
                          '${activeOffer['creditScore']}',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
        ] else if (!showScoreStatus) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.t('No Active Offer', 'Chưa có đề nghị'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.t(
                      'Complete a loan application to see your offer here.',
                      'Hoàn thành hồ sơ vay để xem đề nghị tại đây.',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoanDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1F3F),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
