import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import '../services/local_storage_service.dart';
import '../utils/app_localization.dart';
import 'onboarding_page.dart';
import '../auth/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule initialization after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  /// Initialize app and determine next screen based on onboarding status
  /// If user has seen onboarding before, skip to login
  /// Otherwise, show onboarding splash screens for first-time users
  Future<void> _initializeApp() async {
    await context.read<OnboardingViewModel>().initializeApp();
    if (mounted) {
      // Check if user has already seen onboarding
      final hasSeenOnboarding = LocalStorageService.hasSeenOnboarding();

      if (hasSeenOnboarding) {
        // User has completed onboarding before, go to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        // First time user, show onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingVm = context.watch<OnboardingViewModel>();
    return Scaffold(
      backgroundColor: const Color(0xFF0C0F11),
      body: Stack(
        children: [
          // Animated gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0C0F11), Color(0xFF1a1f2e)],
              ),
            ),
          ),
          // Decorative blur elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4A52FF).withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A52FF).withValues(alpha: 0.2),
                    blurRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7E85FF).withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7E85FF).withValues(alpha: 0.2),
                    blurRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo container with gradient
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4A52FF), Color(0xFF7E85FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A52FF).withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/SwinCredit_logo2.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.wallet,
                        size: 40,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFF4A52FF), Color(0xFF7E85FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'VietCredit',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  context.t('FINANCIAL ATELIER', 'ATELIER TÀI CHÍNH'),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
          // Loading indicator at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (!onboardingVm.apiHealthy) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB45309).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      onboardingVm.apiHealthMessage ??
                          context.t(
                            'Temporary connection issue. Please try again.',
                            'Kết nối tạm thời gián đoạn. Vui lòng thử lại.',
                          ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                Text(
                  context.t('Initializing', 'Đang khởi tạo...'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF7E85FF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
