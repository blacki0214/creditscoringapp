import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'processing_page.dart';

class Step2PersonalInfoPage extends StatefulWidget {
  const Step2PersonalInfoPage({super.key});

  @override
  State<Step2PersonalInfoPage> createState() => _Step2PersonalInfoPageState();
}

class _Step2PersonalInfoPageState extends State<Step2PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _yearsEmployedController = TextEditingController();
  final _yearsCreditHistoryController = TextEditingController();

  final List<String> employmentOptions = ['EMPLOYED', 'SELF_EMPLOYED', 'UNEMPLOYED', 'STUDENT', 'RETIRED'];
  final List<String> homeOwnershipOptions = ['RENT', 'OWN', 'MORTGAGE', 'LIVING_WITH_PARENTS', 'OTHER'];
  final List<String> loanPurposeOptions = [
    'PERSONAL', 
    'EDUCATION', 
    'MEDICAL', 
    'BUSINESS', 
    'HOME_IMPROVEMENT', 
    'DEBT_CONSOLIDATION', 
    'VENTURE', 
    'OTHER'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with data from ViewModel
    final viewModel = context.read<LoanViewModel>();
    _nameController.text = viewModel.fullName;
    _phoneController.text = viewModel.phoneNumber;
    _idController.text = viewModel.idNumber;
    _addressController.text = viewModel.address;
    _ageController.text = viewModel.age.toString();
    _monthlyIncomeController.text = viewModel.monthlyIncome.toStringAsFixed(0);
    _yearsEmployedController.text = viewModel.yearsEmployed.toString();
    _yearsCreditHistoryController.text = viewModel.yearsCreditHistory.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Watch ViewModel for state changes
    final viewModel = context.watch<LoanViewModel>();

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
                padding: const EdgeInsets.all(24),
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
                      const SizedBox(height: 32),
                      
                      _buildSectionHeader('Personal Details'),
                      _buildTextField(_nameController, 'Full Name', 'Nguyen Van A', 
                        onChanged: (val) => viewModel.updatePersonalInfo(name: val)),
                      const SizedBox(height: 16),
                      _buildTextField(_ageController, 'Age', '30', keyboardType: TextInputType.number,
                        onChanged: (val) => viewModel.updatePersonalInfo(ageVal: int.tryParse(val))),
                      const SizedBox(height: 16),
                      _buildTextField(_phoneController, 'Phone Number', '(+84) 901234567', keyboardType: TextInputType.phone,
                        onChanged: (val) => viewModel.updatePersonalInfo(phone: val)),
                      const SizedBox(height: 16),
                      _buildTextField(_idController, 'ID Number (CCCD)', '079...',
                        onChanged: (val) => viewModel.updatePersonalInfo(id: val)),
                      
                      const SizedBox(height: 24),
                      _buildSectionHeader('Employment & Income'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              'Employment Status',
                              viewModel.employmentStatus,
                              employmentOptions,
                              (val) => viewModel.updatePersonalInfo(employment: val!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(_yearsEmployedController, 'Years Employed', '5', keyboardType: TextInputType.number,
                              onChanged: (val) => viewModel.updatePersonalInfo(yearsEmp: double.tryParse(val))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_monthlyIncomeController, 'Monthly Income (VND)', '15000000', keyboardType: TextInputType.number,
                        onChanged: (val) => viewModel.updatePersonalInfo(income: double.tryParse(val))),

                      const SizedBox(height: 24),
                      _buildSectionHeader('Residence & Assets'),
                      _buildDropdown(
                        'Home Ownership',
                        viewModel.homeOwnership,
                        homeOwnershipOptions,
                        (val) => viewModel.updatePersonalInfo(home: val!),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_addressController, 'Current Address', '123 Street...',
                        onChanged: (val) => viewModel.updatePersonalInfo(addr: val)),

                      const SizedBox(height: 24),
                      _buildSectionHeader('Loan Request'),
                      _buildDropdown(
                        'Loan Purpose',
                        viewModel.loanPurpose,
                        loanPurposeOptions,
                        (val) => viewModel.updatePersonalInfo(purpose: val!),
                      ),
                      
                      const SizedBox(height: 24),
                      _buildSectionHeader('Credit History'),
                      _buildTextField(_yearsCreditHistoryController, 'Years Credit History', '2', keyboardType: TextInputType.number,
                        onChanged: (val) => viewModel.updatePersonalInfo(history: int.tryParse(val))),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Have you ever defaulted?'),
                        value: viewModel.hasPreviousDefaults,
                        onChanged: (val) => viewModel.updatePersonalInfo(defaults: val),
                        activeColor: const Color(0xFF4C40F7),
                      ),
                      SwitchListTile(
                        title: const Text('Currently defaulting?'),
                        value: viewModel.currentlyDefaulting,
                        onChanged: (val) => viewModel.updatePersonalInfo(currentDefault: val),
                        activeColor: const Color(0xFF4C40F7),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: viewModel.isProcessing ? null : () => _submitApplication(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C40F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: viewModel.isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
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

  Widget _buildTextField(TextEditingController controller, String label, String hint, {TextInputType keyboardType = TextInputType.text, Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
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
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _submitApplication(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
       // Navigate to ProcessingPage - which will trigger the submission in VM
       // Or even better, let ProcessingPage be just a "Waiter" for the VM state?
       // But wait, ProcessingPage in original design did the call.
       // Here I will use ProcessingPage to TRIGGER the call.
       
       Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProcessingPage(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _monthlyIncomeController.dispose();
    _yearsEmployedController.dispose();
    _yearsCreditHistoryController.dispose();
    super.dispose();
  }
}
