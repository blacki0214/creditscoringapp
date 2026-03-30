import 'package:flutter/material.dart';

import '../config/domain_map.dart';
import '../utils/app_localization.dart';
import 'student_step_1_profile.dart';

enum StudentVerificationPhase { demo, beta, production }

class StudentVerificationGatePage extends StatefulWidget {
  const StudentVerificationGatePage({super.key});

  @override
  State<StudentVerificationGatePage> createState() =>
      _StudentVerificationGatePageState();
}

class _StudentVerificationGatePageState extends State<StudentVerificationGatePage> {
  final TextEditingController _emailController = TextEditingController();

  StudentVerificationPhase _phase = StudentVerificationPhase.demo;
  bool _otpSent = false;
  bool _otpVerified = false;
  bool _legalConfirmed = false;
  bool _studentCardUploaded = false;
  bool _transcriptUploaded = false;

  String? _mappedUniversity;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    switch (_phase) {
      case StudentVerificationPhase.demo:
        return _legalConfirmed;
      case StudentVerificationPhase.beta:
        return _legalConfirmed && _otpVerified;
      case StudentVerificationPhase.production:
        return _legalConfirmed && _otpVerified && _transcriptUploaded;
    }
  }

  String _phaseLabel(BuildContext context, StudentVerificationPhase phase) {
    switch (phase) {
      case StudentVerificationPhase.demo:
        return context.t('Demo / Hackathon', 'Demo / Hackathon');
      case StudentVerificationPhase.beta:
        return context.t('Beta / Pilot', 'Beta / Pilot');
      case StudentVerificationPhase.production:
        return context.t('Production (future)', 'Production (tuong lai)');
    }
  }

  String? _extractDomain(String email) {
    final normalized = email.trim().toLowerCase();
    final at = normalized.lastIndexOf('@');
    if (at < 0 || at == normalized.length - 1) return null;
    return normalized.substring(at + 1);
  }

  void _sendOtp() {
    final domain = _extractDomain(_emailController.text);
    if (domain == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t('Please enter a valid university email.', 'Vui long nhap email truong hop le.'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final mapped = universityDomains[domain];
    setState(() {
      _otpSent = true;
      _mappedUniversity = mapped;
      _otpVerified = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mapped == null
              ? context.t(
                  'OTP sent. Domain is not mapped yet, but verification can continue.',
                  'Da gui OTP. Ten mien chua map, nhung van co the tiep tuc xac minh.',
                )
              : context.t(
                  'OTP sent to university email.',
                  'Da gui OTP den email truong.',
                ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        title: Text(
          context.t(
            'Student Verification',
            'Xac minh thong tin sinh vien',
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1F3F),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionCard(
                title: context.t('Verification Phase', 'Giai doan xac minh'),
                child: DropdownButtonFormField<StudentVerificationPhase>(
                  initialValue: _phase,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: StudentVerificationPhase.values
                      .map(
                        (phase) => DropdownMenuItem(
                          value: phase,
                          child: Text(_phaseLabel(context, phase)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _phase = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              _SectionCard(
                title: context.t(
                  'Field Verification Strategy',
                  'Chien luoc xac minh truong thong tin',
                ),
                child: Column(
                  children: [
                    _riskRow(
                      context,
                      field: context.t('Major, Program level, Living status', 'Nganh hoc, Bac hoc, Cho o'),
                      risk: context.t('Low', 'Thap'),
                      verification: context.t('Self-declare OK', 'Tu khai bao chap nhan'),
                    ),
                    _riskRow(
                      context,
                      field: context.t('Academic year', 'Nam hoc'),
                      risk: context.t('Medium', 'Trung binh'),
                      verification: context.t('Soft verify', 'Xac minh mem'),
                    ),
                    _riskRow(
                      context,
                      field: 'GPA',
                      risk: context.t('High', 'Cao'),
                      verification: context.t('Friction required', 'Bat buoc co ma sat xac minh'),
                    ),
                    _riskRow(
                      context,
                      field: context.t('Income', 'Thu nhap'),
                      risk: context.t('High', 'Cao'),
                      verification: context.t('Friction required', 'Bat buoc co ma sat xac minh'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _SectionCard(
                title: context.t(
                  'Method 1 - University Email OTP',
                  'Phuong thuc 1 - OTP email truong',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: context.t('University email', 'Email truong'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4D4AF9),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(context.t('Send OTP', 'Gui OTP')),
                        ),
                        OutlinedButton(
                          onPressed: _otpSent
                              ? () {
                                  setState(() {
                                    _otpVerified = true;
                                  });
                                }
                              : null,
                          child: Text(
                            context.t('Mark OTP verified', 'Danh dau OTP da xac minh'),
                          ),
                        ),
                      ],
                    ),
                    if (_mappedUniversity != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        context.t(
                          'Detected university: $_mappedUniversity',
                          'Da nhan dien truong: $_mappedUniversity',
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _SectionCard(
                title: context.t(
                  'Method 2 - Document Upload (Checklist)',
                  'Phuong thuc 2 - Tai lieu xac minh (Danh dau)',
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _studentCardUploaded,
                      onChanged: (value) {
                        setState(() {
                          _studentCardUploaded = value ?? false;
                        });
                      },
                      title: Text(
                        context.t('Student ID uploaded', 'Da tai len the sinh vien'),
                      ),
                      subtitle: Text(
                        context.t(
                          'Path: student_docs/{uid}/student_id.jpg',
                          'Duong dan: student_docs/{uid}/student_id.jpg',
                        ),
                      ),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _transcriptUploaded,
                      onChanged: (value) {
                        setState(() {
                          _transcriptUploaded = value ?? false;
                        });
                      },
                      title: Text(
                        context.t('Transcript uploaded', 'Da tai len bang diem'),
                      ),
                      subtitle: Text(
                        context.t(
                          'Path: student_docs/{uid}/transcript.jpg',
                          'Duong dan: student_docs/{uid}/transcript.jpg',
                        ),
                      ),
                    ),
                    Text(
                      context.t(
                        'Upload is optional at Step 1 but required before disbursement (Step 5).',
                        'Tai lieu la tuy chon o Buoc 1 nhung bat buoc truoc giai ngan (Buoc 5).',
                      ),
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _SectionCard(
                title: context.t(
                  'Method 3 - Legal Self-Declaration',
                  'Phuong thuc 3 - Cam ket phap ly tu khai bao',
                ),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _legalConfirmed,
                  onChanged: (value) {
                    setState(() {
                      _legalConfirmed = value ?? false;
                    });
                  },
                  title: Text(
                    context.t(
                      'I confirm the above information is accurate. This information will be verified before disbursement. False declaration may cause rejection now and in future applications.',
                      'Toi xac nhan thong tin tren la chinh xac. Thong tin se duoc xac minh truoc giai ngan. Khai bao sai co the bi tu choi hien tai va cac lan sau.',
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _SectionCard(
                title: context.t(
                  'Method 4 - In-form Consistency Checks',
                  'Phuong thuc 4 - Kiem tra nhat quan trong form',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'if (gpaLatest > 3.8 && academicYear == 1) showWarning();',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'if (monthlyIncome > 4000000 && supportSources.isEmpty) showWarning();',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _PhaseMethodSummary(phase: _phase),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canContinue
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StudentStepAProfilePage(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D4AF9),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(
                    context.t(
                      'Continue to Student Step 1',
                      'Tiep tuc vao Buoc 1 Sinh vien',
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

  Widget _riskRow(
    BuildContext context, {
    required String field,
    required String risk,
    required String verification,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE3E8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1F3F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${context.t('Risk', 'Rui ro')}: $risk',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            '${context.t('Verification', 'Xac minh')}: $verification',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7EBFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1F3F),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _PhaseMethodSummary extends StatelessWidget {
  const _PhaseMethodSummary({required this.phase});

  final StudentVerificationPhase phase;

  @override
  Widget build(BuildContext context) {
    String method;
    switch (phase) {
      case StudentVerificationPhase.demo:
        method = context.t('Self-declare + legal checkbox', 'Tu khai bao + checkbox phap ly');
        break;
      case StudentVerificationPhase.beta:
        method = context.t(
          'University email OTP + transcript upload at disbursement',
          'OTP email truong + tai bang diem truoc giai ngan',
        );
        break;
      case StudentVerificationPhase.production:
        method = context.t(
          'OCR transcript / university API partnership',
          'OCR bang diem / ket noi API truong dai hoc',
        );
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB9E2C1)),
      ),
      child: Text(
        '${context.t('Selected phase method', 'Phuong thuc giai doan da chon')}: $method',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF1B5E20),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
