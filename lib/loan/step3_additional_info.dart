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
  final TextEditingController _emergencyContactRelationshipController = TextEditingController();
  final TextEditingController _referencesController = TextEditingController();

  @override
  void dispose() {
    _employerNameController.dispose();
    _jobTitleController.dispose();
    _workPhoneController.dispose();
    _yearsAtEmployerController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _emergencyContactRelationshipController.dispose();
    _referencesController.dispose();
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
                        controller: _employerNameController,
                        label: 'Employer Name',
                        icon: Icons.business,
                        validator: _validateEmployerName,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _jobTitleController,
                        label: 'Job Title',
                        icon: Icons.work,
                        validator: _validateJobTitle,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _workPhoneController,
                        label: 'Work Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: _validatePhoneNumber,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _yearsAtEmployerController,
                        label: 'Years at Current Employer',
                        icon: Icons.calendar_today,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]'))],
                        validator: _validateYearsAtEmployer,
                      ),
                      
                      const SizedBox(height: 24),
                      _buildSectionHeader('Emergency Contact'),
                      _buildTextField(
                        controller: _emergencyContactNameController,
                        label: 'Emergency Contact Name',
                        icon: Icons.person,
                        validator: _validateName,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emergencyContactPhoneController,
                        label: 'Emergency Contact Phone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: _validatePhoneNumber,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emergencyContactRelationshipController,
                        label: 'Relationship',
                        icon: Icons.family_restroom,
                        validator: _validateRelationship,
                      ),
                      
                      const SizedBox(height: 24),
                      _buildSectionHeader('References (Optional)'),
                      _buildTextField(
                        controller: _referencesController,
                        label: 'References',
                        icon: Icons.people,
                        maxLines: 3,
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
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool isRequired = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
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
  
  String? _validateRelationship(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter relationship';
    }
    if (value.length < 2) {
      return 'Relationship must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value)) {
      return 'Relationship can only contain letters, spaces, and hyphens';
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
