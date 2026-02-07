import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final Map<String, GlobalKey<FormFieldState>> _fieldKeys = {};
  final Map<String, FocusNode> _fieldFocusNodes = {};
  final Map<String, bool> _touchedFields = {};

  /// Validate email format: must have text@text pattern
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // Check for basic email pattern: text@text.text
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _sendResetEmail() async {
    _markAllTouched(['email']);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.sendPasswordResetEmail(_emailController.text.trim());

    if (success && mounted) {
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Email Sent!'),
          content: const Text(
            'We\'ve sent a password reset link to your email. Please check your inbox and follow the instructions to reset your password.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to login
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF4C40F7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  GlobalKey<FormFieldState> _fieldKey(String id) {
    return _fieldKeys.putIfAbsent(id, () => GlobalKey<FormFieldState>());
  }

  FocusNode _fieldFocus(String id) {
    return _fieldFocusNodes.putIfAbsent(id, () {
      final node = FocusNode();
      node.addListener(() {
        if (!node.hasFocus) {
          _touchedFields[id] = true;
          _fieldKeys[id]?.currentState?.validate();
        }
      });
      return node;
    });
  }

  String? _validateIfTouched(
    String id,
    String? Function(String?) validator,
    String? value,
  ) {
    if (_touchedFields[id] != true) {
      return null;
    }
    return validator(value);
  }

  void _markAllTouched(Iterable<String> ids) {
    for (final id in ids) {
      _touchedFields[id] = true;
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
        title: const Text(
          'Forgot password',
          style: TextStyle(color: Colors.black),
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
                        color: const Color(0xFF4C40F7).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 100,
                        color: Color(0xFF4C40F7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Title
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F3F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter your email address and we\'ll send you a link to reset your password.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Email field
                  TextFormField(
                    key: _fieldKey('email'),
                    controller: _emailController,
                    focusNode: _fieldFocus('email'),
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 50,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email_outlined),
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
                      counterText: '', // Hide character counter
                    ),
                    validator: (value) =>
                        _validateIfTouched('email', _validateEmail, value),
                  ),
                  const SizedBox(height: 32),
                  // Send reset link button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading ? null : _sendResetEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C40F7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Send Reset Link',
                              style: TextStyle(
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
    for (final node in _fieldFocusNodes.values) {
      node.dispose();
    }
    _emailController.dispose();
    super.dispose();
  }
}
