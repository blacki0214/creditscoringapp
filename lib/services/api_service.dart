import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// ===== Two-Step API Flow Models (API v2.0) =====

/// Request model for Step 1: Calculate Limit
class CalculateLimitRequest {
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

  CalculateLimitRequest({
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
  final double interestRate;
  final int loanTermMonths;
  final double monthlyPaymentVnd;
  final double totalPaymentVnd;
  final double totalInterestVnd;

  CalculateTermsResponse({
    required this.interestRate,
    required this.loanTermMonths,
    required this.monthlyPaymentVnd,
    required this.totalPaymentVnd,
    required this.totalInterestVnd,
  });

  factory CalculateTermsResponse.fromJson(Map<String, dynamic> json) {
    return CalculateTermsResponse(
      interestRate: (json['interest_rate'] as num).toDouble(),
      loanTermMonths: json['loan_term_months'] as int,
      monthlyPaymentVnd: (json['monthly_payment_vnd'] as num).toDouble(),
      totalPaymentVnd: (json['total_payment_vnd'] as num).toDouble(),
      totalInterestVnd: (json['total_interest_vnd'] as num).toDouble(),
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
  static const String baseUrl = 'https://credit-scoring-h7mv.onrender.com/api';
  final http.Client? _client;

  ApiService({http.Client? client}) : _client = client;

  // ===== Two-Step API Flow (API v2.0) =====

  /// Step 1: Calculate credit score and loan limit
  Future<CalculateLimitResponse> calculateLimit(CalculateLimitRequest request) async {
    final client = _client ?? http.Client();
    final url = Uri.parse('$baseUrl/calculate-limit');
    try {
      final accessToken = dotenv.env['VNPT_ACCESS_TOKEN'] ?? '';
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CalculateLimitResponse.fromJson(data);
      } else {
        throw Exception('Failed to calculate limit: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error calculating limit: $e');
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  /// Step 2: Calculate loan terms (interest rate, monthly payment, etc.)
  Future<CalculateTermsResponse> calculateTerms(CalculateTermsRequest request) async {
    final client = _client ?? http.Client();
    final url = Uri.parse('$baseUrl/calculate-terms');
    try {
      final accessToken = dotenv.env['VNPT_ACCESS_TOKEN'] ?? '';
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CalculateTermsResponse.fromJson(data);
      } else {
        throw Exception('Failed to calculate terms: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error calculating terms: $e');
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  // ===== Legacy API (for backward compatibility) =====

  /// Legacy one-step loan application (still works but deprecated)
  Future<LoanOfferResponse> applyForLoan(SimpleLoanRequest request) async {
    final client = _client ?? http.Client();
    final url = Uri.parse('$baseUrl/apply');
    try {
      final accessToken = dotenv.env['VNPT_ACCESS_TOKEN'] ?? '';
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoanOfferResponse.fromJson(data);
      } else {
        throw Exception('Failed to apply for loan: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error applying for loan: $e');
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}
