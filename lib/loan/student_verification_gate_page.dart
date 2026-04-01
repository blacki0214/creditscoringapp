import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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

  String? _extractDomain(String email) {
    final normalized = email.trim().toLowerCase();
    final at = normalized.lastIndexOf('@');
    if (at < 0 || at == normalized.length - 1) return null;
    return normalized.substring(at + 1);
  }

  void _sendOtp() {
    final domain = _extractDomain(_emailController.text);
    if (domain == null || !domain.endsWith('edu.vn')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Please enter a valid university email (must end with @edu.vn).',
              'Vui lòng nhập email trường hợp lệ (phải kết thúc bằng @edu.vn).',
            ),
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
                  'OTP sent. Please check your email.',
                  'Đã gửi OTP. Vui lòng kiểm tra email.',
                )
              : context.t(
                  'OTP sent to university email.',
                  'Đã gửi OTP đến email trường.',
                ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  Future<void> _pickDocument({required bool isStudentId}) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (!mounted) return;
    if (result == null || result.files.isEmpty) return;

    setState(() {
      if (isStudentId) {
        _studentCardUploaded = true;
      } else {
        _transcriptUploaded = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isStudentId
              ? context.t('Student ID selected.', 'Đã chọn tệp thẻ sinh viên.')
              : context.t('Transcript selected.', 'Đã chọn tệp bảng điểm.'),
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
            'Xác minh thông tin sinh viên',
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
                  'University Email OTP',
                  'OTP email trường',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: context.t('University email', 'Email trường'),
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
                          child: Text(context.t('Send OTP', 'Gửi OTP')),
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
                            context.t('Mark OTP verified', 'Đánh dấu OTP đã xác minh'),
                          ),
                        ),
                      ],
                    ),
                    if (_mappedUniversity != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        context.t(
                          'Detected university: $_mappedUniversity',
                          'Đã nhận diện trường: $_mappedUniversity',
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
                  'Document Upload',
                  'Tài liệu xác minh',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDocument(isStudentId: true),
                        icon: const Icon(Icons.badge_outlined),
                        label: Text(
                          context.t('Upload Student ID', 'Tải lên thẻ sinh viên'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _studentCardUploaded
                          ? context.t('Status: Uploaded', 'Trạng thái: Đã tải lên')
                          : context.t('Status: Not uploaded', 'Trạng thái: Chưa tải lên'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDocument(isStudentId: false),
                        icon: const Icon(Icons.description_outlined),
                        label: Text(
                          context.t('Upload Transcript', 'Tải lên bảng điểm'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _transcriptUploaded
                          ? context.t('Status: Uploaded', 'Trạng thái: Đã tải lên')
                          : context.t('Status: Not uploaded', 'Trạng thái: Chưa tải lên'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.t(
                        'Upload is optional at Step 1 but required before disbursement (Step 5).',
                        'Tài liệu là tùy chọn ở Bước 1 nhưng bắt buộc trước giải ngân (Bước 5).',
                      ),
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _SectionCard(
                title: context.t(
                  'Legal Self-Declaration',
                  'Cam kết pháp lý tự khai báo',
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
                      'Tôi xác nhận thông tin trên là chính xác. Thông tin sẽ được xác minh trước giải ngân. Khai báo sai có thể bị từ chối hiện tại và các lần sau.',
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
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
                      'Tiếp tục vào Bước 1 Sinh viên',
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
