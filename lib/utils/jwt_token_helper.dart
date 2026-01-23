import 'dart:convert';

/// JWT Token Helper for VNPT eKYC
/// 
/// Utilities to decode and validate JWT tokens from VNPT
class JwtTokenHelper {
  /// Decode JWT token and extract payload
  /// 
  /// JWT format: header.payload.signature
  /// All parts are base64url encoded
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      // Remove "bearer " prefix if present
      final cleanToken = token.toLowerCase().startsWith('bearer ')
          ? token.substring(7)
          : token;

      // Split the token
      final parts = cleanToken.split('.');
      if (parts.length != 3) {
        print('[JWT] Invalid token format: expected 3 parts, got ${parts.length}');
        return null;
      }

      // Decode the payload (second part)
      final payload = parts[1];
      
      // Fix padding for base64 decoding
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      print('[JWT] Error decoding token: $e');
      return null;
    }
  }

  /// Get token expiry time from JWT
  /// 
  /// Returns null if token is invalid or doesn't have 'exp' claim
  static DateTime? getExpiryTime(String token) {
    try {
      final payload = decodeToken(token);
      if (payload == null) return null;

      final exp = payload['exp'];
      if (exp == null) return null;

      // 'exp' is in seconds since epoch
      final expInt = exp is int ? exp : int.tryParse(exp.toString());
      if (expInt == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(expInt * 1000);
    } catch (e) {
      print('[JWT] Error getting expiry time: $e');
      return null;
    }
  }

  /// Check if token is expired
  static bool isExpired(String token) {
    final expiryTime = getExpiryTime(token);
    if (expiryTime == null) return true; // Consider invalid tokens as expired
    
    return DateTime.now().isAfter(expiryTime);
  }

  /// Check if token is expiring soon (within buffer duration)
  /// 
  /// Default buffer is 5 minutes
  static bool isExpiringSoon(String token, {Duration buffer = const Duration(minutes: 5)}) {
    final expiryTime = getExpiryTime(token);
    if (expiryTime == null) return true;
    
    final warningTime = expiryTime.subtract(buffer);
    return DateTime.now().isAfter(warningTime);
  }

  /// Get time until token expires
  /// 
  /// Returns null if token is invalid or already expired
  static Duration? getTimeUntilExpiry(String token) {
    final expiryTime = getExpiryTime(token);
    if (expiryTime == null) return null;
    
    final now = DateTime.now();
    if (now.isAfter(expiryTime)) return null; // Already expired
    
    return expiryTime.difference(now);
  }

  /// Get token subject (user)
  static String? getSubject(String token) {
    final payload = decodeToken(token);
    return payload?['sub'] as String?;
  }

  /// Get user email from token
  static String? getUserEmail(String token) {
    final payload = decodeToken(token);
    return payload?['user_name'] as String?;
  }

  /// Get formatted expiry info for logging/display
  static String getExpiryInfo(String token) {
    final expiryTime = getExpiryTime(token);
    if (expiryTime == null) {
      return 'Token is invalid or missing expiry';
    }

    if (isExpired(token)) {
      return 'Token expired at ${expiryTime.toLocal()}';
    }

    final timeUntil = getTimeUntilExpiry(token);
    if (timeUntil == null) {
      return 'Token is expired';
    }

    final hours = timeUntil.inHours;
    final minutes = timeUntil.inMinutes % 60;
    
    if (hours > 0) {
      return 'Token expires in ${hours}h ${minutes}m (${expiryTime.toLocal()})';
    } else {
      return 'Token expires in ${minutes}m (${expiryTime.toLocal()})';
    }
  }
}
