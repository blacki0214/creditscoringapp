import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import '../auth/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;

  final List<OnboardingContent> _pages = [
    OnboardingContent(
      icon: Icons.account_balance_wallet,
      title: 'Unlock Your\nFinancial Future',
      description: 'Personalized credit scoring tailored to your lifestyle and financial aspirations.',
      gradientStart: const Color(0xFF4A52FF),
      gradientEnd: const Color(0xFF7E85FF),
    ),
    OnboardingContent(
      icon: Icons.trending_up,
      title: 'Track Your\nCredit Journey',
      description: 'Global security standards protecting your data across every border.',
      gradientStart: const Color(0xFF7E85FF),
      gradientEnd: const Color(0xFF4A52FF),
    ),
    OnboardingContent(
      icon: Icons.lightbulb,
      title: 'Smart Financial\nDecisions',
      description: 'Harness AI-driven insights to optimize your spending and boost your score.',
      gradientStart: const Color(0xFF4A52FF),
      gradientEnd: const Color(0xFF475569),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<OnboardingViewModel>();
    _pageController = PageController(initialPage: viewModel.currentPage);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            // PageView
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                viewModel.setCurrentPage(index);
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPage(_pages[index], index);
              },
            ),
            // Header with Skip button
            Positioned(
              top: 16,
              right: 16,
              child: viewModel.currentPage < _pages.length - 1
                  ? GestureDetector(
                      onTap: _navigateToLogin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: const Color(0xFF4A52FF),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFF4A52FF),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            // Bottom indicators and buttons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingContent content, int index) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 60),
          // Hero icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  content.gradientStart,
                  content.gradientEnd,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: content.gradientStart.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(
              content.icon,
              size: 70,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 60),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              content.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 36,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              content.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBottomBar(OnboardingViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildIndicator(index == viewModel.currentPage),
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (viewModel.currentPage == _pages.length - 1) {
                    _navigateToLogin();
                  } else {
                    viewModel.setCurrentPage(viewModel.currentPage + 1);
                    _pageController.animateToPage(
                      viewModel.currentPage,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A52FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      viewModel.currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (viewModel.currentPage < _pages.length - 1) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      height: 8,
      width: isActive ? 28 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF4A52FF)
            : const Color(0xFF4A52FF).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _navigateToLogin() {
    context.read<OnboardingViewModel>().completeOnboarding();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingContent {
  final IconData icon;
  final String title;
  final String description;
  final Color gradientStart;
  final Color gradientEnd;

  OnboardingContent({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientStart,
    required this.gradientEnd,
  });
}
