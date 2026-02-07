import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final Map<String, GlobalKey<FormFieldState>> _fieldKeys = {};
  final Map<String, FocusNode> _fieldFocusNodes = {};
  final Map<String, bool> _touchedFields = {};
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _idController = TextEditingController();
  final _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vm = context.read<SettingsViewModel>();
    _nameController.text = vm.name;
    _emailController.text = vm.email;
    _phoneController.text = vm.phone;
    _addressController.text = vm.address;
    _idController.text = vm.idNumber;
    _dobController.text = vm.dob;
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

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final nameRegex = RegExp(r'^[A-Za-z ]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (!cleaned.startsWith('0')) {
      return 'Phone number must start with 0';
    }
    return null;
  }

  String? _validateDob(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final dobRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dobRegex.hasMatch(value.trim())) {
      return 'Use format DD/MM/YYYY';
    }
    return null;
  }

  String? _validateIdNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 12) {
      return 'ID number must be 12 digits';
    }
    return null;
  }

  void _markAllTouched() {
    for (final id in _fieldKeys.keys) {
      _touchedFields[id] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();

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
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Save changes
                  _markAllTouched();
                  if (_formKey.currentState!.validate()) {
                    context.read<SettingsViewModel>().updateProfile(
                      name: _nameController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                      address: _addressController.text,
                      idNumber: _idController.text,
                      dob: _dobController.text,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                    _isEditing = false;
                  }
                } else {
                  _isEditing = true;
                }
              });
            },
            child: Text(
              _isEditing ? 'Save' : 'Edit',
              style: const TextStyle(
                color: Color(0xFF4C40F7),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar section
                Stack(
                  children: [
                    settingsViewModel.avatarUrl != null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(
                              settingsViewModel.avatarUrl!,
                            ),
                          )
                        : CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade200,
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF4C40F7),
                            ),
                          ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4C40F7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Personal Information Section
                _buildSectionTitle('Personal Information'),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: 'Full Name',
                  fieldId: 'fullName',
                  controller: _nameController,
                  icon: Icons.person_outline,
                  enabled: _isEditing,
                  maxLength: 30,
                  validator: _validateFullName,
                ),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: 'Email',
                  fieldId: 'email',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  enabled: _isEditing,
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 50,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: 'Phone Number',
                  fieldId: 'phone',
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _validatePhone,
                ),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: 'Date of Birth',
                  fieldId: 'dob',
                  controller: _dobController,
                  icon: Icons.cake_outlined,
                  enabled: _isEditing,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9/]'))],
                  validator: _validateDob,
                ),
                const SizedBox(height: 32),
                
                // Address Section
                _buildSectionTitle('Address'),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: 'Address',
                  fieldId: 'address',
                  controller: _addressController,
                  icon: Icons.location_on_outlined,
                  enabled: _isEditing,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 200,
                ),
                const SizedBox(height: 32),
                
                // Document Section
                _buildSectionTitle('Documents'),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: 'ID Number (CCCD)',
                  fieldId: 'idNumber',
                  controller: _idController,
                  icon: Icons.badge_outlined,
                  enabled: _isEditing,
                  maxLength: 12,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _validateIdNumber,
                ),
                const SizedBox(height: 24),
                
                // Account Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4C40F7), Color(0xFF6C5CE7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account Status',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_user,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white30),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildAccountStat('Member Since', '2023'),
                          _buildAccountStat('Credit Score', '620'),
                          _buildAccountStat('Active Loans', '1'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1F3F),
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String fieldId,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      key: _fieldKey(fieldId),
      controller: controller,
      focusNode: _fieldFocus(fieldId),
      enabled: enabled,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: enabled ? Colors.black : Colors.grey.shade700,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: enabled ? const Color(0xFF4C40F7) : Colors.grey.shade500,
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF4C40F7),
            width: 2,
          ),
        ),
        counterText: '',
      ),
      validator: (value) => _validateIfTouched(
        fieldId,
        validator ?? (val) => val == null || val.isEmpty ? 'This field is required' : null,
        value,
      ),
    );
  }

  Widget _buildAccountStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (final node in _fieldFocusNodes.values) {
      node.dispose();
    }
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _idController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}
