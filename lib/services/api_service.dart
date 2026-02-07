import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SimpleLoanRequest {
  final String fullName;
  final int age;
  final double monthlyIncome;
  final String employmentStatus;
  final double yearsEmployed;
  final String homeOwnership;
  final String loanPurpose;
  final int yearsCreditHistory;
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
    this.yearsCreditHistory = 0,
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
  final String? loanTier;
  final String? tierReason;

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
    this.loanTier,
    this.tierReason,
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
      loanTier: json['loan_tier'] as String?,
      tierReason: json['tier_reason'] as String?,
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://credit-scoring-h7mv.onrender.com/api';
  
  // Singleton HTTP client to prevent memory leaks
  static final http.Client _sharedClient = http.Client();
  final http.Client? _client;

  // Timeout configuration (matching Python demo's timeout=5)
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  ApiService({http.Client? client}) : _client = client;

  // Get the client to use (shared singleton or injected for testing)
  http.Client get _activeClient => _client ?? _sharedClient;

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
        
        final accessToken = dotenv.env['VNPT_ACCESS_TOKEN'] ?? '';
        final startTime = DateTime.now();
        
        final response = await _activeClient
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': accessToken,
              },
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
          await Future.delayed(retryDelay);
          continue;
        }
        throw Exception('Network error after $maxRetries attempts: $e');
      } on TimeoutException catch (e) {
        print('[ApiService] Timeout after ${requestTimeout.inSeconds}s');
        // Timeout - retry
        if (attempt < maxRetries - 1) {
          await Future.delayed(retryDelay);
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
        
        final accessToken = dotenv.env['VNPT_ACCESS_TOKEN'] ?? '';
        final startTime = DateTime.now();
        
        final response = await _activeClient
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': accessToken,
              },
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
          await Future.delayed(retryDelay);
          continue;
        }
        throw Exception('Network error after $maxRetries attempts: $e');
      } on TimeoutException catch (e) {
        print('[ApiService] Timeout after ${requestTimeout.inSeconds}s');
        // Timeout - retry
        if (attempt < maxRetries - 1) {
          await Future.delayed(retryDelay);
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
              headers: {
                'Content-Type': 'application/json',
                'Authorization': accessToken,
              },
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
          await Future.delayed(retryDelay);
          continue;
        }
        throw Exception('Network error after $maxRetries attempts: $e');
      } on TimeoutException catch (e) {
        // Timeout - retry
        if (attempt < maxRetries - 1) {
          await Future.delayed(retryDelay);
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
}
