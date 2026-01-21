import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/vnpt_config.dart';

/// VNPT eKYC Service
/// 
/// Handles all interactions with VNPT eKYC API including:
/// - ID card OCR (front & back)
/// - Face matching
/// - Liveness detection
class VnptEkycService {
  final http.Client _client;
  String? _cachedAccessToken;
  DateTime? _tokenExpiryTime;

  VnptEkycService({http.Client? client})
      : _client = client ?? http.Client() {
    // Initialize with provided access token
    _cachedAccessToken = VnptConfig.initialAccessToken;
    // Token expires at timestamp 1769003984 (from JWT payload)
    _tokenExpiryTime = DateTime.fromMillisecondsSinceEpoch(1769003984 * 1000);
  }

  /// Get valid access token (cached or refresh if expired)
  Future<String> _getAccessToken() async {
    // Check if cached token is still valid
    if (_cachedAccessToken != null &&
        _tokenExpiryTime != null &&
        DateTime.now().isBefore(_tokenExpiryTime!)) {
      return _cachedAccessToken!;
    }

    // Token expired or not available, use initial token
    // In production, implement token refresh logic here
    _cachedAccessToken = VnptConfig.initialAccessToken;
    return _cachedAccessToken!;
  }

  /// Upload image to VNPT and get image ID
  Future<VnptUploadResponse> uploadImage(Uint8List imageBytes) async {
    try {
      final token = await _getAccessToken();
      final url = Uri.parse('${VnptConfig.baseUrl}${VnptConfig.uploadImageEndpoint}');

      print('[VNPT] Uploading image to: $url');
      print('[VNPT] Image size: ${imageBytes.length} bytes');
      print('[VNPT] Token: ${token.substring(0, 20)}...');

      // Create multipart request
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = token;
      request.headers['Token-id'] = VnptConfig.tokenId;
      request.headers['Token-key'] = VnptConfig.tokenKey;

      print('[VNPT] Headers: ${request.headers}');

      // Add image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'id_card.jpg',
        ),
      );

      // Add required fields according to API docs
      request.fields['title'] = 'ID Card Image';
      request.fields['description'] = 'eKYC ID card verification';

      print('[VNPT] Sending multipart request with file, title, and description');

      final streamedResponse = await request.send().timeout(VnptConfig.uploadTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      print('[VNPT] Upload response status: ${response.statusCode}');
      print('[VNPT] Upload response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VnptUploadResponse.fromJson(data);
      } else {
        throw VnptException(
          'Upload failed: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      print('[VNPT] Upload error: $e');
      throw VnptException('Lỗi khi tải ảnh lên: $e');
    }
  }

  /// Generate client_session string as required by VNPT API
  String _generateClientSession() {
    // Format: <PLATFORM>_<model>_<OS>_<Device/Simulator>_<SDK version>_<Device id>_<timestamp>
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'FLUTTER_app_1_Device_1.0.0_flutter_client_$timestamp';
  }

  /// Perform OCR on ID card front
  Future<VnptIdCardResponse> performOcrFront(Uint8List imageBytes) async {
    try {
      print('[VNPT] Starting OCR for front ID');
      
      // Step 1: Upload image
      final uploadResponse = await uploadImage(imageBytes);

      if (!uploadResponse.success || uploadResponse.imageId == null) {
        throw VnptException('Không thể tải ảnh lên');
      }

      print('[VNPT] Image uploaded, hash: ${uploadResponse.imageId}');

      // Step 2: Perform OCR
      final token = await _getAccessToken();
      final url = Uri.parse('${VnptConfig.baseUrl}${VnptConfig.ocrFrontEndpoint}');

      final requestBody = {
        'img_front': uploadResponse.imageId,
        'client_session': _generateClientSession(),
        'type': -1, // -1 for CMT cũ, mới, CCCD
        'validate_postcode': true,
        'token': 'ekyc_flutter_${DateTime.now().millisecondsSinceEpoch}',
      };

      print('[VNPT] OCR Front request to: $url');
      print('[VNPT] Request body: $requestBody');

      final response = await _client
          .post(
            url,
            headers: {
              'Authorization': token,
              'Token-id': VnptConfig.tokenId,
              'Token-key': VnptConfig.tokenKey,
              'Content-Type': 'application/json',
              'mac-address': 'FLUTTER_APP',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(VnptConfig.apiTimeout);

      print('[VNPT] OCR response status: ${response.statusCode}');
      print('[VNPT] OCR response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VnptIdCardResponse.fromJson(data, isFrontSide: true);
      } else {
        throw VnptException(
          'OCR failed: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      print('[VNPT] OCR error: $e');
      throw VnptException('Lỗi khi nhận diện CMND/CCCD: $e');
    }
  }

  /// Perform OCR on ID card back
  Future<VnptIdCardResponse> performOcrBack(Uint8List imageBytes) async {
    try {
      print('[VNPT] Starting OCR for back ID');
      
      // Step 1: Upload image
      final uploadResponse = await uploadImage(imageBytes);

      if (!uploadResponse.success || uploadResponse.imageId == null) {
        throw VnptException('Không thể tải ảnh lên');
      }

      print('[VNPT] Image uploaded, hash: ${uploadResponse.imageId}');

      // Step 2: Perform OCR
      final token = await _getAccessToken();
      final url = Uri.parse('${VnptConfig.baseUrl}${VnptConfig.ocrBackEndpoint}');

      final requestBody = {
        'img_back': uploadResponse.imageId,
        'client_session': _generateClientSession(),
        'type': -1, // -1 for CMT cũ, mới, CCCD
        'token': 'ekyc_flutter_${DateTime.now().millisecondsSinceEpoch}',
      };

      print('[VNPT] OCR Back request to: $url');

      final response = await _client
          .post(
            url,
            headers: {
              'Authorization': token,
              'Token-id': VnptConfig.tokenId,
              'Token-key': VnptConfig.tokenKey,
              'Content-Type': 'application/json',
              'mac-address': 'FLUTTER_APP',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(VnptConfig.apiTimeout);

      print('[VNPT] OCR Back response status: ${response.statusCode}');
      print('[VNPT] OCR Back response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VnptIdCardResponse.fromJson(data, isFrontSide: false);
      } else {
        throw VnptException(
          'OCR failed: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      print('[VNPT] OCR Back error: $e');
      throw VnptException('Lỗi khi nhận diện mặt sau CMND/CCCD: $e');
    }
  }

  /// Classify ID card type
  Future<VnptClassifyResponse> classifyIdCard(Uint8List imageBytes) async {
    try {
      print('[VNPT] Starting ID classification');
      
      final uploadResponse = await uploadImage(imageBytes);

      if (!uploadResponse.success || uploadResponse.imageId == null) {
        throw VnptException('Không thể tải ảnh lên');
      }

      print('[VNPT] Image uploaded, hash: ${uploadResponse.imageId}');

      final token = await _getAccessToken();
      final url = Uri.parse('${VnptConfig.baseUrl}${VnptConfig.classifyIdEndpoint}');

      final requestBody = {
        'img_card': uploadResponse.imageId,
        'client_session': _generateClientSession(),
        'token': 'ekyc_flutter_${DateTime.now().millisecondsSinceEpoch}',
      };

      print('[VNPT] Classify request to: $url');

      final response = await _client
          .post(
            url,
            headers: {
              'Authorization': token,
              'Token-id': VnptConfig.tokenId,
              'Token-key': VnptConfig.tokenKey,
              'Content-Type': 'application/json',
              'mac-address': 'FLUTTER_APP',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(VnptConfig.apiTimeout);

      print('[VNPT] Classify response status: ${response.statusCode}');
      print('[VNPT] Classify response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VnptClassifyResponse.fromJson(data);
      } else {
        throw VnptException(
          'Classification failed: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      print('[VNPT] Classify error: $e');
      throw VnptException('Lỗi khi phân loại giấy tờ: $e');
    }
  }

  /// Check if ID card is real (not photocopy/fake)
  Future<VnptCardLivenessResponse> checkCardLiveness(Uint8List imageBytes) async {
    try {
      print('[VNPT] Starting card liveness check');
      
      final uploadResponse = await uploadImage(imageBytes);

      if (!uploadResponse.success || uploadResponse.imageId == null) {
        throw VnptException('Không thể tải ảnh lên');
      }

      print('[VNPT] Image uploaded, hash: ${uploadResponse.imageId}');

      final token = await _getAccessToken();
      final url = Uri.parse('${VnptConfig.baseUrl}${VnptConfig.cardLivenessEndpoint}');

      final requestBody = {
        'img': uploadResponse.imageId,
        'client_session': _generateClientSession(),
      };

      print('[VNPT] Card liveness request to: $url');

      final response = await _client
          .post(
            url,
            headers: {
              'Authorization': token,
              'Token-id': VnptConfig.tokenId,
              'Token-key': VnptConfig.tokenKey,
              'Content-Type': 'application/json',
              'mac-address': 'FLUTTER_APP',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(VnptConfig.apiTimeout);

      print('[VNPT] Card liveness response status: ${response.statusCode}');
      print('[VNPT] Card liveness response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VnptCardLivenessResponse.fromJson(data);
      } else {
        throw VnptException(
          'Card liveness check failed: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      print('[VNPT] Card liveness error: $e');
      throw VnptException('Lỗi khi kiểm tra giấy tờ thật: $e');
    }
  }

  /// Verify ID card front side
  Future<VnptIdCardResponse> verifyIdCardFront(Uint8List imageBytes) async {
    return performOcrFront(imageBytes);
  }

  /// Verify ID card back side
  Future<VnptIdCardResponse> verifyIdCardBack(Uint8List imageBytes) async {
    return performOcrBack(imageBytes);
  }

  /// Perform face matching between two images
  Future<VnptFaceMatchResponse> compareFaces({
    required Uint8List image1Bytes,
    required Uint8List image2Bytes,
  }) async {
    try {
      print('[VNPT] Starting face comparison');
      
      // Upload both images
      final upload1 = await uploadImage(image1Bytes);
      final upload2 = await uploadImage(image2Bytes);

      if (!upload1.success || !upload2.success) {
        throw VnptException('Không thể tải ảnh lên');
      }

      print('[VNPT] Both images uploaded');
      print('[VNPT] Image 1 hash: ${upload1.imageId}');
      print('[VNPT] Image 2 hash: ${upload2.imageId}');

      // Perform face matching
      final token = await _getAccessToken();
      final url = Uri.parse('${VnptConfig.baseUrl}${VnptConfig.faceCompareEndpoint}');

      final requestBody = {
        'img_front': upload1.imageId,  // ID card photo
        'img_face': upload2.imageId,   // Selfie photo
        'client_session': _generateClientSession(),
        'token': 'ekyc_flutter_${DateTime.now().millisecondsSinceEpoch}',
      };

      print('[VNPT] Face compare request to: $url');
      print('[VNPT] Request body: $requestBody');

      final response = await _client
          .post(
            url,
            headers: {
              'Authorization': token,
              'Token-id': VnptConfig.tokenId,
              'Token-key': VnptConfig.tokenKey,
              'Content-Type': 'application/json',
              'mac-address': 'FLUTTER_APP',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(VnptConfig.apiTimeout);

      print('[VNPT] Face compare response status: ${response.statusCode}');
      print('[VNPT] Face compare response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VnptFaceMatchResponse.fromJson(data);
      } else {
        throw VnptException(
          'Face matching failed: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      print('[VNPT] Face compare error: $e');
      throw VnptException('Lỗi khi so sánh khuôn mặt: $e');
    }
  }

  /// Perform liveness detection on selfie
  Future<VnptLivenessResponse> detectLiveness(Uint8List imageBytes) async {
    try {
      print('[VNPT] Starting liveness detection');
      
      // Upload image
      final uploadResponse = await uploadImage(imageBytes);

      if (!uploadResponse.success || uploadResponse.imageId == null) {
        throw VnptException('Không thể tải ảnh lên');
      }

      print('[VNPT] Image uploaded for liveness, hash: ${uploadResponse.imageId}');

      // Perform liveness detection
      final token = await _getAccessToken();
      final url = Uri.parse('${VnptConfig.baseUrl}${VnptConfig.faceLivenessEndpoint}');

      final requestBody = {
        'img': uploadResponse.imageId,
        'client_session': _generateClientSession(),
        'token': 'ekyc_flutter_${DateTime.now().millisecondsSinceEpoch}',
      };

      print('[VNPT] Liveness request to: $url');
      print('[VNPT] Request body: $requestBody');

      final response = await _client
          .post(
            url,
            headers: {
              'Authorization': token,
              'Token-id': VnptConfig.tokenId,
              'Token-key': VnptConfig.tokenKey,
              'Content-Type': 'application/json',
              'mac-address': 'FLUTTER_APP',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(VnptConfig.apiTimeout);

      print('[VNPT] Liveness response status: ${response.statusCode}');
      print('[VNPT] Liveness response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VnptLivenessResponse.fromJson(data);
      } else {
        throw VnptException(
          'Liveness detection failed: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      print('[VNPT] Liveness error: $e');
      throw VnptException('Lỗi khi kiểm tra ảnh thật: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Response from image upload
class VnptUploadResponse {
  final bool success;
  final String? imageId;
  final String? errorMessage;

  VnptUploadResponse({
    required this.success,
    this.imageId,
    this.errorMessage,
  });

  factory VnptUploadResponse.fromJson(Map<String, dynamic> json) {
    // VNPT returns: {"message": "IDG-00000000", "object": {"hash": "...", ...}}
    final object = json['object'];
    final isSuccess = json['message'] == 'IDG-00000000' || json['code'] == 200;
    
    return VnptUploadResponse(
      success: isSuccess,
      imageId: object?['hash'], // Use 'hash' as image ID
      errorMessage: isSuccess ? null : (json['message'] ?? json['error']),
    );
  }
}

/// Response from ID card OCR
class VnptIdCardResponse {
  final bool success;
  final String? idNumber;
  final String? fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? nationality;
  final String? placeOfOrigin;
  final String? placeOfResidence;
  final String? issueDate;
  final String? issuePlace;
  final String? expiryDate;
  final double? confidence;
  final String? errorMessage;

  VnptIdCardResponse({
    required this.success,
    this.idNumber,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.placeOfOrigin,
    this.placeOfResidence,
    this.issueDate,
    this.issuePlace,
    this.expiryDate,
    this.confidence,
    this.errorMessage,
  });

  factory VnptIdCardResponse.fromJson(
    Map<String, dynamic> json, {
    required bool isFrontSide,
  }) {
    // VNPT returns: {"message": "IDG-00000000", "object": {...}}
    final object = json['object'];
    final isSuccess = json['message'] == 'IDG-00000000';
    
    if (!isSuccess || object == null) {
      return VnptIdCardResponse(
        success: false,
        errorMessage: json['message'] ?? 'Không nhận diện được thông tin',
      );
    }

    // Calculate confidence from name_prob, birth_day_prob, etc.
    double? avgConfidence;
    try {
      final nameProb = (object['name_prob'] as num?)?.toDouble() ?? 0.0;
      final birthProb = (object['birth_day_prob'] as num?)?.toDouble() ?? 0.0;
      final idProb = (object['id_probs'] as String?)?.contains('0.9') == true ? 0.9 : 0.0;
      avgConfidence = (nameProb + birthProb + idProb) / 3;
    } catch (e) {
      avgConfidence = null;
    }

    return VnptIdCardResponse(
      success: true,
      idNumber: object['id'],
      fullName: object['name'],
      dateOfBirth: _parseDate(object['birth_day']),
      gender: object['gender'],
      nationality: object['nationality'],
      placeOfOrigin: object['origin_location'],
      placeOfResidence: object['recent_location'],
      issueDate: object['issue_date'],
      issuePlace: object['issue_place'],
      expiryDate: object['valid_date'],
      confidence: avgConfidence,
      errorMessage: null,
    );
  }

  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      // Try parsing DD/MM/YYYY format
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}

/// Response from face matching
class VnptFaceMatchResponse {
  final bool success;
  final bool isMatch;
  final double? similarity;
  final String? errorMessage;

  VnptFaceMatchResponse({
    required this.success,
    required this.isMatch,
    this.similarity,
    this.errorMessage,
  });

  factory VnptFaceMatchResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final similarity = (data?['similarity'] as num?)?.toDouble() ?? 0.0;

    return VnptFaceMatchResponse(
      success: json['code'] == 200 || json['success'] == true,
      isMatch: similarity >= 0.7, // 70% threshold
      similarity: similarity,
      errorMessage: json['message'],
    );
  }
}

/// Response from liveness detection
class VnptLivenessResponse {
  final bool success;
  final bool isLivePerson;
  final double? livenessScore;
  final String? errorMessage;

  VnptLivenessResponse({
    required this.success,
    required this.isLivePerson,
    this.livenessScore,
    this.errorMessage,
  });

  factory VnptLivenessResponse.fromJson(Map<String, dynamic> json) {
    // VNPT returns: {"message": "IDG-00000000", "object": {...}}
    final object = json['object'];
    final isSuccess = json['message'] == 'IDG-00000000';
    
    if (!isSuccess || object == null) {
      return VnptLivenessResponse(
        success: false,
        isLivePerson: false,
        errorMessage: json['message'] ?? 'Liveness check failed',
      );
    }

    // Parse liveness result
    final livenessStatus = object['liveness'] as String?;
    final livenessProb = (object['liveness_prob'] as num?)?.toDouble();
    final livenessMsg = object['liveness_msg'] as String?;
    
    // Check if liveness passed
    final isLive = livenessStatus == 'success' || livenessStatus == 'ok';

    return VnptLivenessResponse(
      success: true,
      isLivePerson: isLive,
      livenessScore: livenessProb,
      errorMessage: isLive ? null : (livenessMsg ?? 'Liveness check failed'),
    );
  }
}

/// Response from ID classification
class VnptClassifyResponse {
  final bool success;
  final int? typeId;
  final String? typeName;
  final String? errorMessage;

  VnptClassifyResponse({
    required this.success,
    this.typeId,
    this.typeName,
    this.errorMessage,
  });

  factory VnptClassifyResponse.fromJson(Map<String, dynamic> json) {
    final object = json['object'];
    final isSuccess = json['message'] == 'IDG-00000000';
    
    if (!isSuccess || object == null) {
      return VnptClassifyResponse(
        success: false,
        errorMessage: json['message'] ?? 'Classification failed',
      );
    }

    return VnptClassifyResponse(
      success: true,
      typeId: object['type'] as int?,
      typeName: object['name'] as String?,
      errorMessage: null,
    );
  }

  String get typeDescription {
    switch (typeId) {
      case 0:
      case 1:
        return 'CMT cũ';
      case 2:
      case 3:
        return 'CMND mới/CCCD';
      case 5:
        return 'Hộ chiếu';
      case 6:
        return 'Bằng lái xe';
      case 7:
        return 'Chứng minh quân đội';
      default:
        return 'Giấy tờ khác';
    }
  }
}

/// Response from card liveness check
class VnptCardLivenessResponse {
  final bool success;
  final bool isRealCard;
  final bool? faceSwapping;
  final bool? fakeLiveness;
  final String? livenessMsg;
  final String? errorMessage;

  VnptCardLivenessResponse({
    required this.success,
    required this.isRealCard,
    this.faceSwapping,
    this.fakeLiveness,
    this.livenessMsg,
    this.errorMessage,
  });

  factory VnptCardLivenessResponse.fromJson(Map<String, dynamic> json) {
    final object = json['object'];
    final isSuccess = json['message'] == 'IDG-00000000';
    
    if (!isSuccess || object == null) {
      return VnptCardLivenessResponse(
        success: false,
        isRealCard: false,
        errorMessage: json['message'] ?? 'Card liveness check failed',
      );
    }

    final livenessStatus = object['liveness'] as String?;
    final isReal = livenessStatus == 'success';

    return VnptCardLivenessResponse(
      success: true,
      isRealCard: isReal,
      faceSwapping: object['face_swapping'] as bool?,
      fakeLiveness: object['fake_liveness'] as bool?,
      livenessMsg: object['liveness_msg'] as String?,
      errorMessage: isReal ? null : (object['liveness_msg'] ?? 'Không phải giấy tờ thật'),
    );
  }
}

/// Custom exception for VNPT API errors
class VnptException implements Exception {
  final String message;
  final String? details;

  VnptException(this.message, [this.details]);

  @override
  String toString() => 'VnptException: $message${details != null ? '\nDetails: $details' : ''}';
}
