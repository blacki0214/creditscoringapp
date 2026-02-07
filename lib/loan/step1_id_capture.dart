import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/loan_viewmodel.dart';
import 'step1_selfie.dart';

class Step1IDCapturePage extends StatefulWidget {
  const Step1IDCapturePage({super.key});

  @override
  State<Step1IDCapturePage> createState() => _Step1IDCapturePageState();
}

class _Step1IDCapturePageState extends State<Step1IDCapturePage> {
  Uint8List? frontImageData;
  Uint8List? backImageData;
  bool isFrontLoading = false;
  bool isBackLoading = false;
  final ImagePicker _picker = ImagePicker();
  bool get _isMobile => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> selectImage(bool isFront) async {
    if (isFrontLoading || isBackLoading) return;

    setState(() {
      if (isFront) {
        isFrontLoading = true;
      } else {
        isBackLoading = true;
      }
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        if (mounted) {
          setState(() {
            if (isFront) {
              frontImageData = result.files.first.bytes;
            } else {
              backImageData = result.files.first.bytes;
            }
          });
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
        setState(() {
          if (isFront) {
            isFrontLoading = false;
          } else {
            isBackLoading = false;
          }
        });
      }
    }
  }

  Future<void> takePhoto(bool isFront) async {
    if (isFrontLoading || isBackLoading) return;
    
    setState(() {
      if (isFront) {
        isFrontLoading = true;
      } else {
        isBackLoading = true;
      }
    });

    try {
      if (_isMobile) {
        final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
        if (photo != null) {
          final bytes = await photo.readAsBytes();
          if (mounted) {
            setState(() {
              if (isFront) {
                frontImageData = bytes;
              } else {
                backImageData = bytes;
              }
            });
          }
        }
      } else {
        await selectImage(isFront);
      }
    } catch (e) {
      await selectImage(isFront);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          if (isFront) {
            isFrontLoading = false;
          } else {
            isBackLoading = false;
          }
        });
      }
    }
  }

  Future<void> _processImage(bool isFront) async {
    final imageData = isFront ? frontImageData : backImageData;
    if (imageData == null) return;

    final loanViewModel = context.read<LoanViewModel>();
    
    final success = isFront
        ? await loanViewModel.verifyFrontIdWithVnpt(imageData)
        : await loanViewModel.verifyBackIdWithVnpt(imageData);

    if (!mounted) return;

    if (!success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Authentication failed'),
          content: Text(
            loanViewModel.vnptErrorMessage ?? 
            'Cannot recognize the ID card. Please take a clearer photo.',
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
                setState(() {
                  if (isFront) {
                    frontImageData = null;
                  } else {
                    backImageData = null;
                  }
                });
              },
              child: const Text('Take again'),
            ),
          ],
        ),
      );
    }
  }

  void _continueToNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Step1SelfiePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoanViewModel>(
      builder: (context, loanViewModel, child) {
        final isFrontVerifying = loanViewModel.isVerifyingFrontId;
        final isBackVerifying = loanViewModel.isVerifyingBackId;
        final frontData = loanViewModel.frontIdData;
        final backData = loanViewModel.backIdData;

        final isFrontProcessed = frontData != null && frontData.success;
        final isBackProcessed = backData != null && backData.success;
        final canContinue = isFrontProcessed && isBackProcessed;

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
            child: Column(
              children: [
                Expanded(
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
                          'Capture both sides of your ID',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Front ID Section
                        _buildIDSection(
                          title: 'Front of ID Card',
                          imageData: frontImageData,
                          isLoading: isFrontLoading,
                          isVerifying: isFrontVerifying,
                          isProcessed: isFrontProcessed,
                          onTap: () => takePhoto(true),
                          onProcess: () => _processImage(true),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Back ID Section
                        _buildIDSection(
                          title: 'Back of ID Card',
                          imageData: backImageData,
                          isLoading: isBackLoading,
                          isVerifying: isBackVerifying,
                          isProcessed: isBackProcessed,
                          onTap: () => takePhoto(false),
                          onProcess: () => _processImage(false),
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                
                // Continue Button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: canContinue ? _continueToNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canContinue 
                            ? const Color(0xFF4CAF50) 
                            : Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        canContinue 
                            ? 'Continue to Selfie' 
                            : 'Process both IDs to continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: canContinue ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIDSection({
    required String title,
    required Uint8List? imageData,
    required bool isLoading,
    required bool isVerifying,
    required bool isProcessed,
    required VoidCallback onTap,
    required VoidCallback onProcess,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1F3F),
          ),
        ),
        const SizedBox(height: 12),
        
        // Image capture area
        if (imageData == null)
          GestureDetector(
            onTap: isLoading ? null : onTap,
            child: Container(
              width: double.infinity,
              height: 200,
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
                      size: 60,
                      color: const Color(0xFF4C40F7),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to capture',
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
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isProcessed ? Colors.green : Colors.orange,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      imageData,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Process button
              if (isVerifying)
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C40F7)),
                  ),
                )
              else if (!isProcessed)
                ElevatedButton.icon(
                  onPressed: onProcess,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Process'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C40F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
            ],
          ),
      ],
    );
  }
}
