import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/login_page.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/language_viewmodel.dart';
import 'profile_page.dart';
import 'support_page.dart';
import 'feedback_page.dart';
import 'notifications_page.dart';
import 'security_page.dart';
import 'privacy_policy_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    // Load user profile when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SettingsViewModel>().loadUserProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();
    final languageViewModel = context.watch<LanguageViewModel>();
    final isVietnamese = languageViewModel.isVietnamese;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          isVietnamese ? 'Cài đặt' : 'Settings',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Profile header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4D4AF9), Color(0xFF6D7CFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: settingsViewModel.avatarUrl != null
                                ? CircleAvatar(
                                    radius: 32,
                                    backgroundImage: NetworkImage(
                                      settingsViewModel.avatarUrl!,
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 32,
                                    backgroundColor: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Color(0xFF4D4AF9),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  settingsViewModel.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  settingsViewModel.email,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Settings options
                    _buildSettingItem(
                      context,
                      icon: Icons.language,
                      title: isVietnamese ? 'Ngôn ngữ' : 'Language',
                      subtitle: isVietnamese
                          ? 'Chuyển đổi tiếng Việt/English'
                          : 'Switch between Vietnamese/English',
                      trailing: _buildLanguageToggle(languageViewModel),
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.person_outline,
                      title: isVietnamese ? 'Hồ sơ' : 'Profile',
                      subtitle: isVietnamese
                          ? 'Quản lý thông tin cá nhân'
                          : 'Manage your personal information',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.support_agent_outlined,
                      title: isVietnamese ? 'Hỗ trợ' : 'Support',
                      subtitle: isVietnamese
                          ? 'Nhận trợ giúp và liên hệ'
                          : 'Get help and contact us',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SupportPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.feedback_outlined,
                      title: isVietnamese ? 'Phản hồi' : 'Feedback',
                      subtitle: isVietnamese
                          ? 'Chia sẻ ý kiến của bạn'
                          : 'Share your thoughts with us',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FeedbackPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.notifications_outlined,
                      title: isVietnamese ? 'Thông báo' : 'Notifications',
                      subtitle: isVietnamese
                          ? 'Quản lý tùy chọn thông báo'
                          : 'Manage notification preferences',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.security,
                      title: isVietnamese ? 'Bảo mật' : 'Security',
                      subtitle: isVietnamese
                          ? 'Mật khẩu, sinh trắc học, 2FA'
                          : 'Password, biometric, 2FA',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SecurityPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: isVietnamese
                        ? 'Chính sách bảo mật'
                        : 'Privacy Policy',
                      subtitle: isVietnamese
                        ? 'Cách chúng tôi xử lý dữ liệu'
                        : 'How we handle your data',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.description_outlined,
                      title: isVietnamese
                        ? 'Điều khoản & Điều kiện'
                        : 'Terms & Conditions',
                      subtitle: isVietnamese
                        ? 'Đọc điều khoản và điều kiện'
                        : 'Read our terms and conditions',
                      onTap: () {
                        // Navigate to terms
                      },
                    ),
                    const SizedBox(height: 24),
                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          _showLogoutDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.red.shade200),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isVietnamese ? 'Đăng xuất' : 'Logout',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'VietCredit Score',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '© 2025 VietCredit. All rights reserved.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4D4AF9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF4D4AF9), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F3F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(LanguageViewModel languageViewModel) {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(10),
      constraints: const BoxConstraints(minHeight: 32, minWidth: 50),
      isSelected: [
        !languageViewModel.isVietnamese,
        languageViewModel.isVietnamese,
      ],
      onPressed: (index) {
        if (index == 0) {
          languageViewModel.setLanguage('en');
          return;
        }
        languageViewModel.setLanguage('vi');
      },
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('ENG'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('VN'),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isVietnamese = context.read<LanguageViewModel>().isVietnamese;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isVietnamese ? 'Đăng xuất' : 'Logout',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1F3F),
            ),
          ),
          content: Text(
            isVietnamese
                ? 'Bạn có chắc chắn muốn đăng xuất?'
                : 'Are you sure you want to logout?',
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                isVietnamese ? 'Hủy' : 'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform logout via AuthViewModel
                context.read<AuthViewModel>().reset();

                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isVietnamese ? 'Đăng xuất' : 'Logout',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
