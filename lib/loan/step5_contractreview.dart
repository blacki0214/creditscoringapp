import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'loan_step_transitions.dart';
import 'step6_disbursement.dart';
import '../utils/app_localization.dart';

class Step5ContractReviewPage extends StatefulWidget {
  final double loanAmount;
  final int tenor;
  final double downPayment;
  final String loanPurpose;

  const Step5ContractReviewPage({
    super.key,
    required this.loanAmount,
    required this.tenor,
    required this.downPayment,
    required this.loanPurpose,
  });

  @override
  State<Step5ContractReviewPage> createState() =>
      _Step5ContractReviewPageState();
}

class _Step5ContractReviewPageState extends State<Step5ContractReviewPage> {
  static const Color _accent = Color(0xFF3F4BFF);
  static const Color _pageBg = Color(0xFFE5E7EC);
  static const Color _surface = Color(0xFFF4F5F8);
  static const Color _inputBg = Color(0xFFDDE1E7);

  final _signatureController = TextEditingController();
  final _signatureFieldKey = GlobalKey<FormFieldState<String>>();
  final _signatureFocusNode = FocusNode();
  bool _agreedToTerms = false;
  bool _agreedToDeduction = false;
  bool _agreedToConsent = false;
  bool _isSigning = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
  );

  @override
  void initState() {
    super.initState();
    _signatureController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _signatureFocusNode.addListener(() {
      if (!_signatureFocusNode.hasFocus) {
        _signatureFieldKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _signatureFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoanViewModel>();
    final offer = vm.currentOffer;

    if (offer == null) {
      return Scaffold(
        body: Center(
          child: Text(
            context.t('No offer available.', 'Không có đề nghị khoản vay.'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.t(
            'Step 5: Review & Sign Contract',
            'Bước 5: Xem và ký hợp đồng',
          ),
          style: const TextStyle(
            color: _accent,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t(
                          'Loan Contract Agreement',
                          'Hợp đồng khoản vay',
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F3F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.t(
                          'Please review the contract terms and sign to proceed.',
                          'Vui lòng xem điều khoản hợp đồng và ký để tiếp tục.',
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildContractSummaryCard(offer),

                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        context.t('Loan Terms', 'Điều khoản khoản vay'),
                      ),
                      _buildTermRow(
                        context.t('Loan Amount', 'Số tiền vay'),
                        _currencyFormat.format(widget.loanAmount),
                      ),
                      const SizedBox(height: 12),
                      _buildTermRow(
                        context.t('Interest Rate', 'Lãi suất'),
                        context.t(
                          '${(offer['interestRate'] as num?)?.toStringAsFixed(2) ?? "15.00"}% per annum',
                          '${(offer['interestRate'] as num?)?.toStringAsFixed(2) ?? "15.00"}% mỗi năm',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTermRow(
                        context.t('Loan Term', 'Kỳ hạn vay'),
                        context.t(
                          '${widget.tenor} months',
                          '${widget.tenor} tháng',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTermRow(
                        context.t('Monthly Payment', 'Thanh toán hàng tháng'),
                        _currencyFormat.format(_calculateMonthlyPayment(offer)),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        context.t('Additional Charges', 'Phí bổ sung'),
                      ),
                      _buildTermRow(
                        context.t('Origination Fee', 'Phí khởi tạo'),
                        context.t(
                          'Included in rate',
                          'Đã bao gồm trong lãi suất',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTermRow(
                        context.t('Insurance', 'Bảo hiểm'),
                        context.t(
                          'Optional - will be presented post-approval',
                          'Tùy chọn - sẽ được cung cấp sau khi phê duyệt',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTermRow(
                        context.t('Late Payment Fee', 'Phí trả chậm'),
                        context.t(
                          '2% per month after due date',
                          '2% mỗi tháng sau ngày đến hạn',
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        context.t('Legal Agreements', 'Cam kết pháp lý'),
                      ),
                      _buildAgreementCheckbox(
                        label: context.t(
                          'I agree to the Terms and Conditions of this Loan Agreement',
                          'Tôi đồng ý với các điều khoản và điều kiện của hợp đồng vay này',
                        ),
                        value: _agreedToTerms,
                        onChanged: (val) =>
                            setState(() => _agreedToTerms = val ?? false),
                      ),
                      const SizedBox(height: 12),
                      _buildAgreementCheckbox(
                        label: context.t(
                          'I authorize the lender to deduct monthly payments from my registered bank account',
                          'Tôi ủy quyền cho bên cho vay trích khoản thanh toán hàng tháng từ tài khoản ngân hàng đã đăng ký của tôi',
                        ),
                        value: _agreedToDeduction,
                        onChanged: (val) =>
                            setState(() => _agreedToDeduction = val ?? false),
                      ),
                      const SizedBox(height: 12),
                      _buildAgreementCheckbox(
                        label: context.t(
                          'I consent to sharing my credit information with credit bureaus',
                          'Tôi đồng ý chia sẻ thông tin tín dụng của mình với các tổ chức tín dụng',
                        ),
                        value: _agreedToConsent,
                        onChanged: (val) =>
                            setState(() => _agreedToConsent = val ?? false),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        context.t('Digital Signature', 'Chữ ký điện tử'),
                      ),
                      Text(
                        context.t(
                          'Type your full name as signature:',
                          'Nhập họ và tên đầy đủ để ký:',
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1A1F3F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: _signatureFieldKey,
                        controller: _signatureController,
                        focusNode: _signatureFocusNode,
                        maxLength: 50,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50),
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[A-Za-z\s\-']"),
                          ),
                        ],
                        validator: _validateSignature,
                        decoration: InputDecoration(
                          hintText: context.t(
                            'Enter your full name',
                            'Nhập họ và tên đầy đủ',
                          ),
                          filled: true,
                          fillColor: _inputBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: _accent,
                              width: 1.8,
                            ),
                          ),
                          counterText: '',
                        ),
                      ),

                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                context.t(
                                  'By signing this contract, you acknowledge that you have read and agreed to all terms. This is a legally binding document.',
                                  'Bằng việc ký hợp đồng này, bạn xác nhận đã đọc và đồng ý với toàn bộ điều khoản. Đây là tài liệu có giá trị pháp lý ràng buộc.',
                                ),
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSigningEnabled() && !_isSigning
                      ? _signContract
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSigningEnabled() && !_isSigning
                        ? _accent
                        : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSigning
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          context.t('Sign & Continue', 'Ký và tiếp tục'),
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

  bool _isSigningEnabled() {
    return _agreedToTerms &&
        _agreedToDeduction &&
        _agreedToConsent &&
        _signatureController.text.isNotEmpty;
  }

  Future<void> _signContract() async {
    setState(() => _isSigning = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isSigning = false);

    Navigator.push(context, buildLoanStepRoute(const Step6DisbursementPage()));
  }

  Widget _buildContractSummaryCard(dynamic offer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t('Loan Status', 'Trạng thái khoản vay'),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  context.t('Approved', 'Đã duyệt'),
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
                context.t('Credit Score', 'Điểm tín dụng'),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                '${offer['creditScore']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _accent,
                ),
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
          color: _accent,
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
          color: value
              ? _accent.withOpacity(0.05)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: value ? _accent : Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: value, onChanged: onChanged, activeColor: _accent),
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

  String? _validateSignature(String? value) {
    if (value == null || value.isEmpty) {
      return context.t(
        'Please enter your signature',
        'Vui lòng nhập chữ ký của bạn',
      );
    }
    if (value.trim().length < 2) {
      return context.t(
        'Signature must be at least 2 characters',
        'Chữ ký phải có ít nhất 2 ký tự',
      );
    }
    if (!RegExp(r"^[A-Za-z\s\-']+$").hasMatch(value)) {
      return context.t(
        'Signature can only contain letters, spaces, hyphens, and apostrophes',
        'Chữ ký chỉ được chứa chữ cái, khoảng trắng, dấu gạch ngang và dấu nháy đơn',
      );
    }
    return null;
  }
}
