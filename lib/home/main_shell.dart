import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../loan/loan_application_page.dart';
import '../settings/settings_page.dart';
import '../loan/demo_calculator_page.dart';
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

  final List<Widget> _pages = const [
    HomePage(),
    LoanApplicationPage(),
    DemoCalculatorPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 0),
                _buildNavItem(Icons.upload_file, 1),
                _buildNavItem(Icons.calculate, 2),
                _buildNavItem(Icons.settings_outlined, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isCurrentlySelected = _selectedIndex == index;
    final wasPreviouslySelected = _previousIndex == index;
    final inactiveColor = Colors.grey.shade600;
    const activeColor = Color(0xFF4C40F7);

    return GestureDetector(
      onTap: () {
        setState(() {
          _previousIndex = _selectedIndex;
          _selectedIndex = index;
        });
        _animationController.forward(from: 0.0);
      },
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
            size: 24,
          );
        },
      ),
    );
  }
}
