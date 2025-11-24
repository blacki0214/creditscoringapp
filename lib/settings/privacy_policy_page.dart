import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          'Privacy Policy',
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
          // Last Updated
          Container(
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
                const Icon(Icons.update, color: Color(0xFF4C40F7), size: 20),
                const SizedBox(width: 12),
                Text(
                  'Last updated: November 24, 2025',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Introduction
          _buildSection(
            'Introduction',
            'VietCredit Score ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.',
          ),

          // Information We Collect
          _buildSection(
            'Information We Collect',
            'We collect information that you provide directly to us, including:\n\n'
            '• Personal identification information (name, email, phone number)\n'
            '• Financial information (credit history, loan applications)\n'
            '• Government-issued ID documents\n'
            '• Device information and usage data\n'
            '• Location data (with your permission)',
          ),

          // How We Use Your Information
          _buildSection(
            'How We Use Your Information',
            'We use the information we collect to:\n\n'
            '• Provide and maintain our services\n'
            '• Process your credit score assessments\n'
            '• Verify your identity\n'
            '• Communicate with you about our services\n'
            '• Improve our application and user experience\n'
            '• Comply with legal obligations',
          ),

          // Information Sharing
          _buildSection(
            'Information Sharing',
            'We do not sell your personal information. We may share your information with:\n\n'
            '• Credit bureaus and financial institutions\n'
            '• Service providers who assist our operations\n'
            '• Law enforcement when required by law\n'
            '• Third parties with your explicit consent',
          ),

          // Data Security
          _buildSection(
            'Data Security',
            'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.',
          ),

          // Your Rights
          _buildSection(
            'Your Rights',
            'You have the right to:\n\n'
            '• Access your personal information\n'
            '• Correct inaccurate data\n'
            '• Request deletion of your data\n'
            '• Opt-out of certain data processing\n'
            '• Withdraw consent at any time\n'
            '• Download your data',
          ),

          // Data Retention
          _buildSection(
            'Data Retention',
            'We retain your personal information for as long as necessary to provide our services and comply with legal obligations. You may request deletion of your account and data at any time through the Security settings.',
          ),

          // Children\'s Privacy
          _buildSection(
            'Children\'s Privacy',
            'Our services are not intended for individuals under the age of 18. We do not knowingly collect personal information from children under 18.',
          ),

          // Changes to Privacy Policy
          _buildSection(
            'Changes to This Policy',
            'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
          ),

          // Contact Us
          _buildSection(
            'Contact Us',
            'If you have questions about this Privacy Policy, please contact us:\n\n'
            '• Email: privacy@vietcreditscore.com\n'
            '• Phone: 1800-VIET-CREDIT\n'
            '• Address: 123 Privacy Street, Hanoi, Vietnam',
          ),

          const SizedBox(height: 40),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy policy downloaded'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_outlined, size: 20),
                  label: const Text('Download PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4C40F7),
                    side: const BorderSide(color: Color(0xFF4C40F7)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C40F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
