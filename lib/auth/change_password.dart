import 'package:flutter/material.dart';
import 'success_page.dart';
import '../utils/app_localization.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  /// Validate password syntax: min 8 chars, 1 uppercase, 1 number
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.t('Please enter a password', 'Vui lòng nhập mật khẩu');
    }
    if (value.length < 8) {
      return context.t('Password must be at least 8 characters', 'Mật khẩu phải có ít nhất 8 ký tự');
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return context.t('Password must contain at least 1 uppercase letter', 'Mật khẩu phải có ít nhất 1 chữ in hoa');
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return context.t('Password must contain at least 1 number', 'Mật khẩu phải có ít nhất 1 chữ số');
    }
    return null;
  }

  /// Validate confirm password matches new password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.t('Please confirm your password', 'Vui lòng xác nhận mật khẩu');
    }
    if (value != _newPasswordController.text) {
      return context.t('Passwords do not match', 'Mật khẩu xác nhận không khớp');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
          context.t('Change password', 'Đổi mật khẩu'),
          style: const TextStyle(color: Colors.black),
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
                  const SizedBox(height: 20),
                  // Illustration
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D4AF9).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.vpn_key,
                        size: 100,
                        color: Color(0xFF4D4AF9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Title
                  Text(
                    context.t('Create New Password', 'Tạo mật khẩu mới'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F3F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.t(
                      'Your new password must be different from previously used passwords.',
                      'Mật khẩu mới của bạn phải khác các mật khẩu đã dùng trước đó.',
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // New password field
                  TextFormField(
                    controller: _newPasswordController,
                    maxLength: 50,
                    obscureText: _obscureNewPassword,
                    decoration: InputDecoration(
                      labelText: context.t('New Password', 'Mật khẩu mới'),
                      hintText: context.t('Enter new password', 'Nhập mật khẩu mới'),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
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
                          color: Color(0xFF4D4AF9),
                          width: 2,
                        ),
                      ),
                      helperText: context.t(
                        'At least 8 characters, 1 uppercase letter, 1 number',
                        'Ít nhất 8 ký tự, 1 chữ in hoa, 1 chữ số',
                      ),
                      helperStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      counterText: '', // Hide character counter
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 20),
                  // Confirm password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    maxLength: 50,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: context.t('Confirm Password', 'Xác nhận mật khẩu'),
                      hintText: context.t('Re-enter password', 'Nhập lại mật khẩu'),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
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
                          color: Color(0xFF4D4AF9),
                          width: 2,
                        ),
                      ),
                      counterText: '', // Hide character counter
                    ),
                    validator: _validateConfirmPassword,
                  ),
                  const SizedBox(height: 32),
                  // Reset password button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SuccessPage(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D4AF9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        context.t('Reset Password', 'Đặt lại mật khẩu'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
