import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'processing_page.dart';

class Step2PersonalInfoPage extends StatefulWidget {
  const Step2PersonalInfoPage({super.key});

  @override
  State<Step2PersonalInfoPage> createState() => _Step2PersonalInfoPageState();
}

class _Step2PersonalInfoPageState extends State<Step2PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, GlobalKey<FormFieldState>> _fieldKeys = {};
  final Map<String, FocusNode> _fieldFocusNodes = {};
  final Map<String, bool> _touchedFields = {};
  
  // Credit history selection
  bool? _hasCreditHistory;
  
  // Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _idController;
  late TextEditingController _monthlyIncomeController;
  late TextEditingController _yearsEmployedController;
  late TextEditingController _yearsCreditHistoryController;
  late TextEditingController _addressController;
  
  DateTime? _selectedDOB;
  
  final NumberFormat _currencyFormatter = NumberFormat('#,###', 'vi_VN');
  
  final List<String> employmentOptions = ['EMPLOYED', 'SELF_EMPLOYED', 'UNEMPLOYED', 'STUDENT', 'RETIRED'];
  final List<String> homeOwnershipOptions = ['RENT', 'OWN', 'MORTGAGE', 'LIVING_WITH_PARENTS', 'OTHER'];
  final List<String> loanPurposeOptions = [
    'PERSONAL', 'EDUCATION', 'MEDICAL', 'BUSINESS', 
    'HOME_IMPROVEMENT', 'DEBT_CONSOLIDATION', 'VENTURE', 'OTHER'
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
  }

  GlobalKey<FormFieldState> _fieldKey(String id) {
    return _fieldKeys.putIfAbsent(id, () => GlobalKey<FormFieldState>());
  }

  FocusNode _fieldFocus(String id) {
    return _fieldFocusNodes.putIfAbsent(id, () {
      final node = FocusNode();
      node.addListener(() {
        if (!node.hasFocus) {
          _touchedFields[id] = true;
          _fieldKeys[id]?.currentState?.validate();
        }
      });
      return node;
    });
  }

  String? _validateIfTouched(
    String id,
    String? Function(String?) validator,
    String? value,
  ) {
    if (_touchedFields[id] != true) {
      return null;
    }
    return validator(value);
  }

  void _markAllTouched(Iterable<String> ids) {
    for (final id in ids) {
      _touchedFields[id] = true;
    }
  }

  @override
  void dispose() {
    for (final node in _fieldFocusNodes.values) {
      node.dispose();
    }
    _fullNameController.dispose();
    _idController.dispose();
    _monthlyIncomeController.dispose();
    _yearsEmployedController.dispose();
    _yearsCreditHistoryController.dispose();
    _addressController.dispose();
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
                        fieldId: 'fullName',
                        controller: _fullNameController,
                        label: 'Full Name',
                        maxLength: 30,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]'))],
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter Full Name';
                          }
                          final nameRegex = RegExp(r'^[A-Za-z ]+$');
                          if (!nameRegex.hasMatch(val.trim())) {
                            return 'Name can only contain letters and spaces';
                          }
                          return null;
                        },
                        onChanged: (val) => vm.updatePersonalInfo(name: val),
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        fieldId: 'idNumber',
                        controller: _idController,
                        label: 'ID Number (CCCD)',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 12,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter ID Number (CCCD)';
                          }
                          if (val.length != 12) {
                            return 'ID number must be 12 digits';
                          }
                          return null;
                        },
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
                        fieldId: 'yearsEmployed',
                        controller: _yearsEmployedController,
                        label: 'Years Employed',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]'))],
                        maxLength: 4,
                        onChanged: (val) => vm.updatePersonalInfo(yearsEmp: double.tryParse(val)),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        fieldId: 'monthlyIncome',
                        controller: _monthlyIncomeController,
                        label: 'Monthly Income (VND)',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CurrencyInputFormatter(_currencyFormatter),
                        ],
                        maxLength: 20,
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
                        fieldId: 'address',
                        controller: _addressController,
                        label: 'Current Address',
                        minLines: 2,
                        maxLines: 4,
                        maxLength: 200,
                        onChanged: (val) => vm.updatePersonalInfo(addr: val),
                      ),

                      const SizedBox(height: 16),
                      _buildSectionHeader('Loan Request'),
                      _buildDropdown(
                        label: 'Loan Purpose',
                        value: vm.loanPurpose,
                        items: loanPurposeOptions,
                        onChanged: (val) => vm.updatePersonalInfo(purpose: val!),
                      ),

                      const SizedBox(height: 16),
                      _buildSectionHeader('Credit History'),
                      
                      // Show credit history fields only if user has credit history
                      if (_hasCreditHistory == true) ...[
                        _buildTextField(
                          fieldId: 'yearsCreditHistory',
                          controller: _yearsCreditHistoryController,
                          label: 'Years Credit History',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          maxLength: 2,
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
      key: _fieldKey('dob'),
      readOnly: true,
      controller: TextEditingController(text: dobText),
      focusNode: _fieldFocus('dob'),
      maxLength: 10,
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
      validator: (value) => _validateIfTouched(
        'dob',
        (val) => _selectedDOB == null ? 'Please select your date of birth' : null,
        value,
      ),
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
    required String fieldId,
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
    int minLines = 1,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      key: _fieldKey(fieldId),
      controller: controller,
      focusNode: _fieldFocus(fieldId),
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: (value) => _validateIfTouched(
        fieldId,
        validator ??
            (val) => val == null || val.isEmpty ? 'Please enter $label' : null,
        value,
      ),
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
    );
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
    _markAllTouched([
      'fullName',
      'dob',
      'idNumber',
      'yearsEmployed',
      'monthlyIncome',
      'address',
      'yearsCreditHistory',
    ]);
    if (!_formKey.currentState!.validate()) return;
    
    // Navigate to ProcessingPage (which will handle API call)
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProcessingPage()),
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
