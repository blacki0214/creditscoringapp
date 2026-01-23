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
  PageController _pageController = PageController();

  final List<OnboardingContent> _pages = [
    OnboardingContent(
      image: 'assets/images/splash1.png',
      title: 'Unlock Your Financial Future',
      description: 'Get instant access to your credit score and personalized financial insights',
    ),
    OnboardingContent(
      image: 'assets/images/splash2.png',
      title: 'Track Your Credit Journey',
      description: 'Monitor your credit score changes and receive alerts for important updates',
    ),
    OnboardingContent(
      image: 'assets/images/splash3.png',
      title: 'Smart Financial Decisions',
      description: 'Make informed choices with personalized recommendations and credit tips',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize PageController with current page from ViewModel
    final viewModel = context.read<OnboardingViewModel>();
     _pageController = PageController(initialPage: viewModel.currentPage); 
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F3F),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _navigateToLogin(),
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  viewModel.setCurrentPage(index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildIndicator(index == viewModel.currentPage),
              ),
            ),
            const SizedBox(height: 40),
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (viewModel.currentPage == _pages.length - 1) {
                      _navigateToLogin();
                    } else {
                       viewModel.setCurrentPage(viewModel.currentPage + 1);
                      _pageController.animateToPage(
                        viewModel.currentPage, // It's already updated
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A1F3F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    viewModel.currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingContent content) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            content.image,
            height: 300,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.credit_score,
                  size: 120,
                  color: Colors.white38,
                ),
              );
            },
          ),
          const SizedBox(height: 48),
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// Navigate to login page after onboarding is complete
  /// Marks onboarding as seen to prevent showing it again after logout
  void _navigateToLogin() {
    // Mark onboarding as seen before navigating
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
  final String image;
  final String title;
  final String description;

  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}
