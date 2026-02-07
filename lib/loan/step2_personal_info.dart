import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'processing_page.dart';
import '../home/home_page.dart';

class Step2PersonalInfoPage extends StatefulWidget {
  const Step2PersonalInfoPage({super.key});

  @override
  State<Step2PersonalInfoPage> createState() => _Step2PersonalInfoPageState();
}

class _Step2PersonalInfoPageState extends State<Step2PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Credit history selection
  bool? _hasCreditHistory;
  
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
  
  final List<String> employmentOptions = ['EMPLOYED', 'SELF_EMPLOYED', 'UNEMPLOYED', 'STUDENT', 'RETIRED'];
  final List<String> homeOwnershipOptions = ['RENT', 'OWN', 'MORTGAGE', 'LIVING_WITH_PARENTS', 'OTHER'];
  
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Step 2: Personal Information',
          style: TextStyle(color: Colors.black, fontSize: 16),
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
                      const Text(
                        'Complete your profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F3F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please provide accurate information for credit scoring.',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),
                      
                      // Credit History Selection (Radio)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4C40F7).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF4C40F7).withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Do you have credit history?',
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
                                    title: const Text('Yes, I have credit history'),
                                    value: true,
                                    groupValue: _hasCreditHistory,
                                    onChanged: (val) => setState(() => _hasCreditHistory = val),
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
                                    title: const Text('No, I\'m new to credit'),
                                    value: false,
                                    groupValue: _hasCreditHistory,
                                    onChanged: (val) => setState(() => _hasCreditHistory = val),
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
                      
                      _buildSectionHeader('Personal Details'),
                      _buildTextField(
                        fieldKey: _fullNameFieldKey,
                        controller: _fullNameController,
                        focusNode: _fullNameFocusNode,
                        label: 'Full Name',
                        maxLength: 30,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30),
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[\p{L}\p{M}\s]", unicode: true),
                          ),
                        ],
                        validator: _validateFullName,
                        onChanged: (val) => vm.updatePersonalInfo(name: val),
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        fieldKey: _idFieldKey,
                        controller: _idController,
                        focusNode: _idFocusNode,
                        label: 'ID Number (CCCD)',
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
                      _buildSectionHeader('Employment & Income'),
                      _buildDropdown(
                        label: 'Employment Status',
                        value: vm.employmentStatus,
                        items: employmentOptions,
                        onChanged: (val) => vm.updatePersonalInfo(employment: val!),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        fieldKey: _yearsEmployedFieldKey,
                        controller: _yearsEmployedController,
                        focusNode: _yearsEmployedFocusNode,
                        label: 'Years Employed',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        maxLength: 5,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(5),
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                        ],
                        validator: _validateYearsEmployed,
                        onChanged: (val) => vm.updatePersonalInfo(yearsEmp: double.tryParse(val)),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        fieldKey: _monthlyIncomeFieldKey,
                        controller: _monthlyIncomeController,
                        focusNode: _monthlyIncomeFocusNode,
                        label: 'Monthly Income (VND)',
                        keyboardType: TextInputType.number,
                        maxLength: 15,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                          FilteringTextInputFormatter.digitsOnly,
                          _CurrencyInputFormatter(_currencyFormatter),
                        ],
                        validator: _validateMonthlyIncome,
                        onChanged: (val) {
                          // Store locally - not in ViewModel
                        },
                      ),

                      const SizedBox(height: 16),
                      _buildSectionHeader('Residence & Assets'),
                      _buildDropdown(
                        label: 'Home Ownership',
                        value: vm.homeOwnership,
                        items: homeOwnershipOptions,
                        onChanged: (val) => vm.updatePersonalInfo(home: val!),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        fieldKey: _addressFieldKey,
                        controller: _addressController,
                        focusNode: _addressFocusNode,
                        label: 'Current Address',
                        maxLines: 2,
                        maxLength: 100,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[\p{L}\p{M}0-9\s,\.\-/#]", unicode: true),
                          ),
                        ],
                        validator: _validateAddress,
                        onChanged: (val) => vm.updatePersonalInfo(addr: val),
                      ),

                      const SizedBox(height: 16),
                      _buildSectionHeader('Credit History'),
                      
                      // Show credit history fields only if user has credit history
                      if (_hasCreditHistory == true) ...[
                        _buildTextField(
                          fieldKey: _yearsCreditHistoryFieldKey,
                          controller: _yearsCreditHistoryController,
                          focusNode: _yearsCreditHistoryFocusNode,
                          label: 'Years Credit History',
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: _validateYearsCreditHistory,
                          onChanged: (val) => vm.updatePersonalInfo(history: int.tryParse(val)),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Have you ever defaulted?'),
                          value: vm.hasPreviousDefaults,
                          onChanged: (val) => vm.updatePersonalInfo(defaults: val),
                          activeColor: const Color(0xFF4C40F7),
                        ),
                        SwitchListTile(
                          title: const Text('Currently defaulting?'),
                          value: vm.currentlyDefaulting,
                          onChanged: (val) => vm.updatePersonalInfo(currentDefault: val),
                          activeColor: const Color(0xFF4C40F7),
                        ),
                      ] else if (_hasCreditHistory == false) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No problem! We\'ll evaluate your application based on your income and employment.',
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
                vertical: 16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: vm.isProcessing ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C40F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: vm.isProcessing
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text(
                          'Submit Application',
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
          color: Color(0xFF4C40F7),
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
        if (_selectedDOB == null) return 'Please select your date of birth';
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Date of Birth',
        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF4C40F7)),
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
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
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
          borderSide: const BorderSide(color: Color(0xFF4C40F7), width: 2),
        ),
        counterText: '',
      ),
    );
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter Full Name';
    if (value.trim().length < 2) return 'Full Name must be at least 2 characters';
    if (!RegExp(r"^[\p{L}\p{M}\s]+$", unicode: true).hasMatch(value)) {
      return 'Full Name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateIdNumber(String? value) {
    if (value == null || value.isEmpty) return 'Please enter ID Number';
    if (!RegExp(r'^\d{12}$').hasMatch(value)) {
      return 'ID Number must be exactly 12 digits';
    }
    return null;
  }

  String? _validateYearsEmployed(String? value) {
    if (value == null || value.isEmpty) return 'Please enter Years Employed';
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
      return 'Enter a valid number (up to 2 decimals)';
    }
    final years = double.tryParse(value);
    if (years == null || years < 0 || years > 60) {
      return 'Years Employed must be between 0 and 60';
    }
    return null;
  }

  String? _validateMonthlyIncome(String? value) {
    if (value == null || value.isEmpty) return 'Please enter Monthly Income';
    final cleaned = value.replaceAll('.', '');
    final income = double.tryParse(cleaned);
    if (income == null || income <= 0) {
      return 'Monthly Income must be greater than 0';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) return 'Please enter Current Address';
    if (value.trim().length < 5) return 'Address must be at least 5 characters';
    if (!RegExp(r"^[\p{L}\p{M}0-9\s,\.\-/#]+$", unicode: true).hasMatch(value)) {
      return 'Address can only contain letters, numbers, spaces, commas, dots, hyphens, slashes, and #';
    }
    return null;
  }

  String? _validateYearsCreditHistory(String? value) {
    if (value == null || value.isEmpty) return 'Please enter Years Credit History';
    final years = int.tryParse(value);
    if (years == null || years < 0 || years > 50) {
      return 'Years Credit History must be between 0 and 50';
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
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
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
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis,))).toList(),
      onChanged: onChanged,
    );
  }

  // ==================== SUBMIT HANDLER ====================
  
  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    
    final vm = context.read<LoanViewModel>();
    
    // Submit application asynchronously
    final success = await vm.submitApplicationAsync();
    
    if (!mounted) return;
    
    if (success) {
      // Navigate to HomePage directly (not to '/' which goes to SplashScreen -> LoginPage)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
      
      // Show snackbar to inform user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your application is being processed. Check the Loans tab for status.'),
          backgroundColor: Color(0xFF4C40F7),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(vm.errorMessage ?? 'Failed to submit application'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
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
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
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
