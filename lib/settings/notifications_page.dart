import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../utils/app_localization.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _selectedSnoozeOption = 'None';

  @override
  void initState() {
    super.initState();
    // Load notification settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsViewModel>().loadNotificationSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<SettingsViewModel>();
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
          context.t('Notifications', 'Thông báo'),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                context.t('Notification Settings', 'Cài đặt thông báo'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.t(
                  'Manage how you receive notifications',
                  'Quản lý cách bạn nhận thông báo',
                ),
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              // Master notification toggle
              _buildSwitchCard(
                icon: Icons.notifications_active,
                title: context.t('Push Notifications', 'Thông báo đẩy'),
                subtitle: settingsVM.pushEnabled
                    ? context.t(
                        'Notifications are enabled',
                        'Thông báo đang bật',
                      )
                    : context.t(
                        'Notifications are disabled',
                        'Thông báo đang tắt',
                      ),
                value: settingsVM.pushEnabled,
                onChanged: (value) {
                  settingsVM.updateNotificationSetting('pushEnabled', value);
                },
                iconColor: const Color(0xFF4D4AF9),
              ),
              const SizedBox(height: 16),

              // Sound toggle
              _buildSwitchCard(
                icon: Icons.volume_up,
                title: context.t('Notification Sound', 'Âm thanh thông báo'),
                subtitle: settingsVM.soundEnabled
                    ? context.t('Sound is on', 'Âm thanh đang bật')
                    : context.t('Sound is off', 'Âm thanh đang tắt'),
                value: settingsVM.soundEnabled,
                onChanged: settingsVM.pushEnabled
                    ? (value) {
                        settingsVM.updateNotificationSetting(
                          'soundEnabled',
                          value,
                        );
                      }
                    : null,
                iconColor: const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 16),

              // Vibration toggle
              _buildSwitchCard(
                icon: Icons.vibration,
                title: context.t('Vibration', 'Chế độ rung'),
                subtitle: settingsVM.vibrationEnabled
                    ? context.t('Vibration is on', 'Rung đang bật')
                    : context.t('Vibration is off', 'Rung đang tắt'),
                value: settingsVM.vibrationEnabled,
                onChanged: settingsVM.pushEnabled
                    ? (value) {
                        settingsVM.updateNotificationSetting(
                          'vibrationEnabled',
                          value,
                        );
                      }
                    : null,
                iconColor: const Color(0xFFFFA726),
              ),
              const SizedBox(height: 32),

              // Snooze section
              Text(
                context.t('Snooze Notifications', 'Tạm dừng thông báo'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.t(
                  'Temporarily turn off notifications',
                  'Tạm thời tắt thông báo',
                ),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildSnoozeOption(
                      context.t('None', 'Không'),
                      context.t(
                        'Notifications are active',
                        'Thông báo đang hoạt động',
                      ),
                    ),
                    const Divider(height: 24),
                    _buildSnoozeOption(
                      context.t('1 Hour', '1 giờ'),
                      context.t('Mute for 1 hour', 'Tắt trong 1 giờ'),
                    ),
                    const Divider(height: 24),
                    _buildSnoozeOption(
                      context.t('2 Hours', '2 giờ'),
                      context.t('Mute for 2 hours', 'Tắt trong 2 giờ'),
                    ),
                    const Divider(height: 24),
                    _buildSnoozeOption(
                      context.t('4 Hours', '4 giờ'),
                      context.t('Mute for 4 hours', 'Tắt trong 4 giờ'),
                    ),
                    const Divider(height: 24),
                    _buildSnoozeOption(
                      context.t('8 Hours', '8 giờ'),
                      context.t('Mute for 8 hours', 'Tắt trong 8 giờ'),
                    ),
                    const Divider(height: 24),
                    _buildSnoozeOption(
                      context.t('1 Day', '1 ngày'),
                      context.t('Mute for 1 day', 'Tắt trong 1 ngày'),
                    ),
                    const Divider(height: 24),
                    _buildSnoozeOption(
                      context.t('2 Days', '2 ngày'),
                      context.t('Mute for 2 days', 'Tắt trong 2 ngày'),
                    ),
                    const Divider(height: 24),
                    _buildSnoozeOption(
                      context.t('1 Week', '1 tuần'),
                      context.t('Mute for 1 week', 'Tắt trong 1 tuần'),
                    ),
                    const Divider(height: 24),
                    _buildSnoozeOption(
                      context.t('Forever', 'Mãi mãi'),
                      context.t(
                        'Disable all notifications',
                        'Tắt tất cả thông báo',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Notification channels
              Text(
                context.t('Notification Channels', 'Kênh thông báo'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(height: 16),

              _buildSwitchCard(
                icon: Icons.email_outlined,
                title: context.t('Email Notifications', 'Thông báo Email'),
                subtitle: context.t(
                  'Receive notifications via email',
                  'Nhận thông báo qua email',
                ),
                value: settingsVM.emailNotifications,
                onChanged: (value) {
                  settingsVM.updateNotificationSetting(
                    'emailNotifications',
                    value,
                  );
                },
                iconColor: const Color(0xFF2196F3),
              ),
              const SizedBox(height: 16),

              _buildSwitchCard(
                icon: Icons.sms_outlined,
                title: context.t('SMS Notifications', 'Thông báo SMS'),
                subtitle: context.t(
                  'Receive notifications via SMS',
                  'Nhận thông báo qua SMS',
                ),
                value: settingsVM.smsNotifications,
                onChanged: (value) {
                  settingsVM.updateNotificationSetting(
                    'smsNotifications',
                    value,
                  );
                },
                iconColor: const Color(0xFF9C27B0),
              ),
              const SizedBox(height: 32),

              // Notification types
              Text(
                context.t('Notification Types', 'Loại thông báo'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(height: 16),

              _buildSwitchCard(
                icon: Icons.account_balance_wallet_outlined,
                title: context.t('Loan Updates', 'Cập nhật khoản vay'),
                subtitle: context.t(
                  'Application status and loan approvals',
                  'Trạng thái hồ sơ và phê duyệt khoản vay',
                ),
                value: settingsVM.loanUpdates,
                onChanged: settingsVM.pushEnabled
                    ? (value) {
                        settingsVM.updateNotificationSetting(
                          'loanUpdates',
                          value,
                        );
                      }
                    : null,
                iconColor: const Color(0xFF4D4AF9),
              ),
              const SizedBox(height: 16),

              _buildSwitchCard(
                icon: Icons.trending_up,
                title: context.t(
                  'Credit Score Updates',
                  'Cập nhật điểm tín dụng',
                ),
                subtitle: context.t(
                  'Changes in your credit score',
                  'Thay đổi điểm tín dụng của bạn',
                ),
                value: settingsVM.creditScoreUpdates,
                onChanged: settingsVM.pushEnabled
                    ? (value) {
                        settingsVM.updateNotificationSetting(
                          'creditScoreUpdates',
                          value,
                        );
                      }
                    : null,
                iconColor: const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 16),

              _buildSwitchCard(
                icon: Icons.payment,
                title: context.t('Payment Reminders', 'Nhắc nhở thanh toán'),
                subtitle: context.t(
                  'Upcoming payment due dates',
                  'Ngày đến hạn thanh toán sắp tới',
                ),
                value: settingsVM.paymentReminders,
                onChanged: settingsVM.pushEnabled
                    ? (value) {
                        settingsVM.updateNotificationSetting(
                          'paymentReminders',
                          value,
                        );
                      }
                    : null,
                iconColor: const Color(0xFFFFA726),
              ),
              const SizedBox(height: 16),

              _buildSwitchCard(
                icon: Icons.local_offer_outlined,
                title: context.t('Promotional Offers', 'Ưu đãi khuyến mãi'),
                subtitle: context.t(
                  'Special offers and promotions',
                  'Ưu đãi và khuyến mãi đặc biệt',
                ),
                value: settingsVM.promotionalOffers,
                onChanged: settingsVM.pushEnabled
                    ? (value) {
                        settingsVM.updateNotificationSetting(
                          'promotionalOffers',
                          value,
                        );
                      }
                    : null,
                iconColor: const Color(0xFFFF5252),
              ),
              const SizedBox(height: 32),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D4AF9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4D4AF9).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF4D4AF9),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.t(
                          'Some notifications may still be delivered for important account activities and security alerts.',
                          'Một số thông báo quan trọng về tài khoản và bảo mật vẫn có thể được gửi.',
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool)? onChanged,
    required Color iconColor,
  }) {
    final isEnabled = onChanged != null;

    return Container(
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
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isEnabled ? iconColor : Colors.grey.shade400,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isEnabled
                        ? const Color(0xFF1A1F3F)
                        : Colors.grey.shade500,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF4D4AF9),
          ),
        ],
      ),
    );
  }

  Widget _buildSnoozeOption(String value, String description) {
    final isSelected = _selectedSnoozeOption == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSnoozeOption = value;
        });

        // Calculate snooze time
        DateTime? snoozeUntil;
        if (value != 'None' && value != 'Không') {
          final now = DateTime.now();
          switch (value) {
            case '1 Hour':
            case '1 giờ':
              snoozeUntil = now.add(const Duration(hours: 1));
              break;
            case '2 Hours':
            case '2 giờ':
              snoozeUntil = now.add(const Duration(hours: 2));
              break;
            case '4 Hours':
            case '4 giờ':
              snoozeUntil = now.add(const Duration(hours: 4));
              break;
            case '8 Hours':
            case '8 giờ':
              snoozeUntil = now.add(const Duration(hours: 8));
              break;
            case '1 Day':
            case '1 ngày':
              snoozeUntil = now.add(const Duration(days: 1));
              break;
            case '2 Days':
            case '2 ngày':
              snoozeUntil = now.add(const Duration(days: 2));
              break;
            case '1 Week':
            case '1 tuần':
              snoozeUntil = now.add(const Duration(days: 7));
              break;
            case 'Forever':
            case 'Mãi mãi':
              snoozeUntil = DateTime(2099, 12, 31);
              break;
          }
        }

        // Update snooze in ViewModel
        context.read<SettingsViewModel>().updateSnooze(snoozeUntil);

        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (value == 'None' || value == 'Không')
                  ? context.t(
                      'Notifications are active',
                      'Thông báo đang hoạt động',
                    )
                  : context.t(
                      'Notifications snoozed for $value',
                      'Đã tạm dừng thông báo trong $value',
                    ),
            ),
            backgroundColor: const Color(0xFF4D4AF9),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF4D4AF9)
                    : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4D4AF9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF1A1F3F)
                        : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: Color(0xFF4D4AF9), size: 20),
        ],
      ),
    );
  }
}
