import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'step2_personal_info.dart';
import '../utils/app_localization.dart';

class Step1SelfiePage extends StatefulWidget {
  const Step1SelfiePage({super.key});

  @override
  State<Step1SelfiePage> createState() => _Step1SelfiePageState();
}

class _Step1SelfiePageState extends State<Step1SelfiePage> {
  Uint8List? imageData;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  bool get _isMobile => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> selectImage() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        if (mounted) {
          setState(() => imageData = result.files.first.bytes);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.t('Error', 'Lỗi')}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void clearImage() {
    setState(() => imageData = null);
    // Only clear selfie verification data, keep ID card data
    final loanViewModel = context.read<LoanViewModel>();
    loanViewModel.clearSelfieData();
  }

  Future<void> takePhoto() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
      if (_isMobile) {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front,
        );
        if (photo != null) {
          final bytes = await photo.readAsBytes();
          if (mounted) setState(() => imageData = bytes);
        }
      } else {
        await selectImage();
      }
    } catch (e) {
      await selectImage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.t('Camera error', 'Lỗi camera')}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _processImage() async {
    if (imageData == null) return;

    final loanViewModel = context.read<LoanViewModel>();
    
    // Call VNPT API to verify selfie (face comparison only, no navigation)
    final success = await loanViewModel.verifySelfieWithVnpt(imageData!);

    if (!mounted) return;

    if (!success) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.t('Verification failed', 'Xác thực thất bại')),
          content: Text(
            loanViewModel.vnptErrorMessage ?? 
            context.t(
              'Cannot verify your selfie. Please ensure good lighting and try again.',
              'Không thể xác minh ảnh khuôn mặt. Vui lòng đảm bảo đủ ánh sáng và thử lại.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                loanViewModel.clearVnptError();
              },
              child: Text(context.t('Close', 'Đóng')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                loanViewModel.clearVnptError();
                clearImage();
              },
              child: Text(context.t('Take again', 'Chụp lại')),
            ),
          ],
        ),
      );
    }
    // If success, results will be displayed automatically via Consumer
  }

  void _continueToNext() {
    final loanViewModel = context.read<LoanViewModel>();
    
    // Complete Step 1 and navigate to Step 2
    loanViewModel.completeStep1();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Step2PersonalInfoPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoanViewModel>(
      builder: (context, loanViewModel, child) {
        final isVerifying = loanViewModel.isVerifyingSelfie;
        final faceMatchData = loanViewModel.faceMatchData;
       

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
              context.t('Scoring - Step 1 EKYC', 'Chấm điểm - Bước 1 EKYC'),
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    context.t('Step 1: Verify your identity', 'Bước 1: Xác minh danh tính'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F3F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.t('Take your selfie for verification', 'Chụp ảnh khuôn mặt để xác thực'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // Image capture area
                  if (imageData == null)
                    GestureDetector(
                      onTap: isLoading ? null : takePhoto,
                      child: Container(
                        width: double.infinity,
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF4D4AF9),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isLoading)
                              const CircularProgressIndicator()
                            else ...[
                              Icon(
                                Icons.camera_alt,
                                size: 80,
                                color: const Color(0xFF4D4AF9),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.t('Click to capture a selfie image', 'Nhấn để chụp ảnh khuôn mặt'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: faceMatchData?.isMatch == true
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF4D4AF9),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.memory(
                              imageData!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Show face match results if available
                        if (faceMatchData != null && faceMatchData.success) 
                          Builder(
                            builder: (context) {
                              // Determine if face verification passed all checks
                              final bool passedValidation = faceMatchData.isMatch && 
                                  (faceMatchData.similarity ?? 0) >= 0.70;
                              
                              return Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: passedValidation
                                          ? const Color(0xFFE8F5E9)  // Green for pass
                                          : const Color(0xFFFFEBEE),  // Red for fail
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: passedValidation
                                            ? const Color(0xFF4CAF50)  // Green border
                                            : const Color(0xFFE53935),  // Red border
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              passedValidation
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color: passedValidation
                                                  ? const Color(0xFF4CAF50)
                                                  : const Color(0xFFE53935),
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                passedValidation 
                                                    ? context.t('Face verification successful', 'Xác thực khuôn mặt thành công')
                                                    : context.t('Face verification failed', 'Xác thực khuôn mặt thất bại'),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: passedValidation
                                                      ? const Color(0xFF4CAF50)
                                                      : const Color(0xFFE53935),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        _buildInfoRow(
                                          context.t('Status', 'Trạng thái'),
                                          faceMatchData.isMatch
                                              ? context.t('✓ Match', '✓ Khớp')
                                              : context.t('✗ Not Match', '✗ Không khớp'),
                                        ),
                                        if (!passedValidation) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.info_outline, color: Colors.red.shade700, size: 18),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    faceMatchData.similarity != null && faceMatchData.similarity! < 0.70
                                                        ? context.t(
                                                            'Similarity is too low (need ≥70%). Please retake with a clear face.',
                                                            'Độ tương đồng quá thấp (cần ≥70%). Vui lòng chụp lại rõ khuôn mặt.',
                                                          )
                                                        : context.t(
                                                            'Face does not match. Please try again.',
                                                            'Khuôn mặt không khớp. Vui lòng thử lại.',
                                                          ),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.red.shade700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  
                  const SizedBox(height: 60),
                  
                  // Process/Continue buttons with loading state
                  if (isVerifying)
                    Column(
                      children: [
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4D4AF9)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.t('Comparing faces...', 'Đang so khớp khuôn mặt...'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1F3F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  else if (faceMatchData == null || !faceMatchData.success)
                    // Show Process button when image is uploaded but not processed
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: imageData != null
                                ? const Color(0xFF4D4AF9)
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: imageData != null ? _processImage : null,
                            icon: Icon(
                              Icons.play_arrow,
                              color: imageData != null ? Colors.white : Colors.grey,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          context.t('Process', 'Xử lý'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: imageData != null
                                ? const Color(0xFF4D4AF9)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    )
                  else if (faceMatchData.isMatch && (faceMatchData.similarity ?? 0) >= 0.70)
                    // Show Continue button ONLY if validation passed
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _continueToNext,
                            icon: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          context.t('Continue', 'Tiếp tục'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    )
                  else
                    // Show Retake button if validation failed
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE53935),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: clearImage,
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          context.t('Retake Photo', 'Chụp lại ảnh'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1F3F),
            ),
          ),
        ],
      ),
    );
  }
}
