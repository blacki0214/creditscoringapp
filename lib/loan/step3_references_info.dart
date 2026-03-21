import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../utils/app_localization.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'step4_offer_calculator.dart';

class Step3ReferencesInfoPage extends StatefulWidget {
  final Map<String, dynamic> personalData;
  final Map<String, dynamic> employmentData;

  const Step3ReferencesInfoPage({
    super.key,
    required this.personalData,
    required this.employmentData,
  });

  @override
  State<Step3ReferencesInfoPage> createState() =>
      _Step3ReferencesInfoPageState();
}

class _Step3ReferencesInfoPageState extends State<Step3ReferencesInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final _reference1NameController = TextEditingController();
  final _reference1PhoneController = TextEditingController();
  final _reference2NameController = TextEditingController();
  final _reference2PhoneController = TextEditingController();

  String? _selectedReference1Relationship;
  String? _selectedReference2Relationship;

  List<PlatformFile> _additionalDocuments = [];

  // Validation error tracking
  final Map<String, String?> _fieldErrors = {};

  final List<String> _relationshipOptions = [
    'PARENT',
    'SPOUSE',
    'SIBLING',
    'CHILD',
    'FRIEND',
    'OTHER',
  ];

  @override
  void dispose() {
    _reference1NameController.dispose();
    _reference1PhoneController.dispose();
    _reference2NameController.dispose();
    _reference2PhoneController.dispose();
    super.dispose();
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
      return context.t('Invalid name format', 'Định dạng tên không hợp lệ');
    }
    return null;
  }

  String? _validateRequiredName(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return context.t('Please enter name', 'Vui lòng nhập tên');
    }
    return _validateOptionalName(raw);
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String fieldKey,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
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
        maxLines: maxLines,
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
            'Step 3.3: Additional Information',
            'Bước 3.3: Thông tin bổ sung',
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
                        context.t('References', 'Người tham chiếu'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F3F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.t(
                          'Provide contact information for personal references',
                          'Cung cấp thông tin liên hệ cho những người tham chiếu',
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.t('Reference 1', 'Người tham chiếu 1'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4C40F7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _reference1NameController,
                        label: context.t('Name', 'Tên'),
                        fieldKey: 'reference1Name',
                        icon: Icons.person,
                        validator: _validateRequiredName,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _reference1PhoneController,
                        label: context.t('Phone Number', 'Số điện thoại'),
                        fieldKey: 'reference1Phone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: _validateRequiredPhone,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        label: context.t('Relationship', 'Mối quan hệ'),
                        fieldKey: 'reference1Relationship',
                        icon: Icons.people,
                        value: _selectedReference1Relationship,
                        items: _relationshipOptions,
                        display: _displayRelationship,
                        onChanged: (value) => setState(
                          () => _selectedReference1Relationship = value,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.t('Reference 2', 'Người tham chiếu 2'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4C40F7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _reference2NameController,
                        label: context.t('Name', 'Tên'),
                        fieldKey: 'reference2Name',
                        icon: Icons.person,
                        validator: _validateRequiredName,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _reference2PhoneController,
                        label: context.t('Phone Number', 'Số điện thoại'),
                        fieldKey: 'reference2Phone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: _validateRequiredPhone,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        label: context.t('Relationship', 'Mối quan hệ'),
                        fieldKey: 'reference2Relationship',
                        icon: Icons.people,
                        value: _selectedReference2Relationship,
                        items: _relationshipOptions,
                        display: _displayRelationship,
                        onChanged: (value) => setState(
                          () => _selectedReference2Relationship = value,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.t('Additional Documents', 'Tài liệu bổ sung'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1F3F),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                              child: ElevatedButton(
                                onPressed: _pickAdditionalDocuments,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4C40F7),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.upload_file),
                                    const SizedBox(width: 8),
                                    Text(
                                      context.t(
                                        'Upload Additional Documents',
                                        'Tải lên tài liệu bổ sung',
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_additionalDocuments.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _additionalDocuments.map((doc) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.attachment,
                                            size: 16,
                                            color: Color(0xFF4C40F7),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              doc.name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF1A1F3F),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
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
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: const Color(0xFF1A1F3F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                      onPressed: () async {
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

                        if (_selectedReference1Relationship != null &&
                            _selectedReference1Relationship ==
                                _selectedReference2Relationship) {
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

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Step4OfferCalculatorPage(),
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
                          'Next: Calculate Offer',
                          'Tiếp: Tính toán đề nghị',
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
}
