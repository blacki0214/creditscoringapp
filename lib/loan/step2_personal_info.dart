import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/loan_viewmodel.dart';
import '../home/main_shell.dart';
import 'loan_step_transitions.dart';
import '../utils/app_localization.dart';

class Step2PersonalInfoPage extends StatefulWidget {
  const Step2PersonalInfoPage({super.key});

  @override
  State<Step2PersonalInfoPage> createState() => _Step2PersonalInfoPageState();
}

class _Step2PersonalInfoPageState extends State<Step2PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();

  static const Color _accent = Color(0xFF3F4BFF);
  static const Color _pageBg = Color(0xFFE5E7EC);
  static const Color _surface = Color(0xFFF4F5F8);
  static const Color _inputBg = Color(0xFFDDE1E7);

  // Credit history selection
  bool? _hasCreditHistory;

  bool get _isCreditHistoryChosen => _hasCreditHistory != null;

  // Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _idController;
  late TextEditingController _monthlyIncomeController;
  late TextEditingController _yearsEmployedController;
  late TextEditingController _yearsCreditHistoryController;
  late TextEditingController _addressController;

  final _fullNameFieldKey = GlobalKey<FormFieldState<String>>();
  final _idFieldKey = GlobalKey<FormFieldState<String>>();
  final _monthlyIncomeFieldKey = GlobalKey<FormFieldState<String>>();
  final _yearsEmployedFieldKey = GlobalKey<FormFieldState<String>>();
  final _yearsCreditHistoryFieldKey = GlobalKey<FormFieldState<String>>();
  final _addressFieldKey = GlobalKey<FormFieldState<String>>();

  final _fullNameFocusNode = FocusNode();
  final _idFocusNode = FocusNode();
  final _monthlyIncomeFocusNode = FocusNode();
  final _yearsEmployedFocusNode = FocusNode();
  final _yearsCreditHistoryFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();

  DateTime? _selectedDOB;

  final NumberFormat _currencyFormatter = NumberFormat('#,###', 'vi_VN');

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

    // Load from ViewModel
    final vm = context.read<LoanViewModel>();
    _fullNameController = TextEditingController(text: vm.fullName);
    _idController = TextEditingController(text: vm.idNumber);
    _monthlyIncomeController = TextEditingController();
    _yearsEmployedController = TextEditingController();
    _yearsCreditHistoryController = TextEditingController();
    _addressController = TextEditingController(text: vm.address);
    _selectedDOB = vm.dob;

    _fullNameFocusNode.addListener(() {
      if (!_fullNameFocusNode.hasFocus) {
        _fullNameFieldKey.currentState?.validate();
      }
    });
    _idFocusNode.addListener(() {
      if (!_idFocusNode.hasFocus) {
        _idFieldKey.currentState?.validate();
      }
    });
    _monthlyIncomeFocusNode.addListener(() {
      if (!_monthlyIncomeFocusNode.hasFocus) {
        _monthlyIncomeFieldKey.currentState?.validate();
      }
    });
    _yearsEmployedFocusNode.addListener(() {
      if (!_yearsEmployedFocusNode.hasFocus) {
        _yearsEmployedFieldKey.currentState?.validate();
      }
    });
    _yearsCreditHistoryFocusNode.addListener(() {
      if (!_yearsCreditHistoryFocusNode.hasFocus) {
        _yearsCreditHistoryFieldKey.currentState?.validate();
      }
    });
    _addressFocusNode.addListener(() {
      if (!_addressFocusNode.hasFocus) {
        _addressFieldKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _idController.dispose();
    _monthlyIncomeController.dispose();
    _yearsEmployedController.dispose();
    _yearsCreditHistoryController.dispose();
    _addressController.dispose();
    _fullNameFocusNode.dispose();
    _idFocusNode.dispose();
    _monthlyIncomeFocusNode.dispose();
    _yearsEmployedFocusNode.dispose();
    _yearsCreditHistoryFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch ViewModel for state changes
    final vm = context.watch<LoanViewModel>();

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
            'Step 2: Personal Information',
            'Bước 2: Thông tin cá nhân',
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
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
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
                            'Complete your profile',
                            'Hoàn thiện hồ sơ của bạn',
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
                            'Please provide accurate information for credit scoring.',
                            'Vui lòng cung cấp thông tin chính xác để chấm điểm tín dụng.',
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Credit History Selection (Radio)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C40F7).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4C40F7).withOpacity(0.2),
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
                                style: const TextStyle(
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
                                      activeColor: const Color(0xFF4C40F7),
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
                                          'Không, tôi mới bắt đầu tín dụng',
                                        ),
                                      ),
                                      value: false,
                                      groupValue: _hasCreditHistory,
                                      onChanged: (val) => setState(
                                        () => _hasCreditHistory = val,
                                      ),
                                      activeColor: const Color(0xFF4C40F7),
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

                          _buildSectionHeader(
                            context.t('Personal Details', 'Thông tin cá nhân'),
                          ),
                          _buildTextField(
                            fieldKey: _fullNameFieldKey,
                            controller: _fullNameController,
                            focusNode: _fullNameFocusNode,
                            label: context.t('Full Name', 'Họ và tên'),
                            maxLength: 30,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(30),
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[\p{L}\p{M}\s]", unicode: true),
                              ),
                            ],
                            validator: _validateFullName,
                            onChanged: (val) =>
                                vm.updatePersonalInfo(name: val),
                          ),
                          const SizedBox(height: 16),
                          _buildDateField(),
                          const SizedBox(height: 16),
                          _buildTextField(
                            fieldKey: _idFieldKey,
                            controller: _idController,
                            focusNode: _idFocusNode,
                            label: context.t('ID Number (CCCD)', 'Số CCCD'),
                            keyboardType: TextInputType.number,
                            maxLength: 12,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(12),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: _validateIdNumber,
                            onChanged: (val) => vm.updatePersonalInfo(id: val),
                          ),

                          const SizedBox(height: 16),
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
                            value: vm.employmentStatus,
                            items: employmentOptions,
                            onChanged: (val) =>
                                vm.updatePersonalInfo(employment: val!),
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
                            keyboardType: const TextInputType.numberWithOptions(
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
                            onChanged: (val) => vm.updatePersonalInfo(
                              yearsEmp: double.tryParse(val),
                            ),
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
                            onChanged: (val) {
                              // Remove formatting characters (dots) and parse to double
                              final cleaned = val
                                  .replaceAll('.', '')
                                  .replaceAll(',', '');
                              final parsedIncome = double.tryParse(cleaned);
                              if (parsedIncome != null) {
                                vm.updatePersonalInfo(income: parsedIncome);
                              }
                            },
                          ),

                          const SizedBox(height: 16),
                          _buildSectionHeader(
                            context.t('Residence & Assets', 'Nơi ở & Tài sản'),
                          ),
                          _buildDropdown(
                            label: context.t(
                              'Home Ownership',
                              'Tình trạng nhà ở',
                            ),
                            value: vm.homeOwnership,
                            items: homeOwnershipOptions,
                            onChanged: (val) =>
                                vm.updatePersonalInfo(home: val!),
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
                                  r"[\p{L}\p{M}0-9\s,\.\-/#]",
                                  unicode: true,
                                ),
                              ),
                            ],
                            validator: _validateAddress,
                            onChanged: (val) =>
                                vm.updatePersonalInfo(addr: val),
                          ),

                          const SizedBox(height: 16),
                          _buildSectionHeader(
                            context.t('Credit History', 'Lịch sử tín dụng'),
                          ),

                          // Show credit history fields only if user has credit history
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
                              onChanged: (val) => vm.updatePersonalInfo(
                                history: double.tryParse(val),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: Text(
                                context.t(
                                  'Have you ever defaulted?',
                                  'Bạn đã từng trễ hạn/thất hẹn trả nợ chưa?',
                                ),
                              ),
                              value: vm.hasPreviousDefaults,
                              onChanged: (val) =>
                                  vm.updatePersonalInfo(defaults: val),
                              activeThumbColor: const Color(0xFF4C40F7),
                            ),
                            SwitchListTile(
                              title: Text(
                                context.t(
                                  'Currently defaulting?',
                                  'Hiện tại bạn có đang chậm trả nợ không?',
                                ),
                              ),
                              value: vm.currentlyDefaulting,
                              onChanged: (val) =>
                                  vm.updatePersonalInfo(currentDefault: val),
                              activeThumbColor: const Color(0xFF4C40F7),
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
                                        'No problem! We\'ll evaluate your application based on your income and employment.',
                                        'Không sao! Chúng tôi sẽ đánh giá hồ sơ dựa trên thu nhập và công việc của bạn.',
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
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
                vertical: 16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: vm.isProcessing || !_isCreditHistoryChosen
                      ? null
                      : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: vm.isProcessing
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          context.t('Submit Application', 'Nộp hồ sơ'),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _accent,
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
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF4C40F7),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _selectedDOB = picked);
          context.read<LoanViewModel>().updatePersonalInfo(dob: picked);
        }
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
        suffixIcon: const Icon(Icons.calendar_today, color: _accent),
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
    Function(String)? onChanged,
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

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return context.t('Please enter Full Name', 'Vui lòng nhập họ và tên');
    }
    if (value.trim().length < 2) {
      return context.t(
        'Full Name must be at least 2 characters',
        'Họ và tên phải có ít nhất 2 ký tự',
      );
    }
    if (!RegExp(r"^[\p{L}\p{M}\s]+$", unicode: true).hasMatch(value)) {
      return context.t(
        'Full Name can only contain letters and spaces',
        'Họ và tên chỉ được chứa chữ cái và khoảng trắng',
      );
    }
    return null;
  }

  String? _validateIdNumber(String? value) {
    if (value == null || value.isEmpty) {
      return context.t('Please enter ID Number', 'Vui lòng nhập số CCCD');
    }
    if (!RegExp(r'^\d{12}$').hasMatch(value)) {
      return context.t(
        'ID Number must be exactly 12 digits',
        'Số CCCD phải gồm đúng 12 chữ số',
      );
    }
    return null;
  }

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
        'Số năm làm việc phải nằm trong khoảng 0 đến 60',
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
    final cleaned = value.replaceAll('.', '');
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
      r"^[\p{L}\p{M}0-9\s,\.\-/#]+$",
      unicode: true,
    ).hasMatch(value)) {
      return context.t(
        'Address can only contain letters, numbers, spaces, commas, dots, hyphens, slashes, and #',
        'Địa chỉ chỉ được chứa chữ cái, số, khoảng trắng, dấu phẩy, dấu chấm, dấu gạch ngang, dấu gạch chéo và #',
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
        'Số năm lịch sử tín dụng phải nằm trong khoảng 0 đến 50',
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
      isExpanded: true,
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
              child: Text(
                _displayOption(item),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  String _displayOption(String item) {
    switch (item) {
      case 'EMPLOYED':
        return context.t('Employed', 'Nhân viên');
      case 'SELF_EMPLOYED':
        return context.t('Self-employed', 'Tự kinh doanh');
      case 'UNEMPLOYED':
        return context.t('Unemployed', 'Thất nghiệp');
      case 'STUDENT':
        return context.t('Student', 'Sinh viên');
      case 'RETIRED':
        return context.t('Retired', 'Nghỉ hưu');
      case 'RENT':
        return context.t('Rent', 'Thuê nhà');
      case 'OWN':
        return context.t('Own', 'Sở hữu');
      case 'MORTGAGE':
        return context.t('Mortgage', 'Thế chấp');
      case 'LIVING_WITH_PARENTS':
        return context.t('Living with parents', 'Ở cùng bố mẹ');
      case 'OTHER':
        return context.t('Other', 'Khác');
      default:
        return item;
    }
  }

  // ==================== SUBMIT HANDLER ====================

  Future<void> _submitApplication() async {
    if (!_isCreditHistoryChosen) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Please choose your credit history before submitting.',
              'Vui lòng chọn lịch sử tín dụng trước khi nộp hồ sơ.',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<LoanViewModel>();

    // Submit application asynchronously
    final success = await vm.submitApplicationAsync();

    if (!mounted) return;

    if (success) {
      // Navigate to MainShell so the bottom navigation bar remains visible.
      Navigator.of(context).pushAndRemoveUntil(
        buildLoanStepRoute(const MainShell()),
        (route) => false,
      );

      // Show snackbar to inform user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Your application is being processed. Check the Loans tab for status.',
              'Hồ sơ của bạn đang được xử lý. Vào tab Khoản vay để theo dõi trạng thái.',
            ),
          ),
          backgroundColor: Color(0xFF4C40F7),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.t('Error', 'Lỗi')),
          content: Text(
            vm.errorMessage ??
                context.t('Failed to submit application', 'Nộp hồ sơ thất bại'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.t('OK', 'Đồng ý')),
            ),
          ],
        ),
      );
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
