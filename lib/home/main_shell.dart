import 'package:flutter/material.dart';
import '../loan/loan_application_page.dart';
import '../settings/settings_page.dart';
import '../loan/demo_calculator_page.dart';
import '../loan/student_hub_page.dart';
import 'home_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(
        onOpenSettings: () => _onNavItemTap(4),
        onOpenStudent: () => _onNavItemTap(3),
        onOpenApplication: () => _onNavItemTap(1),
      ),
      const LoanApplicationPage(),
      const DemoCalculatorPage(),
      const StudentHubPage(),
      const SettingsPage(),
    ];
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
                    Expanded(
                      child: _buildNavItem(
                        Icons.home,
                        context,
                        0,
                        iconSize,
                        'Home',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        Icons.upload_file,
                        context,
                        1,
                        iconSize,
                        'Application',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        Icons.calculate,
                        context,
                        2,
                        iconSize,
                        'Demo',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        Icons.school_outlined,
                        context,
                        3,
                        iconSize,
                        'Student',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        Icons.settings_outlined,
                        context,
                        4,
                        iconSize,
                        'Settings',
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
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem(
    IconData icon,
    BuildContext context,
    int index,
    double iconSize,
    String label,
  ) {
    final isCurrentlySelected = _selectedIndex == index;
    final inactiveColor = Colors.grey.shade500;
    const activeColor = Color(0xFF4D4AF9);
    final iconColor = isCurrentlySelected ? activeColor : inactiveColor;

    return SizedBox(
      height: 52,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: isCurrentlySelected
              ? const Color(0xFFEEF0FF)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onNavItemTap(index),
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: iconColor, size: iconSize),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
