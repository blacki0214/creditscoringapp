import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/loan_viewmodel.dart';
import '../services/local_storage_service.dart';
import '../loan/loan_application_page.dart';
import '../loan/demo_calculator_page.dart';
import '../settings/settings_page.dart';
import '../settings/profile_page.dart';
import '../settings/support_page.dart';
import '../auth/login_page.dart';

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
                          // Handle logout - navigate to login page
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
                        // Content based on selected period
                        if (viewModel.selectedPeriod == 'Current year') ...[
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
                        ] else if (viewModel.selectedPeriod == 'Loans') ...[
                          // Loan display section
                          _buildLoanDisplay(context),
                        ] else if (viewModel.selectedPeriod == 'Hards') ...[
                          // Hards section - placeholder
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.warning_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No hard inquiries',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Your credit record is clean',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                _buildNavItem(context, viewModel, Icons.calculate, 'Demo', 2),
                _buildNavItem(context, viewModel, Icons.settings_outlined, 'Settings', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoanDisplay(BuildContext context) {
    final loanViewModel = context.watch<LoanViewModel>();
    final applicationHistory = LocalStorageService.getApplicationHistory();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Loan Offer Section
        if (loanViewModel.currentOffer != null) ...[
          const Text(
            'Current Loan Offer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1F3F),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: loanViewModel.currentOffer!.approved 
                ? const Color(0xFFE8F5E9) 
                : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: loanViewModel.currentOffer!.approved
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFEF5350),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loanViewModel.currentOffer!.approved ? 'APPROVED' : 'REJECTED',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: loanViewModel.currentOffer!.approved
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFEF5350),
                      ),
                    ),
                    Icon(
                      loanViewModel.currentOffer!.approved
                        ? Icons.check_circle
                        : Icons.cancel,
                      color: loanViewModel.currentOffer!.approved
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFEF5350),
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (loanViewModel.currentOffer!.approved) ...[
                  _buildLoanDetailRow(
                    'Loan Amount',
                    currencyFormat.format(loanViewModel.currentOffer!.loanAmountVnd),
                  ),
                  const SizedBox(height: 12),
                  if (loanViewModel.currentOffer!.interestRate != null)
                    Column(
                      children: [
                        _buildLoanDetailRow(
                          'Interest Rate',
                          '${loanViewModel.currentOffer!.interestRate!.toStringAsFixed(2)}% / year',
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  if (loanViewModel.currentOffer!.monthlyPaymentVnd != null)
                    Column(
                      children: [
                        _buildLoanDetailRow(
                          'Monthly Payment',
                          currencyFormat.format(loanViewModel.currentOffer!.monthlyPaymentVnd),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  if (loanViewModel.currentOffer!.loanTermMonths != null)
                    Column(
                      children: [
                        _buildLoanDetailRow(
                          'Loan Term',
                          '${loanViewModel.currentOffer!.loanTermMonths} months',
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  _buildLoanDetailRow(
                    'Credit Score',
                    '${loanViewModel.currentOffer!.creditScore}',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Viewing loan terms...'),
                                backgroundColor: Color(0xFF4C40F7),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4C40F7),
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFF4C40F7)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('View Terms'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Processing loan acceptance...'),
                                backgroundColor: Color(0xFF4CAF50),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Accept Loan'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Center(
                    child: Column(
                      children: [
                        Text(
                          loanViewModel.currentOffer!.approvalMessage,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFEF5350),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        _buildLoanDetailRow(
                          'Credit Score',
                          '${loanViewModel.currentOffer!.creditScore}',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
        ] else if (loanViewModel.isProcessing) ...[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C40F7)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Processing your loan application...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1F3F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.money_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Active Loan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a new loan application',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoanApplicationPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C40F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Apply Now'),
                ),
              ],
            ),
          ),
        ],
        // Application History Section
        if (applicationHistory.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text(
            'Application History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1F3F),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: applicationHistory.length,
            itemBuilder: (context, index) {
              final app = applicationHistory[index];
              final timestamp = app['timestamp'] != null
                ? DateTime.parse(app['timestamp'])
                : DateTime.now();
              final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
              final isApproved = app['approved'] == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isApproved
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF5350),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isApproved ? Icons.check_circle : Icons.cancel,
                      color: isApproved
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFEF5350),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isApproved ? 'Approved' : 'Rejected',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isApproved
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFEF5350),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Score: ${app['creditScore'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1F3F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Amount: ${app['loanAmount'] != null ? currencyFormat.format(app['loanAmount']) : 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLoanDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F3F),
          ),
        ),
      ],
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
          // Navigate to demo calculator
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DemoCalculatorPage(),
            ),
          );
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
