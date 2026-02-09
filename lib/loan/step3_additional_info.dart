import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'step4_offer_calculator.dart';

class Step3AdditionalInfoPage extends StatefulWidget {
  const Step3AdditionalInfoPage({super.key});

  @override
  State<Step3AdditionalInfoPage> createState() => _Step3AdditionalInfoPageState();
}

class _Step3AdditionalInfoPageState extends State<Step3AdditionalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _employerNameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _workPhoneController = TextEditingController();
  final TextEditingController _yearsAtEmployerController = TextEditingController();
  final TextEditingController _emergencyContactNameController = TextEditingController();
  final TextEditingController _emergencyContactPhoneController = TextEditingController();
  final TextEditingController _referencesController = TextEditingController();

  final _employerNameFieldKey = GlobalKey<FormFieldState<String>>();
  final _jobTitleFieldKey = GlobalKey<FormFieldState<String>>();
  final _workPhoneFieldKey = GlobalKey<FormFieldState<String>>();
  final _yearsAtEmployerFieldKey = GlobalKey<FormFieldState<String>>();
  final _emergencyContactNameFieldKey = GlobalKey<FormFieldState<String>>();
  final _emergencyContactPhoneFieldKey = GlobalKey<FormFieldState<String>>();
  final _referencesFieldKey = GlobalKey<FormFieldState<String>>();

  final _employerNameFocusNode = FocusNode();
  final _jobTitleFocusNode = FocusNode();
  final _workPhoneFocusNode = FocusNode();
  final _yearsAtEmployerFocusNode = FocusNode();
  final _emergencyContactNameFocusNode = FocusNode();
  final _emergencyContactPhoneFocusNode = FocusNode();
  final _referencesFocusNode = FocusNode();

  String? _selectedRelationship;
  final List<String> _relationshipOptions = [
    'Mother',
    'Father',
    'Brother',
    'Sister',
    'Spouse',
    'Child',
    'Guardian',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _employerNameFocusNode.addListener(() {
      if (!_employerNameFocusNode.hasFocus) {
        _employerNameFieldKey.currentState?.validate();
      }
    });
    _jobTitleFocusNode.addListener(() {
      if (!_jobTitleFocusNode.hasFocus) {
        _jobTitleFieldKey.currentState?.validate();
      }
    });
    _workPhoneFocusNode.addListener(() {
      if (!_workPhoneFocusNode.hasFocus) {
        _workPhoneFieldKey.currentState?.validate();
      }
    });
    _yearsAtEmployerFocusNode.addListener(() {
      if (!_yearsAtEmployerFocusNode.hasFocus) {
        _yearsAtEmployerFieldKey.currentState?.validate();
      }
    });
    _emergencyContactNameFocusNode.addListener(() {
      if (!_emergencyContactNameFocusNode.hasFocus) {
        _emergencyContactNameFieldKey.currentState?.validate();
      }
    });
    _emergencyContactPhoneFocusNode.addListener(() {
      if (!_emergencyContactPhoneFocusNode.hasFocus) {
        _emergencyContactPhoneFieldKey.currentState?.validate();
      }
    });
    _referencesFocusNode.addListener(() {
      if (!_referencesFocusNode.hasFocus) {
        _referencesFieldKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _employerNameController.dispose();
    _jobTitleController.dispose();
    _workPhoneController.dispose();
    _yearsAtEmployerController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _referencesController.dispose();
    _employerNameFocusNode.dispose();
    _jobTitleFocusNode.dispose();
    _workPhoneFocusNode.dispose();
    _yearsAtEmployerFocusNode.dispose();
    _emergencyContactNameFocusNode.dispose();
    _emergencyContactPhoneFocusNode.dispose();
    _referencesFocusNode.dispose();
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
        title: const Text(
          'Step 3: Additional Information',
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
                        'Additional Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F3F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please provide additional information to complete your loan application.',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 24),
                      
                      _buildSectionHeader('Employment Information'),
                      _buildTextField(
                        fieldKey: _employerNameFieldKey,
                        controller: _employerNameController,
                        focusNode: _employerNameFocusNode,
                        label: 'Employer Name',
                        icon: Icons.business,
                        maxLength: 50,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50),
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\-\.&]')),
                        ],
                        validator: _validateEmployerName,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        fieldKey: _jobTitleFieldKey,
                        controller: _jobTitleController,
                        focusNode: _jobTitleFocusNode,
                        label: 'Job Title',
                        icon: Icons.work,
                        maxLength: 50,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50),
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\-/]')),
                        ],
                        validator: _validateJobTitle,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        fieldKey: _workPhoneFieldKey,
                        controller: _workPhoneController,
                        focusNode: _workPhoneFocusNode,
                        label: 'Work Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: _validatePhoneNumber,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        fieldKey: _yearsAtEmployerFieldKey,
                        controller: _yearsAtEmployerController,
                        focusNode: _yearsAtEmployerFocusNode,
                        label: 'Years at Current Employer',
                        icon: Icons.calendar_today,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        maxLength: 5,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(5),
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                        ],
                        validator: _validateYearsAtEmployer,
                      ),
                      
                      const SizedBox(height: 24),
                      _buildSectionHeader('Emergency Contact'),
                      _buildTextField(
                        fieldKey: _emergencyContactNameFieldKey,
                        controller: _emergencyContactNameController,
                        focusNode: _emergencyContactNameFocusNode,
                        label: 'Emergency Contact Name',
                        icon: Icons.person,
                        maxLength: 30,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30),
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\-\.]')),
                        ],
                        validator: _validateName,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        fieldKey: _emergencyContactPhoneFieldKey,
                        controller: _emergencyContactPhoneController,
                        focusNode: _emergencyContactPhoneFocusNode,
                        label: 'Emergency Contact Phone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: _validatePhoneNumber,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRelationship,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Relationship',
                          prefixIcon: const Icon(
                            Icons.family_restroom,
                            color: Color(0xFF4C40F7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF4C40F7),
                              width: 2,
                            ),
                          ),
                        ),
                        items: _relationshipOptions
                            .map(
                              (option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRelationship = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select relationship';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      _buildSectionHeader('References (Optional)'),
                      _buildTextField(
                        fieldKey: _referencesFieldKey,
                        controller: _referencesController,
                        focusNode: _referencesFocusNode,
                        label: 'References',
                        icon: Icons.people,
                        maxLines: 3,
                        maxLength: 200,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(200),
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[A-Za-z0-9\s,\.\-/#&()']"),
                          ),
                        ],
                        isRequired: false,
                      ),
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
                  child: const Text(
                    'Continue',
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

  Widget _buildTextField({
    GlobalKey<FormFieldState<String>>? fieldKey,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
    bool isRequired = true,
    FocusNode? focusNode,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      focusNode: focusNode,
      validator: validator ?? (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
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
        counterText: '',
      ),
    );
  }

  // ==================== VALIDATION FUNCTIONS ====================
  
  String? _validateEmployerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter employer name';
    }
    if (value.length < 2) {
      return 'Employer name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s\-\.&]+$').hasMatch(value)) {
      return 'Employer name can only contain letters, spaces, hyphens, dots, and &';
    }
    return null;
  }
  
  String? _validateJobTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter job title';
    }
    if (value.length < 2) {
      return 'Job title must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s\-\/]+$').hasMatch(value)) {
      return 'Job title can only contain letters, spaces, hyphens, and slashes';
    }
    return null;
  }
  
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    if (value.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Phone number can only contain digits';
    }
    return null;
  }
  
  String? _validateYearsAtEmployer(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter years at employer';
    }
    final years = double.tryParse(value);
    if (years == null) {
      return 'Please enter a valid number';
    }
    if (years < 0) {
      return 'Years cannot be negative';
    }
    if (years > 50) {
      return 'Please enter a realistic number of years';
    }
    return null;
  }
  
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter contact name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s\-\.]+$').hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and dots';
    }
    return null;
  }
  

  void _continueToOfferCalculator() {
    if (!_formKey.currentState!.validate()) return;
    
    // Mark Step 3 as completed
    final loanViewModel = context.read<LoanViewModel>();
    loanViewModel.completeStep3();
    
    // TODO: Save additional info to ViewModel/Firebase
    
    // Navigate to Step 4 - Offer Calculator
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Step4OfferCalculatorPage(),
      ),
    );
  }
}
