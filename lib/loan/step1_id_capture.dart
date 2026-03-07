import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
  bool _autoFlowRunning = false;
  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScanFlow();
    });
  }

  Future<void> _startAutoScanFlow() async {
    if (_autoFlowRunning || !mounted) return;
    if (!_isMobile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auto-scan is only available on Android/iOS devices.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final vm = context.read<LoanViewModel>();
    final frontDone = vm.frontIdData?.success ?? false;
    final backDone = vm.backIdData?.success ?? false;

    setState(() {
      _autoFlowRunning = true;
    });

    try {
      if (!frontDone) {
        final frontOk = await _scanAndVerify(isFront: true);
        if (!frontOk || !mounted) return;
      }

      final latestVm = context.read<LoanViewModel>();
      final latestBackDone = latestVm.backIdData?.success ?? false;
      if (!latestBackDone) {
        final backOk = await _scanAndVerify(isFront: false);
        if (!backOk || !mounted) return;
      }

      if (!mounted) return;
      _continueToNext();
    } finally {
      if (mounted) {
        setState(() {
          _autoFlowRunning = false;
        });
      }
    }
  }

  Future<bool> _scanAndVerify({required bool isFront}) async {
    while (mounted) {
      setState(() {
        if (isFront) {
          isFrontLoading = true;
        } else {
          isBackLoading = true;
        }
      });

      final capturedBytes = await Navigator.push<Uint8List?>(
        context,
        MaterialPageRoute(
          builder: (_) => _LiveAutoCapturePage(
            title: isFront ? 'Scan Front of ID Card' : 'Scan Back of ID Card',
            subtitle:
                'Center the card inside the frame and keep your hand steady.',
          ),
        ),
      );

      if (!mounted) return false;

      if (capturedBytes == null) {
        setState(() {
          if (isFront) {
            isFrontLoading = false;
          } else {
            isBackLoading = false;
          }
        });
        return false;
      }

      setState(() {
        if (isFront) {
          frontImageData = capturedBytes;
          isFrontLoading = false;
        } else {
          backImageData = capturedBytes;
          isBackLoading = false;
        }
      });

      final success = await _processImage(isFront);
      if (success) {
        return true;
      }

      final retry = await _showRetryDialog(isFront);
      if (!retry) {
        return false;
      }
    }

    return false;
  }

  Future<bool> _showRetryDialog(bool isFront) async {
    final loanViewModel = context.read<LoanViewModel>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication failed'),
        content: Text(
          loanViewModel.vnptErrorMessage ??
              'Cannot recognize the ID card. Please rescan clearly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rescan'),
          ),
        ],
      ),
    );

    loanViewModel.clearVnptError();

    if (result != true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan cancelled. Tap Retry Auto-Scan to try again.'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    if (result == true && mounted) {
      setState(() {
        if (isFront) {
          frontImageData = null;
        } else {
          backImageData = null;
        }
      });
    }

    return result == true;
  }

  Future<bool> _processImage(bool isFront) async {
    final imageData = isFront ? frontImageData : backImageData;
    if (imageData == null) return false;

    final loanViewModel = context.read<LoanViewModel>();

    final success = isFront
        ? await loanViewModel.verifyFrontIdWithVnpt(imageData)
        : await loanViewModel.verifyBackIdWithVnpt(imageData);

    return success;
  }

  void _continueToNext() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Step1SelfiePage()),
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
                          'Auto-scanning front then back ID card',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _autoFlowRunning
                              ? 'Keep your card stable. Capture and verification run automatically.'
                              : 'Auto flow paused. Tap retry to continue.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Front ID Section
                        _buildIDSection(
                          title: 'Front of ID Card',
                          imageData: frontImageData,
                          isLoading: isFrontLoading,
                          isVerifying: isFrontVerifying,
                          isProcessed: isFrontProcessed,
                        ),

                        const SizedBox(height: 32),

                        // Back ID Section
                        _buildIDSection(
                          title: 'Back of ID Card',
                          imageData: backImageData,
                          isLoading: isBackLoading,
                          isVerifying: isBackVerifying,
                          isProcessed: isBackProcessed,
                        ),

                        const SizedBox(height: 40),

                        if (!_autoFlowRunning && !canContinue)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _startAutoScanFlow,
                              icon: const Icon(Icons.autorenew),
                              label: const Text('Retry Auto-Scan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4C40F7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
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
                      onPressed: canContinue && !_autoFlowRunning
                          ? _continueToNext
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canContinue
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        canContinue ? 'Continue to Selfie' : 'Auto-scanning...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: canContinue
                              ? Colors.white
                              : Colors.grey.shade600,
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
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF4C40F7), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const CircularProgressIndicator()
                else ...[
                  Icon(
                    Icons.auto_awesome,
                    size: 60,
                    color: const Color(0xFF4C40F7),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Waiting for auto-scan',
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
          )
        else
          Column(
            children: [
              Container(
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
                  child: Image.memory(imageData, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 12),

              // Process button
              if (isVerifying)
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4C40F7),
                    ),
                  ),
                )
              else if (!isProcessed)
                const Text(
                  'Verifying...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4C40F7),
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

class _LiveAutoCapturePage extends StatefulWidget {
  const _LiveAutoCapturePage({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  State<_LiveAutoCapturePage> createState() => _LiveAutoCapturePageState();
}

class _LiveAutoCapturePageState extends State<_LiveAutoCapturePage> {
  CameraController? _controller;
  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _isAnalyzing = false;
  bool _idInterfaceDetected = false;
  int _frameCounter = 0;
  Timer? _autoCaptureTimer;
  int _stableTicks = 0;
  static const int _requiredStableTicks = 4;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _autoCaptureTimer?.cancel();
    final controller = _controller;
    if (controller != null && controller.value.isStreamingImages) {
      controller.stopImageStream();
    }
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitializing = false;
      });

      _startDetectionStream();
      _startAutoCaptureCountdown();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to start live camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startAutoCaptureCountdown() {
    _autoCaptureTimer?.cancel();
    _stableTicks = 0;

    _autoCaptureTimer = Timer.periodic(const Duration(milliseconds: 250), (
      timer,
    ) async {
      final controller = _controller;
      if (!mounted || controller == null || !controller.value.isInitialized) {
        return;
      }
      if (_isCapturing || controller.value.isTakingPicture) {
        return;
      }

      if (_idInterfaceDetected) {
        setState(() {
          _stableTicks = (_stableTicks + 1).clamp(0, _requiredStableTicks);
        });
      } else if (_stableTicks != 0) {
        setState(() {
          _stableTicks = 0;
        });
      }

      if (_stableTicks >= _requiredStableTicks) {
        await _capture(autoTriggered: true);
      }
    });
  }

  void _startDetectionStream() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isStreamingImages) return;

    controller.startImageStream((CameraImage image) {
      if (!mounted || _isCapturing || _isAnalyzing) return;

      // Analyze every 4th frame to avoid overloading UI thread.
      _frameCounter = (_frameCounter + 1) % 4;
      if (_frameCounter != 0) return;

      _isAnalyzing = true;
      final detected = _detectIdInterface(image);
      if (mounted && detected != _idInterfaceDetected) {
        setState(() {
          _idInterfaceDetected = detected;
        });
      }
      _isAnalyzing = false;
    });
  }

  bool _detectIdInterface(CameraImage image) {
    if (image.planes.isEmpty) return false;

    final width = image.width;
    final height = image.height;
    if (width <= 0 || height <= 0) return false;

    final bytes = image.planes.first.bytes;
    final bytesPerRow = image.planes.first.bytesPerRow;
    if (bytes.isEmpty || bytesPerRow <= 0) return false;

    // Match the overlay capture frame area.
    final left = (width * 0.07).toInt();
    final right = (width * 0.93).toInt();
    final top = (height * 0.36).toInt();
    final bottom = (height * 0.64).toInt();

    if (right - left < 40 || bottom - top < 20) return false;

    const step = 6;
    int sampleCount = 0;
    int edgeCount = 0;
    int sum = 0;
    int sumSq = 0;

    for (int y = top; y < bottom - step; y += step) {
      final row = y * bytesPerRow;
      for (int x = left; x < right - step; x += step) {
        final idx = row + x;
        final current = bytes[idx];
        final rightPixel = bytes[idx + step];
        final downPixel = bytes[idx + (step * bytesPerRow)];

        sum += current;
        sumSq += current * current;
        sampleCount++;

        final grad = (current - rightPixel).abs() + (current - downPixel).abs();
        if (grad > 55) {
          edgeCount++;
        }
      }
    }

    if (sampleCount == 0) return false;

    final mean = sum / sampleCount;
    final variance = (sumSq / sampleCount) - (mean * mean);
    final edgeDensity = edgeCount / sampleCount;

    // Heuristic thresholds tuned for "ID-like" framed object:
    // enough texture edges + not too dark/washed + acceptable contrast.
    final contrastOk = variance > 200;
    final edgeOk = edgeDensity > 0.13;
    final exposureOk = mean > 60 && mean < 210;

    return contrastOk && edgeOk && exposureOk;
  }

  Future<void> _capture({bool autoTriggered = false}) async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isCapturing ||
        controller.value.isTakingPicture) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      Navigator.pop(context, bytes);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
        _stableTicks = 0;
      });
      _startDetectionStream();
      _startAutoCaptureCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            autoTriggered
                ? 'Auto-capture failed. Keep ID inside the frame and retry.'
                : 'Capture failed: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _stableTicks / _requiredStableTicks;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child:
                  _isInitializing ||
                      _controller == null ||
                      !_controller!.value.isInitialized
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : CameraPreview(_controller!),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _CaptureFramePainter()),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isCapturing
                        ? null
                        : () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.grey.shade200,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isCapturing
                        ? 'Capturing...'
                        : _idInterfaceDetected
                        ? 'ID interface detected. Auto-capture in ${((_requiredStableTicks - _stableTicks) * 0.25).clamp(0, 99).toStringAsFixed(2)}s'
                        : 'Detecting ID interface...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.45);
    final clearRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.86,
      height: size.height * 0.28,
    );
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(clearRect, const Radius.circular(20)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF4CAF50);
    canvas.drawRRect(
      RRect.fromRectAndRadius(clearRect, const Radius.circular(20)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
