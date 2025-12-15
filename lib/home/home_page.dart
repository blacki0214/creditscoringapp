import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../viewmodels/home_viewmodel.dart';
import '../loan/loan_application_page.dart';
import '../settings/settings_page.dart';
import '../settings/profile_page.dart';
import '../settings/support_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F3F),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatar with menu
                  PopupMenuButton(
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.settings_outlined, color: Colors.grey.shade700, size: 20),
                            const SizedBox(width: 12),
                            const Text('Settings'),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, color: Colors.grey.shade700, size: 20),
                            const SizedBox(width: 12),
                            const Text('Profile'),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfilePage(),
                            ),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.support_agent_outlined, color: Colors.grey.shade700, size: 20),
                            const SizedBox(width: 12),
                            const Text('Support'),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SupportPage(),
                            ),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.logout, color: Colors.red, size: 20),
                            const SizedBox(width: 12),
                            const Text('Logout', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        onTap: () {
                          // Handle logout - navigate back to login
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/',
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                  const Column(
                    children: [
                      Text(
                        'Nguyen Van A',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Notification with menu
                  PopupMenuButton(
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1A1F3F),
                              ),
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        child: SizedBox(
                          width: 280,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4C40F7).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF4CAF50),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Loan Approved',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Your loan has been approved',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '2 hours ago',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        child: SizedBox(
                          width: 280,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4C40F7).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.trending_up,
                                      color: Color(0xFF4C40F7),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Credit Score Updated',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Your score increased by 20 points',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '1 day ago',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        child: SizedBox(
                          width: 280,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4C40F7).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.payment,
                                      color: Color(0xFFFFA726),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Payment Reminder',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Payment due in 3 days',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '3 days ago',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
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
            ),
            // Main content card
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting
                        const Text(
                          'Hello, Nguyen Van A',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1F3F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Here is your credit rate',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Period selector
                        Row(
                          children: [
                            _buildPeriodChip(context, viewModel, 'Current year'),
                            const SizedBox(width: 8),
                            _buildPeriodChip(context, viewModel, 'Loans'),
                            const SizedBox(width: 8),
                            _buildPeriodChip(context, viewModel, 'Hards'),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Credit score gauge
                        Center(
                          child: SizedBox(
                            width: 250,
                            height: 200,
                            child: CustomPaint(
                              painter: CreditScoreGaugePainter(score: 620),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 60),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '620',
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1F3F),
                                        ),
                                      ),
                                      Text(
                                        'Your credit score',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Score info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'starting score',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '600',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1F3F),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'change to date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '20',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1F3F),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Update button
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Updating your credit score...'),
                                  backgroundColor: Color(0xFF4C40F7),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE8F5E9),
                              foregroundColor: const Color(0xFF4CAF50),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Update your credit score',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Credit metrics grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                'Payment history',
                                '100%',
                                'On-time payments',
                                const Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                'Credit card use',
                                '2%',
                                'Of credit limit',
                                const Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                'Derogatory marks',
                                '0',
                                'Accounts',
                                const Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                'Credit age',
                                '7yrs',
                                'Average',
                                const Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                'Total accounts',
                                '28',
                                'Open and closed',
                                const Color(0xFFFFA726),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                'Hard inquiries',
                                '3',
                                'Last 2 years',
                                const Color(0xFFFFA726),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, viewModel, Icons.home, 'Home', 0),
                _buildNavItem(context, viewModel, Icons.upload_file, 'Upload', 1),
                _buildNavItem(context, viewModel, Icons.mail_outline, 'Messages', 2),
                _buildNavItem(context, viewModel, Icons.settings_outlined, 'Settings', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(BuildContext context, HomeViewModel viewModel, String label) {
    final isSelected = viewModel.selectedPeriod == label;
    return GestureDetector(
      onTap: () {
        viewModel.setPeriod(label);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viewing $label data'),
            backgroundColor: const Color(0xFF4C40F7),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1F3F) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    Color indicatorColor,
  ) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF252B4C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Value: $value',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text(
                  'This metric affects your credit score. Keep monitoring it regularly for the best results.',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: Color(0xFF4C40F7))),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F3F),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, HomeViewModel viewModel, IconData icon, String label, int index) {
    final isSelected = viewModel.selectedIndex == index;
    return InkWell(
      onTap: () {
        if (index == 1) {
          // Navigate to loan application
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LoanApplicationPage(),
            ),
          );
        } else if (index == 2) {
          // Messages functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Messages feature coming soon!'),
              backgroundColor: Color(0xFF4C40F7),
              duration: Duration(seconds: 2),
            ),
          );
          viewModel.setIndex(index);
        } else if (index == 3) {
          // Navigate to settings
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SettingsPage(),
            ),
          );
        } else {
          viewModel.setIndex(index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4C40F7) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CreditScoreGaugePainter extends CustomPainter {
  final int score;

  CreditScoreGaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.75);
    final radius = size.width * 0.4;
    final strokeWidth = 20.0;

    // Background arc
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Color segments
    final segments = [
      {'color': const Color(0xFFFF5252), 'start': 0.0, 'sweep': 0.25},
      {'color': const Color(0xFFFFA726), 'start': 0.25, 'sweep': 0.25},
      {'color': const Color(0xFFFFEB3B), 'start': 0.5, 'sweep': 0.25},
      {'color': const Color(0xFF4CAF50), 'start': 0.75, 'sweep': 0.25},
    ];

    for (var segment in segments) {
      final paint = Paint()
        ..color = segment['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi + (math.pi * (segment['start'] as double)),
        math.pi * (segment['sweep'] as double),
        false,
        paint,
      );
    }

    // Indicator needle
    final scorePercentage = ((score - 300) / (850 - 300)).clamp(0.0, 1.0);
    final angle = math.pi + (math.pi * scorePercentage);

    final needlePaint = Paint()
      ..color = const Color(0xFF1A1F3F)
      ..style = PaintingStyle.fill;

    final needleLength = radius - 10;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(angle),
      center.dy + needleLength * math.sin(angle),
    );

    // Draw needle circle
    canvas.drawCircle(center, 8, needlePaint);

    // Draw needle line
    final needleLinePaint = Paint()
      ..color = const Color(0xFF1A1F3F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needleLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
