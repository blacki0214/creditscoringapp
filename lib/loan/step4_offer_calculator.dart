import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'loan_step_transitions.dart';
import 'step5_contractreview.dart';
import '../utils/app_localization.dart';

class Step4OfferCalculatorPage extends StatefulWidget {
  const Step4OfferCalculatorPage({super.key});

  @override
  State<Step4OfferCalculatorPage> createState() =>
      _Step4OfferCalculatorPageState();
}

class _Step4OfferCalculatorPageState extends State<Step4OfferCalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  static const Color _accent = Color(0xFF3F4BFF);
  static const Color _pageBg = Color(0xFFE5E7EC);
  static const Color _surface = Color(0xFFF4F5F8);
  static const Color _inputBg = Color(0xFFDDE1E7);

  late TextEditingController _totalPriceController;
  late TextEditingController _downPaymentController;

  final _totalPriceFieldKey = GlobalKey<FormFieldState<String>>();
  final _downPaymentFieldKey = GlobalKey<FormFieldState<String>>();

  final _totalPriceFocusNode = FocusNode();
  final _downPaymentFocusNode = FocusNode();

  String _selectedPurpose = 'PERSONAL';
  double _tenor = 12; // months, default 12

  // Local state - not persisted to ViewModel
  bool _isProceeding = false;

  final NumberFormat _currencyFormatter = NumberFormat('#,###', 'vi_VN');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
  );

  final List<String> loanPurposeOptions = [
    'ELECTRONICS',
    'VEHICLE',
    'HOME',
    'PERSONAL',
    'EDUCATION',
    'MEDICAL',
    'BUSINESS',
    'HOME_IMPROVEMENT',
    'DEBT_CONSOLIDATION',
    'VENTURE',
    'OTHER',
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

    _totalPriceFocusNode.addListener(() {
      if (!_totalPriceFocusNode.hasFocus) {
        _totalPriceFieldKey.currentState?.validate();
      }
    });
    _downPaymentFocusNode.addListener(() {
      if (!_downPaymentFocusNode.hasFocus) {
        _downPaymentFieldKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _totalPriceController.dispose();
    _downPaymentController.dispose();
    _totalPriceFocusNode.dispose();
    _downPaymentFocusNode.dispose();
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
            context.t(
              'No offer available. Please go back.',
              'Không có đề nghị khoản vay. Vui lòng quay lại.',
            ),
          ),
        ),
      );
    }

    // Parse inputs
    final totalPrice = _parseAmount(_totalPriceController.text);
    final downPayment = _parseAmount(_downPaymentController.text);
    final calculatedLoanAmount = (totalPrice - downPayment).clamp(
      0.0,
      double.infinity,
    );

    // Loan Limit comes from the scoring API (based on income/credit score)
    final loanLimit = offer['maxAmountVnd'] as num;
    final isWithinLimit = calculatedLoanAmount <= loanLimit;

    // Calculate monthly payment based on tenor
    final interestRate =
        (offer['interestRate'] as num?) ?? 15.0; // Default 15% if null
    final monthlyPayment = calculatedLoanAmount > 0
        ? (calculatedLoanAmount / _tenor.toInt()) * (1 + (interestRate / 100))
        : 0.0;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: _pageBg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              context.t('Step 4: Loan Calculator', 'Bước 4: Tính khoản vay'),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width > 600
                          ? 24
                          : 16,
                      vertical: 16,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.t(
                                'Calculate Your Loan',
                                'Tính khoản vay của bạn',
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
                                'Select your loan purpose and financing options.',
                                'Chọn mục đích vay và phương án tài chính.',
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Loan Purpose
                            _buildSectionHeader(
                              context.t('Loan Purpose', 'Mục đích vay'),
                            ),
                            _buildDropdown(
                              label: context.t(
                                'What are you financing?',
                                'Bạn cần tài trợ cho mục đích gì?',
                              ),
                              value: _selectedPurpose,
                              items: loanPurposeOptions,
                              onChanged: (val) =>
                                  setState(() => _selectedPurpose = val!),
                            ),

                            const SizedBox(height: 24),
                            // Total Price
                            _buildSectionHeader(
                              context.t(
                                'Financing Details',
                                'Chi tiết tài chính',
                              ),
                            ),
                            _buildTextField(
                              fieldKey: _totalPriceFieldKey,
                              controller: _totalPriceController,
                              focusNode: _totalPriceFocusNode,
                              label: context.t(
                                'Total Price (VND)',
                                'Tổng giá trị (VND)',
                              ),
                              hint: '100,000,000',
                              keyboardType: TextInputType.number,
                              maxLength: 15,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(15),
                                FilteringTextInputFormatter.digitsOnly,
                                _CurrencyInputFormatter(_currencyFormatter),
                              ],
                              validator: _validateAmount,
                              onChanged: (val) => setState(() {}),
                            ),

                            const SizedBox(height: 16),
                            // Down Payment
                            _buildTextField(
                              fieldKey: _downPaymentFieldKey,
                              controller: _downPaymentController,
                              focusNode: _downPaymentFocusNode,
                              label: context.t(
                                'Down Payment (VND)',
                                'Trả trước (VND)',
                              ),
                              hint: '20,000,000',
                              keyboardType: TextInputType.number,
                              maxLength: 15,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(15),
                                FilteringTextInputFormatter.digitsOnly,
                                _CurrencyInputFormatter(_currencyFormatter),
                              ],
                              validator: _validateDownPayment,
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
                                  context.t(
                                    'Down Payment: ${((downPayment / totalPrice) * 100).toStringAsFixed(1)}% of total price',
                                    'Trả trước: ${((downPayment / totalPrice) * 100).toStringAsFixed(1)}% tổng giá trị',
                                  ),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 24),
                            // Tenor Slider
                            _buildSectionHeader(
                              context.t('Loan Term (Tenor)', 'Kỳ hạn vay'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        context.t(
                                          'Tenor: ${_tenor.toInt()} months',
                                          'Kỳ hạn: ${_tenor.toInt()} tháng',
                                        ),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A1F3F),
                                        ),
                                      ),
                                      Text(
                                        '(${(_tenor / 12).toStringAsFixed(1)} years)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
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
                                    onChanged: (val) =>
                                        setState(() => _tenor = val),
                                    activeColor: const Color(0xFF4C40F7),
                                    inactiveColor: Colors.grey.shade300,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '6m',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          '60m',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),
                            // Offer Summary
                            _buildSectionHeader(
                              context.t('Offer Summary', 'Tóm tắt đề nghị'),
                            ),
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
                                          isWithinLimit
                                              ? Icons.check_circle
                                              : Icons.error,
                                          color: isWithinLimit
                                              ? const Color(0xFF4CAF50)
                                              : Colors.red,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            isWithinLimit
                                                ? context.t(
                                                    'Within Your Loan Limit ✓',
                                                    'Trong hạn mức vay của bạn ✓',
                                                  )
                                                : context.t(
                                                    'Exceeds Your Loan Limit',
                                                    'Vượt hạn mức vay của bạn',
                                                  ),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                context.t(
                                                  'Your Loan Limit:',
                                                  'Hạn mức vay của bạn:',
                                                ),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              Text(
                                                _currencyFormat.format(
                                                  loanLimit,
                                                ),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                context.t(
                                                  'Requested Amount:',
                                                  'Số tiền yêu cầu:',
                                                ),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              Text(
                                                _currencyFormat.format(
                                                  calculatedLoanAmount,
                                                ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.info_outline,
                                            color: Colors.orange,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              context.t(
                                                'Please reduce your loan amount or increase your down payment to proceed.',
                                                'Vui lòng giảm số tiền vay hoặc tăng khoản trả trước để tiếp tục.',
                                              ),
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
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width > 600
                        ? 24
                        : 16,
                    vertical: 16,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          (calculatedLoanAmount <= 0 ||
                              !isWithinLimit ||
                              _isProceeding)
                          ? null
                          : () async {
                              setState(() => _isProceeding = true);

                              // Short processing pause for smoother perceived response.
                              await Future.delayed(
                                const Duration(milliseconds: 1200),
                              );
                              if (!mounted) return;

                              // Get the loan view model
                              final loanViewModel = context
                                  .read<LoanViewModel>();

                              // Calculate monthly payment
                              final interestRate =
                                  (offer['interestRate'] as num?) ?? 15.0;
                              final monthlyPayment =
                                  (calculatedLoanAmount / _tenor.toInt()) *
                                  (1 + (interestRate / 100));

                              // Update the loan offer with user's chosen parameters
                              loanViewModel.updateLoanOffer(
                                loanAmount: calculatedLoanAmount,
                                tenor: _tenor.toInt(),
                                monthlyPayment: monthlyPayment,
                                loanPurpose: _selectedPurpose,
                              );

                              // Mark Step 4 as completed
                              loanViewModel.completeStep4();

                              if (!mounted) return;
                              setState(() => _isProceeding = false);

                              // Navigate to Step 5 - Contract Review
                              Navigator.push(
                                context,
                                buildLoanStepRoute(
                                  Step5ContractReviewPage(
                                    loanAmount: calculatedLoanAmount,
                                    tenor: _tenor.toInt(),
                                    downPayment: downPayment,
                                    loanPurpose: _selectedPurpose,
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (calculatedLoanAmount <= 0 || !isWithinLimit)
                            ? Colors.grey.shade400
                            : _accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isWithinLimit
                            ? context.t(
                                'Accept Offer & Continue',
                                'Chấp nhận đề nghị và tiếp tục',
                              )
                            : context.t(
                                'Reduce Loan Amount',
                                'Giảm số tiền vay',
                              ),
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
        ),

        // Full-screen loading overlay
        if (_isProceeding)
          Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF4C40F7),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 20),
                      Text(
                        context.t(
                          'Processing your offer…',
                          'Đang xử lý đề nghị của bạn…',
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1F3F),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        context.t(
                          'Please wait a moment.',
                          'Vui lòng chờ trong giây lát.',
                        ),
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
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

  Widget _buildTextField({
    GlobalKey<FormFieldState<String>>? fieldKey,
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    FocusNode? focusNode,
    int? maxLength,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      maxLength: maxLength,
      onChanged: onChanged,
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return context.t('Please enter $label', 'Vui lòng nhập $label');
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: _inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accent, width: 1.8),
        ),
        counterText: '',
      ),
    );
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return context.t(
        'Please enter Total Price',
        'Vui lòng nhập tổng giá trị',
      );
    }
    final amount = _parseAmount(value);
    if (amount <= 0) {
      return context.t(
        'Total Price must be greater than 0',
        'Tổng giá trị phải lớn hơn 0',
      );
    }
    return null;
  }

  String? _validateDownPayment(String? value) {
    if (value == null || value.isEmpty) {
      return context.t(
        'Please enter Down Payment',
        'Vui lòng nhập khoản trả trước',
      );
    }
    final amount = _parseAmount(value);
    if (amount < 0) {
      return context.t(
        'Down Payment cannot be negative',
        'Khoản trả trước không được âm',
      );
    }
    return null;
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: _inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accent, width: 1.8),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(_displayLoanPurpose(item)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  String _displayLoanPurpose(String item) {
    switch (item) {
      case 'ELECTRONICS':
        return context.t('Electronics', 'Thiết bị điện tử');
      case 'VEHICLE':
        return context.t('Vehicle', 'Phương tiện');
      case 'HOME':
        return context.t('Home', 'Nhà ở');
      case 'PERSONAL':
        return context.t('Personal', 'Tiêu dùng cá nhân');
      case 'EDUCATION':
        return context.t('Education', 'Giáo dục');
      case 'MEDICAL':
        return context.t('Medical', 'Y tế');
      case 'BUSINESS':
        return context.t('Business', 'Kinh doanh');
      case 'HOME_IMPROVEMENT':
        return context.t('Home improvement', 'Sửa chữa nhà');
      case 'DEBT_CONSOLIDATION':
        return context.t('Debt consolidation', 'Hợp nhất nợ');
      case 'VENTURE':
        return context.t('Venture', 'Khởi nghiệp');
      case 'OTHER':
        return context.t('Other', 'Khác');
      default:
        return item;
    }
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
                context.t('Monthly Payment', 'Thanh toán hàng tháng'),
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
              _buildDetailChip(
                context.t('Loan Amount', 'Số tiền vay'),
                _currencyFormat.format(calculatedLoanAmount),
              ),
              _buildDetailChip(
                context.t('Term', 'Kỳ hạn'),
                context.t('$tenor months', '$tenor tháng'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailChip(
                context.t('Interest Rate', 'Lãi suất'),
                '${(offer['interestRate'] as num).toStringAsFixed(2)}%',
              ),
              _buildDetailChip(
                context.t('Credit Score', 'Điểm tín dụng'),
                '${offer['creditScore']}',
              ),
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
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
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
