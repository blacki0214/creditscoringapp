import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'step1_verify_identity.dart';

class LoanApplicationPage extends StatelessWidget {
  const LoanApplicationPage({super.key});

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
          'Apply for Loan',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Consumer<LoanViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start Your Loan Application',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F3F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Complete the following steps to apply for your loan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildStepCard(
                          context,
                          icon: Icons.verified_user_outlined,
                          title: 'Step 1: Verify Identity',
                          description: 'Confirm your identity with ID and selfie',
                          isCompleted: viewModel.step1Completed,
                        ),
                        const SizedBox(height: 16),
                        _buildStepCard(
                          context,
                          icon: Icons.person_outline,
                          title: 'Step 2: Personal Information',
                          description: 'Provide your personal details',
                          isCompleted: viewModel.step2Completed,
                        ),
                        const SizedBox(height: 16),
                        _buildStepCard(
                          context,
                          icon: Icons.analytics_outlined,
                          title: 'Step 3: Processing',
                          description: 'We\'ll process your application',
                          isCompleted: viewModel.step2Completed && viewModel.step3Completed, // Logic can be improved
                        ),
                        const SizedBox(height: 16),
                        _buildStepCard(
                          context,
                          icon: Icons.check_circle_outline,
                          title: 'Step 4: Loan Offer',
                          description: 'Review your loan offer',
                          isCompleted: false,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logic to decide which page to open based on progress?
                        // For now keep it simple: Start/Continue goes to Step 1 or Step 2
                        if (!viewModel.step1Completed) {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Step1VerifyIdentityPage(),
                            ),
                          );
                        } else if (!viewModel.step2Completed) {
                           // TODO: Navigate to Step 2
                           // Since Step 1 usually leads to Step 2 via its own flow, 
                           // we might just want to restart at Step 1 or verify where user left off.
                           // For this refactor, let's just go to Step 1 which has logic to proceed.
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Step1VerifyIdentityPage(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C40F7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        viewModel.step1Completed ? 'Continue Application' : 'Start Application',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isCompleted 
                ? const Color(0xFF4CAF50).withOpacity(0.1)
                : const Color(0xFF4C40F7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isCompleted ? const Color(0xFF4CAF50) : const Color(0xFF4C40F7),
              size: 28,
            ),
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
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1F3F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
              size: 28,
            ),
        ],
      ),
    );
  }
}
