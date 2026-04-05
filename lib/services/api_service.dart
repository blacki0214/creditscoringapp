import 'dart:convert';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

class ApiService {
  /// Reads the production API base URL from .env at runtime.
  /// Falls back to the stable production domain if env var is missing.
  static String get baseUrl =>
      dotenv.env['GCP_API_URL'] ?? 'https://swincredit.duckdns.org/api';
  
  // Singleton HTTP client to prevent memory leaks
  static final http.Client _sharedClient = http.Client();
  final http.Client? _client;

  // Network behavior based on APP_INTEGRATION_GUIDE_VI.
  static const Duration requestTimeout = Duration(seconds: 20);
  static const int maxRetries = 2;
  static const Duration baseRetryDelay = Duration(milliseconds: 300);

  ApiService({http.Client? client}) : _client = client;

  // Get the client to use (shared singleton or injected for testing)
  http.Client get _activeClient => _client ?? _sharedClient;

  /// Gets a fresh Firebase ID token for the current signed-in user.
  /// forceRefresh:true ensures stale tokens (> 1h) are renewed automatically.
  static Future<String> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated — please sign in first');
    final token = await user.getIdToken(true); // forceRefresh
    return 'Bearer $token';
  }

  Map<String, String> _buildJsonHeaders(String authToken) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': authToken,
    };

    final apiKey = dotenv.env['API_KEY']?.trim() ?? '';
    if (apiKey.isNotEmpty) {
      headers['X-API-Key'] = apiKey;
    }

    return headers;
  }

  Duration _retryBackoff(int attempt) {
    if (attempt <= 0) {
      return baseRetryDelay;
    }

    return Duration(milliseconds: baseRetryDelay.inMilliseconds * 3);
  }

  Future<bool> checkHealth() async {
    final healthUrl = Uri.parse('${baseUrl.replaceFirst('/api', '')}/api/health');
    final response = await _activeClient.get(healthUrl).timeout(requestTimeout);
    return response.statusCode == 200;
  }

  // ===== Two-Step API Flow (API v2.0) =====

  /// Step 1: Calculate credit score and loan limit
  Future<CalculateLimitResponse> calculateLimit(CalculateLimitRequest request) async {
    final url = Uri.parse('$baseUrl/calculate-limit');
    print('[ApiService] POST $url');
    print('[ApiService] Request: ${jsonEncode(request.toJson())}');
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          print('[ApiService] Retry attempt $attempt/$maxRetries');
        }
        
        final authToken = await _getAuthToken();
        final startTime = DateTime.now();
        
        final response = await _activeClient
            .post(
              url,
              headers: _buildJsonHeaders(authToken),
              body: jsonEncode(request.toJson()),
            )
            .timeout(requestTimeout);

        final duration = DateTime.now().difference(startTime);
        print('[ApiService] Response received in ${duration.inMilliseconds}ms, Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('[ApiService] Success: ${jsonEncode(data)}');
          return CalculateLimitResponse.fromJson(data);
        } else {
          print('[ApiService] Error response: ${response.body}');
          throw Exception('Failed to calculate limit: ${response.body}');
        }
      } on http.ClientException catch (e) {
        print('[ApiService] Network error: $e');
        // Network error - retry
        if (attempt < maxRetries - 1) {
          await Future.delayed(_retryBackoff(attempt));
          continue;
        }
        throw Exception('Network error after $maxRetries attempts: $e');
      } on TimeoutException catch (e) {
        print('[ApiService] Timeout after ${requestTimeout.inSeconds}s');
        // Timeout - retry
        if (attempt < maxRetries - 1) {
          await Future.delayed(_retryBackoff(attempt));
          continue;
        }
        throw Exception('Request timeout after $maxRetries attempts: $e');
      } catch (e) {
        print('[ApiService] Unexpected error: $e');
        // Other errors - don't retry
        throw Exception('Error calculating limit: $e');
      }
    }
    
    throw Exception('Failed to calculate limit after $maxRetries attempts');
  }

  /// Step 2: Calculate loan terms (interest rate, monthly payment, etc.)
  Future<CalculateTermsResponse> calculateTerms(CalculateTermsRequest request) async {
    final url = Uri.parse('$baseUrl/calculate-terms');
    print('[ApiService] POST $url');
    print('[ApiService] Request: ${jsonEncode(request.toJson())}');
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          print('[ApiService] Retry attempt $attempt/$maxRetries');
        }
        
        final authToken = await _getAuthToken();
        final startTime = DateTime.now();
        
        final response = await _activeClient
            .post(
              url,
              headers: _buildJsonHeaders(authToken),
              body: jsonEncode(request.toJson()),
            )
            .timeout(requestTimeout);

        final duration = DateTime.now().difference(startTime);
        print('[ApiService] Response received in ${duration.inMilliseconds}ms, Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('[ApiService] Success: ${jsonEncode(data)}');
          return CalculateTermsResponse.fromJson(data);
        } else {
          print('[ApiService] Error response: ${response.body}');
          throw Exception('Failed to calculate terms: ${response.body}');
        }
      } on http.ClientException catch (e) {
        print('[ApiService] Network error: $e');
        // Network error - retry
        if (attempt < maxRetries - 1) {
          await Future.delayed(_retryBackoff(attempt));
          continue;
        }
        throw Exception('Network error after $maxRetries attempts: $e');
      } on TimeoutException catch (e) {
        print('[ApiService] Timeout after ${requestTimeout.inSeconds}s');
        // Timeout - retry
        if (attempt < maxRetries - 1) {
          await Future.delayed(_retryBackoff(attempt));
          continue;
        }
        throw Exception('Request timeout after $maxRetries attempts: $e');
      } catch (e) {
        print('[ApiService] Unexpected error: $e');
        // Other errors - don't retry
        throw Exception('Error calculating terms: $e');
      }
    }
    
    throw Exception('Failed to calculate terms after $maxRetries attempts');
  }

  // ===== Legacy API (for backward compatibility) =====

  /// Legacy one-step loan application (still works but deprecated)
  Future<LoanOfferResponse> applyForLoan(SimpleLoanRequest request) async {
    final url = Uri.parse('$baseUrl/apply');
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final accessToken = dotenv.env['VNPT_ACCESS_TOKEN'] ?? '';
        final response = await _activeClient
            .post(
              url,
              headers: _buildJsonHeaders(accessToken),
              body: jsonEncode(request.toJson()),
            )
            .timeout(requestTimeout);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return LoanOfferResponse.fromJson(data);
        } else {
          throw Exception('Failed to apply for loan: ${response.body}');
        }
      } on http.ClientException catch (e) {
        // Network error - retry
        if (attempt < maxRetries - 1) {
          await Future.delayed(_retryBackoff(attempt));
          continue;
        }
        throw Exception('Network error after $maxRetries attempts: $e');
      } on TimeoutException catch (e) {
        // Timeout - retry
        if (attempt < maxRetries - 1) {
          await Future.delayed(_retryBackoff(attempt));
          continue;
        }
        throw Exception('Request timeout after $maxRetries attempts: $e');
      } catch (e) {
        // Other errors - don't retry
        throw Exception('Error applying for loan: $e');
      }
    }
    
    throw Exception('Failed to apply for loan after $maxRetries attempts');
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

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          print('[ApiService] Retry attempt $attempt/$maxRetries');
        }

        final authToken = await _getAuthToken();
        final startTime = DateTime.now();

        final response = await _activeClient
            .post(
              url,
              headers: _buildJsonHeaders(authToken),
              body: jsonEncode(request.toJson()),
            )
            .timeout(requestTimeout);

        final duration = DateTime.now().difference(startTime);
        print('[ApiService] Response received in ${duration.inMilliseconds}ms, Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('[ApiService] Success: ${jsonEncode(data)}');
          return BankAccountValidationResponse.fromJson(data);
        } else if (response.statusCode == 400) {
          // Bad request - don't retry
          final data = jsonDecode(response.body);
          final message = data['message'] ?? 'Invalid bank account information';
          print('[ApiService] Validation failed: $message');
          throw BankAccountValidationException(
            message,
            code: 'INVALID_ACCOUNT',
            originalError: response.body,
          );
        } else if (response.statusCode == 404) {
          // Account not found - don't retry
          final data = jsonDecode(response.body);
          final message = data['message'] ?? 'Bank account not found';
          print('[ApiService] Account not found: $message');
          throw BankAccountValidationException(
            message,
            code: 'ACCOUNT_NOT_FOUND',
            originalError: response.body,
          );
        } else {
          print('[ApiService] Error response: ${response.body}');
          // Server error - retry
          if (attempt < maxRetries - 1) {
            await Future.delayed(_retryBackoff(attempt));
            continue;
          }
          throw Exception('Failed to validate bank account: ${response.body}');
        }
      } on http.ClientException catch (e) {
        print('[ApiService] Network error: $e');
        // Network error - retry
        if (attempt < maxRetries - 1) {
          await Future.delayed(_retryBackoff(attempt));
          continue;
        }
        throw Exception('Network error after $maxRetries attempts: $e');
      } on TimeoutException catch (e) {
        print('[ApiService] Timeout after ${requestTimeout.inSeconds}s');
        // Timeout - retry
        if (attempt < maxRetries - 1) {
          await Future.delayed(_retryBackoff(attempt));
          continue;
        }
        throw Exception('Request timeout after $maxRetries attempts: $e');
      } on BankAccountValidationException {
        // Don't retry validation exceptions
        rethrow;
      } catch (e) {
        print('[ApiService] Unexpected error: $e');
        // Other errors - don't retry
        throw Exception('Error validating bank account: $e');
      }
    }

    throw Exception('Failed to validate bank account after $maxRetries attempts');
  }
}
