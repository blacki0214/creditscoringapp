import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'otp_page.dart';
import '../home/main_shell.dart';
import '../utils/app_localization.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  /// Validate phone number: 10 digits starting with 0
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return context.t('Please enter your phone number', 'Vui lòng nhập số điện thoại');
    }
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.length != 10) {
      return context.t('Phone number must be 10 digits', 'Số điện thoại phải có 10 chữ số');
    }
    if (!cleaned.startsWith('0')) {
      return context.t('Phone number must start with 0', 'Số điện thoại phải bắt đầu bằng 0');
    }
    return null;
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<AuthViewModel>();
    viewModel.clearError();

    // Convert Vietnamese phone to international format
    final phoneNumber = _phoneController.text.trim();
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final internationalPhone = '+84${cleaned.substring(1)}';

    final success = await viewModel.sendPhoneOTP(internationalPhone);

    if (success && mounted) {
      // Navigate to OTP page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPPage(
            phoneNumber: phoneNumber,
            onVerified: () {
              // OTP verified, user is logged in
              // Navigate to home page and remove all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainShell()),
                (route) => false,
              );
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Title
                  Text(
                    context.t('Sign in with Phone', 'Đăng nhập bằng số điện thoại'),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F3F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.t(
                      'Enter your phone number to receive OTP',
                      'Nhập số điện thoại để nhận mã OTP',
                    ),
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 40),
                  // Phone field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: context.t('Phone Number', 'Số điện thoại'),
                      hintText: context.t('Enter your phone number', 'Nhập số điện thoại của bạn'),
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF4C40F7),
                          width: 2,
                        ),
                      ),
                      counterText: '',
                    ),
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 32),
                  // Send OTP button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading ? null : _sendOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C40F7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                              context.t('Send OTP', 'Gửi OTP'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Error message
                  if (viewModel.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
