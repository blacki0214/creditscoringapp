import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/domain_map.dart';
import '../services/student_email_verification_service.dart';
import '../utils/app_localization.dart';
import 'student_step_1_profile.dart';

enum StudentVerificationPhase { demo, beta, production }

class StudentVerificationGatePage extends StatefulWidget {
  const StudentVerificationGatePage({super.key});

  @override
  State<StudentVerificationGatePage> createState() =>
      _StudentVerificationGatePageState();
}

class _StudentVerificationGatePageState
    extends State<StudentVerificationGatePage> {
  final TextEditingController _emailController = TextEditingController();
  final StudentEmailVerificationService _verificationService =
      StudentEmailVerificationService();

  final StudentVerificationPhase _phase = StudentVerificationPhase.demo;
  bool _emailSent = false;
  bool _emailVerified = false;
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
        return _legalConfirmed && _emailVerified;
      case StudentVerificationPhase.production:
        return _legalConfirmed && _emailVerified && _transcriptUploaded;
    }
  }

  String? _extractDomain(String email) {
    final normalized = email.trim().toLowerCase();
    final at = normalized.lastIndexOf('@');
    if (at < 0 || at == normalized.length - 1) return null;
    return normalized.substring(at + 1);
  }

  Future<void> _sendEmail() async {
    final normalizedEmail = _emailController.text.trim().toLowerCase();
    final domain = _extractDomain(normalizedEmail);
    if (domain == null ||
        !domain.endsWith('edu.vn') && !domain.endsWith('student.swin.edu.au')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Please enter a valid university email.',
              'Vui lòng nhập email trường hợp lệ.',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Please log in with your main account before verifying student email.',
              'Vui lòng đăng nhập bằng tài khoản chính trước khi xác minh email sinh viên.',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final mapped = universityDomains[domain];
    try {
      await _verificationService.sendVerificationEmail(
        studentEmail: normalizedEmail,
      );
      if (!mounted) return;

      setState(() {
        _emailSent = true;
        _mappedUniversity = mapped;
        _emailVerified = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mapped == null
                ? context.t(
                    'Verification email sent to $normalizedEmail. Please check your inbox and click the link.',
                    'Email xác minh đã được gửi đến $normalizedEmail. Vui lòng kiểm tra hộp thư và bấm vào liên kết.',
                  )
                : context.t(
                    'Verification email sent to $normalizedEmail. Please open the link in your mail.',
                    'Email xác minh đã được gửi đến $normalizedEmail. Vui lòng mở liên kết trong email.',
                  ),
          ),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Failed to send verification email: $e',
              'Không gửi được email xác minh: $e',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'No verification session found. Tap Send Email first.',
              'Không tìm thấy phiên xác minh. Hãy bấm Gửi Email trước.',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final state = await _verificationService.getVerificationState();
    if (!mounted) return;

    final expectedEmail = _emailController.text.trim().toLowerCase();
    final currentEmail = (state.studentEmail ?? '').trim().toLowerCase();
    final verified = state.isVerified && currentEmail == expectedEmail;

    setState(() {
      _emailVerified = verified;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          verified
              ? context.t(
                  'Email verified successfully.',
                  'Email đã được xác minh thành công.',
                )
              : context.t(
                  'Email is not verified yet. Open the verification link in your inbox, then tap Email Verified again.',
                  'Email chưa được xác minh. Hãy mở link xác minh trong hộp thư, sau đó bấm Email đã được xác minh lần nữa.',
                ),
        ),
        backgroundColor: verified ? const Color(0xFF2E7D32) : Colors.orange,
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
          context.t('Student Verification', 'Xác minh thông tin sinh viên'),
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
                title: context.t(
                  'University Email Authentication',
                  'Xác thực email trường',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: context.t(
                          'University email',
                          'Email trường',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: _sendEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4D4AF9),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(context.t('Send Email', 'Gửi Email')),
                        ),
                        OutlinedButton(
                          onPressed: _emailSent ? _checkEmailVerified : null,
                          child: Text(
                            context.t(
                              'Email Verified',
                              'Email đã được xác minh',
                            ),
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
                title: context.t('Document Upload', 'Tài liệu xác minh'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDocument(isStudentId: true),
                        icon: const Icon(Icons.badge_outlined),
                        label: Text(
                          context.t(
                            'Upload Student ID',
                            'Tải lên thẻ sinh viên',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _studentCardUploaded
                          ? context.t(
                              'Status: Uploaded',
                              'Trạng thái: Đã tải lên',
                            )
                          : context.t(
                              'Status: Not uploaded',
                              'Trạng thái: Chưa tải lên',
                            ),
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
                          ? context.t(
                              'Status: Uploaded',
                              'Trạng thái: Đã tải lên',
                            )
                          : context.t(
                              'Status: Not uploaded',
                              'Trạng thái: Chưa tải lên',
                            ),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.t(
                        'Upload is optional at Step 1 but required before disbursement (Step 5).',
                        'Tài liệu là tùy chọn ở Bước 1 nhưng bắt buộc trước giải ngân (Bước 5).',
                      ),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
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
