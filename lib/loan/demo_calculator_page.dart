import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/loan_viewmodel.dart';
import '../services/api_service.dart';

class DemoCalculatorPage extends StatefulWidget {
  const DemoCalculatorPage({super.key});

  @override
  State<DemoCalculatorPage> createState() => _DemoCalculatorPageState();
}

class _DemoCalculatorPageState extends State<DemoCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _monthlyIncomeController = TextEditingController();
  final _yearsEmployedController = TextEditingController();
  final _yearsCreditHistoryController = TextEditingController();
  final _loanAmountController = TextEditingController();
  final _addressController = TextEditingController();
  
  DateTime? _selectedDOB;
  
  // Form state
  String _employmentStatus = 'EMPLOYED';
  String _homeOwnership = 'RENT';
  String _loanPurpose = 'PERSONAL';
  bool _hasPreviousDefaults = false;
  bool _currentlyDefaulting = false;
  
  // Results
  Map<String, dynamic>? _demoResult;
  bool _isCalculating = false;

  final NumberFormat _currencyFormatter = NumberFormat('#,###', 'vi_VN');
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  final List<String> employmentOptions = ['EMPLOYED', 'SELF_EMPLOYED', 'UNEMPLOYED', 'STUDENT', 'RETIRED'];
  final List<String> homeOwnershipOptions = ['RENT', 'OWN', 'MORTGAGE', 'LIVING_WITH_PARENTS', 'OTHER'];
  final List<String> loanPurposeOptions = [
    'PERSONAL', 'EDUCATION', 'MEDICAL', 'BUSINESS', 
    'HOME_IMPROVEMENT', 'DEBT_CONSOLIDATION', 'VENTURE', 'OTHER'
  ];

  @override
  void dispose() {
    _monthlyIncomeController.dispose();
    _yearsEmployedController.dispose();
    _yearsCreditHistoryController.dispose();
    _loanAmountController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Demo: Financial Calculator',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calculate Your Financial Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F3F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your information to see your credit score and loan eligibility (no ID verification required).',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 32),
                    
                    // Personal Details
                    _buildSectionHeader('Personal Details'),
                    _buildDateField(),
                    
                    const SizedBox(height: 24),
                    // Employment & Income
                    _buildSectionHeader('Employment & Income'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Employment Status',
                            value: _employmentStatus,
                            items: employmentOptions,
                            onChanged: (val) => setState(() => _employmentStatus = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _yearsEmployedController,
                            label: 'Years Employed',
                            hint: '5',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]'))],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _monthlyIncomeController,
                      label: 'Monthly Income (VND)',
                      hint: '15,000,000',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CurrencyInputFormatter(_currencyFormatter),
                      ],
                    ),

                    const SizedBox(height: 24),
                    // Residence & Assets
                    _buildSectionHeader('Residence & Assets'),
                    _buildDropdown(
                      label: 'Home Ownership',
                      value: _homeOwnership,
                      items: homeOwnershipOptions,
                      onChanged: (val) => setState(() => _homeOwnership = val!),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Current Address',
                      hint: '123 Street...',
                    ),

                    const SizedBox(height: 24),
                    // Loan Request
                    _buildSectionHeader('Loan Request'),
                    _buildDropdown(
                      label: 'Loan Purpose',
                      value: _loanPurpose,
                      items: loanPurposeOptions,
                      onChanged: (val) => setState(() => _loanPurpose = val!),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _loanAmountController,
                      label: 'Desired Loan Amount (VND)',
                      hint: '100,000,000',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CurrencyInputFormatter(_currencyFormatter),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    // Credit History
                    _buildSectionHeader('Credit History'),
                    _buildTextField(
                      controller: _yearsCreditHistoryController,
                      label: 'Years Credit History',
                      hint: '2',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Have you ever defaulted?'),
                      value: _hasPreviousDefaults,
                      onChanged: (val) => setState(() => _hasPreviousDefaults = val),
                      activeColor: const Color(0xFF4C40F7),
                    ),
                    SwitchListTile(
                      title: const Text('Currently defaulting?'),
                      value: _currentlyDefaulting,
                      onChanged: (val) => setState(() => _currentlyDefaulting = val),
                      activeColor: const Color(0xFF4C40F7),
                    ),
                    
                    // Results
                    if (_demoResult != null) ...[
                      const SizedBox(height: 24),
                      _buildSectionHeader('Your Financial Profile'),
                      _buildResultCard(),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // Calculate Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isCalculating ? null : _calculateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C40F7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isCalculating
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text(
                        'Calculate Profile',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _calculateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isCalculating = true;
      _demoResult = null;
    });

    try {
      // Parse inputs
      final income = double.parse(_monthlyIncomeController.text.replaceAll(RegExp(r'[,.]'), ''));
      final yearsEmp = double.parse(_yearsEmployedController.text);
      final creditYears = int.parse(_yearsCreditHistoryController.text);
      final loanAmount = double.parse(_loanAmountController.text.replaceAll(RegExp(r'[,.]'), ''));
      
      // Calculate age
      int age = 25;
      if (_selectedDOB != null) {
        final today = DateTime.now();
        age = today.year - _selectedDOB!.year;
        if (today.month < _selectedDOB!.month || 
            (today.month == _selectedDOB!.month && today.day < _selectedDOB!.day)) {
          age--;
        }
      }

      // Call ViewModel API (sandbox - no storage)
      final vm = context.read<LoanViewModel>();
      final request = SimpleLoanRequest(
        fullName: 'Demo User',
        age: age,
        monthlyIncome: income,
        employmentStatus: _employmentStatus,
        yearsEmployed: yearsEmp,
        homeOwnership: _homeOwnership,
        loanPurpose: _loanPurpose,
        requestedAmountVnd: loanAmount,
        yearsCreditHistory: creditYears,
        hasPreviousDefaults: _hasPreviousDefaults,
        currentlyDefaulting: _currentlyDefaulting,
      );

      final response = await vm.getDemoCalculation(request);

      if (!mounted) return;
      
      if (response == null) {
        setState(() => _isCalculating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error calculating profile'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() {
        _demoResult = {
          'creditScore': response.creditScore,
          'riskLevel': _getRiskLevel(response.creditScore),
          'interestRate': response.interestRate ?? 15.0,
          'monthlyPayment': response.monthlyPaymentVnd ?? 0.0,
          'loanTerm': response.loanTermMonths ?? 36,
          'dti': ((loanAmount / (income * 12)) * 100).toStringAsFixed(2),
          'maxLoan': response.loanAmountVnd?.toInt() ?? 0,
        };
        _isCalculating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile calculated successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCalculating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _getRiskLevel(int score) {
    if (score >= 740) return 'EXCELLENT';
    if (score >= 670) return 'GOOD';
    if (score >= 580) return 'FAIR';
    if (score >= 500) return 'POOR';
    return 'VERY POOR';
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4C40F7),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    final dobText = _selectedDOB != null
        ? '${_selectedDOB!.day.toString().padLeft(2, '0')}/${_selectedDOB!.month.toString().padLeft(2, '0')}/${_selectedDOB!.year}'
        : '';

    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: dobText),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDOB ?? DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
        );
        if (picked != null) {
          setState(() => _selectedDOB = picked);
        }
      },
      validator: (value) {
        if (_selectedDOB == null) return 'Please select your date of birth';
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Date of Birth',
        hintText: 'DD/MM/YYYY',
        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF4C40F7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4C40F7), width: 2),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4C40F7), width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4C40F7), width: 2),
        ),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildResultCard() {
    final result = _demoResult!;
    final riskColor = _getRiskColor(result['riskLevel']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: riskColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result['riskLevel'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildResultRow('Credit Score', '${result['creditScore']}'),
          const SizedBox(height: 8),
          _buildResultRow('Interest Rate', '${result['interestRate'].toStringAsFixed(2)}% / year'),
          const SizedBox(height: 8),
          _buildResultRow('Monthly Payment', _currencyFormat.format(result['monthlyPayment'])),
          const SizedBox(height: 8),
          _buildResultRow('Loan Term', '${result['loanTerm']} months'),
          const SizedBox(height: 8),
          _buildResultRow('Debt-to-Income Ratio', '${result['dti']}%'),
          const SizedBox(height: 8),
          _buildResultRow('Max Recommended Loan', _currencyFormat.format(result['maxLoan'])),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
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

  Color _getRiskColor(String level) {
    switch (level) {
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

class _CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat formatter;
  _CurrencyInputFormatter(this.formatter);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final number = int.tryParse(newValue.text);
    if (number == null) return oldValue;
    final formatted = formatter.format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
