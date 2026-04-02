import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../home/main_shell.dart';
import '../services/local_storage_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'forgot_password.dart';
import 'phone_login_page.dart';
import 'signup_page.dart';
import 'termOfService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tosLinkRecognizer = TapGestureRecognizer();
  bool _isTosDialogVisible = false;
  bool _tosDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          !_tosDialogShown &&
          !LocalStorageService.hasAcceptedTos()) {
        _showTosDialog();
      }
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8 ||
        !value.contains(RegExp(r'[A-Z]')) ||
        !value.contains(RegExp(r'[0-9]'))) {
      return 'Invalid password';
    }
    return null;
  }

  Future<void> _showTosDialog() async {
    setState(() {
      _isTosDialogVisible = true;
      _tosDialogShown = true;
    });

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Terms of Service',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Color(0xFF676B78),
                    ),
                    children: [
                      const TextSpan(text: 'I agree to '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3F4BFF),
                        ),
                        recognizer: _tosLinkRecognizer
                          ..onTap = () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TermOfServicePage(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Decline'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Agree to all'),
                ),
              ],
            ),
          ),
        );
      },
    );

    setState(() {
      _isTosDialogVisible = false;
    });

    if (accepted == true) {
      await LocalStorageService.markTosAccepted();
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final size = MediaQuery.of(context).size;
    final isSmallDevice = size.height < 760 || size.width < 380;
    final headingSize = isSmallDevice ? 42.0 : 54.0;
    final subtitleSize = isSmallDevice ? 16.0 : 20.0;
    final accountTextSize = isSmallDevice ? 16.0 : 22.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, isSmallDevice ? 8 : 18, 24, 18),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _LoginBrandHeader(),
                    SizedBox(height: isSmallDevice ? 14 : 26),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: headingSize,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E222B),
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please enter your details to sign in',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: const Color(0xFF5B5F69),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSignInCard(viewModel),
                    SizedBox(height: isSmallDevice ? 18 : 28),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 2,
                      runSpacing: 0,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: accountTextSize,
                            color: const Color(0xFF3F4450),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<AuthViewModel>().reset();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Create account',
                            style: TextStyle(
                              color: Color(0xFF3445FF),
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Privacy Policy    •    Terms of Service    •    Help Center',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF636876).withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isTosDialogVisible)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(color: Colors.black.withOpacity(0.06)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInCard(AuthViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Email Address',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF4A4F59),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            maxLength: 50,
            inputFormatters: [
              LengthLimitingTextInputFormatter(50),
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            validator: _validateEmail,
            decoration: InputDecoration(
              counterText: '',
              hintText: 'name@company.com',
              hintStyle: const TextStyle(color: Color(0xFFA2A7B2)),
              filled: true,
              fillColor: const Color(0xFFEEF0F4),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Color(0xFFA0A5AF),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Color(0xFF5863FF),
                  width: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF4A4F59),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordPage(),
                    ),
                  );
                },
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3BFF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: viewModel.obscurePassword,
            maxLength: 50,
            inputFormatters: [
              LengthLimitingTextInputFormatter(50),
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            validator: _validatePassword,
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••••••',
              hintStyle: const TextStyle(
                color: Color(0xFFA2A7B2),
                letterSpacing: 2,
              ),
              filled: true,
              fillColor: const Color(0xFFEEF0F4),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Color(0xFFA0A5AF),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  viewModel.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFFA0A5AF),
                ),
                onPressed: context
                    .read<AuthViewModel>()
                    .togglePasswordVisibility,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Color(0xFF5863FF),
                  width: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF3F4BFF), Color(0xFF7C88FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B66FF).withOpacity(0.32),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SizedBox(
              height: 62,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await viewModel.signInWithEmail(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                          if (success && mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainShell(),
                              ),
                            );
                          }
                        }
                      },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          if (viewModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              viewModel.errorMessage!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFD7DAE0))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR CONTINUE WITH',
                  style: TextStyle(
                    color: const Color(0xFF6B707D).withOpacity(0.6),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFFD7DAE0))),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _smallAuthButton(
                  label: 'Google',
                  icon: Image.asset(
                    'assets/images/gg_logo.png',
                    height: 20,
                    width: 20,
                  ),
                  onTap: () async {
                    final success = await context
                        .read<AuthViewModel>()
                        .signInWithGoogle();
                    if (success && context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainShell()),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _smallAuthButton(
                  label: 'Phone',
                  icon: const Icon(
                    Icons.phone_android_rounded,
                    color: Color(0xFF1E222B),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PhoneLoginPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallAuthButton({
    required String label,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 64,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFEEF0F4),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1E222B),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tosLinkRecognizer.dispose();
    super.dispose();
  }
}

class _LoginBrandHeader extends StatelessWidget {
  const _LoginBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.tips_and_updates_rounded,
          color: Color(0xFF3445FF),
          size: 42,
        ),
        SizedBox(width: 10),
        Text(
          'Lumina Finance',
          style: TextStyle(
            color: Color(0xFF3445FF),
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}
