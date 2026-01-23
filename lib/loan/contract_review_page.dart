import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'approval_status_page.dart';

class ContractReviewPage extends StatefulWidget {
  final double loanAmount;
  final int tenor;
  final double downPayment;
  final String loanPurpose;

  const ContractReviewPage({
    super.key,
    required this.loanAmount,
    required this.tenor,
    required this.downPayment,
    required this.loanPurpose,
  });

  @override
  State<ContractReviewPage> createState() => _ContractReviewPageState();
}

class _ContractReviewPageState extends State<ContractReviewPage> {
  final _signatureController = TextEditingController();
  bool _agreedToTerms = false;
  bool _agreedToDeduction = false;
  bool _agreedToConsent = false;
  bool _isSigning = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoanViewModel>();
    final offer = vm.currentOffer;

    if (offer == null) {
      return const Scaffold(
        body: Center(child: Text('No offer available.')),
      );
    }

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
          'Step 4: Review & Sign Contract',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Loan Contract Agreement',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F3F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please review the contract terms and sign to proceed.',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),

                    // Contract Summary Card
                    _buildContractSummaryCard(offer),

                    const SizedBox(height: 24),
                    // Loan Terms Details
                    _buildSectionHeader('Loan Terms'),
                    _buildTermRow('Loan Amount', _currencyFormat.format(widget.loanAmount)),
                    const SizedBox(height: 12),
                    _buildTermRow('Interest Rate', '${(offer['interestRate'] as num?)?.toStringAsFixed(2) ?? "15.00"}% per annum'),
                    const SizedBox(height: 12),
                    _buildTermRow('Loan Term', '${widget.tenor} months'),
                    const SizedBox(height: 12),
                    _buildTermRow('Monthly Payment', _currencyFormat.format(_calculateMonthlyPayment(offer))),

                    const SizedBox(height: 24),
                    // Fees and Insurance (if available)
                    _buildSectionHeader('Additional Charges'),
                    _buildTermRow('Origination Fee', 'Included in rate'),
                    const SizedBox(height: 12),
                    _buildTermRow('Insurance', 'Optional - will be presented post-approval'),
                    const SizedBox(height: 12),
                    _buildTermRow('Late Payment Fee', '2% per month after due date'),

                    const SizedBox(height: 24),
                    // Legal Agreements - Checkboxes
                    _buildSectionHeader('Legal Agreements'),
                    _buildAgreementCheckbox(
                      label: 'I agree to the Terms and Conditions of this Loan Agreement',
                      value: _agreedToTerms,
                      onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                    ),
                    const SizedBox(height: 12),
                    _buildAgreementCheckbox(
                      label: 'I authorize the lender to deduct monthly payments from my registered bank account',
                      value: _agreedToDeduction,
                      onChanged: (val) => setState(() => _agreedToDeduction = val ?? false),
                    ),
                    const SizedBox(height: 12),
                    _buildAgreementCheckbox(
                      label: 'I consent to sharing my credit information with credit bureaus',
                      value: _agreedToConsent,
                      onChanged: (val) => setState(() => _agreedToConsent = val ?? false),
                    ),

                    const SizedBox(height: 24),
                    // Digital Signature
                    _buildSectionHeader('Digital Signature'),
                    const Text(
                      'Type your full name as signature:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1A1F3F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _signatureController,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
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
                    ),

                    const SizedBox(height: 24),
                    // Legal notice
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'By signing this contract, you acknowledge that you have read and agreed to all terms. This is a legally binding document.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSigningEnabled() && !_isSigning ? _signContract : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSigningEnabled() && !_isSigning
                            ? const Color(0xFF4C40F7)
                            : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSigning
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : const Text(
                              'Sign & Submit Contract',
                              style: TextStyle(
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
                      onPressed: _isSigning ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4C40F7), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Review Offer Again',
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

  bool _isSigningEnabled() {
    return _agreedToTerms && _agreedToDeduction && _agreedToConsent && _signatureController.text.isNotEmpty;
  }

  Future<void> _signContract() async {
    setState(() => _isSigning = true);

    // Simulate contract signing API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isSigning = false);

    // Navigate to Approval Status Page (pass data via constructor)
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ApprovalStatusPage(
            loanAmount: widget.loanAmount,
            tenor: widget.tenor,
            signature: _signatureController.text,
          ),
        ),
      );
    }
  }

  Widget _buildContractSummaryCard(dynamic offer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4C40F7).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4C40F7).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loan Status',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Approved',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Credit Score',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${offer['creditScore']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4C40F7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
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

  Widget _buildTermRow(String label, String value) {
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
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1F3F),
          ),
        ),
      ],
    );
  }

  Widget _buildAgreementCheckbox({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF4C40F7).withOpacity(0.05) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? const Color(0xFF4C40F7) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF4C40F7),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMonthlyPayment(dynamic offer) {
    if (widget.loanAmount <= 0) return 0;
    final interestRate = (offer['interestRate'] as num?) ?? 15.0;
    return (widget.loanAmount / widget.tenor) * (1 + (interestRate / 100));
  }
}
