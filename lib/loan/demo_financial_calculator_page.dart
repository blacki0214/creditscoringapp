import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class DemoFinancialCalculatorPage extends StatefulWidget {
  const DemoFinancialCalculatorPage({super.key});

  @override
  State<DemoFinancialCalculatorPage> createState() => _DemoFinancialCalculatorPageState();
}

class _DemoFinancialCalculatorPageState extends State<DemoFinancialCalculatorPage> {
  // Controllers for form inputs
  late TextEditingController _monthlyIncomeController;
  late TextEditingController _yearsEmployedController;
  late TextEditingController _creditYearsController;
  late TextEditingController _loanAmountController;

  // Form data
  String _employmentStatus = 'EMPLOYED';
  String _homeOwnership = 'RENT';
  bool _hasPreviousDefaults = false;
  bool _currentlyDefaulting = false;

  // Calculation results
  double _calculatedCreditScore = 0;
  String _riskLevel = '';
  Map<String, dynamic>? _calculationResult;

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final decimalFormat = NumberFormat('#,##0', 'vi_VN');

  @override
  void initState() {
    super.initState();
    _monthlyIncomeController = TextEditingController();
    _yearsEmployedController = TextEditingController();
    _creditYearsController = TextEditingController();
    _loanAmountController = TextEditingController();
  }

  @override
  void dispose() {
    _monthlyIncomeController.dispose();
    _yearsEmployedController.dispose();
    _creditYearsController.dispose();
    _loanAmountController.dispose();
    super.dispose();
  }

  void _calculateFinancialProfile() {
    // Validate inputs
    if (_monthlyIncomeController.text.isEmpty ||
        _yearsEmployedController.text.isEmpty ||
        _creditYearsController.text.isEmpty ||
        _loanAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Color(0xFFEF5350),
        ),
      );
      return;
    }

    try {
      final monthlyIncome = double.parse(_monthlyIncomeController.text);
      final yearsEmployed = double.parse(_yearsEmployedController.text);
      final creditYears = double.parse(_creditYearsController.text);
      final loanAmount = double.parse(_loanAmountController.text);

      // Calculate credit score (0-850 scale)
      double score = 300; // Base score

      // Employment stability (max +150)
      if (_employmentStatus == 'EMPLOYED') {
        score += 80;
        if (yearsEmployed >= 5) score += 40;
        if (yearsEmployed >= 10) score += 30;
      } else if (_employmentStatus == 'SELF_EMPLOYED') {
        score += 60;
        if (yearsEmployed >= 3) score += 30;
      }

      // Credit history (max +200)
      score += (creditYears * 15).clamp(0, 200);

      // Credit defaults (max -250)
      if (_hasPreviousDefaults) score -= 150;
      if (_currentlyDefaulting) score -= 250;

      // Home ownership (max +100)
      if (_homeOwnership == 'OWN') {
        score += 100;
      } else if (_homeOwnership == 'MORTGAGE') {
        score += 80;
      } else if (_homeOwnership == 'RENT') {
        score += 40;
      }

      // Debt-to-income ratio (max +50)
      double dti = loanAmount / (monthlyIncome * 12); // Annual debt / annual income
      if (dti < 0.36) {
        score += 50;
      } else if (dti < 0.43) {
        score += 30;
      } else if (dti < 0.50) {
        score += 10;
      }

      // Clamp score between 300 and 850
      score = score.clamp(300, 850);

      // Determine risk level
      late String riskLevel;
      if (score >= 740) {
        riskLevel = 'EXCELLENT';
      } else if (score >= 670) {
        riskLevel = 'GOOD';
      } else if (score >= 580) {
        riskLevel = 'FAIR';
      } else if (score >= 500) {
        riskLevel = 'POOR';
      } else {
        riskLevel = 'VERY POOR';
      }

      // Calculate interest rate based on score
      double interestRate = 20.0;
      if (score >= 740) {
        interestRate = 6.5;
      } else if (score >= 670) {
        interestRate = 9.5;
      } else if (score >= 580) {
        interestRate = 13.5;
      } else if (score >= 500) {
        interestRate = 17.5;
      }

        // Calculate monthly payment (36-month loan)
        int loanTermMonths = 36;
        double monthlyRate = interestRate / 100 / 12;
        double monthlyPayment = loanAmount *
          (monthlyRate * pow(1 + monthlyRate, loanTermMonths)) /
          (pow(1 + monthlyRate, loanTermMonths) - 1);

      setState(() {
        _calculatedCreditScore = score;
        _riskLevel = riskLevel;
        _calculationResult = {
          'creditScore': score.toInt(),
          'riskLevel': riskLevel,
          'interestRate': interestRate,
          'monthlyPayment': monthlyPayment,
          'loanTermMonths': loanTermMonths,
          'dti': (dti * 100).toStringAsFixed(2),
          'maxLoanAmount': (monthlyIncome * 12 * 0.43 / 100).toInt(),
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Financial profile calculated!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Color(0xFFEF5350),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F3F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Financial Calculator',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Calculate Your Financial Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F3F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your financial information to see what your credit profile looks like',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Income Section
                  _buildSectionTitle('Income & Employment'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Monthly Income (₫)',
                    _monthlyIncomeController,
                    'e.g., 15000000',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Years Employed',
                    _yearsEmployedController,
                    'e.g., 5',
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    'Employment Status',
                    _employmentStatus,
                    ['EMPLOYED', 'SELF_EMPLOYED', 'RETIRED'],
                    (value) {
                      setState(() => _employmentStatus = value!);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Housing Section
                  _buildSectionTitle('Housing & Assets'),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    'Home Ownership',
                    _homeOwnership,
                    ['OWN', 'MORTGAGE', 'RENT'],
                    (value) {
                      setState(() => _homeOwnership = value!);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Credit Section
                  _buildSectionTitle('Credit History'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Years of Credit History',
                    _creditYearsController,
                    'e.g., 2',
                  ),
                  const SizedBox(height: 12),
                  _buildCheckbox(
                    'Previous Payment Defaults',
                    _hasPreviousDefaults,
                    (value) {
                      setState(() => _hasPreviousDefaults = value ?? false);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildCheckbox(
                    'Currently in Default',
                    _currentlyDefaulting,
                    (value) {
                      setState(() => _currentlyDefaulting = value ?? false);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Loan Amount Section
                  _buildSectionTitle('Desired Loan Amount'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Loan Amount (₫)',
                    _loanAmountController,
                    'e.g., 20000000',
                  ),
                  const SizedBox(height: 24),

                  // Calculate Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _calculateFinancialProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C40F7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Calculate Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Results Section
                  if (_calculationResult != null) ...[
                    _buildSectionTitle('Your Financial Profile'),
                    const SizedBox(height: 12),
                    _buildResultCard(),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1F3F),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF4C40F7),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item.replaceAll('_', ' ')),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A1F3F),
        ),
      ),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: const Color(0xFF4C40F7),
    );
  }

  Widget _buildResultCard() {
    final result = _calculationResult!;
    final riskColor = _getRiskColor(_riskLevel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Risk Level Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: riskColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _riskLevel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Credit Score
          _buildResultRow(
            'Credit Score',
            result['creditScore'].toString(),
            Colors.black,
          ),
          const SizedBox(height: 12),

          // Interest Rate
          _buildResultRow(
            'Interest Rate',
            '${result['interestRate'].toStringAsFixed(2)}% / year',
            Colors.black,
          ),
          const SizedBox(height: 12),

          // Monthly Payment
          _buildResultRow(
            'Monthly Payment',
            currencyFormat.format(result['monthlyPayment']),
            Colors.black,
          ),
          const SizedBox(height: 12),

          // Loan Term
          _buildResultRow(
            'Loan Term',
            '${result['loanTermMonths']} months',
            Colors.black,
          ),
          const SizedBox(height: 12),

          // DTI Ratio
          _buildResultRow(
            'Debt-to-Income Ratio',
            '${result['dti']}%',
            Colors.black,
          ),
          const SizedBox(height: 12),

          // Max Loan Amount
          _buildResultRow(
            'Max Recommended Loan',
            currencyFormat.format(result['maxLoanAmount']),
            Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'EXCELLENT':
        return const Color(0xFF4CAF50);
      case 'GOOD':
        return const Color(0xFF8BC34A);
      case 'FAIR':
        return const Color(0xFFFFC107);
      case 'POOR':
        return const Color(0xFFFF9800);
      case 'VERY POOR':
        return const Color(0xFFEF5350);
      default:
        return Colors.grey;
    }
  }
}
