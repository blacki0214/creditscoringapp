import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../config/app_environment.dart';
import '../services/local_storage_service.dart';
import '../utils/app_localization.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'step1_id_capture.dart';
import 'step2_personal_info.dart';
import 'step3_additional_info.dart';
import 'step4_offer_calculator.dart';
import 'step5_contractreview.dart';
import 'step6_disbursement.dart';
import 'processing_page.dart';

class LoanApplicationPage extends StatefulWidget {
  const LoanApplicationPage({super.key});

  @override
  State<LoanApplicationPage> createState() => _LoanApplicationPageState();
}

class _LoanApplicationPageState extends State<LoanApplicationPage> {
  int _step1ResetTapCount = 0;
  DateTime? _lastStep1ResetTap;

  Future<void> _handleStep1IconTapForDemo() async {
    final now = DateTime.now();
    final withinWindow =
        _lastStep1ResetTap != null &&
        now.difference(_lastStep1ResetTap!) <= const Duration(seconds: 3);

    _step1ResetTapCount = withinWindow ? _step1ResetTapCount + 1 : 1;
    _lastStep1ResetTap = now;

    if (_step1ResetTapCount < 3) return;

    _step1ResetTapCount = 0;
    await LocalStorageService.clearEkycCompletion();

    if (!mounted) return;

    context.read<LoanViewModel>().clearStep1CompletionForDemo();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Demo reset: Step 1 verification will be required again.',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  /// Routes to the appropriate step based on the application progress
  void _routeToCurrentStep(LoanViewModel viewModel) {
    final currentStep = viewModel.getCurrentStep;
    
    // Determine which page to navigate to based on current step
    final Widget targetPage = _getPageForStep(currentStep, viewModel);
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => targetPage),
    );
  }

  /// Returns the appropriate page widget for a given step number
  Widget _getPageForStep(int step, LoanViewModel viewModel) {
    switch (step) {
      case 1:
        return const Step1IDCapturePage();
      case 2:
        return const Step2PersonalInfoPage();
      case 3:
        return const Step3AdditionalInfoPage();
      case 4:
        // For step 4, if offer doesn't exist yet, go to processing
        // Otherwise go to offer calculator
        if (viewModel.currentOffer != null) {
          return const Step4OfferCalculatorPage();
        } else {
          return const ProcessingPage();
        }
      case 5:
        // Get loan details from current offer
        final offer = viewModel.currentOffer;
        if (offer != null) {
          return Step5ContractReviewPage(
            loanAmount: offer['loanAmountVnd'] as double? ?? 0.0,
            tenor: offer['loanTermMonths'] as int? ?? 12,
            downPayment: offer['downPayment'] as double? ?? 0.0,
            loanPurpose: offer['loanPurpose'] as String? ?? 'PERSONAL',
          );
        }
        return const ProcessingPage();
      case 6:
        return const Step6DisbursementPage();
      default:
        // All steps completed, show the overview again
        return const LoanApplicationPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          context.t('Start Your Loan Application', 'Bắt đầu hồ sơ vay của bạn'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1F3F),
          ),
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
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildStepCard(
                          context,
                          icon: Icons.verified_user_outlined,
                          title: context.t(
                            'Step 1: Verify Identity',
                            'Bước 1: Xác minh danh tính',
                          ),
                          description: context.t(
                            'Confirm your identity with ID and selfie',
                            'Xác minh danh tính bằng CCCD và ảnh khuôn mặt',
                          ),
                          isCompleted: viewModel.step1Completed,
                          onIconTap: _handleStep1IconTapForDemo,
                        ),
                        const SizedBox(height: 16),
                        _buildStepCard(
                          context,
                          icon: Icons.person_outline,
                          title: context.t(
                            'Step 2: Personal Information',
                            'Bước 2: Thông tin cá nhân',
                          ),
                          description: context.t(
                            'Provide your personal details',
                            'Cung cấp thông tin cá nhân',
                          ),
                          isCompleted: viewModel.step2Completed,
                        ),
                        const SizedBox(height: 16),
                        _buildStepCard(
                          context,
                          icon: Icons.analytics_outlined,
                          title: context.t(
                            'Step 3: Processing',
                            'Bước 3: Xử lý hồ sơ',
                          ),
                          description: context.t(
                            'We\'ll process your application',
                            'Chúng tôi sẽ xử lý hồ sơ của bạn',
                          ),
                          isCompleted:
                              viewModel.step2Completed &&
                              viewModel.step3Completed,
                        ),
                        const SizedBox(height: 16),
                        _buildStepCard(
                          context,
                          icon: Icons.check_circle_outline,
                          title: context.t(
                            'Step 4: Loan Offer',
                            'Bước 4: Đề nghị khoản vay',
                          ),
                          description: context.t(
                            'Review your loan offer',
                            'Xem lại đề nghị vay',
                          ),
                          isCompleted: viewModel.step4Completed,
                        ),
                        const SizedBox(height: 16),
                        _buildStepCard(
                          context,
                          icon: Icons.description_outlined,
                          title: context.t(
                            'Step 5: Contract Review',
                            'Bước 5: Xem hợp đồng',
                          ),
                          description: context.t(
                            'Read and sign your loan contract',
                            'Đọc và ký hợp đồng vay',
                          ),
                          isCompleted: viewModel.step6Completed,
                        ),
                        const SizedBox(height: 16),
                        _buildStepCard(
                          context,
                          icon: Icons.account_balance_wallet_outlined,
                          title: context.t(
                            'Step 6: Disbursement',
                            'Bước 6: Giải ngân',
                          ),
                          description: context.t(
                            'Provide bank details to receive funds',
                            'Cung cấp thông tin ngân hàng để nhận tiền',
                          ),
                          isCompleted: viewModel.step6Completed,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (AppEnvironment.shouldSkipEkyc(
                                hasCompletedEkyc:
                                    LocalStorageService.hasCompletedEkyc(
                                      userId: FirebaseAuth.instance.currentUser?.uid,
                                    ),
                                isTestAccountMode:
                                    LocalStorageService.isTestAccountMode(),
                              )) {
                                viewModel.applySavedEkycPrefill();
                                if (!viewModel.step1Completed) {
                                  viewModel.markStep1CompletedLocalOnly();
                                }
                                
                                // Route to the appropriate step based on progress
                                // If there's an active application, use getCurrentStep
                                if (viewModel.hasActiveApplication) {
                                  _routeToCurrentStep(viewModel);
                                } else {
                                  // No active application, go to Step 2 (next logical step after eKYC)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const Step2PersonalInfoPage(),
                                    ),
                                  );
                                }
                                return;
                              }

                              final cameraStatus = await Permission.camera
                                  .request();
                              if (!context.mounted) return;

                              if (!cameraStatus.isGranted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Camera permission is required to auto-scan your ID.',
                                    ),
                                    action: cameraStatus.isPermanentlyDenied
                                        ? SnackBarAction(
                                            label: 'Open Settings',
                                            onPressed: openAppSettings,
                                          )
                                        : null,
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Route to the appropriate step based on application progress
                              _routeToCurrentStep(viewModel);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4D4AF9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              viewModel.step1Completed
                                  ? context.t(
                                      'Continue Application',
                                      'Tiếp tục hồ sơ',
                                    )
                                  : context.t(
                                      'Start Application',
                                      'Bắt đầu hồ sơ',
                                    ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
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
    VoidCallback? onIconTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey.shade200,
        ),
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onIconTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : const Color(0xFF4D4AF9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isCompleted
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF4D4AF9),
                size: 28,
              ),
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
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
        ],
      ),
    );
  }
}
