import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'step2_personal_info.dart';

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
          SnackBar(content: Text('Error: $e')),
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
          SnackBar(content: Text('Camera error: $e')),
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
          title: const Text('Verification failed'),
          content: Text(
            loanViewModel.vnptErrorMessage ?? 
            'Cannot verify your selfie. Please ensure good lighting and try again.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                loanViewModel.clearVnptError();
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                loanViewModel.clearVnptError();
                clearImage();
              },
              child: const Text('Take again'),
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
            title: const Text(
              'Scoring - Step 1 EKYC',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Step 1: Verify your identity',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F3F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Take your selfie for verification',
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
                            color: const Color(0xFF4C40F7),
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
                                color: const Color(0xFF4C40F7),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Click to capture a selfie image',
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
                                  : const Color(0xFF4C40F7),
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
                        if (faceMatchData != null && faceMatchData.success) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: faceMatchData.isMatch
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: faceMatchData.isMatch
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFFF9800),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      faceMatchData.isMatch
                                          ? Icons.check_circle
                                          : Icons.warning,
                                      color: faceMatchData.isMatch
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFFFF9800),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Kết quả so sánh khuôn mặt',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: faceMatchData.isMatch
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFFFF9800),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Trạng thái',
                                  faceMatchData.isMatch ? '✓ Khớp' : '✗ Không khớp',
                                ),
                                if (faceMatchData.similarity != null)
                                  _buildInfoRow(
                                    'Độ tương đồng',
                                    '${(faceMatchData.similarity! * 100).toStringAsFixed(1)}%',
                                  ),
                                if (faceMatchData.result != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      faceMatchData.result!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Retake options
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isMobile) ...[
                              ElevatedButton.icon(
                                onPressed: takePhoto,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Camera'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4C40F7),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            ElevatedButton.icon(
                              onPressed: selectImage,
                              icon: const Icon(Icons.photo_library),
                              label: Text(_isMobile ? 'Gallery' : 'Choose File'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade400,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
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
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C40F7)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Đang so sánh khuôn mặt...',
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
                                ? const Color(0xFF4C40F7)
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
                          'Process',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: imageData != null
                                ? const Color(0xFF4C40F7)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    )
                  else
                    // Show Continue button after successful processing
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
                        const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
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
