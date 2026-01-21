// Additional VNPT eKYC Service Methods
// Copy these methods into vnpt_ekyc_service.dart after performOcrBack()

  /// Classify ID card type
  Future<VnptClassifyResponse> classifyIdCard(Uint8List imageBytes) async {
    try {
      print('[VNPT] Starting ID classification');
      
      // Upload image
      final uploadResponse = await uploadImage(imageBytes);

      if (!uploadResponse.success || uploadResponse.imageId == null) {
        throw VnptException('Không thể tải ảnh lên');
      }

      print('[VNPT] Image uploaded, hash: ${uploadResponse.imageId}');

      // Classify ID type
      final token = await _getAccessToken();
      final url = Uri.parse('${VnptConfig.baseUrl}${VnptConfig.classifyIdEndpoint}');

      final requestBody = {
        'img_card': uploadResponse.imageId,
        'client_session': _generateClientSession(),
        'token': 'ekyc_flutter_${DateTime.now().millisecondsSinceEpoch}',
      };

      print('[VNPT] Classify request to: $url');
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
      
      // Upload image
      final uploadResponse = await uploadImage(imageBytes);

      if (!uploadResponse.success || uploadResponse.imageId == null) {
        throw VnptException('Không thể tải ảnh lên');
      }

      print('[VNPT] Image uploaded, hash: ${uploadResponse.imageId}');

      // Check card liveness
      final token = await _getAccessToken();
      final url = Uri.parse('${VnptConfig.baseUrl}${VnptConfig.cardLivenessEndpoint}');

      final requestBody = {
        'img': uploadResponse.imageId,
        'client_session': _generateClientSession(),
      };

      print('[VNPT] Card liveness request to: $url');
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

// Response Models - Add these at the end of the file

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
