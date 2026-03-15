import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'otp_page.dart';
import 'login_page.dart';
import 'email_verification_page.dart';
import '../utils/app_localization.dart';

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
  final _nameFieldKey = GlobalKey<FormFieldState<String>>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();
  final _phoneFieldKey = GlobalKey<FormFieldState<String>>();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        _nameFieldKey.currentState?.validate();
      }
    });
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        _emailFieldKey.currentState?.validate();
      }
    });
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        _passwordFieldKey.currentState?.validate();
      }
    });
    _phoneFocusNode.addListener(() {
      if (!_phoneFocusNode.hasFocus) {
        _phoneFieldKey.currentState?.validate();
      }
    });
  }
  
  /// Validate password syntax: min 8 chars, 1 uppercase, 1 number
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.t('Please enter your password', 'Vui lòng nhập mật khẩu');
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

  /// Validate email format: must be a Gmail address (required)
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return context.t('Please enter your email', 'Vui lòng nhập email');
    }
    // Enforce Gmail format
    final emailRegex = RegExp(r'^[A-Z0-9._%+-]+@gmail\.com$', caseSensitive: false);
    if (!emailRegex.hasMatch(value)) {
      return context.t('Please enter a valid Gmail address', 'Vui lòng nhập địa chỉ Gmail hợp lệ');
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
      return context.t('Phone number must be 10 digits', 'Số điện thoại phải có 10 chữ số');
    }
    if (!cleaned.startsWith('0')) {
      return context.t('Phone number must start with 0', 'Số điện thoại phải bắt đầu bằng 0');
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
                      ? context.t('Create Account', 'Tạo tài khoản')
                        : viewModel.signupStep == 1
                        ? context.t('Phone Number (Optional)', 'Số điện thoại (không bắt buộc)')
                        : context.t('Profile Picture', 'Ảnh hồ sơ'),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F3F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.signupStep == 0
                      ? context.t('Enter your details to get started', 'Nhập thông tin để bắt đầu')
                        : viewModel.signupStep == 1
                        ? context.t('Add phone for verification (optional)', 'Thêm số điện thoại để xác thực (không bắt buộc)')
                        : context.t('Add profile picture (optional)', 'Thêm ảnh hồ sơ (không bắt buộc)'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Step 0: Name, Email, Password
                  if (viewModel.signupStep == 0) ...[
                    TextFormField(
                      key: _nameFieldKey,
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      maxLength: 30,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(30),
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[\p{L}\p{M}\s]", unicode: true),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: context.t('Full Name', 'Họ và tên'),
                        hintText: context.t('Enter your full name', 'Nhập họ và tên'),
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
                          return context.t('Please enter your name', 'Vui lòng nhập họ tên');
                        }
                        if (value.trim().length < 2) {
                          return context.t('Name must be at least 2 characters', 'Tên phải có ít nhất 2 ký tự');
                        }
                        if (!RegExp(r"^[\p{L}\p{M}\s]+$", unicode: true)
                            .hasMatch(value)) {
                          return context.t('Name can only contain letters and spaces', 'Tên chỉ được chứa chữ cái và khoảng trắng');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      key: _emailFieldKey,
                      controller: _emailController,
                      maxLength: 50,
                      keyboardType: TextInputType.emailAddress,
                      focusNode: _emailFocusNode,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      decoration: InputDecoration(
                        labelText: context.t('Email', 'Email'),
                        hintText: context.t('Enter your email', 'Nhập email của bạn'),
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
                      key: _passwordFieldKey,
                      controller: _passwordController,
                      maxLength: 50,
                      focusNode: _passwordFocusNode,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      obscureText: viewModel.obscurePassword,
                      decoration: InputDecoration(
                        labelText: context.t('Password', 'Mật khẩu'),
                        hintText: context.t('Enter password', 'Nhập mật khẩu'),
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
                        child: Text(
                          context.t('Continue', 'Tiếp tục'),
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
                      key: _phoneFieldKey,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      focusNode: _phoneFocusNode,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: context.t('Phone Number (Optional)', 'Số điện thoại (không bắt buộc)'),
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
                            : Text(
                              context.t('Continue', 'Tiếp tục'),
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
                      child: Text(
                        context.t('Skip', 'Bỏ qua'),
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
                        child: Text(
                          context.t('Choose from gallery', 'Chọn từ thư viện'),
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
                            context.t('Remove photo', 'Xóa ảnh'),
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
                            : Text(
                              context.t('Complete', 'Hoàn tất'),
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
                        child: Text(
                          context.t('Skip', 'Bỏ qua'),
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
                          context.t('Already have an account? ', 'Đã có tài khoản? '),
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
                          child: Text(
                            context.t('Sign in', 'Đăng nhập'),
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
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }
}
