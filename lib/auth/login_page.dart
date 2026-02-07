import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'signup_page.dart';
import 'forgot_password.dart';
import 'phone_login_page.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _acceptedTos = false;
  bool _showTosText = false;
  final Map<String, GlobalKey<FormFieldState>> _fieldKeys = {};
  final Map<String, FocusNode> _fieldFocusNodes = {};
  final Map<String, bool> _touchedFields = {};

  /// Validate email format
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
                  const Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F3F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 40),
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
                      counterText: '',
                    ),
                    validator: (value) =>
                      _validateIfTouched('email', _validateEmail, value),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: _fieldKey('password'),
                    controller: _passwordController,
                    focusNode: _fieldFocus('password'),
                    maxLength: 50,
                    obscureText: viewModel.obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
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
                    validator: (value) =>
                        _validateIfTouched('password', _validatePassword, value),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
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
                          color: Color(0xFF4C40F7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Opacity(
                    opacity: _acceptedTos ? 1 : 0.5,
                    child: IgnorePointer(
                      ignoring: !_acceptedTos,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () async {
                                      _markAllTouched(['email', 'password']);
                                      if (_formKey.currentState!.validate()) {
                                        final success = await viewModel.signInWithEmail(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text.trim(),
                                        );

                                        if (success && mounted) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (_) => const HomePage()),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4C40F7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: viewModel.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Sign in',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const PhoneLoginPage(),
                                        ),
                                      );
                                    },
                              icon: const Icon(Icons.phone_outlined, color: Color(0xFF4C40F7)),
                              label: const Text(
                                'Sign in with Phone',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4C40F7),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF4C40F7), width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () async {
                                      final success = await context.read<AuthViewModel>().signInWithGoogle();
                                      if (success && context.mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const HomePage(),
                                          ),
                                        );
                                      }
                                    },
                              icon: Image.asset(
                                'assets/images/gg_logo.png',
                                height: 24,
                                width: 24,
                              ),
                              label: const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1F3F),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptedTos,
                              onChanged: (value) {
                                setState(() {
                                  _acceptedTos = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF4C40F7),
                            ),
                            Expanded(
                              child: Wrap(
                                children: [
                                  const Text(
                                    'I agree to the ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1F3F),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _showTosText = !_showTosText;
                                      });
                                    },
                                    child: const Text(
                                      'Terms of Service',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4C40F7),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 220),
                          firstChild: const SizedBox.shrink(),
                          secondChild: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Text(
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF4A4F6A),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                          crossFadeState: _showTosText
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey.shade700),
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
                          'Sign up',
                          style: TextStyle(
                            color: Color(0xFF4C40F7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
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

  @override
  void dispose() {
    for (final node in _fieldFocusNodes.values) {
      node.dispose();
    }
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
