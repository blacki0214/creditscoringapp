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

  final List<_SlideContent> _slides = const [
    _SlideContent(
      title: 'VietCreditScore',
      subtitle: 'THE FINANCIAL ATELIER',
      description: '',
      buttonLabel: '',
      isDarkIntro: true,
    ),
    _SlideContent(
      title: 'Unlock Your\nFinancial Future',
      subtitle: '',
      description:
          'Personalized credit scoring tailored to your lifestyle and financial aspirations.',
      buttonLabel: 'Next',
    ),
    _SlideContent(
      title: 'Track Your\nCredit Journey',
      subtitle: '',
      description:
          'Global security standards protecting your data across every border.',
      buttonLabel: 'Next',
    ),
    _SlideContent(
      title: 'Smart Financial\nDecisions',
      subtitle: '',
      description:
          'Harness AI-driven insights to optimize your spending and boost your score.',
      buttonLabel: 'Get Started',
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

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _slides.length,
        onPageChanged: vm.setCurrentPage,
        itemBuilder: (context, index) {
          final slide = _slides[index];
          if (slide.isDarkIntro) {
            return _IntroPage(
              onNext: () => _goToNext(index),
            );
          }

          return _LightSlidePage(
            content: slide,
            isLast: index == _slides.length - 1,
            onPressed: () {
              if (index == _slides.length - 1) {
                _navigateToLogin();
              } else {
                _goToNext(index);
              }
            },
            visual: switch (index) {
              1 => const _ScoreCardVisual(),
              2 => const _SecurityVisual(),
              _ => const _AiCardsVisual(),
            },
          );
        },
      ),
    );
  }

  void _goToNext(int index) {
    final next = index + 1;
    if (next < _slides.length) {
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
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

class _SlideContent {
  final String title;
  final String subtitle;
  final String description;
  final String buttonLabel;
  final bool isDarkIntro;

  const _SlideContent({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.buttonLabel,
    this.isDarkIntro = false,
  });
}

class _IntroPage extends StatelessWidget {
  final VoidCallback onNext;

  const _IntroPage({
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF03060E), Color(0xFF050910)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(
                'assets/images/SwinCredit_logo2.png',
                width: 82,
                height: 82,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text(
                'VietCreditScore',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'THE FINANCIAL ATELIER',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.52),
                  fontSize: 11,
                  letterSpacing: 2.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _Dot(active: true),
                  SizedBox(width: 6),
                  _Dot(),
                  SizedBox(width: 6),
                  _Dot(),
                  SizedBox(width: 6),
                  _Dot(),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 88,
                child: TextButton(
                  onPressed: onNext,
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Color(0xFF6E7BFF)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LightSlidePage extends StatelessWidget {
  final _SlideContent content;
  final Widget visual;
  final VoidCallback onPressed;
  final bool isLast;

  const _LightSlidePage({
    required this.content,
    required this.visual,
    required this.onPressed,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E9ED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.title,
                style: const TextStyle(
                  color: Color(0xFF24262D),
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  height: 1.02,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                content.description,
                style: const TextStyle(
                  color: Color(0xFF757984),
                  fontSize: 18,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 26),
              Expanded(child: Center(child: visual)),
              const SizedBox(height: 24),
              _PrimaryButton(
                label: content.buttonLabel,
                onPressed: onPressed,
              ),
              if (isLast) ...[
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'PREMIUM FINANCIAL EXPERIENCE',
                    style: TextStyle(
                      color: const Color(0xFF787D88).withValues(alpha: 0.6),
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C56F8).withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF3A43EC), Color(0xFF7D87F9)],
        ),
      ),
      child: SizedBox(
        height: 62,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreCardVisual extends StatelessWidget {
  const _ScoreCardVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFD9DCE1),
                  shape: BoxShape.circle,
                ),
              ),
              const Text(
                '...',
                style: TextStyle(
                  color: Color(0xFF7F828D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 184,
                  height: 184,
                  child: CircularProgressIndicator(
                    value: 0.78,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFFD0D3DA),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF666EF8),
                    ),
                  ),
                ),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '782',
                      style: TextStyle(
                        color: Color(0xFF20232A),
                        fontSize: 46,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'EXCELLENT',
                      style: TextStyle(
                        color: Color(0xFF178E67),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFDADDE3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 12,
              width: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFDADDE3),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityVisual extends StatelessWidget {
  const _SecurityVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFCCD2FF),
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
          ),
          Container(
            width: 122,
            height: 122,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFC),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Color(0xFF3C46EF),
              size: 54,
            ),
          ),
          Positioned(
            right: 30,
            top: 44,
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: const Color(0xFF5AE2A5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.public,
                color: Color(0xFF0A4E31),
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiCardsVisual extends StatelessWidget {
  const _AiCardsVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5F7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A53F4), Color(0xFF7D88F9)],
                    ),
                  ),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Brain',
                      style: TextStyle(
                        color: Color(0xFF24262D),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Active Analysis',
                      style: TextStyle(
                        color: Color(0xFF7B7F88),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 122,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC2F1DA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.trending_up_rounded, color: Color(0xFF08603E)),
                      Spacer(),
                      Text(
                        '+12 pts',
                        style: TextStyle(
                          color: Color(0xFF0C6242),
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        'PREDICTED',
                        style: TextStyle(
                          color: Color(0xFF317961),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 122,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E1C8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.insights_rounded, color: Color(0xFF755321)),
                      Spacer(),
                      Text(
                        'Smart',
                        style: TextStyle(
                          color: Color(0xFF6A4A1B),
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        'ADVICE',
                        style: TextStyle(
                          color: Color(0xFF876435),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;

  const _Dot({this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 28 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF4250FF) : Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
