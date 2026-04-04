import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/app_localization.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = false;
  bool _loginNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.t('Security', 'Bảo mật'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Password Section
          _buildSectionTitle(
            context.t('Password & Authentication', 'Mật khẩu & Xác thực'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.lock_outline,
            title: context.t('Change Password', 'Đổi mật khẩu'),
            subtitle: context.t(
              'Update your account password',
              'Cập nhật mật khẩu tài khoản',
            ),
            onTap: () {
              _showChangePasswordDialog();
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchCard(
            icon: Icons.fingerprint,
            title: context.t('Biometric Login', 'Đăng nhập sinh trắc học'),
            subtitle: context.t(
              'Use fingerprint or face recognition',
              'Dùng vân tay hoặc nhận diện khuôn mặt',
            ),
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() {
                _biometricEnabled = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchCard(
            icon: Icons.security,
            title: context.t('Two-Factor Authentication', 'Xác thực hai lớp'),
            subtitle: context.t(
              'Add an extra layer of security',
              'Thêm một lớp bảo mật bổ sung',
            ),
            value: _twoFactorEnabled,
            onChanged: (value) {
              setState(() {
                _twoFactorEnabled = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Account Security
          _buildSectionTitle(
            context.t('Account Security', 'Bảo mật tài khoản'),
          ),
          const SizedBox(height: 12),
          _buildSwitchCard(
            icon: Icons.notifications_active_outlined,
            title: context.t('Login Notifications', 'Thông báo đăng nhập'),
            subtitle: context.t(
              'Get notified of new login activity',
              'Nhận thông báo khi có đăng nhập mới',
            ),
            value: _loginNotifications,
            onChanged: (value) {
              setState(() {
                _loginNotifications = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.devices,
            title: context.t('Active Sessions', 'Phiên đăng nhập hoạt động'),
            subtitle: context.t(
              'Manage your logged-in devices',
              'Quản lý thiết bị đang đăng nhập',
            ),
            onTap: () {
              _showActiveSessionsDialog();
            },
          ),

          const SizedBox(height: 24),

          // Data & Privacy
          _buildSectionTitle(
            context.t('Data & Privacy', 'Dữ liệu & Quyền riêng tư'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.download_outlined,
            title: context.t('Download My Data', 'Tải dữ liệu của tôi'),
            subtitle: context.t(
              'Request a copy of your data',
              'Yêu cầu bản sao dữ liệu của bạn',
            ),
            onTap: () {
              _showDownloadDataDialog();
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.delete_outline,
            title: context.t('Delete Account', 'Xóa tài khoản'),
            subtitle: context.t(
              'Permanently delete your account',
              'Xóa vĩnh viễn tài khoản của bạn',
            ),
            onTap: () {
              _showDeleteAccountDialog();
            },
            isDestructive: true,
          ),

          const SizedBox(height: 24),

          // Info Card
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252B4C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF4D4AF9).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF4D4AF9), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF4D4AF9),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252B4C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDestructive
                ? const Color(0xFFFF5252).withOpacity(0.1)
                : const Color(0xFF4D4AF9).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive
                ? const Color(0xFFFF5252)
                : const Color(0xFF4D4AF9),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? const Color(0xFFFF5252) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white30,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4D4AF9).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4D4AF9).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF4D4AF9), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.t(
                'We recommend enabling two-factor authentication and biometric login for maximum security.',
                'Chúng tôi khuyến nghị bật xác thực hai lớp và đăng nhập sinh trắc học để bảo mật tối đa.',
              ),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF252B4C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              context.t('Change Password', 'Đổi mật khẩu'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  enabled: !isLoading,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: context.t(
                      'Current Password',
                      'Mật khẩu hiện tại',
                    ),
                    labelStyle: const TextStyle(color: Colors.white60),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF4D4AF9)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  enabled: !isLoading,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: context.t('New Password', 'Mật khẩu mới'),
                    labelStyle: const TextStyle(color: Colors.white60),
                    helperText: context.t(
                      'Min 8 chars, uppercase, lowercase, number, special char',
                      'Tối thiểu 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt',
                    ),
                    helperStyle: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                    helperMaxLines: 2,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF4D4AF9)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  enabled: !isLoading,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: context.t(
                      'Confirm Password',
                      'Xác nhận mật khẩu',
                    ),
                    labelStyle: const TextStyle(color: Colors.white60),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF4D4AF9)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4D4AF9),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: Text(
                  context.t('Cancel', 'Hủy'),
                  style: TextStyle(
                    color: isLoading ? Colors.white30 : Colors.white60,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        // Validate inputs
                        if (currentPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.t(
                                  'Please enter your current password',
                                  'Vui lòng nhập mật khẩu hiện tại',
                                ),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (newPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.t(
                                  'Please enter a new password',
                                  'Vui lòng nhập mật khẩu mới',
                                ),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (newPasswordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.t(
                                  'Passwords do not match',
                                  'Mật khẩu xác nhận không khớp',
                                ),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Show loading
                        setState(() {
                          isLoading = true;
                        });

                        // Call AuthViewModel to change password
                        final authVM = context.read<AuthViewModel>();
                        final result = await authVM.changePassword(
                          currentPassword: currentPasswordController.text,
                          newPassword: newPasswordController.text,
                        );

                        // Hide loading
                        setState(() {
                          isLoading = false;
                        });

                        // Close dialog
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }

                        // Show result
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message']),
                              backgroundColor: result['success']
                                  ? const Color(0xFF4CAF50)
                                  : Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLoading
                      ? const Color(0xFF4D4AF9).withOpacity(0.5)
                      : const Color(0xFF4D4AF9),
                ),
                child: Text(context.t('Update', 'Cập nhật')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showActiveSessionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252B4C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.t('Active Sessions', 'Phiên đăng nhập hoạt động'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSessionItem(
              context.t('Current Device', 'Thiết bị hiện tại'),
              context.t('Windows - Chrome', 'Windows - Chrome'),
              true,
            ),
            const SizedBox(height: 8),
            _buildSessionItem(
              context.t('Mobile Device', 'Thiết bị di động'),
              context.t('Android - App', 'Android - Ứng dụng'),
              false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.t('Close', 'Đóng'),
              style: const TextStyle(color: Colors.white60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(String device, String details, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isCurrent ? Icons.smartphone : Icons.phone_android,
            color: const Color(0xFF4D4AF9),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  details,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Chip(
              label: Text(
                context.t('Current', 'Hiện tại'),
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: Color(0xFF4CAF50),
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
        ],
      ),
    );
  }

  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252B4C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.t('Download My Data', 'Tải dữ liệu của tôi'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          context.t(
            'We will send a copy of your data to your registered email address within 24 hours.',
            'Chúng tôi sẽ gửi bản sao dữ liệu tới email đã đăng ký của bạn trong vòng 24 giờ.',
          ),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.t('Cancel', 'Hủy'),
              style: const TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.t(
                      'Data download request submitted',
                      'Đã gửi yêu cầu tải dữ liệu',
                    ),
                  ),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4D4AF9),
            ),
            child: Text(context.t('Request', 'Yêu cầu')),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252B4C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.t('Delete Account', 'Xóa tài khoản'),
          style: const TextStyle(
            color: Color(0xFFFF5252),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          context.t(
            'This action cannot be undone. All your data will be permanently deleted.',
            'Hành động này không thể hoàn tác. Toàn bộ dữ liệu của bạn sẽ bị xóa vĩnh viễn.',
          ),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.t('Cancel', 'Hủy'),
              style: const TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.t(
                      'Account deletion requires email verification',
                      'Xóa tài khoản yêu cầu xác minh email',
                    ),
                  ),
                  backgroundColor: Color(0xFFFF5252),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: Text(context.t('Delete', 'Xóa')),
          ),
        ],
      ),
    );
  }
}
