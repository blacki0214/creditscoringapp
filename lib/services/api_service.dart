import 'dart:convert';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/bank_account_validation_model.dart';

// ===== Two-Step API Flow Models (API v2.0) =====

/// Request model for Step 1: Calculate Limit
class CalculateLimitRequest {
  final String fullName;
  final int age;
  final double monthlyIncome;
  final String employmentStatus;
  final double yearsEmployed;
  final String homeOwnership;
  // loanPurpose kept for Firestore storage but NOT sent to API v2
  final String? loanPurpose;
  final double yearsCreditHistory;
  final bool hasPreviousDefaults;
  final bool currentlyDefaulting;

  CalculateLimitRequest({
    required this.fullName,
    required this.age,
    required this.monthlyIncome,
    required this.employmentStatus,
    required this.yearsEmployed,
    required this.homeOwnership,
    this.loanPurpose,
    this.yearsCreditHistory = 0,
    this.hasPreviousDefaults = false,
    this.currentlyDefaulting = false,
  });

  /// API v2: loan_purpose is NOT sent to /api/calculate-limit.
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'age': age,
      'monthly_income': monthlyIncome,
      'employment_status': employmentStatus,
      'years_employed': yearsEmployed,
      'home_ownership': homeOwnership,
      'years_credit_history': yearsCreditHistory,
      'has_previous_defaults': hasPreviousDefaults,
      'currently_defaulting': currentlyDefaulting,
    };
  }
}

/// Response model for Step 1: Calculate Limit
class CalculateLimitResponse {
  final int creditScore;
  final double loanLimitVnd;
  final String riskLevel;
  final bool approved;
  final String message;

  CalculateLimitResponse({
    required this.creditScore,
    required this.loanLimitVnd,
    required this.riskLevel,
    required this.approved,
    required this.message,
  });

  factory CalculateLimitResponse.fromJson(Map<String, dynamic> json) {
    return CalculateLimitResponse(
      creditScore: json['credit_score'] as int,
      loanLimitVnd: (json['loan_limit_vnd'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
      approved: json['approved'] as bool,
      message: json['message'] as String,
    );
  }
}

/// Request model for Step 2: Calculate Terms
class CalculateTermsRequest {
  final double loanAmount;
  final String loanPurpose;
  final int creditScore;

  CalculateTermsRequest({
    required this.loanAmount,
    required this.loanPurpose,
    required this.creditScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'loan_amount': loanAmount,
      'loan_purpose': loanPurpose,
      'credit_score': creditScore,
    };
  }
}

/// Response model for Step 2: Calculate Terms
class CalculateTermsResponse {
  final double loanAmountVnd;
  final String loanPurpose;
  final double interestRate;
  final int loanTermMonths;
  final double monthlyPaymentVnd;
  final double totalPaymentVnd;
  final double totalInterestVnd;
  final String rateExplanation;
  final String termExplanation;

  CalculateTermsResponse({
    required this.loanAmountVnd,
    required this.loanPurpose,
    required this.interestRate,
    required this.loanTermMonths,
    required this.monthlyPaymentVnd,
    required this.totalPaymentVnd,
    required this.totalInterestVnd,
    required this.rateExplanation,
    required this.termExplanation,
  });

  factory CalculateTermsResponse.fromJson(Map<String, dynamic> json) {
    return CalculateTermsResponse(
      loanAmountVnd: (json['loan_amount_vnd'] as num).toDouble(),
      loanPurpose: json['loan_purpose'] as String,
      interestRate: (json['interest_rate'] as num).toDouble(),
      loanTermMonths: json['loan_term_months'] as int,
      monthlyPaymentVnd: (json['monthly_payment_vnd'] as num).toDouble(),
      totalPaymentVnd: (json['total_payment_vnd'] as num).toDouble(),
      totalInterestVnd: (json['total_interest_vnd'] as num).toDouble(),
      rateExplanation: json['rate_explanation'] as String? ?? '',
      termExplanation: json['term_explanation'] as String? ?? '',
    );
  }
}

// ===== Legacy Models (for backward compatibility) =====

class SimpleLoanRequest {
  final String fullName;
  final int age;
  final double monthlyIncome;
  final String employmentStatus;
  final double yearsEmployed;
  final String homeOwnership;
  final String loanPurpose;
  final double yearsCreditHistory;
  final bool hasPreviousDefaults;
  final bool currentlyDefaulting;

  SimpleLoanRequest({
    required this.fullName,
    required this.age,
    required this.monthlyIncome,
    required this.employmentStatus,
    required this.yearsEmployed,
    required this.homeOwnership,
    required this.loanPurpose,
    this.yearsCreditHistory = 0.0,
    this.hasPreviousDefaults = false,
    this.currentlyDefaulting = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'age': age,
      'monthly_income': monthlyIncome,
      'employment_status': employmentStatus,
      'years_employed': yearsEmployed,
      'home_ownership': homeOwnership,
      'loan_purpose': loanPurpose,
      'years_credit_history': yearsCreditHistory,
      'has_previous_defaults': hasPreviousDefaults,
      'currently_defaulting': currentlyDefaulting,
    };
  }
}

class LoanOfferResponse {
  final bool approved;
  final double loanAmountVnd;
  final double maxAmountVnd;
  final double? interestRate;
  final double? monthlyPaymentVnd;
  final int? loanTermMonths;
  final int creditScore;
  final String riskLevel;
  final String approvalMessage;

  LoanOfferResponse({
    required this.approved,
    required this.loanAmountVnd,
    required this.maxAmountVnd,
    this.interestRate,
    this.monthlyPaymentVnd,
    this.loanTermMonths,
    required this.creditScore,
    required this.riskLevel,
    required this.approvalMessage,
  });

  factory LoanOfferResponse.fromJson(Map<String, dynamic> json) {
    return LoanOfferResponse(
      approved: json['approved'] as bool,
      loanAmountVnd: (json['loan_amount_vnd'] as num).toDouble(),
      maxAmountVnd: (json['max_amount_vnd'] as num).toDouble(),
      interestRate: json['interest_rate'] != null
          ? (json['interest_rate'] as num).toDouble()
          : null,
      monthlyPaymentVnd: json['monthly_payment_vnd'] != null
          ? (json['monthly_payment_vnd'] as num).toDouble()
          : null,
      loanTermMonths: json['loan_term_months'] as int?,
      creditScore: json['credit_score'] as int,
      riskLevel: json['risk_level'] as String,
      approvalMessage: json['approval_message'] as String,
    );
  }
}

class ApiServiceException implements Exception {
  final String message;
  final int? statusCode;
  final bool retryable;

  ApiServiceException(
    this.message, {
    this.statusCode,
    this.retryable = false,
  });

  @override
  String toString() {
    final code = statusCode == null ? '' : ' (status: $statusCode)';
    return 'ApiServiceException$code: $message';
  }
}

class ApiService {
  static const String _apiKeyStorageKey = 'api_key';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Reads the production API base URL from .env at runtime.
  /// Prefers the guide's `API_BASE_URL`, then falls back to `GCP_API_URL`.
  static String get baseUrl {
    final configuredUrl = dotenv.env['API_BASE_URL'] ?? dotenv.env['GCP_API_URL'];
    return _normalizeBaseUrl(
      configuredUrl ?? 'https://swincredit.duckdns.org/api',
    );
  }

  // Singleton HTTP client to prevent memory leaks
  static final http.Client _sharedClient = http.Client();
  final http.Client? _client;

  // Network behavior based on APP_INTEGRATION_GUIDE_VI.
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration requestTimeout = Duration(seconds: 20);
  static const int maxRetries = 2;
  static const Duration baseRetryDelay = Duration(milliseconds: 300);
  static const Set<int> _retryableStatusCodes = {429, 500, 502, 503, 504};
  static const Set<int> _nonRetryableStatusCodes = {400, 401, 403, 404, 422};

  ApiService({http.Client? client}) : _client = client;

  // Get the client to use (shared singleton or injected for testing)
  http.Client get _activeClient => _client ?? _sharedClient;

  static String _normalizeBaseUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Gets a fresh Firebase ID token for the current signed-in user.
  /// forceRefresh:true ensures stale tokens (> 1h) are renewed automatically.
  static Future<String> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null)
      throw Exception('User not authenticated — please sign in first');
    final token = await user.getIdToken(true); // forceRefresh
    return 'Bearer $token';
  }

  static Future<String?> _getApiKey() async {
    final secureKey = await _secureStorage.read(key: _apiKeyStorageKey);
    if (secureKey != null && secureKey.isNotEmpty) {
      return secureKey;
    }

    final envKey = dotenv.env['API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }

    return null;
  }

  static Future<void> saveApiKey(String apiKey) async {
    if (apiKey.trim().isEmpty) {
      throw ApiServiceException('API key cannot be empty');
    }

    await _secureStorage.write(key: _apiKeyStorageKey, value: apiKey.trim());
  }

  static Future<void> clearApiKey() async {
    await _secureStorage.delete(key: _apiKeyStorageKey);
  }

  Future<Map<String, String>> _buildHeaders({
    bool includeAuthToken = true,
    bool includeApiKey = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (includeAuthToken) {
      headers['Authorization'] = await _getAuthToken();
    }

    if (includeApiKey) {
      final apiKey = await _getApiKey();
      if (apiKey != null && apiKey.isNotEmpty) {
        headers['X-API-Key'] = apiKey;
      }
    }

    return headers;
  }

  static Duration _retryBackoff(int attempt) {
    return attempt == 0
        ? baseRetryDelay
        : Duration(milliseconds: baseRetryDelay.inMilliseconds * 3);
  }

  static bool _isRetryableStatusCode(int statusCode) {
    return _retryableStatusCodes.contains(statusCode) ||
        (statusCode >= 500 && statusCode < 600);
  }

  Future<http.Response> _postJsonWithRetry(
    Uri url,
    Map<String, dynamic> body, {
    required bool includeAuthToken,
    required bool includeApiKey,
    required String operationName,
    Map<String, String>? extraHeaders,
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          print('[ApiService] Retry attempt $attempt/$maxRetries for $operationName');
        }

        final startTime = DateTime.now();
        final response = await _activeClient
            .post(
              url,
              headers: {
                ...await _buildHeaders(
                includeAuthToken: includeAuthToken,
                includeApiKey: includeApiKey,
              ),
                ...?extraHeaders,
              },
              body: jsonEncode(body),
            )
            .timeout(requestTimeout);

        final duration = DateTime.now().difference(startTime);
        print(
          '[ApiService] $operationName completed in ${duration.inMilliseconds}ms, status: ${response.statusCode}',
        );

        if (response.statusCode == 200) {
          return response;
        }

        if (_nonRetryableStatusCodes.contains(response.statusCode)) {
          throw ApiServiceException(
            response.body.isNotEmpty
                ? response.body
                : 'Request failed with status ${response.statusCode}',
            statusCode: response.statusCode,
          );
        }

        if (attempt < maxRetries - 1 && _isRetryableStatusCode(response.statusCode)) {
          print('[ApiService] Retryable status ${response.statusCode} from $operationName');
          await Future.delayed(_retryBackoff(attempt));
          continue;
        }

        throw ApiServiceException(
          response.body.isNotEmpty
              ? response.body
              : 'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
          retryable: _isRetryableStatusCode(response.statusCode),
        );
      } on http.ClientException catch (e) {
        print('[ApiService] Network error during $operationName: $e');
        if (attempt < maxRetries - 1) {
          await Future.delayed(_retryBackoff(attempt));
          continue;
        }
        throw ApiServiceException(
          'Network error after $maxRetries attempts: $e',
          retryable: true,
        );
      } on TimeoutException catch (e) {
        print('[ApiService] Timeout during $operationName after ${requestTimeout.inSeconds}s');
        if (attempt < maxRetries - 1) {
          await Future.delayed(_retryBackoff(attempt));
          continue;
        }
        throw ApiServiceException(
          'Request timeout after $maxRetries attempts: $e',
          retryable: true,
        );
      }
    }

    throw ApiServiceException('Failed to complete $operationName after $maxRetries attempts');
  }

  Future<http.Response> _getWithRetry(
    Uri url, {
    required bool includeAuthToken,
    required bool includeApiKey,
    required String operationName,
    Duration? timeout,
  }) async {
    final effectiveTimeout = timeout ?? requestTimeout;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          print('[ApiService] Retry attempt $attempt/$maxRetries for $operationName');
        }

        final startTime = DateTime.now();
        final response = await _activeClient
            .get(
              url,
              headers: await _buildHeaders(
                includeAuthToken: includeAuthToken,
                includeApiKey: includeApiKey,
              ),
            )
            .timeout(effectiveTimeout);

        final duration = DateTime.now().difference(startTime);
        print(
          '[ApiService] $operationName completed in ${duration.inMilliseconds}ms, status: ${response.statusCode}',
        );

        if (response.statusCode == 200) {
          return response;
        }

        if (_nonRetryableStatusCodes.contains(response.statusCode)) {
          throw ApiServiceException(
            response.body.isNotEmpty
                ? response.body
                : 'Request failed with status ${response.statusCode}',
            statusCode: response.statusCode,
          );
        }

        if (attempt < maxRetries - 1 && _isRetryableStatusCode(response.statusCode)) {
          print('[ApiService] Retryable status ${response.statusCode} from $operationName');
          await Future.delayed(_retryBackoff(attempt));
          continue;
        }

        throw ApiServiceException(
          response.body.isNotEmpty
              ? response.body
              : 'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
          retryable: _isRetryableStatusCode(response.statusCode),
        );
      } on http.ClientException catch (e) {
        print('[ApiService] Network error during $operationName: $e');
        if (attempt < maxRetries - 1) {
          await Future.delayed(_retryBackoff(attempt));
          continue;
        }
        throw ApiServiceException(
          'Network error after $maxRetries attempts: $e',
          retryable: true,
        );
      } on TimeoutException catch (e) {
        print('[ApiService] Timeout during $operationName after ${effectiveTimeout.inSeconds}s');
        if (attempt < maxRetries - 1) {
          await Future.delayed(_retryBackoff(attempt));
          continue;
        }
        throw ApiServiceException(
          'Request timeout after $maxRetries attempts: $e',
          retryable: true,
        );
      }
    }

    throw ApiServiceException('Failed to complete $operationName after $maxRetries attempts');
  }

  /// Performs a lightweight health check before app flows that submit data.
  Future<bool> checkHealth() async {
    final url = Uri.parse('$baseUrl/health');
    print('[ApiService] GET $url');

    try {
      final response = await _getWithRetry(
        url,
        includeAuthToken: false,
        includeApiKey: true,
        operationName: 'health-check',
        timeout: connectTimeout,
      );

      return response.statusCode == 200;
    } on ApiServiceException catch (e) {
      print('[ApiService] Health check failed: $e');
      return false;
    } catch (e) {
      print('[ApiService] Health check unexpected error: $e');
      return false;
    }
  }

  // ===== Two-Step API Flow (API v2.0) =====

  /// Step 1: Calculate credit score and loan limit
  Future<CalculateLimitResponse> calculateLimit(
    CalculateLimitRequest request,
  ) async {
    final url = Uri.parse('$baseUrl/calculate-limit');
    print('[ApiService] POST $url');
    print('[ApiService] Request: ${jsonEncode(request.toJson())}');

    try {
      final response = await _postJsonWithRetry(
        url,
        request.toJson(),
        includeAuthToken: true,
        includeApiKey: true,
        operationName: 'calculate-limit',
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      print('[ApiService] Success: ${jsonEncode(data)}');
      return CalculateLimitResponse.fromJson(data);
    } on ApiServiceException catch (e) {
      throw ApiServiceException(
        'Error calculating limit: ${e.message}',
        statusCode: e.statusCode,
        retryable: e.retryable,
      );
    } catch (e) {
      print('[ApiService] Unexpected error: $e');
      throw ApiServiceException('Error calculating limit: $e');
    }
  }

  /// Step 2: Calculate loan terms (interest rate, monthly payment, etc.)
  Future<CalculateTermsResponse> calculateTerms(
    CalculateTermsRequest request,
  ) async {
    final url = Uri.parse('$baseUrl/calculate-terms');
    print('[ApiService] POST $url');
    print('[ApiService] Request: ${jsonEncode(request.toJson())}');

    try {
      final response = await _postJsonWithRetry(
        url,
        request.toJson(),
        includeAuthToken: true,
        includeApiKey: true,
        operationName: 'calculate-terms',
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      print('[ApiService] Success: ${jsonEncode(data)}');
      return CalculateTermsResponse.fromJson(data);
    } on ApiServiceException catch (e) {
      throw ApiServiceException(
        'Error calculating terms: ${e.message}',
        statusCode: e.statusCode,
        retryable: e.retryable,
      );
    } catch (e) {
      print('[ApiService] Unexpected error: $e');
      throw ApiServiceException('Error calculating terms: $e');
    }
  }

  // ===== Legacy API (for backward compatibility) =====

  /// Legacy one-step loan application (still works but deprecated)
  Future<LoanOfferResponse> applyForLoan(SimpleLoanRequest request) async {
    final url = Uri.parse('$baseUrl/apply');

    try {
      final accessToken = dotenv.env['VNPT_ACCESS_TOKEN'] ?? '';
      final extraHeaders = accessToken.isNotEmpty
          ? {'Authorization': accessToken}
          : null;
      final response = await _postJsonWithRetry(
        url,
        request.toJson(),
        includeAuthToken: false,
        includeApiKey: false,
        operationName: 'apply-for-loan',
        extraHeaders: extraHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return LoanOfferResponse.fromJson(data);
      }

      throw ApiServiceException(
        'Failed to apply for loan: ${response.body}',
        statusCode: response.statusCode,
      );
    } catch (e) {
      throw Exception('Error applying for loan: $e');
    }
  }

  // ===== Bank Account Validation (Step 6) =====

  /// Validate bank account through external service
  ///
  /// This endpoint verifies that the provided bank account details are valid
  /// and that the account holder name matches.
  Future<BankAccountValidationResponse> validateBankAccount(
    BankAccountValidationRequest request,
  ) async {
    const endpoint = '/validate-bank-account';
    final url = Uri.parse('$baseUrl$endpoint');
    print('[ApiService] POST $url');
    print('[ApiService] Request: ${jsonEncode(request.toJson())}');

    try {
      final response = await _postJsonWithRetry(
        url,
        request.toJson(),
        includeAuthToken: true,
        includeApiKey: true,
        operationName: 'validate-bank-account',
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      print('[ApiService] Success: ${jsonEncode(data)}');
      return BankAccountValidationResponse.fromJson(data);
    } on ApiServiceException catch (e) {
      if (e.statusCode == 400) {
        final data = e.message.isNotEmpty ? _tryDecodeJsonMap(e.message) : null;
        final message = data?['message'] as String? ?? 'Invalid bank account information';
        print('[ApiService] Validation failed: $message');
        throw BankAccountValidationException(
          message,
          code: 'INVALID_ACCOUNT',
          originalError: e.message,
        );
      }

      if (e.statusCode == 404) {
        final data = e.message.isNotEmpty ? _tryDecodeJsonMap(e.message) : null;
        final message = data?['message'] as String? ?? 'Bank account not found';
        print('[ApiService] Account not found: $message');
        throw BankAccountValidationException(
          message,
          code: 'ACCOUNT_NOT_FOUND',
          originalError: e.message,
        );
      }

      throw Exception('Failed to validate bank account: ${e.message}');
    } catch (e) {
      print('[ApiService] Unexpected error: $e');
      throw Exception('Error validating bank account: $e');
    }
  }

  static Map<String, dynamic>? _tryDecodeJsonMap(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
