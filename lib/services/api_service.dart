import 'dart:convert';
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
  final double requestedAmountVnd;
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
    required this.requestedAmountVnd,
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
      // The API now implies requested amount is internal or irrelevant, 
      // but keeping it if returned or defaulting to 0 for stability
      requestedAmountVnd: 0.0, 
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
  final http.Client? _client;

  ApiService({http.Client? client}) : _client = client;

  Future<LoanOfferResponse> applyForLoan(SimpleLoanRequest request) async {
    final client = _client ?? http.Client();
    final url = Uri.parse('$baseUrl/apply');
    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
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
