import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'change_password.dart';
import 'login_page.dart';

class OTPPage extends StatefulWidget {
  final bool isForResetPassword;
  final String? phoneNumber; // For display
  final VoidCallback? onVerified; // Callback for phone signup

  const OTPPage({
    super.key,
    this.isForResetPassword = false,
    this.phoneNumber,
    this.onVerified,
  });

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  String otpCode = '';
  
  void _onNumberTap(String number) {
    if (otpCode.length < 6) {
      setState(() {
        otpCode += number;
      });
      if (otpCode.length == 6) {
        _submitOTP();
      }
    }
  }
  
  void _onBackspace() {
    if (otpCode.isNotEmpty) {
      setState(() {
        otpCode = otpCode.substring(0, otpCode.length - 1);
      });
    }
  }
  
  Future<void> _submitOTP() async {
    if (widget.onVerified != null) {
      // Phone signup flow - verify with ViewModel
      final viewModel = context.read<AuthViewModel>();
      final success = await viewModel.verifyOTP(otpCode);
      
      if (success && mounted) {
        widget.onVerified!();
      }
    } else if (widget.isForResetPassword) {
      // Password reset flow
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
      );
    } else {
      // Old signup flow
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> _resendOTP() async {
    if (widget.onVerified != null) {
      final viewModel = context.read<AuthViewModel>();
      await viewModel.resendOTP();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isForResetPassword ? 'Forgot password' : 'Verify OTP',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Enter OTP Code',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F3F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.phoneNumber != null
                        ? 'Verification code sent to\n${widget.phoneNumber}'
                        : 'We texted you a code to verify\nyour phone number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // OTP Display - 6 digits
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 45,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: otpCode.length > index
                                  ? const Color(0xFF4C40F7)
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              otpCode.length > index ? otpCode[index] : '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1F3F),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Error message
                  if (viewModel.errorMessage != null)
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                viewModel.errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Resend button
                  if (widget.onVerified != null) ...[
                    if (viewModel.otpResendTime > 0)
                      Text(
                        'Resend OTP in ${viewModel.otpResendTime}s',
                        style: TextStyle(color: Colors.grey.shade600),
                      )
                    else
                      TextButton(
                        onPressed: viewModel.isLoading ? null : _resendOTP,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: Color(0xFF4C40F7),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ] else
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Resend',
                        style: TextStyle(
                          color: Color(0xFF4C40F7),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            // Numeric Keypad
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  _buildKeypadRow(['4', '5', '6']),
                  _buildKeypadRow(['7', '8', '9']),
                  _buildKeypadRow(['.', '0', 'backspace']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildKeypadRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) => _buildKey(key)).toList(),
      ),
    );
  }
  
  Widget _buildKey(String key) {
    return InkWell(
      onTap: () {
        if (key == 'backspace') {
          _onBackspace();
        } else if (key != '.') {
          _onNumberTap(key);
        }
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: key == 'backspace'
              ? const Icon(Icons.backspace_outlined, size: 24)
              : key == '.'
                  ? const SizedBox()
                  : Text(
                      key,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1F3F),
                      ),
                    ),
        ),
      ),
    );
  }
}
