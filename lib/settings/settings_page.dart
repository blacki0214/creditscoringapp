import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/login_page.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/language_viewmodel.dart';
import 'profile_page.dart';
import 'support_page.dart';
import 'feedback_page.dart';
import 'notifications_page.dart';
import 'security_page.dart';
import 'privacy_policy_page.dart';
import 'support_staff_page.dart';
import '../services/firebase_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isSupportStaff = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadSupportRole();
      }
    });
  }

  Future<void> _loadSupportRole() async {
    try {
      final isSupport = await FirebaseService().isCurrentUserSupportStaff();
      if (!mounted) return;
      setState(() {
        _isSupportStaff = isSupport;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSupportStaff = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageViewModel = context.watch<LanguageViewModel>();
    final isVietnamese = languageViewModel.isVietnamese;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 120 + bottomInset),
                child: Column(
                  children: [
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
                    if (_isSupportStaff) ...[
                      const SizedBox(height: 12),
                      _buildSettingItem(
                        context,
                        icon: Icons.headset_mic_outlined,
                        title: isVietnamese
                            ? 'Bảng điều khiển hỗ trợ'
                            : 'Support Console',
                        subtitle: isVietnamese
                            ? 'Trả lời chat và xử lý phản hồi'
                            : 'Reply to support chats and resolve feedback',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SupportStaffPage(),
                            ),
                          );
                        },
                      ),
                    ],
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Text(
                            'SwinCredit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version 0.0.10',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const PrivacyPolicyPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  isVietnamese
                                      ? 'Chính sách bảo mật'
                                      : 'Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: const Color(0xFF4D4AF9),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Text(
                                ' | ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Navigate to terms
                                },
                                child: Text(
                                  isVietnamese
                                      ? 'Điều khoản & Điều kiện'
                                      : 'Terms & Conditions',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: const Color(0xFF4D4AF9),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '© 2025 SwinCredit. All rights reserved.',
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LanguageChip(
          label: 'ENG',
          selected: !languageViewModel.isVietnamese,
          onTap: () => languageViewModel.setLanguage('en'),
        ),
        const SizedBox(width: 6),
        _LanguageChip(
          label: 'VN',
          selected: languageViewModel.isVietnamese,
          onTap: () => languageViewModel.setLanguage('vi'),
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

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 32, minWidth: 50),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8EBFF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFF4D4AF9)
                : const Color(0xFFDDE3FF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected
                ? const Color(0xFF2D2AA8)
                : const Color(0xFF1A1F3F),
          ),
        ),
      ),
    );
  }
}
