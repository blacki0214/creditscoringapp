import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/login_page.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  final List<_LandingSlide> _slides = const [
    _LandingSlide(
      title: 'Unlock Your Financial Future',
      description:
          'Precision-engineered credit insights tailored to your unique financial footprint. Start your journey with VietCredit Score.',
    ),
    _LandingSlide(
      title: 'Track Your Journey',
      description:
          'Follow score movement, see monthly gains, and stay informed with concise status insights.',
    ),
    _LandingSlide(
      title: 'Smart Decisions',
      description:
          'Get practical loan recommendations and move confidently with clear next actions.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final vm = context.read<OnboardingViewModel>();
    _pageController = PageController(initialPage: vm.currentPage);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final currentIndex = vm.currentPage.clamp(0, _slides.length - 1);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF171C57), Color(0xFF020817)],
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _LandingHeader(),
                const SizedBox(height: 20),
                const _ScoreHeroRing(),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A2447).withOpacity(0.95),
                        const Color(0xFF121D3D).withOpacity(0.85),
                      ],
                    ),
                  ),
                  child: SizedBox(
                    height: 140,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: vm.setCurrentPage,
                      itemBuilder: (context, index) {
                        final slide = _slides[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slide.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                height: 1.16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              slide.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 15,
                                height: 1.45,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index == currentIndex ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index == currentIndex
                            ? const Color(0xFF5D67FF)
                            : Colors.white.withOpacity(0.26),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F5CFF).withOpacity(0.38),
                        blurRadius: 34,
                        offset: const Offset(0, 16),
                      ),
                    ],
                    gradient: const LinearGradient(
                      colors: [Color(0xFF444DF6), Color(0xFF8995FF)],
                    ),
                  ),
                  child: SizedBox(
                    height: 66,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: _navigateToLogin,
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: const [
                    Expanded(
                      child: _FeatureBadge(
                        icon: Icons.insights_rounded,
                        title: 'Track Your Journey',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _FeatureBadge(
                        icon: Icons.psychology_alt_rounded,
                        title: 'Smart Decisions',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'By continuing, you agree to Lumina Finance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.52),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    decoration: TextDecoration.underline,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
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

class _LandingSlide {
  final String title;
  final String description;

  const _LandingSlide({required this.title, required this.description});
}

class _LandingHeader extends StatelessWidget {
  const _LandingHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xFF5B66FF),
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Text(
          'Lumina Finance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}

class _ScoreHeroRing extends StatelessWidget {
  const _ScoreHeroRing();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 430,
      child: Stack(
        children: [
          Align(
            child: SizedBox(
              width: 360,
              height: 360,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 340,
                    height: 340,
                    child: CircularProgressIndicator(
                      value: 0.88,
                      strokeWidth: 28,
                      backgroundColor: Colors.white.withOpacity(0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF69EBC0),
                      ),
                    ),
                  ),
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0F1742),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.28),
                          blurRadius: 40,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'VIETCREDIT SCORE',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.62),
                            fontSize: 18,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '784',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF74F6B8),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'EXCELLENT',
                            style: TextStyle(
                              color: Color(0xFF042F25),
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
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
          Positioned(
            top: 52,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.16)),
                color: const Color(0xFF1A264B).withOpacity(0.92),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D4A5A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF74F6B8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '+12 pts',
                        style: TextStyle(
                          color: Color(0xFFD1FFF0),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Monthly gain',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.56),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A2447).withOpacity(0.90),
            const Color(0xFF0F1B38).withOpacity(0.80),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF9EA7FF)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
