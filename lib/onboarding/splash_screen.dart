import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import '../services/local_storage_service.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F3F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 350,
              height: 350,
            ),
            const SizedBox(height: 24),
            const Text(
              'VietCredit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'SCORE',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w300,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
