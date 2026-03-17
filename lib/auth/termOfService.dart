import 'package:flutter/material.dart';
import '../utils/app_localization.dart';

class TermOfServicePage extends StatelessWidget {
  const TermOfServicePage({super.key});

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
        title: Text(
          context.t('Terms Of Agreement', 'Điều khoản thỏa thuận'),
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t('Terms Of Agreement', 'Điều khoản thỏa thuận'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ipsum lorum\n...\n...',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF3E4566),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
