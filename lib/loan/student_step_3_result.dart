import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/app_localization.dart';
import '../viewmodels/student_loan_viewmodel.dart';
import 'step5_contractreview.dart';

class StudentStepCResultPage extends StatelessWidget {
  const StudentStepCResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentLoanViewModel>();
    final score = vm.creditScore ?? vm.previewScore;
    final limit = vm.loanLimitVnd ?? vm.previewLoanLimit;
    final approved = vm.approved ?? false;
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        title: Text(context.t('Student Path - Step 3', 'Vay dành cho sinh viên - Bước 3')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1F3F),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7EBFF)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D2AA8).withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('Student credit score', 'Điểm tín dụng sinh viên'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1F3F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$score / 850 (${_bandText(context, score)})',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D2AA8),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 12,
                    value: (score / 850).clamp(0, 1),
                    backgroundColor: const Color(0xFFE6EAFF),
                    color: _scoreColor(score),
                  ),
                ),
                const SizedBox(height: 18),
                _InfoRow(
                  title: context.t('Limit', 'Hạn mức'),
                  value: limit > 0
                      ? '${formatter.format(limit)} VND'
                      : context.t('Not eligible yet', 'Chưa đủ điều kiện'),
                ),
                const SizedBox(height: 8),
                _InfoRow(title: context.t('Risk', 'Rủi ro'), value: vm.riskLevel),
                const SizedBox(height: 8),
                if ((vm.decisionBand ?? '').isNotEmpty) ...[
                  _InfoRow(
                    title: context.t('Decision band', 'Nhóm quyết định'),
                    value: vm.decisionBand!,
                  ),
                  const SizedBox(height: 8),
                ],
                if (vm.manualReview != null) ...[
                  _InfoRow(
                    title: context.t('Manual review', 'Cần thẩm định thủ công'),
                    value: vm.manualReview == true
                        ? context.t('Required', 'Có')
                        : context.t('Not required', 'Không'),
                  ),
                  const SizedBox(height: 8),
                ],
                _InfoRow(
                  title: context.t('Status', 'Trạng thái'),
                  value: approved
                      ? context.t('Pre-approved', 'Đã duyệt sơ bộ')
                      : context.t('Needs improvement', 'Cần cải thiện'),
                  valueColor: approved
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                ),
                const SizedBox(height: 18),
                if ((vm.apiMessage ?? '').isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE1E6FF)),
                    ),
                    child: Text(
                      vm.apiMessage!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF30374A),
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                if (!approved) _buildImproveTips(score),
                if (approved) _buildApprovedTips(score),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: approved
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Step5ContractReviewPage(
                                  loanAmount: limit.toDouble(),
                                  tenor: 12,
                                  downPayment: 0,
                                  loanPurpose: 'EDUCATION',
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D4AF9),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(context.t('Choose term and continue', 'Chọn kỳ hạn và tiếp tục')),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: Color(0xFF4D4AF9)),
                    ),
                    child: Text(context.t('Improve score', 'Cải thiện điểm')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImproveTips(int score) {
    final tips = <String>[
      'Declare income and support sources to increase score.',
      'Enable savings if you have an emergency buffer.',
      'Update your latest GPA if your result improved.',
    ];

    if (score < 650) {
      tips.add('Below 650: add more details and retry the form.');
    }

    return _TipsBox(title: 'Tips to improve score', tips: tips);
  }

  Widget _buildApprovedTips(int score) {
    final tips = <String>[
      if (score >= 720) '720+: you may reach the maximum 10M limit.',
      if (score >= 650 && score < 680)
        '650-680: typical approved limit is around 5M-6M.',
      'Verification documents may be requested before disbursement.',
    ];

    return _TipsBox(title: 'What to do next', tips: tips);
  }

  static Color _scoreColor(int score) {
    if (score < 650) return const Color(0xFFE53935);
    if (score < 720) return const Color(0xFFF9A825);
    return const Color(0xFF43A047);
  }

  static String _bandText(BuildContext context, int score) {
    if (score < 650) {
      return context.t('Need Improvement', 'Cần cải thiện');
    }
    if (score < 720) {
      return context.t('Good', 'Tốt');
    }
    return context.t('Excellent', 'Xuất sắc');
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.value,
    this.valueColor = const Color(0xFF1A1F3F),
  });

  final String title;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _TipsBox extends StatelessWidget {
  const _TipsBox({required this.title, required this.tips});

  final String title;
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    final isVi = context.isVietnamese;
    final localizedTips = isVi
        ? tips
            .map(
              (tip) => _tipMap[tip] ?? tip,
            )
            .toList()
        : tips;
    final localizedTitle = isVi ? (_titleMap[title] ?? title) : title;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizedTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1F3F),
            ),
          ),
          const SizedBox(height: 8),
          for (final tip in localizedTips)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '- $tip',
                style: const TextStyle(fontSize: 13, color: Color(0xFF30374A)),
              ),
            ),
        ],
      ),
    );
  }

  static const Map<String, String> _titleMap = {
    'Tips to improve score': 'Mẹo cải thiện điểm',
    'What to do next': 'Hướng dẫn tiếp theo',
  };

  static const Map<String, String> _tipMap = {
    'Declare income and support sources to increase score.':
      'Khai báo thu nhập và nguồn hỗ trợ để tăng điểm.',
    'Enable savings if you have an emergency buffer.':
      'Bật tùy chọn tiết kiệm nếu bạn có quỹ dự phòng.',
    'Update your latest GPA if your result improved.':
      'Cập nhật GPA mới nhất nếu kết quả học tập đã tốt hơn.',
    'Below 650: add more details and retry the form.':
      'Dưới 650: bổ sung thông tin và thử lại.',
    '720+: you may reach the maximum 10M limit.':
      '720+: có thể đạt hạn mức tối đa 10M.',
    '650-680: typical approved limit is around 5M-6M.':
      '650-680: hạn mức thường nằm trong 5M-6M.',
    'Verification documents may be requested before disbursement.':
      'Có thể yêu cầu tài liệu xác minh trước giải ngân.',
  };
}
