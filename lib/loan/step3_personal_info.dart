import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/app_localization.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'step3_employment_info.dart';

class Step3PersonalInfoPage extends StatefulWidget {
  const Step3PersonalInfoPage({super.key});

  @override
  State<Step3PersonalInfoPage> createState() => _Step3PersonalInfoPageState();
}

class _Step3PersonalInfoPageState extends State<Step3PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _nationalityController = TextEditingController(text: 'Việt Nam');
  final _cccdController = TextEditingController();
  final _oldIdController = TextEditingController();
  final _issuePlaceController = TextEditingController();
  final _taxCodeController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _currentAddressController = TextEditingController();
  final _mobilePhoneController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime? _dob;
  DateTime? _idIssueDate;
  DateTime? _idExpiryDate;

  String? _selectedGender;
  String? _selectedEducationLevel;
  String? _selectedMaritalStatus;
  String? _selectedResidencyStatus;

  bool _lockFullName = false;
  bool _lockDob = false;
  bool _lockCccd = false;
  bool _lockMobilePhone = false;

  // Validation error tracking
  final Map<String, String?> _fieldErrors = {};

  final List<String> _genderOptions = ['MALE', 'FEMALE', 'OTHER'];
  final List<String> _maritalStatusOptions = [
    'SINGLE',
    'MARRIED',
    'DIVORCED',
    'WIDOWED',
  ];
  final List<String> _residencyStatusOptions = ['RESIDENT', 'NON_RESIDENT'];
  final List<String> _educationLevelOptions = [
    'THCS',
    'THPT',
    'INTERMEDIATE',
    'COLLEGE',
    'UNIVERSITY',
    'MASTER',
    'DOCTORATE',
    'OTHER',
  ];

  @override
  void initState() {
    super.initState();
    _prefillFromStep2();
  }

  void _prefillFromStep2() {
    final vm = context.read<LoanViewModel>();
    final ekycFront = vm.frontIdData;
    final ekycBack = vm.backIdData;

    final idResidenceAddress =
        (ekycFront?.placeOfResidence ?? ekycBack?.placeOfResidence ?? '')
            .trim();
    if (idResidenceAddress.isNotEmpty) {
      _permanentAddressController.text = idResidenceAddress;
    }

    final issuePlace = (ekycBack?.issuePlace ?? ekycFront?.issuePlace ?? '')
        .trim();
    if (issuePlace.isNotEmpty) {
      _issuePlaceController.text = issuePlace;
    }

    final issueDateRaw = (ekycBack?.issueDate ?? ekycFront?.issueDate ?? '')
        .trim();
    if (issueDateRaw.isNotEmpty) {
      _idIssueDate = _parseDateLoose(issueDateRaw);
    }

    final expiryDateRaw = (ekycBack?.expiryDate ?? ekycFront?.expiryDate ?? '')
        .trim();
    if (expiryDateRaw.isNotEmpty) {
      _idExpiryDate = _parseDateLoose(expiryDateRaw);
    }

    final nationality = (ekycFront?.nationality ?? ekycBack?.nationality ?? '')
        .trim();
    if (nationality.isNotEmpty) {
      _nationalityController.text = nationality;
    }

    final normalizedGender = _normalizeGender(
      (ekycFront?.gender ?? ekycBack?.gender ?? '').trim(),
    );
    if (normalizedGender != null) {
      _selectedGender = normalizedGender;
    }

    if (vm.step2Completed) {
      final fullName = vm.fullName.trim();
      if (fullName.isNotEmpty && fullName != 'Nguyen Van A') {
        _fullNameController.text = fullName;
        _lockFullName = true;
      }

      if (vm.dob != null) {
        _dob = vm.dob;
        _lockDob = true;
      }

      final cccd = vm.idNumber.trim();
      if (RegExp(r'^\d{12}$').hasMatch(cccd)) {
        _cccdController.text = cccd;
        _lockCccd = true;
      }

      final address = vm.address.trim();
      if (address.isNotEmpty && address != '123 Street...') {
        _currentAddressController.text = address;
        if (_permanentAddressController.text.trim().isEmpty) {
          _permanentAddressController.text = address;
        }
      } else if (idResidenceAddress.isNotEmpty) {
        _currentAddressController.text = idResidenceAddress;
      }

      final phone = vm.phoneNumber.trim();
      if (phone.isNotEmpty && phone != '(+84) 901234567') {
        _mobilePhoneController.text = phone;
        _lockMobilePhone = true;
      }
    } else {
      final fullName = (ekycFront?.fullName ?? '').trim();
      if (fullName.isNotEmpty) {
        _fullNameController.text = fullName;
      }

      final idNumber = (ekycFront?.idNumber ?? '').trim();
      if (RegExp(r'^\d{12}$').hasMatch(idNumber)) {
        _cccdController.text = idNumber;
      }

      if (ekycFront?.dateOfBirth != null) {
        _dob = ekycFront!.dateOfBirth;
      }

      if (_currentAddressController.text.trim().isEmpty &&
          idResidenceAddress.isNotEmpty) {
        _currentAddressController.text = idResidenceAddress;
      }
    }
  }

  DateTime? _parseDateLoose(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final slash = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(value);
    if (slash != null) {
      final day = int.tryParse(slash.group(1)!);
      final month = int.tryParse(slash.group(2)!);
      final year = int.tryParse(slash.group(3)!);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    final dash = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(value);
    if (dash != null) {
      final year = int.tryParse(dash.group(1)!);
      final month = int.tryParse(dash.group(2)!);
      final day = int.tryParse(dash.group(3)!);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return DateTime.tryParse(value);
  }

  String? _normalizeGender(String raw) {
    if (raw.isEmpty) return null;
    final value = raw.toLowerCase();

    if (value.contains('male') || value.contains('nam')) return 'MALE';
    if (value.contains('female') ||
        value.contains('nữ') ||
        value.contains('nu')) {
      return 'FEMALE';
    }

    if (value.contains('other') ||
        value.contains('khác') ||
        value.contains('khac')) {
      return 'OTHER';
    }

    return null;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalityController.dispose();
    _cccdController.dispose();
    _oldIdController.dispose();
    _issuePlaceController.dispose();
    _taxCodeController.dispose();
    _permanentAddressController.dispose();
    _currentAddressController.dispose();
    _mobilePhoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateRequiredName(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return context.t('Please enter full name', 'Vui lòng nhập họ và tên');
    }
    if (raw.length < 2) {
      return context.t(
        'Name must be at least 2 characters',
        'Tên phải có ít nhất 2 ký tự',
      );
    }
    if (!RegExp(r"^[\p{L}\p{M}\s\-.']+$", unicode: true).hasMatch(raw)) {
      return context.t(
        'Name can only contain letters, spaces, dots, apostrophes, and hyphens',
        'Tên chỉ được chứa chữ cái, khoảng trắng, dấu chấm, dấu nháy và gạch nối',
      );
    }
    return null;
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

  String? _validateRequiredPhone(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return context.t(
        'Please enter phone number',
        'Vui lòng nhập số điện thoại',
      );
    }
    return _validateOptionalPhone(raw);
  }

  String? _validateOptionalGmail(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;

    final gmailRegex = RegExp(
      r'^[A-Z0-9._%+-]+@gmail\.com$',
      caseSensitive: false,
    );
    if (!gmailRegex.hasMatch(raw)) {
      return context.t(
        'Please enter a valid Gmail address',
        'Vui lòng nhập địa chỉ Gmail hợp lệ',
      );
    }
    return null;
  }

  String? _validateRequiredGmail(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return context.t('Please enter email', 'Vui lòng nhập email');
    }
    return _validateOptionalGmail(raw);
  }

  String _displayGender(String value) {
    switch (value) {
      case 'MALE':
        return context.t('Male', 'Nam');
      case 'FEMALE':
        return context.t('Female', 'Nữ');
      case 'OTHER':
        return context.t('Other', 'Khác');
      default:
        return value;
    }
  }

  String _displayMaritalStatus(String value) {
    switch (value) {
      case 'SINGLE':
        return context.t('Single', 'Độc thân');
      case 'MARRIED':
        return context.t('Married', 'Đã kết hôn');
      case 'DIVORCED':
        return context.t('Divorced', 'Ly hôn');
      case 'WIDOWED':
        return context.t('Widowed', 'Góa');
      default:
        return value;
    }
  }

  String _displayEducationLevel(String value) {
    switch (value) {
      case 'THCS':
        return context.t(
          'Lower secondary school (THCS)',
          'Trung học cơ sở (THCS)',
        );
      case 'THPT':
        return context.t(
          'Upper secondary school (THPT)',
          'Trung học phổ thông (THPT)',
        );
      case 'INTERMEDIATE':
        return context.t('Intermediate', 'Trung cấp');
      case 'COLLEGE':
        return context.t('College', 'Cao đẳng');
      case 'UNIVERSITY':
        return context.t(
          'University (Bachelor / Engineer)',
          'Đại học (Cử nhân / Kỹ sư)',
        );
      case 'MASTER':
        return context.t('Master', 'Thạc sĩ');
      case 'DOCTORATE':
        return context.t('Doctorate', 'Tiến sĩ');
      case 'OTHER':
        return context.t('Other', 'Khác');
      default:
        return value;
    }
  }

  String _displayResidencyStatus(String value) {
    switch (value) {
      case 'RESIDENT':
        return context.t('Resident', 'Người cư trú');
      case 'NON_RESIDENT':
        return context.t('Non-resident', 'Người không cư trú');
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
          prefixIcon: Icon(icon, color: const Color(0xFF4C40F7)),
          suffixIcon: readOnly
              ? const Icon(Icons.lock_outline, color: Color(0xFF4C40F7))
              : null,
          filled: true,
          fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _fieldErrors[fieldKey] != null
                  ? const Color(0xFFEF5350)
                  : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _fieldErrors[fieldKey] != null
                  ? const Color(0xFFEF5350)
                  : const Color(0xFF4C40F7),
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

  Widget _buildDateField({
    required String label,
    required String fieldKey,
    required IconData icon,
    required DateTime? initialValue,
    required ValueChanged<DateTime?> onChanged,
    required DateTime firstDate,
    required DateTime lastDate,
    bool locked = false,
    String? Function(DateTime?)? validator,
  }) {
    final text = initialValue == null
        ? ''
        : '${initialValue.day.toString().padLeft(2, '0')}/${initialValue.month.toString().padLeft(2, '0')}/${initialValue.year}';

    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: text),
      onTap: locked
          ? null
          : () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: initialValue ?? DateTime.now(),
                firstDate: firstDate,
                lastDate: lastDate,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF4C40F7),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                onChanged(picked);
              }
            },
      validator: (value) {
        final error = validator?.call(initialValue);
        setState(() {
          _fieldErrors[fieldKey] = error;
        });
        return error;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4C40F7)),
        suffixIcon: locked
            ? const Icon(Icons.lock_outline, color: Color(0xFF4C40F7))
            : const Icon(Icons.calendar_today, color: Color(0xFF4C40F7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _fieldErrors[fieldKey] != null
                ? const Color(0xFFEF5350)
                : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _fieldErrors[fieldKey] != null
                ? const Color(0xFFEF5350)
                : const Color(0xFF4C40F7),
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
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4C40F7)),
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
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(display(item)),
        );
      }).toList(),
      onChanged: onChanged,
    );
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
        title: Text(
          context.t(
            'Step 3.1: Additional Information',
            'Bước 3.1: Thông tin bổ sung',
          ),
          style: const TextStyle(color: Colors.black, fontSize: 16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t('Personal Information', 'Thông tin cá nhân'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F3F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.t(
                          'Complete your personal details from your ID',
                          'Hoàn thành thông tin cá nhân từ CCCD/Hộ chiếu của bạn',
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _fullNameController,
                        label: context.t('Full Name', 'Họ và tên'),
                        fieldKey: 'fullName',
                        icon: Icons.person,
                        readOnly: _lockFullName,
                        validator: _validateRequiredName,
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        label: context.t('Date of Birth', 'Ngày sinh'),
                        fieldKey: 'dob',
                        icon: Icons.cake,
                        initialValue: _dob,
                        onChanged: (date) => setState(() => _dob = date),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now().subtract(
                          const Duration(days: 18 * 365),
                        ),
                        locked: _lockDob,
                        validator: (date) => date == null
                            ? context.t(
                                'Please select date of birth',
                                'Vui lòng chọn ngày sinh',
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: context.t('Gender', 'Giới tính'),
                        fieldKey: 'gender',
                        icon: Icons.wc,
                        value: _selectedGender,
                        items: _genderOptions,
                        display: _displayGender,
                        onChanged: (value) =>
                            setState(() => _selectedGender = value),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _nationalityController,
                        label: context.t('Nationality', 'Quốc tịch'),
                        fieldKey: 'nationality',
                        icon: Icons.public,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: context.t(
                          'Marital Status',
                          'Tình trạng hôn nhân',
                        ),
                        fieldKey: 'maritalStatus',
                        icon: Icons.favorite,
                        value: _selectedMaritalStatus,
                        items: _maritalStatusOptions,
                        display: _displayMaritalStatus,
                        onChanged: (value) =>
                            setState(() => _selectedMaritalStatus = value),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: context.t('Education Level', 'Trình độ học vấn'),
                        fieldKey: 'educationLevel',
                        icon: Icons.school,
                        value: _selectedEducationLevel,
                        items: _educationLevelOptions,
                        display: _displayEducationLevel,
                        onChanged: (value) =>
                            setState(() => _selectedEducationLevel = value),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _cccdController,
                        label: context.t(
                          'CCCD / Passport ID',
                          'CCCD / Hộ chiếu',
                        ),
                        fieldKey: 'cccd',
                        icon: Icons.credit_card,
                        readOnly: _lockCccd,
                        validator: (value) {
                          final raw = value?.trim() ?? '';
                          if (raw.isEmpty) {
                            return context.t(
                              'Please enter CCCD',
                              'Vui lòng nhập CCCD',
                            );
                          }
                          if (!RegExp(r'^\d{12}$').hasMatch(raw)) {
                            return context.t(
                              'CCCD must be 12 digits',
                              'CCCD phải gồm 12 chữ số',
                            );
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _oldIdController,
                        label: context.t(
                          'Old ID Number (if any)',
                          'Chứng minh nhân dân cũ (nếu có)',
                        ),
                        fieldKey: 'oldId',
                        icon: Icons.receipt,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _issuePlaceController,
                        label: context.t('Issue Place', 'Nơi cấp'),
                        fieldKey: 'issuePlace',
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        label: context.t('Issue Date', 'Ngày cấp'),
                        fieldKey: 'issueDate',
                        icon: Icons.event,
                        initialValue: _idIssueDate,
                        onChanged: (date) =>
                            setState(() => _idIssueDate = date),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        label: context.t('Expiry Date', 'Ngày hết hạn'),
                        fieldKey: 'expiryDate',
                        icon: Icons.event,
                        initialValue: _idExpiryDate,
                        onChanged: (date) =>
                            setState(() => _idExpiryDate = date),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _taxCodeController,
                        label: context.t(
                          'Tax Code (if any)',
                          'Mã số thuế (nếu có)',
                        ),
                        fieldKey: 'taxCode',
                        icon: Icons.receipt_long,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: context.t(
                          'Residency Status',
                          'Tình trạng cư trú',
                        ),
                        fieldKey: 'residencyStatus',
                        icon: Icons.home,
                        value: _selectedResidencyStatus,
                        items: _residencyStatusOptions,
                        display: _displayResidencyStatus,
                        onChanged: (value) =>
                            setState(() => _selectedResidencyStatus = value),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _permanentAddressController,
                        label: context.t(
                          'Permanent Address',
                          'Địa chỉ thường trú',
                        ),
                        fieldKey: 'permanentAddress',
                        icon: Icons.location_on,
                        maxLines: 3,
                        validator: _requiredValidator(
                          context.t(
                            'Please enter permanent address',
                            'Vui lòng nhập địa chỉ thường trú',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _currentAddressController,
                        label: context.t('Current Address', 'Địa chỉ hiện tại'),
                        fieldKey: 'currentAddress',
                        icon: Icons.location_on,
                        maxLines: 3,
                        validator: _requiredValidator(
                          context.t(
                            'Please enter current address',
                            'Vui lòng nhập địa chỉ hiện tại',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _mobilePhoneController,
                        label: context.t(
                          'Mobile Phone',
                          'Số điện thoại di động',
                        ),
                        fieldKey: 'mobilePhone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        readOnly: _lockMobilePhone,
                        validator: _validateRequiredPhone,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: context.t('Email (Gmail)', 'Email (Gmail)'),
                        fieldKey: 'email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateRequiredGmail,
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
                        builder: (_) => Step3EmploymentInfoPage(
                          personalData: {
                            'fullName': _fullNameController.text.trim(),
                            'nationality': _nationalityController.text.trim(),
                            'gender': _selectedGender,
                            'cccd': _cccdController.text.trim(),
                            'oldIdNumber': _oldIdController.text.trim(),
                            'issuePlace': _issuePlaceController.text.trim(),
                            'issueDate': _idIssueDate?.toIso8601String(),
                            'expiryDate': _idExpiryDate?.toIso8601String(),
                            'educationLevel': _selectedEducationLevel,
                            'taxCode': _taxCodeController.text.trim(),
                            'maritalStatus': _selectedMaritalStatus,
                            'permanentAddress':
                                _permanentAddressController.text.trim(),
                            'currentAddress': _currentAddressController.text.trim(),
                            'mobilePhone': _mobilePhoneController.text.trim(),
                            'email': _emailController.text.trim(),
                            'residencyStatus': _selectedResidencyStatus,
                            'dob': _dob?.toIso8601String(),
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C40F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.t(
                      'Next: Employment Info',
                      'Tiếp: Thông tin công việc',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  String? Function(String?) _requiredValidator(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }
}
