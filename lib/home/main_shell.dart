import 'package:flutter/material.dart';
import '../loan/loan_application_page.dart';
import '../settings/settings_page.dart';
import '../loan/demo_calculator_page.dart';
import '../loan/student_verification_gate_page.dart';
import 'home_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  late AnimationController _animationController;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(onOpenSettings: () => _onNavItemTap(4)),
      const LoanApplicationPage(),
      const DemoCalculatorPage(),
      const StudentVerificationGatePage(),
      const SettingsPage(),
    ];
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Keep Home highlighted on first load before any tap animation runs.
    _animationController.value = 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 360;
            final horizontalPadding = isCompact ? 8.0 : 16.0;
            final verticalPadding = isCompact ? 8.0 : 10.0;
            final iconSize = isCompact ? 24.0 : 26.0;

            return Container(
              constraints: BoxConstraints(minHeight: isCompact ? 68 : 76),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildNavItem(Icons.home, 0, iconSize)),
                    Expanded(
                      child: _buildNavItem(Icons.upload_file, 1, iconSize),
                    ),
                    Expanded(
                      child: _buildNavItem(Icons.calculate, 2, iconSize),
                    ),
                    Expanded(
                      child: _buildNavItem(Icons.school_outlined, 3, iconSize),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        Icons.settings_outlined,
                        4,
                        iconSize,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onNavItemTap(int index) {
    if (!mounted) return;
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
    _animationController.forward(from: 0.0);
  }

  Widget _buildNavItem(IconData icon, int index, double iconSize) {
    final isCurrentlySelected = _selectedIndex == index;
    final wasPreviouslySelected = _previousIndex == index;
    final inactiveColor = Colors.grey.shade600;
    const activeColor = Color(0xFF4D4AF9);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _onNavItemTap(index);
      },
      child: SizedBox(
        height: 52,
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              double animationValue;

              if (isCurrentlySelected) {
                // Item becoming selected: animate from grey to blue
                animationValue = _animationController.value;
              } else if (wasPreviouslySelected) {
                // Item being deselected: animate from blue to grey
                animationValue = 1.0 - _animationController.value;
              } else {
                // Item not involved in animation: stay grey
                animationValue = 0.0;
              }

              return Icon(
                icon,
                color: Color.lerp(inactiveColor, activeColor, animationValue),
                size: iconSize,
              );
            },
          ),
        ),
      ),
    );
  }
}
