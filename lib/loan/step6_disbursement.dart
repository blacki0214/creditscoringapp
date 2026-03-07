import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/loan_viewmodel.dart';
import '../services/local_storage_service.dart';

class Step6DisbursementPage extends StatefulWidget {
  const Step6DisbursementPage({super.key});

  @override
  State<Step6DisbursementPage> createState() => _Step6DisbursementPageState();
}

class _Step6DisbursementPageState extends State<Step6DisbursementPage> {
  final _formKey = GlobalKey<FormState>();
  final _bankAccountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountHolderController = TextEditingController();

  bool _isProcessing = false;
  bool _agreeToDisbursement = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
  );

  @override
  void dispose() {
    _bankAccountController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  Future<void> _submitDisbursement() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToDisbursement) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the disbursement terms'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final loanViewModel = context.read<LoanViewModel>();

      // Mark step 6 as completed.
      await loanViewModel.completeStep6();

      // Persist ID-derived fields locally so Step 2 can be pre-filled on future skips.
      await loanViewModel.persistEkycPrefill();

      // Mark eKYC as permanently completed (won't need to redo for future applications).
      await LocalStorageService.markEkycCompleted();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disbursement details submitted successfully!'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loanViewModel = context.watch<LoanViewModel>();
    final offer = loanViewModel.currentOffer;
    final loanAmount = offer?['loanAmountVnd'] ?? 0;

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
          'Step 6: Disbursement',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
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
                        'Loan Disbursement',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F3F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your bank details to receive the loan amount',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 32),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF4CAF50)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Loan Amount to be Disbursed',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1F3F),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currencyFormat.format(loanAmount),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        'Bank Account Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F3F),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _accountHolderController,
                        decoration: InputDecoration(
                          labelText: 'Account Holder Name',
                          hintText: 'Enter full name as per bank account',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter account holder name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _bankNameController,
                        decoration: InputDecoration(
                          labelText: 'Bank Name',
                          hintText: 'e.g., Vietcombank, BIDV, Techcombank',
                          prefixIcon: const Icon(Icons.account_balance),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter bank name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _bankAccountController,
                        decoration: InputDecoration(
                          labelText: 'Account Number',
                          hintText: 'Enter your bank account number',
                          prefixIcon: const Icon(Icons.credit_card),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter account number';
                          }
                          if (value.length < 8) {
                            return 'Account number must be at least 8 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              value: _agreeToDisbursement,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToDisbursement = value ?? false;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: const Text(
                                'I agree to receive the loan amount in the bank account provided above',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Note: Disbursement typically takes 1-3 business days. Ensure your account details are correct.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _submitDisbursement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C40F7),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Complete Application',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
