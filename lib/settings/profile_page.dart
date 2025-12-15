import 'package:flutter/material.dart';
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
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Save changes
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
                    CircleAvatar(
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
                  controller: _nameController,
                  icon: Icons.person_outline,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: 'Email',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  enabled: _isEditing,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: 'Date of Birth',
                  controller: _dobController,
                  icon: Icons.cake_outlined,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 32),
                
                // Address Section
                _buildSectionTitle('Address'),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: 'Address',
                  controller: _addressController,
                  icon: Icons.location_on_outlined,
                  enabled: _isEditing,
                  maxLines: 2,
                ),
                const SizedBox(height: 32),
                
                // Document Section
                _buildSectionTitle('Documents'),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: 'ID Number (CCCD)',
                  controller: _idController,
                  icon: Icons.badge_outlined,
                  enabled: _isEditing,
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
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _idController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}
