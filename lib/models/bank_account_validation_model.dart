/// Bank account validation request and response models
/// Used for validating bank accounts through external API service
library;

class BankAccountValidationRequest {
  final String bankCode;
  final String accountNumber;
  final String accountHolder;
  final String? branchCode;   // Optional branch code

  BankAccountValidationRequest({
    required this.bankCode,
    required this.accountNumber,
    required this.accountHolder,
    this.branchCode,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final json = {
      'bank_code': bankCode,
      'account_number': accountNumber,
      'account_holder': accountHolder,
    };
    
    if (branchCode != null) {
      json['branch_code'] = branchCode!;
    }
    
    return json;
  }

  @override
  String toString() => 'BankAccountValidationRequest($bankCode:$accountNumber)';
}

class BankAccountValidationResponse {
  final bool valid;
  final String accountHolderName;
  final String bankName;
  final String bankCode;
  final String status;          // 'active', 'inactive', 'closed', etc.
  final String message;
  final String? accountType;    // Optional: 'savings', 'checking', etc.
  final DateTime? validatedAt;

  BankAccountValidationResponse({
    required this.valid,
    required this.accountHolderName,
    required this.bankName,
    required this.bankCode,
    required this.status,
    required this.message,
    this.accountType,
    this.validatedAt,
  });

  /// Create from JSON API response
  factory BankAccountValidationResponse.fromJson(Map<String, dynamic> json) {
    return BankAccountValidationResponse(
      valid: json['valid'] as bool,
      accountHolderName: json['account_holder_name'] as String,
      bankName: json['bank_name'] as String,
      bankCode: json['bank_code'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      message: json['message'] as String,
      accountType: json['account_type'] as String?,
      validatedAt: json['validated_at'] != null 
          ? DateTime.parse(json['validated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'valid': valid,
    'account_holder_name': accountHolderName,
    'bank_name': bankName,
    'bank_code': bankCode,
    'status': status,
    'message': message,
    'account_type': accountType,
    'validated_at': validatedAt?.toIso8601String(),
  };

  @override
  String toString() => 'BankAccountValidationResponse(valid=$valid, status=$status)';
}

/// Exception for bank account validation errors
class BankAccountValidationException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  BankAccountValidationException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'BankAccountValidationException: $message${code != null ? ' ($code)' : ''}';
}
