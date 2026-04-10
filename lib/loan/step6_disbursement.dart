import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/loan_viewmodel.dart';
import '../services/local_storage_service.dart';
import '../utils/app_localization.dart';

class Step6DisbursementPage extends StatefulWidget {
  const Step6DisbursementPage({
    super.key,
    this.restrictToAcb = false,
    this.lockedAccountHolder,
    this.lockedAccountNumber,
  });

  final bool restrictToAcb;
  final String? lockedAccountHolder;
  final String? lockedAccountNumber;

  @override
  State<Step6DisbursementPage> createState() => _Step6DisbursementPageState();
}

class _Step6DisbursementPageState extends State<Step6DisbursementPage> {
  final _formKey = GlobalKey<FormState>();
  final _bankAccountController = TextEditingController();
  final _accountHolderController = TextEditingController();

  bool _isProcessing = false;
  bool _agreeToDisbursement = false;
  bool _bankAccountValidated = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
  );

  @override
  void initState() {
    super.initState();
    if (widget.lockedAccountHolder != null) {
      _accountHolderController.text = widget.lockedAccountHolder!;
    }
    if (widget.lockedAccountNumber != null) {
      _bankAccountController.text = widget.lockedAccountNumber!;
    }

    // Load banks on init
    Future.microtask(() {
      final vm = context.read<LoanViewModel>();
      vm
          .loadBanks()
          .then((_) {
            if (!widget.restrictToAcb) return;
            if (vm.banks.any((bank) => bank.bankCode == 'ACB')) {
              vm.updateSelectedBank('ACB');
            }
          })
          .catchError((e) {
            print('[Step6] Error loading banks: $e');
          });
    });
  }

  @override
  void dispose() {
    _bankAccountController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  /// Validate bank account with the service
  Future<void> _validateBankAccount() async {
    final viewModel = context.read<LoanViewModel>();

    if (viewModel.selectedBankCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t('Please select a bank', 'Vui lòng chọn ngân hàng'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_accountHolderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Please enter account holder name',
              'Vui lòng nhập tên chủ tài khoản',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_bankAccountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Please enter account number',
              'Vui lòng nhập số tài khoản',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Call validation API
    final isValid = await viewModel.validateBankAccount(
      bankCode: viewModel.selectedBankCode!,
      accountNumber: _bankAccountController.text,
      accountHolder: _accountHolderController.text,
      branchCode: viewModel.selectedBranchCode,
    );

    if (mounted) {
      if (isValid) {
        setState(() {
          _bankAccountValidated = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.t(
                'Bank account verified successfully!',
                'Tài khoản ngân hàng đã được xác nhận thành công!',
              ),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _bankAccountValidated = false;
        });
        final errorMessage =
            viewModel.bankAccountValidationError ??
            context.t(
              'Account validation failed',
              'Xác nhận tài khoản thất bại',
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _submitDisbursement() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<LoanViewModel>();

    // Check if bank account is validated
    if (!_bankAccountValidated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Please validate your bank account first',
              'Vui lòng xác nhận tài khoản ngân hàng trước',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_agreeToDisbursement) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Please agree to the disbursement terms',
              'Vui lòng đồng ý điều khoản giải ngân',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Mark step 6 as completed and persist disbursement details
      await viewModel.completeStep6(
        disbursementData: {
          'bankCode': viewModel.selectedBankCode,
          'bankName': viewModel.selectedBank?.bankName,
          'branchCode': viewModel.selectedBranchCode,
          'branchName': viewModel.selectedBranch?.branchName,
          'accountNumber': _bankAccountController.text.trim(),
          'accountHolder': _accountHolderController.text.trim(),
          'validated': _bankAccountValidated,
          'submittedAt': DateTime.now().toIso8601String(),
        },
      );

      // Persist ID-derived fields locally so Step 2 can be pre-filled on future skips
      await viewModel.persistEkycPrefill();

      // Mark eKYC as permanently completed
      await LocalStorageService.markEkycCompleted(
        userId: FirebaseAuth.instance.currentUser?.uid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.t(
                'Disbursement details submitted successfully!',
                'Thông tin giải ngân đã được gửi thành công!',
              ),
            ),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.t('Error', 'Lỗi')}: $e'),
            backgroundColor: Colors.red,
          ),
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

  /// Build bank selection dropdown
  Widget _buildBankDropdown(LoanViewModel viewModel) {
    return DropdownButtonFormField<String>(
      initialValue: viewModel.selectedBankCode,
      isExpanded: true,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: context.t('Bank*', 'Ngân hàng*'),
        prefixIcon: const Icon(Icons.account_balance, color: Color(0xFF4D4AF9)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4D4AF9), width: 2),
        ),
      ),
      items: viewModel.banks.map((bank) {
        final isEnabled = !widget.restrictToAcb || bank.bankCode == 'ACB';
        return DropdownMenuItem<String>(
          value: bank.bankCode,
          enabled: isEnabled,
          child: Text(
            '${bank.bankCode} - ${bank.bankName}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isEnabled ? const Color(0xFF1A1F3F) : Colors.grey.shade500,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          if (widget.restrictToAcb && value != 'ACB') {
            return;
          }
          viewModel.updateSelectedBank(value);
          setState(() {
            _bankAccountValidated = false; // Reset validation
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.t('Please select a bank', 'Vui lòng chọn ngân hàng');
        }
        if (widget.restrictToAcb && value != 'ACB') {
          return context.t(
            'Only ACB is available in this flow',
            'Chỉ hỗ trợ ACB trong luồng này',
          );
        }
        return null;
      },
      hint: Text(context.t('Select a bank...', 'Chọn ngân hàng...')),
    );
  }

  /// Build branch selection dropdown
  Widget _buildBranchDropdown(LoanViewModel viewModel) {
    final branches = viewModel.selectedBankCode != null
        ? viewModel.selectedBank?.branches ?? []
        : [];

    return DropdownButtonFormField<String>(
      initialValue: viewModel.selectedBranchCode,
      isExpanded: true,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: context.t('Branch (Optional)', 'Chi nhánh (Tùy chọn)'),
        prefixIcon: const Icon(Icons.location_on, color: Color(0xFF4D4AF9)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4D4AF9), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      items: branches.map((branch) {
        return DropdownMenuItem<String>(
          value: branch.branchCode,
          child: Text(
            '${branch.branchName} (${branch.branchCode})',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: branches.isEmpty
          ? null
          : (value) {
              if (value != null) {
                viewModel.updateSelectedBranch(value);
                setState(() {
                  _bankAccountValidated = false; // Reset validation
                });
              }
            },
      hint: Text(context.t('Select a branch...', 'Chọn chi nhánh...')),
      disabledHint: Text(
        context.t('Select bank first', 'Chọn ngân hàng trước'),
      ),
    );
  }

  /// Build account holder name field
  Widget _buildAccountHolderField() {
    return TextFormField(
      controller: _accountHolderController,
      readOnly: widget.restrictToAcb,
      decoration: InputDecoration(
        labelText: context.t('Account Holder Name*', 'Tên chủ tài khoản*'),
        hintText: context.t(
          'Enter full name as per bank account',
          'Nhập họ tên đầy đủ theo tài khoản ngân hàng',
        ),
        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4D4AF9)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4D4AF9), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.t(
            'Please enter account holder name',
            'Vui lòng nhập tên chủ tài khoản',
          );
        }
        if (value.trim().length < 2) {
          return context.t(
            'Name must be at least 2 characters',
            'Tên phải có ít nhất 2 ký tự',
          );
        }
        return null;
      },
      onChanged: (_) {
        setState(() {
          _bankAccountValidated = false; // Reset validation
        });
      },
    );
  }

  /// Build account number field
  Widget _buildAccountNumberField() {
    return TextFormField(
      controller: _bankAccountController,
      readOnly: widget.restrictToAcb,
      decoration: InputDecoration(
        labelText: context.t('Account Number*', 'Số tài khoản*'),
        hintText: context.t(
          'Enter your bank account number',
          'Nhập số tài khoản ngân hàng của bạn',
        ),
        prefixIcon: const Icon(Icons.credit_card, color: Color(0xFF4D4AF9)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4D4AF9), width: 2),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.t(
            'Please enter account number',
            'Vui lòng nhập số tài khoản',
          );
        }
        if (value.length < 8) {
          return context.t(
            'Account number must be at least 8 digits',
            'Số tài khoản phải có ít nhất 8 chữ số',
          );
        }
        if (!RegExp(r'^\d{8,20}$').hasMatch(value)) {
          return context.t(
            'Account number must be 8-20 digits',
            'Số tài khoản phải từ 8-20 chữ số',
          );
        }
        return null;
      },
      onChanged: (_) {
        setState(() {
          _bankAccountValidated = false; // Reset validation
        });
      },
    );
  }

  /// Build validation status widget
  Widget _buildValidationStatus(LoanViewModel viewModel) {
    if (_bankAccountValidated) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t('Account Verified', 'Tài khoản đã xác nhận'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  if (viewModel.bankValidationResult != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${viewModel.bankValidationResult!.accountHolderName} - ${viewModel.bankValidationResult!.bankName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF558B2F),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.isValidatingAccount) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade300),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              context.t('Validating account...', 'Đang xác nhận tài khoản...'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.bankAccountValidationError != null &&
        viewModel.bankAccountValidationError!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                viewModel.bankAccountValidationError!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final loanViewModel = context.watch<LoanViewModel>();
    final offer = loanViewModel.currentOffer;
    final loanAmount = offer?['loanAmountVnd'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.t('Loan Disbursement', 'Giải ngân khoản vay'),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        context.t('Loan Disbursement', 'Giải ngân khoản vay'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F3F),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Loan amount display
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF4CAF50)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              context.t(
                                'Loan Amount to be Disbursed',
                                'Số tiền vay sẽ được giải ngân',
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1A1F3F),
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

                      // Bank selection section
                      Text(
                        context.t(
                          'Bank Account Details',
                          'Thông tin tài khoản ngân hàng',
                        ),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1F3F),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (widget.restrictToAcb) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFD54F)),
                          ),
                          child: Text(
                            context.t(
                              'Student flow: only ACB is available for disbursement in this test setup.',
                              'Luồng sinh viên: chỉ hỗ trợ ngân hàng ACB cho giải ngân trong môi trường kiểm thử này.',
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF694D00),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Bank dropdown
                      if (loanViewModel.isLoadingBanks)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        _buildBankDropdown(loanViewModel),
                      const SizedBox(height: 16),

                      // Branch dropdown
                      _buildBranchDropdown(loanViewModel),
                      const SizedBox(height: 16),

                      // Account holder name
                      _buildAccountHolderField(),
                      const SizedBox(height: 16),

                      // Account number
                      _buildAccountNumberField(),
                      const SizedBox(height: 20),

                      // Validation status
                      _buildValidationStatus(loanViewModel),
                      const SizedBox(height: 20),

                      // Validate button
                      if (!_bankAccountValidated)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: loanViewModel.isValidatingAccount
                                ? null
                                : _validateBankAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              context.t('Verify Account', 'Xác nhận tài khoản'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 16),

                      // Agreement checkbox
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
                              onChanged: _bankAccountValidated
                                  ? (value) {
                                      setState(() {
                                        _agreeToDisbursement = value ?? false;
                                      });
                                    }
                                  : null,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                context.t(
                                  'I agree to receive the loan using the verified account',
                                  'Tôi đồng ý nhận khoản vay vào tài khoản đã xác nhận',
                                ),
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.t(
                                'Note: Disbursement typically takes 1-3 business days.',
                                'Lưu ý: Giải ngân thường mất 1-3 ngày làm việc.',
                              ),
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

            // Submit button
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
                  onPressed: _isProcessing || !_bankAccountValidated
                      ? null
                      : _submitDisbursement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D4AF9),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
                      : Text(
                          context.t('Complete Application', 'Hoàn tất hồ sơ'),
                          style: const TextStyle(
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
