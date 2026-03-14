import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_page.dart';
import '../utils/app_localization.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isChecking = false;

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);
    
    final viewModel = context.read<AuthViewModel>();
    final isVerified = await viewModel.checkEmailVerified();
    
    setState(() => _isChecking = false);
    
    if (isVerified && mounted) {
      // Email verified, go to login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Email verified! You can now login.',
              'Email đã được xác thực! Bạn có thể đăng nhập ngay.',
            ),
          ),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Email not verified yet. Please check your inbox.',
              'Email chưa được xác thực. Vui lòng kiểm tra hộp thư của bạn.',
            ),
          ),
          backgroundColor: Color(0xFFEF5350),
        ),
      );
    }
  }

  Future<void> _resendVerification() async {
    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.sendEmailVerification();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Verification email sent! Check your inbox.',
              'Đã gửi email xác thực! Vui lòng kiểm tra hộp thư của bạn.',
            ),
          ),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF4C40F7).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 80,
                  color: Color(0xFF4C40F7),
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                context.t('Verify Your Email', 'Xác thực email của bạn'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F3F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                context.t(
                  'We\'ve sent a verification link to your email address. Please check your inbox and click the link to verify your account.',
                  'Chúng tôi đã gửi liên kết xác thực đến email của bạn. Vui lòng kiểm tra hộp thư và nhấn vào liên kết để xác thực tài khoản.',
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Check verification button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C40F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isChecking
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          context.t(
                            'I\'ve Verified My Email',
                            'Tôi đã xác thực email',
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Resend button
              TextButton(
                onPressed: viewModel.isLoading ? null : _resendVerification,
                child: Text(
                  context.t(
                    'Resend Verification Email',
                    'Gửi lại email xác thực',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF4C40F7),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Back to login
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: Text(
                  context.t('Back to Login', 'Quay lại đăng nhập'),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
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
