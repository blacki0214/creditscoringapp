import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFF1A1F3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Security',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Password Section
          _buildSectionTitle('Password & Authentication'),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () {
              _showChangePasswordDialog();
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchCard(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Use fingerprint or face recognition',
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
            title: 'Two-Factor Authentication',
            subtitle: 'Add an extra layer of security',
            value: _twoFactorEnabled,
            onChanged: (value) {
              setState(() {
                _twoFactorEnabled = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Account Security
          _buildSectionTitle('Account Security'),
          const SizedBox(height: 12),
          _buildSwitchCard(
            icon: Icons.notifications_active_outlined,
            title: 'Login Notifications',
            subtitle: 'Get notified of new login activity',
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
            title: 'Active Sessions',
            subtitle: 'Manage your logged-in devices',
            onTap: () {
              _showActiveSessionsDialog();
            },
          ),

          const SizedBox(height: 24),

          // Data & Privacy
          _buildSectionTitle('Data & Privacy'),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.download_outlined,
            title: 'Download My Data',
            subtitle: 'Request a copy of your data',
            onTap: () {
              _showDownloadDataDialog();
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.delete_outline,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
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
            color: const Color(0xFF4C40F7).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF4C40F7), size: 24),
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
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4C40F7),
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
                : const Color(0xFF4C40F7).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive ? const Color(0xFFFF5252) : const Color(0xFF4C40F7),
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
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
          ),
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
        color: const Color(0xFF4C40F7).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4C40F7).withOpacity(0.3),
          width: 1,
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
              'We recommend enabling two-factor authentication and biometric login for maximum security.',
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252B4C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: const TextStyle(color: Colors.white60),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white30),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF4C40F7)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: const TextStyle(color: Colors.white60),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white30),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF4C40F7)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: const TextStyle(color: Colors.white60),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white30),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF4C40F7)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password updated successfully'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C40F7),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252B4C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Active Sessions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSessionItem('Current Device', 'Windows - Chrome', true),
            const SizedBox(height: 8),
            _buildSessionItem('Mobile Device', 'Android - App', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white60)),
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
            color: const Color(0xFF4C40F7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                Text(
                  details,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isCurrent)
            const Chip(
              label: Text('Current', style: TextStyle(fontSize: 10)),
              backgroundColor: Color(0xFF4CAF50),
              labelPadding: EdgeInsets.symmetric(horizontal: 8),
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
        title: const Text(
          'Download My Data',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'We will send a copy of your data to your registered email address within 24 hours.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data download request submitted'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C40F7),
            ),
            child: const Text('Request'),
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
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion requires email verification'),
                  backgroundColor: Color(0xFFFF5252),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
