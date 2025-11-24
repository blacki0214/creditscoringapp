import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _loanUpdates = true;
  bool _creditScoreUpdates = true;
  bool _paymentReminders = true;
  bool _promotionalOffers = false;

  String _selectedSnoozeOption = 'None';

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
          'Notifications',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Notification Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage how you receive notifications',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Master notification toggle
              _buildSwitchCard(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                subtitle: _notificationsEnabled 
                    ? 'Notifications are enabled' 
                    : 'Notifications are disabled',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                iconColor: const Color(0xFF4C40F7),
              ),
              const SizedBox(height: 16),

              // Sound toggle
              _buildSwitchCard(
                icon: Icons.volume_up,
                title: 'Notification Sound',
                subtitle: _soundEnabled 
                    ? 'Sound is on' 
                    : 'Sound is off',
                value: _soundEnabled,
                onChanged: _notificationsEnabled ? (value) {
                  setState(() {
                    _soundEnabled = value;
                  });
                } : null,
                iconColor: const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 16),

              // Vibration toggle
              _buildSwitchCard(
                icon: Icons.vibration,
                title: 'Vibration',
                subtitle: _vibrationEnabled 
                    ? 'Vibration is on' 
                    : 'Vibration is off',
                value: _vibrationEnabled,
                onChanged: _notificationsEnabled ? (value) {
                  setState(() {
                    _vibrationEnabled = value;
                  });
                } : null,
                iconColor: const Color(0xFFFFA726),
              ),
              const SizedBox(height: 32),

              // Snooze section
              const Text(
                'Snooze Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Temporarily turn off notifications',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
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
                    _buildSnoozeOption('None', 'Notifications are active'),
                    const Divider(height: 24),
                    _buildSnoozeOption('1 Hour', 'Mute for 1 hour'),
                    const Divider(height: 24),
                    _buildSnoozeOption('2 Hours', 'Mute for 2 hours'),
                    const Divider(height: 24),
                    _buildSnoozeOption('4 Hours', 'Mute for 4 hours'),
                    const Divider(height: 24),
                    _buildSnoozeOption('8 Hours', 'Mute for 8 hours'),
                    const Divider(height: 24),
                    _buildSnoozeOption('1 Day', 'Mute for 1 day'),
                    const Divider(height: 24),
                    _buildSnoozeOption('2 Days', 'Mute for 2 days'),
                    const Divider(height: 24),
                    _buildSnoozeOption('1 Week', 'Mute for 1 week'),
                    const Divider(height: 24),
                    _buildSnoozeOption('Forever', 'Disable all notifications'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Notification channels
              const Text(
                'Notification Channels',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(height: 16),

              _buildSwitchCard(
                icon: Icons.email_outlined,
                title: 'Email Notifications',
                subtitle: 'Receive notifications via email',
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
                iconColor: const Color(0xFF2196F3),
              ),
              const SizedBox(height: 16),

              _buildSwitchCard(
                icon: Icons.sms_outlined,
                title: 'SMS Notifications',
                subtitle: 'Receive notifications via SMS',
                value: _smsNotifications,
                onChanged: (value) {
                  setState(() {
                    _smsNotifications = value;
                  });
                },
                iconColor: const Color(0xFF9C27B0),
              ),
              const SizedBox(height: 32),

              // Notification types
              const Text(
                'Notification Types',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(height: 16),

              _buildSwitchCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Loan Updates',
                subtitle: 'Application status and loan approvals',
                value: _loanUpdates,
                onChanged: _notificationsEnabled ? (value) {
                  setState(() {
                    _loanUpdates = value;
                  });
                } : null,
                iconColor: const Color(0xFF4C40F7),
              ),
              const SizedBox(height: 16),

              _buildSwitchCard(
                icon: Icons.trending_up,
                title: 'Credit Score Updates',
                subtitle: 'Changes in your credit score',
                value: _creditScoreUpdates,
                onChanged: _notificationsEnabled ? (value) {
                  setState(() {
                    _creditScoreUpdates = value;
                  });
                } : null,
                iconColor: const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 16),

              _buildSwitchCard(
                icon: Icons.payment,
                title: 'Payment Reminders',
                subtitle: 'Upcoming payment due dates',
                value: _paymentReminders,
                onChanged: _notificationsEnabled ? (value) {
                  setState(() {
                    _paymentReminders = value;
                  });
                } : null,
                iconColor: const Color(0xFFFFA726),
              ),
              const SizedBox(height: 16),

              _buildSwitchCard(
                icon: Icons.local_offer_outlined,
                title: 'Promotional Offers',
                subtitle: 'Special offers and promotions',
                value: _promotionalOffers,
                onChanged: _notificationsEnabled ? (value) {
                  setState(() {
                    _promotionalOffers = value;
                  });
                } : null,
                iconColor: const Color(0xFFFF5252),
              ),
              const SizedBox(height: 32),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4C40F7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4C40F7).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF4C40F7),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Some notifications may still be delivered for important account activities and security alerts.',
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
                    color: isEnabled ? const Color(0xFF1A1F3F) : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4C40F7),
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
        
        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value == 'None' 
                  ? 'Notifications are active' 
                  : 'Notifications snoozed for $value',
            ),
            backgroundColor: const Color(0xFF4C40F7),
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
                color: isSelected ? const Color(0xFF4C40F7) : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4C40F7),
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
                    color: isSelected ? const Color(0xFF1A1F3F) : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle,
              color: Color(0xFF4C40F7),
              size: 20,
            ),
        ],
      ),
    );
  }
}
