import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/vnpt_config.dart';
import '../services/vnpt_credentials_manager.dart';
import '../utils/jwt_token_helper.dart';

/// VNPT eKYC Service
/// 
/// Handles all interactions with VNPT eKYC API including:
/// - ID card OCR (front & back)
/// - Face matching
/// - Liveness detection
class VnptEkycService {
  static final VnptEkycService _instance = VnptEkycService._internal();
  factory VnptEkycService() => _instance;
  VnptEkycService._internal();

  final http.Client _client = http.Client();
  late VnptCredentials _credentials;
  String? _cachedAccessToken;
  DateTime? _tokenExpiryTime;
  
  // Callback for token expiry warnings
  void Function(String message, DateTime expiryTime)? onTokenExpiryWarning;

  /// Initialize the service with credentials
  /// Must be called before using any API methods
  static Future<void> initialize() async {
    try {
      final instance = VnptEkycService._instance;
      instance._credentials = await VnptCredentialsManager.loadCredentials();
      instance._cachedAccessToken = instance._credentials.accessToken;
      
      // Parse token expiry from JWT
      instance._tokenExpiryTime = JwtTokenHelper.getExpiryTime(instance._credentials.accessToken);
      
      // Log token info
      if (instance._tokenExpiryTime != null) {
        final expiryInfo = JwtTokenHelper.getExpiryInfo(instance._credentials.accessToken);
        print('[VNPT] Token info: $expiryInfo');
        
        // Check if token is expired or expiring soon
        if (JwtTokenHelper.isExpired(instance._credentials.accessToken)) {
          final errorMsg = 'VNPT Access Token đã HẾT HẠN! Vui lòng cập nhật token mới trong file .env';
          print('[VNPT] $errorMsg');
          throw VnptException(errorMsg);
        } else if (JwtTokenHelper.isExpiringSoon(
          instance._credentials.accessToken,
          buffer: VnptConfig.tokenExpiryWarningBuffer,
        )) {
          final warningMsg = 'VNPT Access Token sẽ hết hạn trong ${JwtTokenHelper.getTimeUntilExpiry(instance._credentials.accessToken)?.inHours} giờ. Vui lòng chuẩn bị token mới.';
          print('[VNPT] $warningMsg');
          instance.onTokenExpiryWarning?.call(warningMsg, instance._tokenExpiryTime!);
        }
      } else {
        print('[VNPT] Warning: Could not parse token expiry time');
      }
      
      print('[VNPT] Service initialized successfully');
    } catch (e) {
      print('[VNPT] Failed to initialize service: $e');
      rethrow;
    }
  }

  /// Get valid access token with expiry check
  Future<String> _getAccessToken() async {
    if (_cachedAccessToken == null) {
      throw VnptException('Service not initialized. Call initialize() first.');
    }

    // Check if token is expired
    if (JwtTokenHelper.isExpired(_cachedAccessToken!)) {
      final errorMsg = 'VNPT Access Token đã hết hạn! Vui lòng cập nhật token mới trong file .env và khởi động lại app.';
      print('[VNPT] $errorMsg');
      throw VnptException(errorMsg);
    }
    
    // Warn if token is expiring soon
    if (_tokenExpiryTime != null && JwtTokenHelper.isExpiringSoon(
      _cachedAccessToken!,
      buffer: VnptConfig.tokenExpiryWarningBuffer,
    )) {
      final timeLeft = JwtTokenHelper.getTimeUntilExpiry(_cachedAccessToken!);
      print('[VNPT] Warning: Token expires in ${timeLeft?.inHours} hours');
    }

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
      request.headers['Token-id'] = _credentials.tokenId;
      request.headers['Token-key'] = _credentials.tokenKey;

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
              'Token-id': _credentials.tokenId,
              'Token-key': _credentials.tokenKey,
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
              'Token-id': _credentials.tokenId,
              'Token-key': _credentials.tokenKey,
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
              'Token-id': _credentials.tokenId,
              'Token-key': _credentials.tokenKey,
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

  /// Compare face on ID card with selfie
  Future<VnptFaceMatchResponse> compareFaces({
    required Uint8List idCardImageBytes,
    required Uint8List selfieImageBytes,
  }) async {
    try {
      print('[VNPT] Starting face comparison');
      
      // Upload both images
      final idCardUpload = await uploadImage(idCardImageBytes);
      final selfieUpload = await uploadImage(selfieImageBytes);

      if (!idCardUpload.success || !selfieUpload.success) {
        throw VnptException('Không thể tải ảnh lên');
      }

      print('[VNPT] Both images uploaded');
      print('[VNPT] ID card hash: ${idCardUpload.imageId}');
      print('[VNPT] Selfie hash: ${selfieUpload.imageId}');

      // Perform face matching
      final token = await _getAccessToken();
      final url = Uri.parse('${VnptConfig.baseUrl}${VnptConfig.faceCompareEndpoint}');

      final requestBody = {
        'img_front': idCardUpload.imageId,  // ID card photo
        'img_face': selfieUpload.imageId,   // Selfie photo
        'client_session': _generateClientSession(),
        'token': 'ekyc_flutter_${DateTime.now().millisecondsSinceEpoch}',
      };

      print('[VNPT] Face compare request to: $url');

      final response = await _client
          .post(
            url,
            headers: {
              'Authorization': token,
              'Token-id': _credentials.tokenId,
              'Token-key': _credentials.tokenKey,
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

  /// Verify ID card front side
  Future<VnptIdCardResponse> verifyIdCardFront(Uint8List imageBytes) async {
    return performOcrFront(imageBytes);
  }

  /// Verify ID card back side
  Future<VnptIdCardResponse> verifyIdCardBack(Uint8List imageBytes) async {
    return performOcrBack(imageBytes);
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

/// Response from face matching
class VnptFaceMatchResponse {
  final bool success;
  final bool isMatch;
  final double? similarity;
  final String? result;
  final String? matchStatus; // MATCH or NOMATCH
  final String? errorMessage;

  VnptFaceMatchResponse({
    required this.success,
    required this.isMatch,
    this.similarity,
    this.result,
    this.matchStatus,
    this.errorMessage,
  });

  factory VnptFaceMatchResponse.fromJson(Map<String, dynamic> json) {
    final object = json['object'];
    final isSuccess = json['message'] == 'IDG-00000000';
    
    if (!isSuccess || object == null) {
      return VnptFaceMatchResponse(
        success: false,
        isMatch: false,
        errorMessage: json['message'] ?? 'Face matching failed',
      );
    }

    final matchStatus = object['msg'] as String?;
    final isMatch = matchStatus == 'MATCH';
    final prob = object['prob'];
    final similarity = prob != null ? (prob is int ? prob.toDouble() : prob as double) / 100.0 : null;

    return VnptFaceMatchResponse(
      success: true,
      isMatch: isMatch,
      similarity: similarity,
      result: object['result'] as String?,
      matchStatus: matchStatus,
      errorMessage: null,
    );
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
