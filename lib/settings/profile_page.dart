import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../utils/app_localization.dart';

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
    
    // Load user profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<SettingsViewModel>();
      vm.loadUserProfile();
      
      // Initialize controllers with loaded data
      _nameController.text = vm.name;
      _emailController.text = vm.email;
      _phoneController.text = vm.phone;
      _addressController.text = vm.address;
      _idController.text = vm.idNumber;
      _dobController.text = vm.dob;
    });
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
        title: Text(
          context.t('Profile', 'Hồ sơ'),
          style: const TextStyle(color: Colors.black),
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
                      SnackBar(
                        content: Text(
                          context.t('Profile updated successfully', 'Cập nhật hồ sơ thành công'),
                        ),
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
              _isEditing ? context.t('Save', 'Lưu') : context.t('Edit', 'Sửa'),
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
                _buildSectionTitle(context.t('Personal Information', 'Thông tin cá nhân')),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: context.t('Full Name', 'Họ và tên'),
                  controller: _nameController,
                  icon: Icons.person_outline,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: context.t('Email', 'Email'),
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  enabled: _isEditing,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: context.t('Phone Number', 'Số điện thoại'),
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: context.t('Date of Birth', 'Ngày sinh'),
                  controller: _dobController,
                  icon: Icons.cake_outlined,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 32),
                
                // Address Section
                _buildSectionTitle(context.t('Address', 'Địa chỉ')),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: context.t('Address', 'Địa chỉ'),
                  controller: _addressController,
                  icon: Icons.location_on_outlined,
                  enabled: _isEditing,
                  maxLines: 2,
                ),
                const SizedBox(height: 32),
                
                // Document Section
                _buildSectionTitle(context.t('Documents', 'Giấy tờ')),
                const SizedBox(height: 16),
                
                _buildInfoField(
                  label: context.t('ID Number (CCCD)', 'Số CCCD'),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.t('Account Status', 'Trạng thái tài khoản'),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.t('Verified', 'Đã xác thực'),
                                style: const TextStyle(
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
                          _buildAccountStat(
                            context.t('Member Since', 'Thành viên từ'),
                            settingsViewModel.memberSince?.year.toString() ?? 'N/A',
                          ),
                          _buildAccountStat(
                            context.t('Credit Score', 'Điểm tín dụng'),
                            settingsViewModel.latestCreditScore?.toString() ?? 'N/A',
                          ),
                          _buildAccountStat(
                            context.t('Applications', 'Hồ sơ vay'),
                            settingsViewModel.totalApplications.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Credit Score Section
                _buildSectionTitle(context.t('Credit Status', 'Tình trạng tín dụng')),
                const SizedBox(height: 16),
                _buildCreditScoreCard(settingsViewModel),
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
    // Show placeholder text when field is empty and not editing
    final bool isEmpty = controller.text.isEmpty;
    
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        color: enabled ? Colors.black : (isEmpty ? Colors.grey.shade500 : Colors.grey.shade700),
        fontSize: 16,
        fontStyle: isEmpty && !enabled ? FontStyle.italic : FontStyle.normal,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: !enabled && isEmpty ? context.t('Not available', 'Không có') : null,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontStyle: FontStyle.italic,
        ),
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
      validator: enabled ? (value) {
        if (value == null || value.isEmpty) {
          return context.t('This field is required', 'Trường này là bắt buộc');
        }
        return null;
      } : null,
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

  Widget _buildCreditScoreCard(SettingsViewModel vm) {
    if (vm.latestCreditScore == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              context.t('No Credit Score Yet', 'Chưa có điểm tín dụng'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.t(
                'Complete a loan application to get your credit score',
                'Hoàn tất hồ sơ vay để nhận điểm tín dụng của bạn',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // Determine score color and label
    Color scoreColor;
    String scoreLabel;
    if (vm.latestCreditScore! >= 700) {
      scoreColor = const Color(0xFF4CAF50); // Green
      scoreLabel = context.t('Excellent', 'Xuất sắc');
    } else if (vm.latestCreditScore! >= 600) {
      scoreColor = const Color(0xFFFFA726); // Orange
      scoreLabel = context.t('Good', 'Tốt');
    } else {
      scoreColor = const Color(0xFFEF5350); // Red
      scoreLabel = context.t('Fair', 'Trung bình');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scoreColor.withOpacity(0.8), scoreColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('Credit Score', 'Điểm tín dụng'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  vm.latestCreditScore.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scoreLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (vm.riskLevel != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    context.t('Risk Level: ${vm.riskLevel}', 'Mức rủi ro: ${vm.riskLevel}'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
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
