import 'package:flutter/material.dart';
import 'success_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B5E20);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Type your new password",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _newPass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "New password",
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _confirmPass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm password",
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: validate passwords match
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SuccessPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Change password",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
