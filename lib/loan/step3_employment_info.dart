import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/app_localization.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'step3_references_info.dart';

class Step3EmploymentInfoPage extends StatefulWidget {
  final Map<String, dynamic> personalData;

  const Step3EmploymentInfoPage({super.key, required this.personalData});

  @override
  State<Step3EmploymentInfoPage> createState() =>
      _Step3EmploymentInfoPageState();
}

class _Step3EmploymentInfoPageState extends State<Step3EmploymentInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final _monthlyIncomeController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _occupationTitleController = TextEditingController();

  String? _selectedJobType;
  String? _selectedContractType;

  bool _lockMonthlyIncome = false;

  // Validation error tracking
  final Map<String, String?> _fieldErrors = {};

  final NumberFormat _vndFormatter = NumberFormat('#,###', 'vi_VN');

  final List<String> _jobTypeOptions = [
    'EMPLOYED',
    'SELF_EMPLOYED',
    'UNEMPLOYED',
    'STUDENT',
    'RETIRED',
    'OTHER',
  ];

  final List<String> _contractTypeOptions = [
    'INDEFINITE',
    'FIXED_TERM',
    'SEASONAL',
    'PROBATION',
    'OTHER',
  ];

  @override
  void initState() {
    super.initState();
    _prefillFromViewModel();
  }

  void _prefillFromViewModel() {
    final vm = context.read<LoanViewModel>();

    if (vm.step2Completed) {
      if (vm.employmentStatus.trim().isNotEmpty) {
        _selectedJobType = vm.employmentStatus;
      }

      final monthlyIncome = vm.monthlyIncome;
      if (monthlyIncome > 0) {
        _monthlyIncomeController.text = _formatCurrencyNumber(monthlyIncome);
        _lockMonthlyIncome = true;
      }
    }
  }

  String _formatCurrencyNumber(num value) {
    return _vndFormatter.format(value.round());
  }

  double? _parseCurrencyNumber(String raw) {
    final cleaned = raw.replaceAll('.', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned);
  }

  @override
  void dispose() {
    _monthlyIncomeController.dispose();
    _companyNameController.dispose();
    _companyPhoneController.dispose();
    _companyAddressController.dispose();
    _occupationTitleController.dispose();
    super.dispose();
  }

  String? _validateOptionalPhone(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;

    final normalized = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    final isVietnamLocal = RegExp(r'^0\d{9}$').hasMatch(normalized);
    final isVietnamIntl = RegExp(r'^\+84\d{9}$').hasMatch(normalized);

    if (!isVietnamLocal && !isVietnamIntl) {
      return context.t(
        'Phone must be 10 digits (0xxxxxxxxx) or +84xxxxxxxxx',
        'Số điện thoại phải có dạng 0xxxxxxxxx hoặc +84xxxxxxxxx',
      );
    }
    return null;
  }

  String? _validateOptionalCurrency(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;

    final parsed = _parseCurrencyNumber(raw);
    if (parsed == null || parsed <= 0) {
      return context.t(
        'Monthly income must be greater than 0',
        'Thu nhập hàng tháng phải lớn hơn 0',
      );
    }
    return null;
  }

  String? _validateRequiredCurrency(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return context.t(
        'Please enter monthly income',
        'Vui lòng nhập thu nhập hàng tháng',
      );
    }
    return _validateOptionalCurrency(raw);
  }

  String? _validateRequiredPhone(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return context.t(
        'Please enter company phone',
        'Vui lòng nhập số điện thoại công ty',
      );
    }
    return _validateOptionalPhone(raw);
  }

  String? Function(String?) _requiredValidator(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  String _displayJobType(String value) {
    switch (value) {
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
      case 'OTHER':
        return context.t('Other', 'Khác');
      default:
        return value;
    }
  }

  String _displayContractType(String value) {
    switch (value) {
      case 'INDEFINITE':
        return context.t('Indefinite-term', 'Không xác định thời hạn');
      case 'FIXED_TERM':
        return context.t('Fixed-term', 'Xác định thời hạn');
      case 'SEASONAL':
        return context.t('Seasonal', 'Thời vụ');
      case 'PROBATION':
        return context.t('Probation', 'Thử việc');
      case 'OTHER':
        return context.t('Other', 'Khác');
      default:
        return value;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String fieldKey,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    void validateNow([String? value]) {
      final error = validator?.call(value ?? controller.text);
      if (_fieldErrors[fieldKey] != error) {
        setState(() {
          _fieldErrors[fieldKey] = error;
        });
      }
    }

    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          validateNow();
        }
      },
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        maxLength: maxLength,
        readOnly: readOnly,
        validator: (value) {
          final error = validator?.call(value);
          setState(() {
            _fieldErrors[fieldKey] = error;
          });
          return error;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF4D4AF9)),
          suffixIcon: readOnly
              ? const Icon(Icons.lock_outline, color: Color(0xFF4D4AF9))
              : null,
          filled: true,
          fillColor: readOnly
              ? const Color(0xFFF1F5F9)
              : const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _fieldErrors[fieldKey] != null
                  ? const Color(0xFFEF5350)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _fieldErrors[fieldKey] != null
                  ? const Color(0xFFEF5350)
                  : const Color(0xFF4D4AF9),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF5350)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
          ),
          errorText: _fieldErrors[fieldKey],
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String fieldKey,
    required IconData icon,
    required String? value,
    required List<String> items,
    required String Function(String) display,
    required ValueChanged<String?>? onChanged,
    String? Function(String?)? validator,
  }) {
    void validateNow([String? selected]) {
      final error = validator?.call(selected ?? value);
      if (_fieldErrors[fieldKey] != error) {
        setState(() {
          _fieldErrors[fieldKey] = error;
        });
      }
    }

    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          validateNow();
        }
      },
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF4D4AF9)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _fieldErrors[fieldKey] != null
                  ? const Color(0xFFEF5350)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _fieldErrors[fieldKey] != null
                  ? const Color(0xFFEF5350)
                  : const Color(0xFF4D4AF9),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF5350)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
          ),
          errorText: _fieldErrors[fieldKey],
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(display(item)),
          );
        }).toList(),
        onChanged: (selected) {
          onChanged?.call(selected);
          validateNow(selected);
        },
        validator: (selected) {
          final error = validator?.call(selected);
          setState(() {
            _fieldErrors[fieldKey] = error;
          });
          return error;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.t(
            'Step 3.2: Additional Information',
            'Bước 3.2: Thông tin bổ sung',
          ),
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
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
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t(
                            'Employment & Income',
                            'Công việc & Thu nhập',
                          ),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.t(
                            'Provide your employment details and income information',
                            'Cung cấp thông tin công việc và thu nhập của bạn',
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildDropdownField(
                          label: context.t('Job Type(*)', 'Loại công việc(*)'),
                          fieldKey: 'jobType',
                          icon: Icons.work,
                          value: _selectedJobType,
                          items: _jobTypeOptions,
                          display: _displayJobType,
                          onChanged: (value) =>
                              setState(() => _selectedJobType = value),
                          validator: (selected) =>
                              (selected == null || selected.isEmpty)
                              ? context.t(
                                  'Please select job type',
                                  'Vui lòng chọn loại công việc',
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _monthlyIncomeController,
                          label: context.t(
                            'Monthly Income(*)',
                            'Thu nhập hàng tháng(*)',
                          ),
                          fieldKey: 'monthlyIncome',
                          icon: Icons.money,
                          keyboardType: TextInputType.number,
                          readOnly: _lockMonthlyIncome,
                          validator: _validateRequiredCurrency,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _companyNameController,
                          label: context.t('Company Name(*)', 'Tên công ty(*)'),
                          fieldKey: 'companyName',
                          icon: Icons.business,
                          validator: _requiredValidator(
                            context.t(
                              'Please enter company name',
                              'Vui lòng nhập tên công ty',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _companyPhoneController,
                          label: context.t(
                            'Company Phone(*)',
                            'Số điện thoại công ty(*)',
                          ),
                          fieldKey: 'companyPhone',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: _validateRequiredPhone,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _companyAddressController,
                          label: context.t(
                            'Company Address(*)',
                            'Địa chỉ công ty(*)',
                          ),
                          fieldKey: 'companyAddress',
                          icon: Icons.location_on,
                          maxLines: 3,
                          validator: _requiredValidator(
                            context.t(
                              'Please enter company address',
                              'Vui lòng nhập địa chỉ công ty',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          label: context.t(
                            'Contract Type(*)',
                            'Loại hợp đồng(*)',
                          ),
                          fieldKey: 'contractType',
                          icon: Icons.description,
                          value: _selectedContractType,
                          items: _contractTypeOptions,
                          display: _displayContractType,
                          onChanged: (value) =>
                              setState(() => _selectedContractType = value),
                          validator: (selected) =>
                              (selected == null || selected.isEmpty)
                              ? context.t(
                                  'Please select contract type',
                                  'Vui lòng chọn loại hợp đồng',
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _occupationTitleController,
                          label: context.t(
                            'Occupation Title(*)',
                            'Chức danh công việc(*)',
                          ),
                          fieldKey: 'occupationTitle',
                          icon: Icons.badge,
                          validator: _requiredValidator(
                            context.t(
                              'Please enter occupation title',
                              'Vui lòng nhập chức danh công việc',
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF334155),
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        context.t('Back', 'Quay lại'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.t(
                                  'Please fix all errors',
                                  'Vui lòng sửa tất cả lỗi',
                                ),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Step3ReferencesInfoPage(
                              personalData: widget.personalData,
                              employmentData: {
                                'jobType': _selectedJobType,
                                'monthlyIncome': _parseCurrencyNumber(
                                  _monthlyIncomeController.text,
                                ),
                                'companyName': _companyNameController.text
                                    .trim(),
                                'companyPhone': _companyPhoneController.text
                                    .trim(),
                                'companyAddress': _companyAddressController.text
                                    .trim(),
                                'contractType': _selectedContractType,
                                'occupationTitle': _occupationTitleController
                                    .text
                                    .trim(),
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D4AF9),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              context.t(
                                'Next: Contact References',
                                'Tiếp: Liên hệ tham chiếu',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
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
}
