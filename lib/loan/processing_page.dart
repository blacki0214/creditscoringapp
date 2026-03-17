import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'loan_offer_page.dart';
import '../utils/app_localization.dart';

/// Processing screen: triggers submission and routes to offer or shows error.
class ProcessingPage extends StatefulWidget {
  const ProcessingPage({super.key});

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processApplication();
    });
  }

  Future<void> _processApplication() async {
    final vm = context.read<LoanViewModel>();
    final success = await vm.submitApplication();
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoanOfferPage()),
      );
    } else {
      _showError(vm.errorMessage ?? context.t('Unknown error occurred', 'Đã xảy ra lỗi không xác định'));
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(context.t('Error', 'Lỗi')),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to form
            },
            child: Text(context.t('Go Back', 'Quay lại')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          context.t('Processing', 'Đang xử lý'),
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  key: ValueKey('loading_indicator'),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C40F7)),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                context.t('Analyzing your profile...', 'Đang phân tích hồ sơ của bạn...'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.t(
                  'Please wait while we calculate your credit score and prepare your loan offer.',
                  'Vui lòng chờ trong khi chúng tôi tính điểm tín dụng và chuẩn bị đề nghị khoản vay của bạn.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
