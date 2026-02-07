import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:creditscoring/services/api_service.dart'; // Adjust path if needed

void main() {
  group('SimpleLoanRequest', () {
    test('toJson returns correct map', () {
      final request = SimpleLoanRequest(
        fullName: 'Test User',
        age: 30,
        monthlyIncome: 10000000,
        employmentStatus: 'EMPLOYED',
        yearsEmployed: 5,
        homeOwnership: 'RENT',
        // loanAmount removed
        loanPurpose: 'PERSONAL',
        yearsCreditHistory: 2,
        hasPreviousDefaults: false,
        currentlyDefaulting: false,
      );

      final json = request.toJson();

      expect(json['full_name'], 'Test User');
      expect(json['age'], 30);
      expect(json['monthly_income'], 10000000);
      expect(json['employment_status'], 'EMPLOYED');
      expect(json['years_employed'], 5);
      expect(json['home_ownership'], 'RENT');
      expect(json.containsKey('loan_amount'), false); // Verify removed
      expect(json['loan_purpose'], 'PERSONAL');
      expect(json['years_credit_history'], 2);
      expect(json['has_previous_defaults'], false);
      expect(json['currently_defaulting'], false);
    });
  });

  group('LoanOfferResponse', () {
    test('fromJson creates correct object', () {
      final json = {
        'approved': true,
        'loan_amount_vnd': 40000000,
        'requested_amount_vnd': 50000000,
        'max_amount_vnd': 60000000,
        'interest_rate': 12.5,
        'monthly_payment_vnd': 2000000,
        'loan_term_months': 24,
        'credit_score': 750,
        'risk_level': 'Low',
        'approval_message': 'Approved',
        'loan_tier': 'GOLD',
        'tier_reason': 'Good credit history'
      };

      final response = LoanOfferResponse.fromJson(json);

      expect(response.approved, true);
      expect(response.loanAmountVnd, 40000000);
      expect(response.maxAmountVnd, 60000000);
      expect(response.interestRate, 12.5);
      expect(response.monthlyPaymentVnd, 2000000);
      expect(response.loanTermMonths, 24);
      expect(response.creditScore, 750);
      expect(response.riskLevel, 'Low');
      expect(response.approvalMessage, 'Approved');
      expect(response.loanTier, 'GOLD');
      expect(response.tierReason, 'Good credit history');
    });
  });

  group('ApiService', () {
    test('applyForLoan returns LoanOfferResponse on success', () async {
      final mockResponse = {
        'approved': true,
        'loan_amount_vnd': 40000000,
        'requested_amount_vnd': 50000000,
        'max_amount_vnd': 60000000,
        'interest_rate': 12.5,
        'monthly_payment_vnd': 2000000,
        'loan_term_months': 24,
        'credit_score': 750,
        'risk_level': 'Low',
        'approval_message': 'Approved',
        'loan_tier': 'SILVER',
        'tier_reason': 'Ok'
      };

      final client = MockClient((request) async {
        if (request.url.toString() == 'https://credit-scoring-h7mv.onrender.com/api/apply' && 
            request.method == 'POST') {
          return http.Response(jsonEncode(mockResponse), 200);
        }
        return http.Response('Not Found', 404);
      });

      final service = ApiService(client: client);
      final request = SimpleLoanRequest(
        fullName: 'Test',
        age: 25,
        monthlyIncome: 1000,
        employmentStatus: 'EMPLOYED',
        yearsEmployed: 2,
        homeOwnership: 'RENT',
        // loanAmount removed
        loanPurpose: 'PERSONAL',
      );

      final result = await service.applyForLoan(request);

      expect(result.approved, true);
      expect(result.loanAmountVnd, 40000000);
      expect(result.loanTier, 'SILVER');
    });

    test('applyForLoan throws exception on error', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = ApiService(client: client);
      final request = SimpleLoanRequest(
        fullName: 'Test',
        age: 25,
        monthlyIncome: 1000,
        employmentStatus: 'EMPLOYED',
        yearsEmployed: 2,
        homeOwnership: 'RENT',
        // loanAmount removed
        loanPurpose: 'PERSONAL',
      );

      expect(service.applyForLoan(request), throwsException);
    });
  });
}
