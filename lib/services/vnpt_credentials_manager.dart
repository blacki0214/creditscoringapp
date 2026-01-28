import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// VNPT Credentials Model
class VnptCredentials {
  final String tokenId;
  final String tokenKey;
  final String publicKeyCa;
  final String accessToken;

  VnptCredentials({
    required this.tokenId,
    required this.tokenKey,
    required this.publicKeyCa,
    required this.accessToken,
  });

  Map<String, dynamic> toJson() => {
        'tokenId': tokenId,
        'tokenKey': tokenKey,
        'publicKeyCa': publicKeyCa,
        'accessToken': accessToken,
      };

  factory VnptCredentials.fromJson(Map<String, dynamic> json) {
    return VnptCredentials(
      tokenId: json['tokenId'] as String,
      tokenKey: json['tokenKey'] as String,
      publicKeyCa: json['publicKeyCa'] as String,
      accessToken: json['accessToken'] as String,
    );
  }

  /// Validate that all credentials are non-empty
  bool isValid() {
    return tokenId.isNotEmpty &&
        tokenKey.isNotEmpty &&
        publicKeyCa.isNotEmpty &&
        accessToken.isNotEmpty;
  }
}

/// Manages VNPT credentials loading from multiple sources
/// Priority: Secure Storage > .env file
class VnptCredentialsManager {
  static const String _storageKeyPrefix = 'vnpt_';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Load credentials from secure storage or .env file
  /// 
  /// Priority:
  /// 1. Try secure storage (for production)
  /// 2. Fall back to .env file (for development)
  /// 
  /// Throws [VnptCredentialsException] if credentials not found or invalid
  static Future<VnptCredentials> loadCredentials() async {
    try {
      // First, try to load from secure storage
      final storageCredentials = await _loadFromSecureStorage();
      if (storageCredentials != null && storageCredentials.isValid()) {
        print('[VnptCredentials] Loaded from secure storage');
        return storageCredentials;
      }

      // Fall back to .env file
      final envCredentials = await _loadFromEnv();
      if (envCredentials != null && envCredentials.isValid()) {
        print('[VnptCredentials] Loaded from .env file');
        
        // Save to secure storage for next time
        await saveCredentials(envCredentials);
        
        return envCredentials;
      }

      throw VnptCredentialsException(
        'VNPT credentials not found. Please configure credentials in .env file or secure storage.',
      );
    } catch (e) {
      if (e is VnptCredentialsException) rethrow;
      throw VnptCredentialsException('Failed to load credentials: $e');
    }
  }

  /// Load credentials from Flutter Secure Storage
  static Future<VnptCredentials?> _loadFromSecureStorage() async {
    try {
      final tokenId = await _secureStorage.read(key: '${_storageKeyPrefix}token_id');
      final tokenKey = await _secureStorage.read(key: '${_storageKeyPrefix}token_key');
      final publicKeyCa = await _secureStorage.read(key: '${_storageKeyPrefix}public_key_ca');
      final accessToken = await _secureStorage.read(key: '${_storageKeyPrefix}access_token');

      if (tokenId == null || tokenKey == null || publicKeyCa == null || accessToken == null) {
        return null;
      }

      return VnptCredentials(
        tokenId: tokenId,
        tokenKey: tokenKey,
        publicKeyCa: publicKeyCa,
        accessToken: accessToken,
      );
    } catch (e) {
      print('[VnptCredentials] Error loading from secure storage: $e');
      return null;
    }
  }

  /// Load credentials from .env file
  static Future<VnptCredentials?> _loadFromEnv() async {
    try {
      // Load .env file if not already loaded
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: '.env');
      }

      final tokenId = dotenv.env['VNPT_TOKEN_ID'];
      final tokenKey = dotenv.env['VNPT_TOKEN_KEY'];
      final publicKeyCa = dotenv.env['VNPT_PUBLIC_KEY_CA'];
      final accessToken = dotenv.env['VNPT_ACCESS_TOKEN'];

      if (tokenId == null || tokenKey == null || publicKeyCa == null || accessToken == null) {
        return null;
      }

      if (tokenId.isEmpty || tokenKey.isEmpty || publicKeyCa.isEmpty || accessToken.isEmpty) {
        return null;
      }

      return VnptCredentials(
        tokenId: tokenId,
        tokenKey: tokenKey,
        publicKeyCa: publicKeyCa,
        accessToken: accessToken,
      );
    } catch (e) {
      print('[VnptCredentials] Error loading from .env: $e');
      return null;
    }
  }

  /// Save credentials to secure storage
  static Future<void> saveCredentials(VnptCredentials credentials) async {
    try {
      if (!credentials.isValid()) {
        throw VnptCredentialsException('Cannot save invalid credentials');
      }

      await _secureStorage.write(
        key: '${_storageKeyPrefix}token_id',
        value: credentials.tokenId,
      );
      await _secureStorage.write(
        key: '${_storageKeyPrefix}token_key',
        value: credentials.tokenKey,
      );
      await _secureStorage.write(
        key: '${_storageKeyPrefix}public_key_ca',
        value: credentials.publicKeyCa,
      );
      await _secureStorage.write(
        key: '${_storageKeyPrefix}access_token',
        value: credentials.accessToken,
      );

      print('[VnptCredentials] Saved to secure storage');
    } catch (e) {
      throw VnptCredentialsException('Failed to save credentials: $e');
    }
  }

  /// Check if credentials exist
  static Future<bool> hasCredentials() async {
    try {
      final credentials = await loadCredentials();
      return credentials.isValid();
    } catch (e) {
      return false;
    }
  }

  /// Clear all stored credentials
  static Future<void> clearCredentials() async {
    try {
      await _secureStorage.delete(key: '${_storageKeyPrefix}token_id');
      await _secureStorage.delete(key: '${_storageKeyPrefix}token_key');
      await _secureStorage.delete(key: '${_storageKeyPrefix}public_key_ca');
      await _secureStorage.delete(key: '${_storageKeyPrefix}access_token');
      print('[VnptCredentials] Cleared from secure storage');
    } catch (e) {
      throw VnptCredentialsException('Failed to clear credentials: $e');
    }
  }

  /// Update access token only (useful for token refresh)
  static Future<void> updateAccessToken(String newAccessToken) async {
    try {
      if (newAccessToken.isEmpty) {
        throw VnptCredentialsException('Access token cannot be empty');
      }

      await _secureStorage.write(
        key: '${_storageKeyPrefix}access_token',
        value: newAccessToken,
      );

      print('[VnptCredentials] Access token updated');
    } catch (e) {
      throw VnptCredentialsException('Failed to update access token: $e');
    }
  }
}

/// Custom exception for credentials errors
class VnptCredentialsException implements Exception {
  final String message;
  final String? details;

  VnptCredentialsException(this.message, [this.details]);

  @override
  String toString() => 'VnptCredentialsException: $message${details != null ? '\nDetails: $details' : ''}';
}
