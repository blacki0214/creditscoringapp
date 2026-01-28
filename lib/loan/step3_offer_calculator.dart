import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'contract_review_page.dart';

class Step3OfferCalculatorPage extends StatefulWidget {
  const Step3OfferCalculatorPage({super.key});

  @override
  State<Step3OfferCalculatorPage> createState() => _Step3OfferCalculatorPageState();
}

class _Step3OfferCalculatorPageState extends State<Step3OfferCalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _totalPriceController;
  late TextEditingController _downPaymentController;
  
  String _selectedPurpose = 'PERSONAL';
  double _tenor = 12; // months, default 12
  
  // Local state - not persisted to ViewModel
  double _calculatedLoanAmount = 0;
  double _downPayment = 0;
  
  final NumberFormat _currencyFormatter = NumberFormat('#,###', 'vi_VN');
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  final List<String> loanPurposeOptions = [
    'ELECTRONICS', 'VEHICLE', 'HOME', 'PERSONAL', 'EDUCATION', 
    'MEDICAL', 'BUSINESS', 'HOME_IMPROVEMENT', 'DEBT_CONSOLIDATION', 'VENTURE', 'OTHER'
  ];

  @override
  void initState() {
    super.initState();
    final vm = context.read<LoanViewModel>();
    
    // Initialize from user input (empty by default)
    _totalPriceController = TextEditingController(text: '');
    _downPaymentController = TextEditingController(text: '0');
    _selectedPurpose = vm.loanPurpose;
    
    // Set tenor from offer if available
    if (vm.currentOffer?['loanTermMonths'] != null) {
      _tenor = ((vm.currentOffer!['loanTermMonths'] as num?) ?? 12).toDouble();
    }
  }

  @override
  void dispose() {
    _totalPriceController.dispose();
    _downPaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoanViewModel>();
    final offer = vm.currentOffer;

    if (offer == null) {
      return const Scaffold(
        body: Center(child: Text('No offer available. Please go back.')),
      );
    }

    // Parse inputs
    final totalPrice = _parseAmount(_totalPriceController.text);
    final downPayment = _parseAmount(_downPaymentController.text);
    final calculatedLoanAmount = (totalPrice - downPayment).clamp(0.0, double.infinity);
    
    // Loan Limit comes from the scoring API (based on income/credit score)
    final loanLimit = offer['maxAmountVnd'] as num;
    final isWithinLimit = calculatedLoanAmount <= loanLimit;

    // Calculate monthly payment based on tenor
    final interestRate = (offer['interestRate'] as num?) ?? 15.0; // Default 15% if null
    final monthlyPayment = calculatedLoanAmount > 0
        ? (calculatedLoanAmount / _tenor.toInt()) * (1 + (interestRate / 100))
        : 0.0;

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
          'Step 3: Loan Calculator',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calculate Your Loan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F3F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select your loan purpose and financing options.',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 24),

                      // Loan Purpose
                      _buildSectionHeader('Loan Purpose'),
                      _buildDropdown(
                        label: 'What are you financing?',
                        value: _selectedPurpose,
                        items: loanPurposeOptions,
                        onChanged: (val) => setState(() => _selectedPurpose = val!),
                      ),

                      const SizedBox(height: 24),
                      // Total Price
                      _buildSectionHeader('Financing Details'),
                      _buildTextField(
                        controller: _totalPriceController,
                        label: 'Total Price (VND)',
                        hint: '100,000,000',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CurrencyInputFormatter(_currencyFormatter),
                        ],
                        onChanged: (val) => setState(() {}),
                      ),

                      const SizedBox(height: 16),
                      // Down Payment
                      _buildTextField(
                        controller: _downPaymentController,
                        label: 'Down Payment (VND)',
                        hint: '20,000,000',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CurrencyInputFormatter(_currencyFormatter),
                        ],
                        onChanged: (val) => setState(() {}),
                      ),

                      const SizedBox(height: 16),
                      // Down Payment Percentage
                      if (totalPrice > 0)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Down Payment: ${((downPayment / totalPrice) * 100).toStringAsFixed(1)}% of total price',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                          ),
                        ),

                      const SizedBox(height: 24),
                      // Tenor Slider
                      _buildSectionHeader('Loan Term (Tenor)'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tenor: ${_tenor.toInt()} months',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1F3F),
                                  ),
                                ),
                                Text(
                                  '(${(_tenor / 12).toStringAsFixed(1)} years)',
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Slider(
                              value: _tenor,
                              min: 6,
                              max: 60,
                              divisions: 54,
                              label: '${_tenor.toInt()} months',
                              onChanged: (val) => setState(() => _tenor = val),
                              activeColor: const Color(0xFF4C40F7),
                              inactiveColor: Colors.grey.shade300,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('6m', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  Text('60m', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Offer Summary
                      _buildSectionHeader('Offer Summary'),
                      _buildOfferCard(
                        offer: offer,
                        calculatedLoanAmount: calculatedLoanAmount,
                        monthlyPayment: monthlyPayment,
                        tenor: _tenor.toInt(),
                      ),

                      const SizedBox(height: 16),
                      // Loan Amount vs Limit Check
                      if (calculatedLoanAmount > 0) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isWithinLimit
                                ? const Color(0xFF4CAF50).withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isWithinLimit
                                  ? const Color(0xFF4CAF50)
                                  : Colors.red,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isWithinLimit ? Icons.check_circle : Icons.error,
                                    color: isWithinLimit ? const Color(0xFF4CAF50) : Colors.red,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      isWithinLimit
                                          ? 'Within Your Loan Limit ✓'
                                          : 'Exceeds Your Loan Limit',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isWithinLimit
                                            ? const Color(0xFF4CAF50)
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Your Loan Limit:',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        Text(
                                          _currencyFormat.format(loanLimit),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A1F3F),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Requested Amount:',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        Text(
                                          _currencyFormat.format(calculatedLoanAmount),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isWithinLimit
                                                ? const Color(0xFF4CAF50)
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (!isWithinLimit) ...[
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Please reduce your loan amount or increase your down payment to proceed.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
                vertical: 16,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (calculatedLoanAmount <= 0 || !isWithinLimit)
                          ? null
                          : () {
                              // Navigate to Contract Review (pass data via constructor or args)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ContractReviewPage(
                                    loanAmount: calculatedLoanAmount,
                                    tenor: _tenor.toInt(),
                                    downPayment: downPayment,
                                    loanPurpose: _selectedPurpose,
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (calculatedLoanAmount <= 0 || !isWithinLimit)
                            ? Colors.grey.shade400
                            : const Color(0xFF4C40F7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isWithinLimit ? 'Accept Offer & Continue' : 'Reduce Loan Amount',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4C40F7), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Adjust Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4C40F7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4C40F7),
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
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
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

  Widget _buildOfferCard({
    required dynamic offer,
    required double calculatedLoanAmount,
    required double monthlyPayment,
    required int tenor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4C40F7).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4C40F7).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Hero number: Monthly Payment
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Monthly Payment',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _currencyFormat.format(monthlyPayment),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C40F7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          // Details grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailChip('Loan Amount', _currencyFormat.format(calculatedLoanAmount)),
              _buildDetailChip('Term', '$tenor months'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailChip('Interest Rate', '${(offer['interestRate'] as num).toStringAsFixed(2)}%'),
              _buildDetailChip('Credit Score', '${offer['creditScore']}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1F3F),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  double _parseAmount(String text) {
    if (text.isEmpty) return 0;
    final cleaned = text.replaceAll(RegExp(r'[,\.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }
}

// Currency input formatter
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
