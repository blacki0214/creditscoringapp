import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'loan_offer_page.dart';

class ProcessingPage extends StatefulWidget {
  final SimpleLoanRequest? request;

  const ProcessingPage({super.key, this.request});

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _processApplication();
  }

  Future<void> _processApplication() async {
    // Artificial delay for better UX (optional)
    await Future.delayed(const Duration(seconds: 2));

    if (widget.request == null) {
       _showError('No application data provided.');
       return;
    }

    try {
      final response = await _apiService.applyForLoan(widget.request!);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoanOfferPage(offer: response),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to input page
            },
            child: const Text('Go Back'),
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
        title: const Text('Processing', style: TextStyle(color: Colors.black)),
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
              const Text(
                'Analyzing your profile...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please wait while we calculate your credit score and prepare your loan offer.',
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
