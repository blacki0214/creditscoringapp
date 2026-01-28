import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'otp_page.dart';
import 'login_page.dart';
import 'email_verification_page.dart';
import '../home/home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  /// Validate password syntax: min 8 chars, 1 uppercase, 1 number
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least 1 uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least 1 number';
    }
    return null;
  }

  /// Validate email format: must have text@text pattern (required)
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

  /// Validate phone number: 10 digits starting with 0 (optional)
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    // Remove any spaces or special characters
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleaned.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (!cleaned.startsWith('0')) {
      return 'Phone number must start with 0';
    }
    return null;
  }

  Future<void> _continueToNextStep() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<AuthViewModel>();
    
    if (viewModel.signupStep == 0) {
      // Step 0: Email + Password entered, move to phone (optional)
      viewModel.setSignupStep(1);
    } else if (viewModel.signupStep == 1) {
      // Step 1: Phone entered (or skipped), move to avatar
      // If phone provided, send OTP
      if (_phoneController.text.trim().isNotEmpty) {
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
                  context.read<AuthViewModel>().setSignupStep(2);
                  Navigator.pop(context);
                },
              ),
            ),
          );
        }
      } else {
        // Skip phone, go to avatar
        viewModel.setSignupStep(2);
      }
    }
  }

  Future<void> _completeSignup() async {
    final viewModel = context.read<AuthViewModel>();
    
    // Sign up with email and password
    final success = await viewModel.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isNotEmpty 
          ? '+84${_phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '').substring(1)}'
          : '', // Empty if not provided
    );

    if (success && mounted) {
      // Send email verification
      await viewModel.sendEmailVerification();
      
      // Navigate to email verification page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const EmailVerificationPage()),
        (route) => false,
      );
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
          onPressed: () {
            if (viewModel.signupStep > 0) {
              viewModel.setSignupStep(viewModel.signupStep - 1);
            } else {
              Navigator.pop(context);
            }
          },
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
                  // Progress indicator
                  Row(
                    children: [
                      _buildStepIndicator(0, true),
                      _buildStepLine(viewModel.signupStep >= 1),
                      _buildStepIndicator(1, viewModel.signupStep >= 1),
                      _buildStepLine(viewModel.signupStep >= 2),
                      _buildStepIndicator(2, viewModel.signupStep >= 2),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    viewModel.signupStep == 0
                        ? 'Create Account'
                        : viewModel.signupStep == 1
                            ? 'Phone Number (Optional)'
                            : 'Profile Picture',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F3F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.signupStep == 0
                        ? 'Enter your details to get started'
                        : viewModel.signupStep == 1
                            ? 'Add phone for verification (optional)'
                            : 'Add profile picture (optional)',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Step 0: Name, Email, Password
                  if (viewModel.signupStep == 0) ...[
                    TextFormField(
                      controller: _nameController,
                      maxLength: 50,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: const Icon(Icons.person_outline),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
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
                        counterText: '',
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      maxLength: 50,
                      obscureText: viewModel.obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            viewModel.obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            context.read<AuthViewModel>().togglePasswordVisibility();
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
                            color: Color(0xFF4C40F7),
                            width: 2,
                          ),
                        ),
                        counterText: '',
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : _continueToNextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C40F7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Step 1: Phone Number (Optional)
                  if (viewModel.signupStep == 1) ...[
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: 'Phone Number (Optional)',
                        hintText: 'Enter your phone number',
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
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : _continueToNextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C40F7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: viewModel.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Skip phone, go to avatar
                        context.read<AuthViewModel>().setSignupStep(2);
                      },
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF4C40F7),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],

                  // Step 2: Avatar Upload
                  if (viewModel.signupStep == 2) ...[
                    Center(
                      child: GestureDetector(
                        onTap: () => context.read<AuthViewModel>().pickAvatar(),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: viewModel.selectedAvatar != null
                              ? FileImage(viewModel.selectedAvatar!)
                              : null,
                          child: viewModel.selectedAvatar == null
                              ? Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.grey.shade600,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.read<AuthViewModel>().pickAvatar(),
                        child: const Text(
                          'Choose from gallery',
                          style: TextStyle(
                            color: Color(0xFF4C40F7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (viewModel.selectedAvatar != null)
                      Center(
                        child: TextButton(
                          onPressed: () => context.read<AuthViewModel>().clearAvatar(),
                          child: Text(
                            'Remove photo',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : _completeSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C40F7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: viewModel.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Complete',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: _completeSignup,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFF4C40F7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  // Sign in link
                  if (viewModel.signupStep == 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<AuthViewModel>().reset();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              color: Color(0xFF4C40F7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  // Error message
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                viewModel.errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
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

  Widget _buildStepIndicator(int step, bool isActive) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF4C40F7) : Colors.grey.shade300,
      ),
      child: Center(
        child: Text(
          '${step + 1}',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? const Color(0xFF4C40F7) : Colors.grey.shade300,
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
