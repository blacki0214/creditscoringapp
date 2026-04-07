import 'package:flutter/material.dart';

import '../utils/app_localization.dart';
import 'student_verification_gate_page.dart';

class StudentHubPage extends StatelessWidget {
  const StudentHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/SwinCredit_logo2.png',
                    width: 30,
                    height: 30,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.credit_card,
                        color: Color(0xFF4D4AF9),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Swin Credit',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F3F),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.menu,
                      size: 18,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDEE5FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  context.t(
                    'Swin Education Credit',
                    'Tín dụng giáo dục Swin',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF2E3192),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('Empowering your', 'Nang tầm hành trình'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      context.t('academic journey.', 'học tập.'),
                      style: const TextStyle(
                        fontSize: 44,
                        height: 0.95,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4D4AF9),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      context.t(
                        'As part of the Swin Credit suite, our student loans are engineered for the modern scholar with transparent terms.',
                        'Thuộc bộ sản phẩm Swin Credit, gói vay sinh viên được tối ưu cho hành trình học tập hiện đại với điều khoản minh bạch.',
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _PrimaryActionButton(
                      label: context.t('Apply Now', 'Đăng ký ngay'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StudentVerificationGatePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('The Swin Credit Advantage', 'Lợi thế Swin Credit'),
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.t(
                        'Sophisticated financial tools tailored for student success.',
                        'Công cụ tài chính hiện đại được thiết kế riêng để hỗ trợ thành công học tập.',
                      ),
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _AdvantageTile(
                      icon: Icons.wallet_outlined,
                      enTitle: 'Swin SmartPay',
                      viTitle: 'Swin SmartPay',
                      enDescription:
                          'Intelligent repayment structures that adapt to your early-career income.',
                      viDescription:
                        'Cấu trúc trả nợ linh hoạt, thích ứng với mức thu nhập giai đoạn đầu sự nghiệp của bạn.',
                    ),
                    const SizedBox(height: 12),
                    _AdvantageTile(
                      icon: Icons.lock_outline,
                      enTitle: 'Zero-Fee Ethics',
                      viTitle: 'Nguyên tắc không phí',
                      enDescription:
                          'No origination fees, no late penalties. We succeed when you succeed.',
                      viDescription:
                        'Không phí khởi tạo, không phí phạt trễ hạn. Chúng tôi thành công khi bạn thành công.',
                    ),
                    const SizedBox(height: 12),
                    _AdvantageTile(
                      icon: Icons.insights_outlined,
                      enTitle: 'Atelier Mentorship',
                      viTitle: 'Cố vấn Atelier',
                      enDescription:
                          '1-on-1 financial design sessions to help build your post-grad wealth strategy.',
                      viDescription:
                        'Các buổi tư vấn tài chính 1-1 giúp xây dựng chiến lược tài sản sau tốt nghiệp.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF101A4A), Color(0xFF0A1237)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatItem(
                          value: '\$2.4B',
                          enLabel: 'TOTAL FUNDING',
                          viLabel: 'TỔNG VỐN TÀI TRỢ',
                        ),
                        _StatItem(
                          value: '4.9/5',
                          enLabel: 'TRUST SCORE',
                          viLabel: 'ĐIỂM TÍN NHIỆM',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatItem(
                          value: '120K+',
                          enLabel: 'SCHOLARS SUPPORTED',
                          viLabel: 'SINH VIÊN ĐƯỢC HỖ TRỢ',
                        ),
                        _StatItem(
                          value: '0%',
                          enLabel: 'HIDDEN COSTS',
                          viLabel: 'CHI PHÍ ẨN',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4D4AF9),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFD8DFEA)),
          foregroundColor: const Color(0xFF334155),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _AdvantageTile extends StatelessWidget {
  const _AdvantageTile({
    required this.icon,
    required this.enTitle,
    required this.viTitle,
    required this.enDescription,
    required this.viDescription,
  });

  final IconData icon;
  final String enTitle;
  final String viTitle;
  final String enDescription;
  final String viDescription;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE4E8FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF4D4AF9)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t(enTitle, viTitle),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.t(enDescription, viDescription),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.enLabel,
    required this.viLabel,
  });

  final String value;
  final String enLabel;
  final String viLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          context.t(enLabel, viLabel),
          style: const TextStyle(
            color: Color(0xFFB7C1E9),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
