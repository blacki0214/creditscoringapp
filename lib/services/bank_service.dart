/// Bank Service - Manages bank data and branch information
/// Currently uses hardcoded Vietnamese bank list (Option A - MVP approach)
///
/// In future, this can be extended to:
/// - Fetch from API endpoint
/// - Load from Firestore
/// - Support real-time updates
library;

import 'package:creditscoring/models/bank_model.dart';

class BankService {
  static final BankService _instance = BankService._internal();

  factory BankService() => _instance;
  BankService._internal();

  /// Hardcoded list of major Vietnamese banks
  /// Source: Vietnamese banking system as of 2024
  static final List<Bank> _vietnameseBanks = [
    // ACB - Asia Commercial Bank
    Bank(
      bankCode: 'ACB',
      bankName: 'Asia Commercial Bank',
      branches: [
        BankBranch(
          branchCode: 'ACB001',
          branchName: 'HCM Main Branch',
          address: '250 Dong Khoi Street, District 1, Ho Chi Minh City',
          city: 'Ho Chi Minh City',
          phone: '(028) 3827 0888',
        ),
        BankBranch(
          branchCode: 'ACB002',
          branchName: 'Ha Noi Main Branch',
          address: '8 Phan Chu Trinh Street, Hoan Kiem District, Hanoi',
          city: 'Hanoi',
          phone: '(024) 3933 0933',
        ),
        BankBranch(
          branchCode: 'ACB003',
          branchName: 'Da Nang Branch',
          address: '89 Nguyen Hue Street, Da Nang',
          city: 'Da Nang',
        ),
      ],
    ),

    // BIDV - Bank For Investment and Development of Vietnam
    Bank(
      bankCode: 'BIDV',
      bankName: 'Bank For Investment and Development of Vietnam',
      branches: [
        BankBranch(
          branchCode: 'BIDV001',
          branchName: 'HCM Main Branch',
          address: '36 Ton That Dam Street, District 1, Ho Chi Minh City',
          city: 'Ho Chi Minh City',
          phone: '(028) 3824 5410',
        ),
        BankBranch(
          branchCode: 'BIDV002',
          branchName: 'Ha Noi Main Branch',
          address: '58 Ly Thai To Street, Hoan Kiem District, Hanoi',
          city: 'Hanoi',
          phone: '(024) 3943 5150',
        ),
        BankBranch(
          branchCode: 'BIDV003',
          branchName: 'Can Tho Branch',
          address: '1A Hoa Lu Street, Can Tho',
          city: 'Can Tho',
        ),
      ],
    ),

    // VCB - Vietcombank
    Bank(
      bankCode: 'VCB',
      bankName:
          'Vietcombank (Joint Stock Commercial Bank for Foreign Trade of Vietnam)',
      branches: [
        BankBranch(
          branchCode: 'VCB001',
          branchName: 'HCM Main Branch',
          address: '1 Me Linh Square, District 1, Ho Chi Minh City',
          city: 'Ho Chi Minh City',
          phone: '(028) 3520 0177',
        ),
        BankBranch(
          branchCode: 'VCB002',
          branchName: 'Ha Noi Main Branch',
          address: '198 Tran Quang Khai Street, Hoan Kiem District, Hanoi',
          city: 'Hanoi',
          phone: '(024) 3934 1234',
        ),
      ],
    ),

    // Techcombank - Techcombank Joint Stock Company
    Bank(
      bankCode: 'TCB',
      bankName: 'Techcombank',
      branches: [
        BankBranch(
          branchCode: 'TCB001',
          branchName: 'HCM Head Office',
          address: '191A Dong Khoi Street, District 1, Ho Chi Minh City',
          city: 'Ho Chi Minh City',
          phone: '(028) 3822 0000',
        ),
        BankBranch(
          branchCode: 'TCB002',
          branchName: 'Ha Noi Branch',
          address: '19 Ngo Quyen Street, Hoan Kiem District, Hanoi',
          city: 'Hanoi',
          phone: '(024) 3266 2828',
        ),
      ],
    ),

    // Sacombank - Saigon Commercial Bank
    Bank(
      bankCode: 'STB',
      bankName: 'Saigon Commercial Bank',
      branches: [
        BankBranch(
          branchCode: 'STB001',
          branchName: 'HCM Main Branch',
          address: '225 Dong Khoi Street, District 1, Ho Chi Minh City',
          city: 'Ho Chi Minh City',
          phone: '(028) 3824 1111',
        ),
        BankBranch(
          branchCode: 'STB002',
          branchName: 'Ha Noi Branch',
          address: '82 Ly Thuong Kiet Street, Hoan Kiem District, Hanoi',
          city: 'Hanoi',
          phone: '(024) 3825 8585',
        ),
      ],
    ),

    // MB - Ngan Hang MB (Military Commercial Bank)
    Bank(
      bankCode: 'MB',
      bankName: 'Ngan Hang MB (Military Commercial Bank)',
      branches: [
        BankBranch(
          branchCode: 'MB001',
          branchName: 'HCM Main Branch',
          address: '21 Nguyen Hue Street, District 1, Ho Chi Minh City',
          city: 'Ho Chi Minh City',
          phone: '(028) 3829 8866',
        ),
        BankBranch(
          branchCode: 'MB002',
          branchName: 'Ha Noi Main Branch',
          address: '5 Hang Dau Street, Hoan Kiem District, Hanoi',
          city: 'Hanoi',
          phone: '(024) 3936 3838',
        ),
      ],
    ),

    // VPBank - VPBank Joint Stock Commercial Bank
    Bank(
      bankCode: 'VPB',
      bankName: 'VPBank',
      branches: [
        BankBranch(
          branchCode: 'VPB001',
          branchName: 'HCM Head Office',
          address: '151 Vo Thi Sau Street, District 3, Ho Chi Minh City',
          city: 'Ho Chi Minh City',
          phone: '(028) 3933 5333',
        ),
        BankBranch(
          branchCode: 'VPB002',
          branchName: 'Ha Noi Branch',
          address: '9 Le Thanh Tong Street, Hoan Kiem District, Hanoi',
          city: 'Hanoi',
          phone: '(024) 3933 5555',
        ),
      ],
    ),

    // TPBank - TPBank Joint Stock Commercial Bank
    Bank(
      bankCode: 'TPB',
      bankName: 'TPBank',
      branches: [
        BankBranch(
          branchCode: 'TPB001',
          branchName: 'HCM Main Branch',
          address: '333 Pham Ngu Lao Street, District 1, Ho Chi Minh City',
          city: 'Ho Chi Minh City',
          phone: '(028) 3838 3838',
        ),
        BankBranch(
          branchCode: 'TPB002',
          branchName: 'Ha Noi Branch',
          address: '111 Ba Trieu Street, Hai Ba Trung District, Hanoi',
          city: 'Hanoi',
          phone: '(024) 3971 3971',
        ),
      ],
    ),

    // OCB - Orient Commercial Bank
    Bank(
      bankCode: 'OCB',
      bankName: 'Orient Commercial Bank',
      branches: [
        BankBranch(
          branchCode: 'OCB001',
          branchName: 'HCM Head Office',
          address: '8 Ngo Duc Ke Street, District 1, Ho Chi Minh City',
          city: 'Ho Chi Minh City',
          phone: '(028) 3821 5555',
        ),
        BankBranch(
          branchCode: 'OCB002',
          branchName: 'Ha Noi Branch',
          address: '6A Phan Boi Chau Street, Hoan Kiem District, Hanoi',
          city: 'Hanoi',
          phone: '(024) 3826 0000',
        ),
      ],
    ),

    // ABBank - An Binh Commercial Bank
    Bank(
      bankCode: 'ABB',
      bankName: 'An Binh Commercial Bank',
      branches: [
        BankBranch(
          branchCode: 'ABB001',
          branchName: 'HCM Main Branch',
          address: '51 Ly Tu Trong Street, District 1, Ho Chi Minh City',
          city: 'Ho Chi Minh City',
          phone: '(028) 3910 5959',
        ),
        BankBranch(
          branchCode: 'ABB002',
          branchName: 'Ha Noi Branch',
          address: '73 Ly Thai To Street, Hoan Kiem District, Hanoi',
          city: 'Hanoi',
          phone: '(024) 3943 6868',
        ),
      ],
    ),
  ];

  /// Test mode - Set to true to use local test accounts without API (change to false for production)
  static const bool TEST_MODE = true;

  /// Test bank accounts for development/testing
  /// Format: { bankCode: [ { accountNumber, accountHolderName }, ... ], ... }
  static final Map<String, List<Map<String, String>>> _testAccounts = {
    'ACB': [
      {'accountNumber': '26272829', 'accountHolderName': 'Nguyen Duy'},
      {'accountNumber': '12345678', 'accountHolderName': 'Test User ACB'},
      {'accountNumber': '87654321', 'accountHolderName': 'John Doe ACB'},
    ],
    'BIDV': [
      {'accountNumber': '11111111', 'accountHolderName': 'Test User BIDV'},
      {'accountNumber': '22222222', 'accountHolderName': 'Jane Smith BIDV'},
    ],
    'VCB': [
      {'accountNumber': '99999999', 'accountHolderName': 'Vietcombank Test'},
    ],
    'MB': [
      {'accountNumber': '33333333', 'accountHolderName': 'MB Bank User'},
    ],
    'TPB': [
      {'accountNumber': '44444444', 'accountHolderName': 'TPBank Customer'},
    ],
  };

  /// Validate bank account against test accounts (for development)
  bool validateTestAccount({
    required String bankCode,
    required String accountNumber,
    required String accountHolderName,
  }) {
    if (!TEST_MODE) return false;

    final normalizedBankCode = bankCode.trim().toUpperCase();
    final testAccounts = _testAccounts[normalizedBankCode];
    if (testAccounts == null) return false;

    final normalizedAccountNumber = accountNumber.replaceAll(RegExp(r'\D'), '');
    final normalizedHolder = accountHolderName.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    return testAccounts.any((account) {
      final storedNumber = (account['accountNumber'] ?? '').replaceAll(
        RegExp(r'\D'),
        '',
      );
      final storedHolder = (account['accountHolderName'] ?? '')
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');

      return storedNumber == normalizedAccountNumber &&
          storedHolder == normalizedHolder;
    });
  }

  /// Get test accounts for a bank (for UI display/debugging)
  List<Map<String, String>> getTestAccountsForBank(String bankCode) {
    if (!TEST_MODE) return [];
    return _testAccounts[bankCode] ?? [];
  }

  /// Get all banks
  List<Bank> getAllBanks() => _vietnameseBanks;

  /// Get bank by code
  Bank? getBankByCode(String bankCode) {
    try {
      return _vietnameseBanks.firstWhere((bank) => bank.bankCode == bankCode);
    } catch (e) {
      return null;
    }
  }

  /// Get all bank codes
  List<String> getAllBankCodes() =>
      _vietnameseBanks.map((b) => b.bankCode).toList();

  /// Get all bank names
  List<String> getAllBankNames() =>
      _vietnameseBanks.map((b) => b.bankName).toList();

  /// Get branches for a specific bank
  List<BankBranch> getBranchesByBankCode(String bankCode) {
    final bank = getBankByCode(bankCode);
    return bank?.branches ?? [];
  }

  /// Get branch details by bank code and branch code
  BankBranch? getBranchDetails(String bankCode, String branchCode) {
    final bank = getBankByCode(bankCode);
    if (bank == null) return null;
    return bank.getBranchByCode(branchCode);
  }

  /// Search banks by name (case-insensitive)
  List<Bank> searchBanks(String query) {
    final lowerQuery = query.toLowerCase();
    return _vietnameseBanks
        .where(
          (bank) =>
              bank.bankName.toLowerCase().contains(lowerQuery) ||
              bank.bankCode.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Search branches by name (case-insensitive, within a specific bank)
  List<BankBranch> searchBranches(String bankCode, String query) {
    final bank = getBankByCode(bankCode);
    if (bank == null) return [];

    final lowerQuery = query.toLowerCase();
    return bank.branches
        .where(
          (branch) =>
              branch.branchName.toLowerCase().contains(lowerQuery) ||
              branch.branchCode.toLowerCase().contains(lowerQuery) ||
              branch.address.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }
}
