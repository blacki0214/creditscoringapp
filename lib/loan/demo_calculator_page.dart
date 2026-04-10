import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/app_localization.dart';

class DemoCalculatorPage extends StatefulWidget {
  const DemoCalculatorPage({super.key});

  @override
  State<DemoCalculatorPage> createState() => _DemoCalculatorPageState();
}

class _DemoCalculatorPageState extends State<DemoCalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  // Credit history selection
  bool? _hasCreditHistory;

  // Controllers
  final _monthlyIncomeController = TextEditingController();
  final _yearsEmployedController = TextEditingController();
  final _yearsCreditHistoryController = TextEditingController();
  final _addressController = TextEditingController();

  final _yearsEmployedFieldKey = GlobalKey<FormFieldState<String>>();
  final _monthlyIncomeFieldKey = GlobalKey<FormFieldState<String>>();
  final _addressFieldKey = GlobalKey<FormFieldState<String>>();
  final _yearsCreditHistoryFieldKey = GlobalKey<FormFieldState<String>>();

  final _yearsEmployedFocusNode = FocusNode();
  final _monthlyIncomeFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _yearsCreditHistoryFocusNode = FocusNode();

  DateTime? _selectedDOB;

  // Form state
  String _employmentStatus = 'EMPLOYED';
  String _homeOwnership = 'RENT';
  bool _hasPreviousDefaults = false;
  bool _currentlyDefaulting = false;

  // Results
  CalculateLimitResponse? _limitResult;
  bool _isCalculating = false;
  String? _errorMessage;

  final NumberFormat _currencyFormatter = NumberFormat('#,###', 'vi_VN');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
  );

  final List<String> employmentOptions = [
    'EMPLOYED',
    'SELF_EMPLOYED',
    'UNEMPLOYED',
    'STUDENT',
    'RETIRED',
  ];
  final List<String> homeOwnershipOptions = [
    'RENT',
    'OWN',
    'MORTGAGE',
    'LIVING_WITH_PARENTS',
    'OTHER',
  ];

  @override
  void initState() {
    super.initState();
    _yearsEmployedFocusNode.addListener(() {
      if (!_yearsEmployedFocusNode.hasFocus) {
        _yearsEmployedFieldKey.currentState?.validate();
      }
    });
    _monthlyIncomeFocusNode.addListener(() {
      if (!_monthlyIncomeFocusNode.hasFocus) {
        _monthlyIncomeFieldKey.currentState?.validate();
      }
    });
    _addressFocusNode.addListener(() {
      if (!_addressFocusNode.hasFocus) {
        _addressFieldKey.currentState?.validate();
      }
    });
    _yearsCreditHistoryFocusNode.addListener(() {
      if (!_yearsCreditHistoryFocusNode.hasFocus) {
        _yearsCreditHistoryFieldKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _monthlyIncomeController.dispose();
    _yearsEmployedController.dispose();
    _yearsCreditHistoryController.dispose();
    _addressController.dispose();
    _yearsEmployedFocusNode.dispose();
    _monthlyIncomeFocusNode.dispose();
    _addressFocusNode.dispose();
    _yearsCreditHistoryFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              context.t(
                'Demo: Financial Calculator',
                'Demo: Máy tính tài chính',
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F3F),
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
                      vertical: 20,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Credit History Selection
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4D4AF9).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF4D4AF9).withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.t(
                                    'Do you have credit history?',
                                    'Bạn có lịch sử tín dụng không?',
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1F3F),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<bool>(
                                        title: Text(
                                          context.t(
                                            'Yes, I have credit history',
                                            'Có, tôi có lịch sử tín dụng',
                                          ),
                                        ),
                                        value: true,
                                        groupValue: _hasCreditHistory,
                                        onChanged: (val) => setState(
                                          () => _hasCreditHistory = val,
                                        ),
                                        activeColor: const Color(0xFF4D4AF9),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<bool>(
                                        title: Text(
                                          context.t(
                                            'No, I\'m new to credit',
                                            'Không, tôi chưa có lịch sử tín dụng',
                                          ),
                                        ),
                                        value: false,
                                        groupValue: _hasCreditHistory,
                                        onChanged: (val) => setState(
                                          () => _hasCreditHistory = val,
                                        ),
                                        activeColor: const Color(0xFF4D4AF9),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          if (_hasCreditHistory != null) ...[
                            const SizedBox(height: 24),

                            // Personal Details
                            _buildSectionHeader(
                              context.t(
                                'Personal Details',
                                'Thông tin cá nhân',
                              ),
                            ),
                            _buildDateField(),

                            const SizedBox(height: 16),

                            // Employment & Income
                            _buildSectionHeader(
                              context.t(
                                'Employment & Income',
                                'Nghề nghiệp & Thu nhập',
                              ),
                            ),
                            _buildDropdown(
                              label: context.t(
                                'Employment Status',
                                'Tình trạng việc làm',
                              ),
                              value: _employmentStatus,
                              items: employmentOptions,
                              onChanged: (val) =>
                                  setState(() => _employmentStatus = val!),
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              fieldKey: _yearsEmployedFieldKey,
                              controller: _yearsEmployedController,
                              focusNode: _yearsEmployedFocusNode,
                              label: context.t(
                                'Years Employed',
                                'Số năm làm việc',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              maxLength: 5,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(5),
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9\.]'),
                                ),
                              ],
                              validator: _validateYearsEmployed,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              fieldKey: _monthlyIncomeFieldKey,
                              controller: _monthlyIncomeController,
                              focusNode: _monthlyIncomeFocusNode,
                              label: context.t(
                                'Monthly Income (VND)',
                                'Thu nhập hàng tháng (VND)',
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 15,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(15),
                                FilteringTextInputFormatter.digitsOnly,
                                _CurrencyInputFormatter(_currencyFormatter),
                              ],
                              validator: _validateMonthlyIncome,
                            ),

                            const SizedBox(height: 16),

                            // Residence & Assets
                            _buildSectionHeader(
                              context.t(
                                'Residence & Assets',
                                'Nơi ở & Tài sản',
                              ),
                            ),
                            _buildDropdown(
                              label: context.t(
                                'Home Ownership',
                                'Tình trạng nhà ở',
                              ),
                              value: _homeOwnership,
                              items: homeOwnershipOptions,
                              onChanged: (val) =>
                                  setState(() => _homeOwnership = val!),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              fieldKey: _addressFieldKey,
                              controller: _addressController,
                              focusNode: _addressFocusNode,
                              label: context.t(
                                'Current Address',
                                'Địa chỉ hiện tại',
                              ),
                              maxLines: 2,
                              maxLength: 100,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100),
                                FilteringTextInputFormatter.allow(
                                  RegExp(
                                    r'[\p{L}\p{M}0-9\s,\.\-/#]',
                                    unicode: true,
                                  ),
                                ),
                              ],
                              validator: _validateAddress,
                            ),

                            const SizedBox(height: 16),

                            // Credit History
                            _buildSectionHeader(
                              context.t('Credit History', 'Lịch sử tín dụng'),
                            ),
                            if (_hasCreditHistory == true) ...[
                              _buildTextField(
                                fieldKey: _yearsCreditHistoryFieldKey,
                                controller: _yearsCreditHistoryController,
                                focusNode: _yearsCreditHistoryFocusNode,
                                label: context.t(
                                  'Years Credit History',
                                  'Số năm lịch sử tín dụng',
                                ),
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(2),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: _validateYearsCreditHistory,
                              ),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                title: Text(
                                  context.t(
                                    'Have you ever defaulted?',
                                    'Bạn đã từng nợ xấu chưa?',
                                  ),
                                ),
                                value: _hasPreviousDefaults,
                                onChanged: (val) =>
                                    setState(() => _hasPreviousDefaults = val),
                                activeThumbColor: const Color(0xFF4D4AF9),
                              ),
                              SwitchListTile(
                                title: Text(
                                  context.t(
                                    'Currently defaulting?',
                                    'Hiện tại đang có nợ xấu?',
                                  ),
                                ),
                                value: _currentlyDefaulting,
                                onChanged: (val) =>
                                    setState(() => _currentlyDefaulting = val),
                                activeThumbColor: const Color(0xFF4D4AF9),
                              ),
                            ] else if (_hasCreditHistory == false) ...[
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
                                          'No problem! We\'ll calculate your profile based on income and employment only.',
                                          'Không sao! Chúng tôi sẽ tính hồ sơ của bạn dựa trên thu nhập và việc làm.',
                                        ),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Error message
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Results card
                            if (_limitResult != null) ...[
                              const SizedBox(height: 20),
                              _buildSectionHeader(
                                context.t(
                                  'Your Financial Profile',
                                  'Hồ sơ tài chính của bạn',
                                ),
                              ),
                              _buildResultCard(),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Calculate Button
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
                      onPressed: (_isCalculating || !_isFormComplete())
                          ? null
                          : _calculateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_isCalculating || !_isFormComplete())
                            ? Colors.grey.shade400
                            : const Color(0xFF4D4AF9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        context.t('Calculate Profile', 'Tính hồ sơ'),
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
        ),

        // Full-screen loading overlay
        if (_isCalculating)
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
                      const CircularProgressIndicator(
                        color: Color(0xFF4D4AF9),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.t(
                          'Analyzing your profile…',
                          'Đang phân tích hồ sơ của bạn…',
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1F3F),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.t(
                          'This may take up to 30 seconds.',
                          'Quá trình này có thể mất đến 30 giây.',
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

  // ==================== SUBMIT ====================

  bool _isFormComplete() {
    if (_hasCreditHistory == null) return false;
    if (_selectedDOB == null) return false;
    if (_yearsEmployedController.text.isEmpty) return false;
    if (_monthlyIncomeController.text.isEmpty) return false;
    if (_addressController.text.isEmpty) return false;
    if (_hasCreditHistory == true &&
        _yearsCreditHistoryController.text.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _calculateProfile() async {
    if (_hasCreditHistory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Please select whether you have credit history',
              'Vui lòng chọn bạn có lịch sử tín dụng hay không',
            ),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _limitResult = null;
      _errorMessage = null;
    });

    // Artificial 30-second processing delay to simulate analysis
    await Future.delayed(const Duration(seconds: 30));
    if (!mounted) return;

    try {
      final incomeText = _monthlyIncomeController.text
          .replaceAll('.', '')
          .replaceAll(',', '');
      final income = double.parse(incomeText);
      final yearsEmp = double.parse(_yearsEmployedController.text);

      double creditYears = 0;
      if (_hasCreditHistory == true) {
        creditYears = double.parse(_yearsCreditHistoryController.text);
      }

      int age = 25;
      if (_selectedDOB != null) {
        final today = DateTime.now();
        age = today.year - _selectedDOB!.year;
        if (today.month < _selectedDOB!.month ||
            (today.month == _selectedDOB!.month &&
                today.day < _selectedDOB!.day)) {
          age--;
        }
      }

      final api = ApiService();
      final limitResponse = await api.calculateLimit(
        CalculateLimitRequest(
          fullName: 'Demo User',
          age: age,
          monthlyIncome: income,
          employmentStatus: _employmentStatus,
          yearsEmployed: yearsEmp,
          homeOwnership: _homeOwnership,
          yearsCreditHistory: creditYears,
          hasPreviousDefaults: _hasPreviousDefaults,
          currentlyDefaulting: _currentlyDefaulting,
        ),
      );

      if (!mounted) return;
      setState(() {
        _limitResult = limitResponse;
        _isCalculating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCalculating = false;
        _errorMessage = context.t(
          'Could not calculate profile. Please try again.\n$e',
          'Không thể tính hồ sơ. Vui lòng thử lại.\n$e',
        );
      });
    }
  }

  // ==================== WIDGETS ====================

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4D4AF9),
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
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF4D4AF9),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _selectedDOB = picked);
      },
      validator: (value) {
        if (_selectedDOB == null) {
          return context.t(
            'Please select your date of birth',
            'Vui lòng chọn ngày sinh',
          );
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: context.t('Date of Birth', 'Ngày sinh'),
        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF4D4AF9)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4D4AF9), width: 2),
        ),
      ),
    );
  }

  Widget _buildTextField({
    GlobalKey<FormFieldState<String>>? fieldKey,
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    FocusNode? focusNode,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      maxLines: maxLines,
      maxLength: maxLength,
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4D4AF9), width: 2),
        ),
        counterText: '',
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
      initialValue: value,
      isExpanded: true,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
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
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                _getDropdownDisplayText(item),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  // ==================== RESULT CARD ====================

  Widget _buildResultCard() {
    final limit = _limitResult!;
    final riskColor = _getRiskColor(limit.riskLevel);
    final approved = limit.approved;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Coloured header (the "grey area" from screenshot)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: riskColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: icon + status + risk level
                Icon(
                  approved ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      approved
                          ? context.t('Approved', 'Được duyệt')
                          : context.t('Not Approved', 'Không được duyệt'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      limit.riskLevel,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Right: credit score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.t('Credit Score', 'Điểm tín dụng'),
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      '${limit.creditScore}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── White body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 18,
                      color: riskColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.t('Max Loan Limit', 'Hạn mức vay tối đa'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  NumberFormat.currency(
                    locale: context.isVietnamese ? 'vi_VN' : 'en_US',
                    symbol: '₫',
                  ).format(limit.loanLimitVnd),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1F3F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String level) {
    switch (level.toUpperCase()) {
      // API v2 values
      case 'LOW':
        return const Color(0xFF4CAF50);
      case 'MEDIUM':
        return const Color(0xFFFFC107);
      case 'HIGH':
        return const Color(0xFFFF9800);
      case 'VERY HIGH':
      case 'VERY_HIGH':
        return const Color(0xFFEF5350);
      // Legacy / alternate values
      case 'EXCELLENT':
        return const Color(0xFF4CAF50);
      case 'GOOD':
        return const Color(0xFF8BC34A);
      case 'FAIR':
        return const Color(0xFFFFC107);
      case 'POOR':
        return const Color(0xFFFF9800);
      case 'VERY POOR':
      case 'VERY_POOR':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF4CAF50); // fallback green if unknown
    }
  }

  // ==================== VALIDATORS ====================

  String? _validateYearsEmployed(String? value) {
    if (value == null || value.isEmpty) {
      return context.t(
        'Please enter Years Employed',
        'Vui lòng nhập số năm làm việc',
      );
    }
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
      return context.t(
        'Enter a valid number (up to 2 decimals)',
        'Nhập số hợp lệ (tối đa 2 chữ số thập phân)',
      );
    }
    final years = double.tryParse(value);
    if (years == null || years < 0 || years > 60) {
      return context.t(
        'Years Employed must be between 0 and 60',
        'Số năm làm việc phải trong khoảng 0 đến 60',
      );
    }
    return null;
  }

  String? _validateMonthlyIncome(String? value) {
    if (value == null || value.isEmpty) {
      return context.t(
        'Please enter Monthly Income',
        'Vui lòng nhập thu nhập hàng tháng',
      );
    }
    final cleaned = value.replaceAll('.', '').replaceAll(',', '');
    final income = double.tryParse(cleaned);
    if (income == null || income <= 0) {
      return context.t(
        'Monthly Income must be greater than 0',
        'Thu nhập hàng tháng phải lớn hơn 0',
      );
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return context.t(
        'Please enter Current Address',
        'Vui lòng nhập địa chỉ hiện tại',
      );
    }
    if (value.trim().length < 5) {
      return context.t(
        'Address must be at least 5 characters',
        'Địa chỉ phải có ít nhất 5 ký tự',
      );
    }
    if (!RegExp(
      r'^[\p{L}\p{M}0-9\s,\.\-/#]+$',
      unicode: true,
    ).hasMatch(value)) {
      return context.t(
        'Address can only contain letters, numbers, spaces, commas, dots, hyphens, slashes, and #',
        'Địa chỉ chỉ được chứa chữ, số, khoảng trắng, dấu phẩy, dấu chấm, dấu gạch nối, dấu gạch chéo và #',
      );
    }
    return null;
  }

  String? _validateYearsCreditHistory(String? value) {
    if (value == null || value.isEmpty) {
      return context.t(
        'Please enter Years Credit History',
        'Vui lòng nhập số năm lịch sử tín dụng',
      );
    }
    final years = int.tryParse(value);
    if (years == null || years < 0 || years > 50) {
      return context.t(
        'Years Credit History must be between 0 and 50',
        'Số năm lịch sử tín dụng phải trong khoảng 0 đến 50',
      );
    }
    return null;
  }

  String _getDropdownDisplayText(String value) {
    switch (value) {
      case 'EMPLOYED':
        return context.t('Employed', 'Đang làm việc');
      case 'SELF_EMPLOYED':
        return context.t('Self-employed', 'Tự kinh doanh');
      case 'UNEMPLOYED':
        return context.t('Unemployed', 'Thất nghiệp');
      case 'STUDENT':
        return context.t('Student', 'Sinh viên');
      case 'RETIRED':
        return context.t('Retired', 'Đã nghỉ hưu');
      case 'RENT':
        return context.t('Rent', 'Thuê');
      case 'OWN':
        return context.t('Own', 'Sở hữu');
      case 'MORTGAGE':
        return context.t('Mortgage', 'Thế chấp');
      case 'LIVING_WITH_PARENTS':
        return context.t('Living with parents', 'Sống cùng bố mẹ');
      case 'OTHER':
        return context.t('Other', 'Khác');
      default:
        return value;
    }
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
