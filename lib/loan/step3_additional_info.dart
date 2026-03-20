import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/app_localization.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'step4_offer_calculator.dart';

class Step3AdditionalInfoPage extends StatefulWidget {
  const Step3AdditionalInfoPage({super.key});

  @override
  State<Step3AdditionalInfoPage> createState() =>
      _Step3AdditionalInfoPageState();
}

class _Step3AdditionalInfoPageState extends State<Step3AdditionalInfoPage> {
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

  final _monthlyIncomeController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _occupationTitleController = TextEditingController();

  final _reference1NameController = TextEditingController();
  final _reference1PhoneController = TextEditingController();
  final _reference2NameController = TextEditingController();
  final _reference2PhoneController = TextEditingController();
  List<PlatformFile> _additionalDocuments = [];

  DateTime? _dob;
  DateTime? _idIssueDate;
  DateTime? _idExpiryDate;

  String? _selectedGender;
  String? _selectedEducationLevel;
  String? _selectedMaritalStatus;
  String? _selectedResidencyStatus;

  String? _selectedJobType;
  String? _selectedContractType;

  String? _selectedReference1Relationship;
  String? _selectedReference2Relationship;

  bool _lockFullName = false;
  bool _lockDob = false;
  bool _lockCccd = false;
  bool _lockMobilePhone = false;
  bool _lockJobType = false;
  bool _lockMonthlyIncome = false;

  final NumberFormat _vndFormatter = NumberFormat('#,###', 'vi_VN');

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
  final List<String> _relationshipOptions = [
    'PARENT',
    'SPOUSE',
    'SIBLING',
    'CHILD',
    'FRIEND',
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

    final issueDateRaw =
        (ekycBack?.issueDate ?? ekycFront?.issueDate ?? '').trim();
    if (issueDateRaw.isNotEmpty) {
      _idIssueDate = _parseDateLoose(issueDateRaw);
    }

    final expiryDateRaw =
        (ekycBack?.expiryDate ?? ekycFront?.expiryDate ?? '').trim();
    if (expiryDateRaw.isNotEmpty) {
      _idExpiryDate = _parseDateLoose(expiryDateRaw);
    }

    final nationality =
        (ekycFront?.nationality ?? ekycBack?.nationality ?? '').trim();
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

      if (vm.employmentStatus.trim().isNotEmpty) {
        _selectedJobType = vm.employmentStatus;
        _lockJobType = true;
      }

      final monthlyIncome = vm.monthlyIncome;
      if (monthlyIncome > 0) {
        _monthlyIncomeController.text = _formatCurrencyNumber(monthlyIncome);
        _lockMonthlyIncome = true;
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

  String _formatCurrencyNumber(num value) {
    return _vndFormatter.format(value.round());
  }

  double? _parseCurrencyNumber(String raw) {
    final cleaned = raw.replaceAll('.', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned);
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
    if (value.contains('female') || value.contains('nữ') || value.contains('nu')) {
      return 'FEMALE';
    }

    if (value.contains('other') || value.contains('khác') || value.contains('khac')) {
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

    _monthlyIncomeController.dispose();
    _companyNameController.dispose();
    _companyPhoneController.dispose();
    _companyAddressController.dispose();
    _occupationTitleController.dispose();

    _reference1NameController.dispose();
    _reference1PhoneController.dispose();
    _reference2NameController.dispose();
    _reference2PhoneController.dispose();
    super.dispose();
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
            'Step 3: Additional Information',
            'Bước 3: Thông tin bổ sung',
          ),
          style: const TextStyle(color: Colors.black, fontSize: 16),
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
                      _buildMainHeader(
                        context.t(
                          'Additional details for disbursement',
                          'Bổ sung thông tin để giải ngân',
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionHeader(
                        context.t(
                          'PERSONAL INFORMATION',
                          'THÔNG TIN CÁ NHÂN',
                        ),
                      ),
                      _buildTextField(
                        controller: _fullNameController,
                        label: context.t('Full Name*', 'Họ và tên*'),
                        icon: Icons.person,
                        readOnly: _lockFullName,
                        maxLength: 60,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(60),
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[\p{L}\p{M}\s]", unicode: true),
                          ),
                        ],
                        validator: _validateRequiredName,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _nationalityController,
                        label: context.t('Nationality*', 'Quốc tịch*'),
                        icon: Icons.flag_outlined,
                        maxLength: 40,
                        inputFormatters: [LengthLimitingTextInputFormatter(40)],
                        validator: _requiredValidator(
                          context.t('Please enter nationality', 'Vui lòng nhập quốc tịch'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDateField(
                        label: context.t(
                          'Date of Birth*',
                          'Ngày, tháng, năm sinh*',
                        ),
                        icon: Icons.cake_outlined,
                        value: _dob,
                        onChanged: (value) => setState(() => _dob = value),
                        locked: _lockDob,
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        label: context.t('Gender*', 'Giới tính*'),
                        icon: Icons.wc,
                        value: _selectedGender,
                        items: _genderOptions,
                        display: _displayGender,
                        onChanged: (value) =>
                            setState(() => _selectedGender = value),
                        validatorMessage: context.t(
                          'Please select gender',
                          'Vui lòng chọn giới tính',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _cccdController,
                        label: context.t('Citizen ID (CCCD)*', 'Căn cước công dân*'),
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        readOnly: _lockCccd,
                        maxLength: 12,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(12),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.t(
                              'Please enter citizen ID',
                              'Vui lòng nhập số CC/CCCD',
                            );
                          }
                          if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                            return context.t(
                              'Citizen ID must be exactly 12 digits',
                              'Số CC/CCCD phải gồm đúng 12 chữ số',
                            );
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _oldIdController,
                        label: context.t(
                          'Old ID Number (if any)',
                          'Số CMND cũ (nếu có)',
                        ),
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                        maxLength: 12,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(12),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDateField(
                        label: context.t('Issue Date*', 'Ngày cấp*'),
                        icon: Icons.event,
                        value: _idIssueDate,
                        onChanged: (value) => setState(() => _idIssueDate = value),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _issuePlaceController,
                        label: context.t('Issue Place*', 'Nơi cấp*'),
                        icon: Icons.location_city,
                        maxLength: 100,
                        inputFormatters: [LengthLimitingTextInputFormatter(100)],
                        validator: _requiredValidator(
                          context.t('Please enter issue place', 'Vui lòng nhập nơi cấp'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDateField(
                        label: context.t(
                          'CCCD Expiry Date*',
                          'Ngày thẻ CC/CCCD hết hạn*',
                        ),
                        icon: Icons.event_available,
                        value: _idExpiryDate,
                        onChanged: (value) =>
                            setState(() => _idExpiryDate = value),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        label: context.t('Education Level*', 'Trình độ học vấn*'),
                        icon: Icons.school_outlined,
                        value: _selectedEducationLevel,
                        items: _educationLevelOptions,
                        display: _displayEducationLevel,
                        onChanged: (value) =>
                            setState(() => _selectedEducationLevel = value),
                        validatorMessage: context.t(
                          'Please select education level',
                          'Vui lòng chọn trình độ học vấn',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _taxCodeController,
                        label: context.t('Tax Code (if any)', 'Mã số thuế (nếu có)'),
                        icon: Icons.numbers,
                        maxLength: 20,
                        inputFormatters: [LengthLimitingTextInputFormatter(20)],
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        label: context.t('Marital Status*', 'Tình trạng hôn nhân*'),
                        icon: Icons.favorite_border,
                        value: _selectedMaritalStatus,
                        items: _maritalStatusOptions,
                        display: _displayMaritalStatus,
                        onChanged: (value) =>
                            setState(() => _selectedMaritalStatus = value),
                        validatorMessage: context.t(
                          'Please select marital status',
                          'Vui lòng chọn tình trạng hôn nhân',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _permanentAddressController,
                        label: context.t('Permanent Address*', 'Địa chỉ thường trú*'),
                        icon: Icons.home_outlined,
                        readOnly: true,
                        maxLines: 2,
                        maxLength: 160,
                        inputFormatters: [LengthLimitingTextInputFormatter(160)],
                        validator: _requiredValidator(
                          context.t('Please enter permanent address', 'Vui lòng nhập địa chỉ thường trú'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _currentAddressController,
                        label: context.t(
                          'Current Residential Address*',
                          'Địa chỉ nơi ở hiện tại*',
                        ),
                        icon: Icons.location_on_outlined,
                        readOnly: false,
                        maxLines: 2,
                        maxLength: 160,
                        inputFormatters: [LengthLimitingTextInputFormatter(160)],
                        validator: _requiredValidator(
                          context.t(
                            'Please enter current residential address',
                            'Vui lòng nhập địa chỉ nơi ở hiện tại',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _mobilePhoneController,
                        label: context.t(
                          'Mobile Phone Number*',
                          'Số điện thoại di động*',
                        ),
                        icon: Icons.phone_android,
                        keyboardType: TextInputType.phone,
                        readOnly: _lockMobilePhone,
                        maxLength: 15,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+\-\s()]'),
                          ),
                        ],
                        validator: _validateRequiredPhone,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _emailController,
                        label: context.t('Email*', 'Email*'),
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 100,
                        inputFormatters: [LengthLimitingTextInputFormatter(100)],
                        validator: _validateRequiredGmail,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        label: context.t(
                          'Residency Status*',
                          'Tình trạng cư trú*',
                        ),
                        icon: Icons.badge,
                        value: _selectedResidencyStatus,
                        items: _residencyStatusOptions,
                        display: _displayResidencyStatus,
                        onChanged: (value) =>
                            setState(() => _selectedResidencyStatus = value),
                        validatorMessage: context.t(
                          'Please select residency status',
                          'Vui lòng chọn tình trạng cư trú',
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        context.t(
                          'EMPLOYMENT AND INCOME INFORMATION',
                          'THÔNG TIN NGHỀ NGHIỆP VÀ THU NHẬP',
                        ),
                      ),
                      _buildDropdownField(
                        label: context.t('Job Type', 'Loại hình công việc'),
                        icon: Icons.work_outline,
                        value: _selectedJobType,
                        items: _jobTypeOptions,
                        display: _displayJobType,
                        onChanged: _lockJobType
                            ? null
                            : (value) => setState(() => _selectedJobType = value),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _monthlyIncomeController,
                        label: context.t('Monthly Income*', 'Thu nhập hàng tháng*'),
                        icon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                        readOnly: _lockMonthlyIncome,
                        maxLength: 15,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                          FilteringTextInputFormatter.digitsOnly,
                          _CurrencyInputFormatter(_vndFormatter),
                        ],
                        suffixText: 'đ',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.t(
                              'Please enter monthly income',
                              'Vui lòng nhập thu nhập hàng tháng',
                            );
                          }
                          final income = _parseCurrencyNumber(value);
                          if (income == null || income <= 0) {
                            return context.t(
                              'Monthly income must be greater than 0',
                              'Thu nhập hàng tháng phải lớn hơn 0',
                            );
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _companyNameController,
                        label: context.t('Company Name*', 'Đơn vị công tác*'),
                        icon: Icons.business,
                        maxLength: 100,
                        inputFormatters: [LengthLimitingTextInputFormatter(100)],
                        validator: _requiredMin2Validator(
                          context.t('Please enter company name', 'Vui lòng nhập đơn vị công tác'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _companyPhoneController,
                        label: context.t('Office Phone*', 'Điện thoại cơ quan*'),
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        maxLength: 15,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+\-\s()]'),
                          ),
                        ],
                        validator: _validateRequiredPhone,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _companyAddressController,
                        label: context.t('Office Address*', 'Địa chỉ cơ quan*'),
                        icon: Icons.location_city,
                        maxLines: 2,
                        maxLength: 160,
                        inputFormatters: [LengthLimitingTextInputFormatter(160)],
                        validator: _requiredValidator(
                          context.t('Please enter office address', 'Vui lòng nhập địa chỉ cơ quan'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        label: context.t(
                          'Labor Contract Type*',
                          'Loại hợp đồng lao động*',
                        ),
                        icon: Icons.description_outlined,
                        value: _selectedContractType,
                        items: _contractTypeOptions,
                        display: _displayContractType,
                        onChanged: (value) =>
                            setState(() => _selectedContractType = value),
                        validatorMessage: context.t(
                          'Please select labor contract type',
                          'Vui lòng chọn loại hợp đồng lao động',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _occupationTitleController,
                        label: context.t(
                          'Occupation / Position*',
                          'Nghề nghiệp, Chức vụ*',
                        ),
                        icon: Icons.badge,
                        maxLength: 60,
                        inputFormatters: [LengthLimitingTextInputFormatter(60)],
                        validator: _requiredMin2Validator(
                          context.t(
                            'Please enter occupation/position',
                            'Vui lòng nhập nghề nghiệp/chức vụ',
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        context.t(
                          'REFERENCE INFORMATION (*)',
                          'THÔNG TIN NGƯỜI THAM CHIẾU (*)',
                        ),
                      ),
                      _buildTextField(
                        controller: _reference1NameController,
                        label: context.t(
                          'Reference Person 1 Name*',
                          'Họ và tên người tham chiếu 1*',
                        ),
                        icon: Icons.person_outline,
                        maxLength: 60,
                        inputFormatters: [LengthLimitingTextInputFormatter(60)],
                        validator: _validateRequiredName,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        label: context.t('Relationship*', 'Quan hệ*'),
                        icon: Icons.family_restroom,
                        value: _selectedReference1Relationship,
                        items: _relationshipOptions,
                        display: _displayRelationship,
                        onChanged: (value) {
                          setState(() {
                            _selectedReference1Relationship = value;
                            if (_selectedReference2Relationship == value) {
                              _selectedReference2Relationship = null;
                            }
                          });
                        },
                        validatorMessage: context.t(
                          'Please select relationship for reference 1',
                          'Vui lòng chọn quan hệ người tham chiếu 1',
                        ),
                        required: true,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _reference1PhoneController,
                        label: context.t('Phone*', 'Điện thoại*'),
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        maxLength: 15,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+\-\s()]'),
                          ),
                        ],
                        validator: _validateRequiredPhone,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _reference2NameController,
                        label: context.t(
                          'Reference Person 2 Name*',
                          'Họ và tên người tham chiếu 2*',
                        ),
                        icon: Icons.person_outline,
                        maxLength: 60,
                        inputFormatters: [LengthLimitingTextInputFormatter(60)],
                        validator: _validateRequiredName,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        label: context.t('Relationship*', 'Quan hệ*'),
                        icon: Icons.family_restroom,
                        value: _selectedReference2Relationship,
                        items: _relationshipOptions,
                        display: _displayRelationship,
                        onChanged: (value) =>
                            setState(() => _selectedReference2Relationship = value),
                        validatorMessage: context.t(
                          'Please select relationship for reference 2',
                          'Vui lòng chọn quan hệ người tham chiếu 2',
                        ),
                        required: true,
                        disabledValues: {
                          if (_selectedReference1Relationship != null)
                            _selectedReference1Relationship!,
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _reference2PhoneController,
                        label: context.t('Phone*', 'Điện thoại*'),
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        maxLength: 15,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+\-\s()]'),
                          ),
                        ],
                        validator: _validateRequiredPhone,
                      ),
                      const SizedBox(height: 16),
                      _buildDocumentUploadField(),
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
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continueToOfferCalculator,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C40F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    context.t('Continue', 'Tiếp tục'),
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

  Widget _buildMainHeader(String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t('Additional Information', 'Thông tin bổ sung'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1F3F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
          fontWeight: FontWeight.w700,
          color: Color(0xFF4C40F7),
        ),
      ),
    );
  }

  Widget _buildDocumentUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t('Additional Documents', 'Tài liệu bổ sung'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1F3F),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickAdditionalDocuments,
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    context.t('Upload Documents', 'Tải tài liệu lên'),
                  ),
                ),
              ),
              if (_additionalDocuments.isNotEmpty) ...[
                const SizedBox(height: 8),
                ..._additionalDocuments.map(
                  (doc) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.insert_drive_file_outlined,
                          size: 16,
                          color: Color(0xFF4C40F7),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            doc.name,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickAdditionalDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
    );
    if (result == null) return;

    setState(() {
      _additionalDocuments = result.files;
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
    bool readOnly = false,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4C40F7)),
        suffixText: suffixText,
        suffixIcon: readOnly
            ? const Icon(Icons.lock_outline, color: Color(0xFF4C40F7))
            : null,
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4C40F7), width: 2),
        ),
        counterText: '',
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
    required DateTime firstDate,
    required DateTime lastDate,
    bool locked = false,
  }) {
    final text = value == null
        ? ''
        : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: text),
      onTap: locked
          ? null
          : () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: firstDate,
                lastDate: lastDate,
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
                onChanged(picked);
              }
            },
      validator: (_) {
        if (value == null) {
          return context.t('Please select $label', 'Vui lòng chọn $label');
        }
        return null;
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
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4C40F7), width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required String Function(String) display,
    required ValueChanged<String?>? onChanged,
    String? validatorMessage,
    bool required = true,
    Set<String> disabledValues = const <String>{},
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
        final disabled = disabledValues.contains(item);
        return DropdownMenuItem<String>(
          value: item,
          enabled: !disabled,
          child: Text(
            display(item),
            style: TextStyle(
              color: disabled ? Colors.grey.shade400 : Colors.black,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (selected) {
        if (required && (selected == null || selected.isEmpty)) {
          return validatorMessage ??
              context.t('Please select $label', 'Vui lòng chọn $label');
        }
        if (selected != null && disabledValues.contains(selected)) {
          return context.t(
            '$label cannot duplicate another selected relationship',
            '$label không được trùng với mối quan hệ đã chọn khác',
          );
        }
        return null;
      },
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

  String? Function(String?) _requiredMin2Validator(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      if (value.trim().length < 2) {
        return context.t(
          'Must be at least 2 characters',
          'Phải có ít nhất 2 ký tự',
        );
      }
      return null;
    };
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

  String? _validateOptionalName(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;
    if (raw.length < 2) {
      return context.t(
        'Name must be at least 2 characters',
        'Tên phải có ít nhất 2 ký tự',
      );
    }
    if (!RegExp(r"^[\p{L}\p{M}\s\-.']+$", unicode: true).hasMatch(raw)) {
      return context.t(
        'Invalid name format',
        'Định dạng tên không hợp lệ',
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

    final gmailRegex = RegExp(r'^[A-Z0-9._%+-]+@gmail\.com$', caseSensitive: false);
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
      return context.t(
        'Please enter email',
        'Vui lòng nhập email',
      );
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
        return context.t('Lower secondary school (THCS)', 'Trung học cơ sở (THCS)');
      case 'THPT':
        return context.t('Upper secondary school (THPT)', 'Trung học phổ thông (THPT)');
      case 'INTERMEDIATE':
        return context.t('Intermediate', 'Trung cấp');
      case 'COLLEGE':
        return context.t('College', 'Cao đẳng');
      case 'UNIVERSITY':
        return context.t('University (Bachelor / Engineer)', 'Đại học (Cử nhân / Kỹ sư)');
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

  String _displayRelationship(String value) {
    switch (value) {
      case 'PARENT':
        return context.t('Parent', 'Cha/Mẹ');
      case 'SPOUSE':
        return context.t('Spouse', 'Vợ/Chồng');
      case 'SIBLING':
        return context.t('Sibling', 'Anh/Chị/Em');
      case 'CHILD':
        return context.t('Child', 'Con');
      case 'FRIEND':
        return context.t('Friend', 'Bạn bè');
      case 'OTHER':
        return context.t('Other', 'Khác');
      default:
        return value;
    }
  }

  Future<void> _continueToOfferCalculator() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedReference1Relationship != null &&
        _selectedReference1Relationship == _selectedReference2Relationship) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Reference relationships must be different',
              'Hai người tham chiếu phải có quan hệ khác nhau',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final loanViewModel = context.read<LoanViewModel>();
    final isRejected =
        loanViewModel.isApplicationRejected ||
        (loanViewModel.currentOffer?['approved'] == false);

    if (isRejected) {
      await loanViewModel.resetLoanApplicationState();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'Your previous application was rejected. Data has been cleared. Please submit a new application.',
              'Hồ sơ trước của bạn đã bị từ chối. Dữ liệu đã được xóa. Vui lòng nộp hồ sơ mới.',
            ),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pop(context);
      return;
    }

    final step3Payload = <String, dynamic>{
      'personalInfo': {
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
        'permanentAddress': _permanentAddressController.text.trim(),
        'currentAddress': _currentAddressController.text.trim(),
        'mobilePhone': _mobilePhoneController.text.trim(),
        'email': _emailController.text.trim(),
        'residencyStatus': _selectedResidencyStatus,
        'dob': _dob?.toIso8601String(),
      },
      'employment': {
        'jobType': _selectedJobType,
        'monthlyIncome': _parseCurrencyNumber(_monthlyIncomeController.text),
        'companyName': _companyNameController.text.trim(),
        'companyPhone': _companyPhoneController.text.trim(),
        'companyAddress': _companyAddressController.text.trim(),
        'contractType': _selectedContractType,
        'occupationTitle': _occupationTitleController.text.trim(),
      },
      'references': [
        {
          'name': _reference1NameController.text.trim(),
          'relationship': _selectedReference1Relationship,
          'phone': _reference1PhoneController.text.trim(),
        },
        {
          'name': _reference2NameController.text.trim(),
          'relationship': _selectedReference2Relationship,
          'phone': _reference2PhoneController.text.trim(),
        },
      ],
      'documents': _additionalDocuments.map((doc) => doc.name).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await loanViewModel.completeStep3(step3Data: step3Payload);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Step4OfferCalculatorPage()),
    );
  }
}

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
