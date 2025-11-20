import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController controller = PageController();
  int currentIndex = 0;

  final List<Map<String, dynamic>> splashData = [
    {
      "image": "assets/images/splash1.png", 
      "title": "Check your credit score\nin seconds",
      "subtitle": "Get instant access to your credit score and\npersonalized financial insights.",
    },
    {
      "image": "assets/images/splash2.png",
      "title": "Secure eKYC\nverification",
      "subtitle": "Your identity is verified using bank-grade\nsecurity technology.",
    },
    {
      "image": "assets/images/splash3.png",
      "title": "AI-powered scoring using\nalternative data",
      "subtitle": "Our advanced AI analyzes multiple data\npoints for accurate credit assessment.",
    },
    {
      "image": "assets/images/splash4.png",
      "title": "Get your credit limit\ninstantly",
      "subtitle": "Receive your personalized credit limit and\nloan recommendations in real-time.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                },
                itemCount: splashData.length,
                itemBuilder: (context, index) {
                  return _buildPage(
                    size,
                    splashData[index]["image"] as String,
                    splashData[index]["title"] as String,
                    splashData[index]["subtitle"] as String,
                  );
                },
              ),
            ),

            // dots indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  splashData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: currentIndex == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: currentIndex == index 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            if (currentIndex != 0)
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: _navButton(
                  label: "Back",
                  icon: Icons.arrow_back,
                  isPrimary: false,
                  onTap: () async {
                    controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                ),
              )
            else
              const SizedBox(width: 100),

            // Next or Get started
            _navButton(
              label: currentIndex == splashData.length - 1
                  ? "Get Started"
                  : "Next",
              icon: Icons.arrow_forward,
              isPrimary: true,
              onTap: () async {
                if (currentIndex == splashData.length - 1) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isFirstTime', false);
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                } else {
                  controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildPage(Size size, String imagePath, String title, String subtitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        
        
        // Image container 
        Container(
          width: size.width * 0.85,
          height: size.height * 0.28, 
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.white,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                );
              },
            ),
          ),
        ),
        
        const SizedBox(height: 40), 
        
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
        ),
        
        const SizedBox(height: 12), 
        
        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13, // Giảm từ 14 xuống 13
              color: Colors.white.withOpacity(0.95),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _navButton({
    required String label, 
    required IconData icon,
    required bool isPrimary,
    required Future<void> Function() onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.transparent,
          border: isPrimary ? null : Border.all(color: Colors.white, width: 1.5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isPrimary) ...[
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isPrimary ? const Color(0xFF4CAF50) : Colors.white,
              ),
            ),
            if (isPrimary) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: const Color(0xFF4CAF50)),
            ],
          ],
        ),
      ),
    );
  }
}
