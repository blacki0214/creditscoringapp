/// Bank and BankBranch models for Vietnamese banking system
/// Supports bank selection and branch-specific operations
library;

class Bank {
  final String bankCode;      // e.g., 'ACB', 'BIDV', 'VCB'
  final String bankName;      // e.g., 'Asia Commercial Bank'
  final List<BankBranch> branches;
  final String? logoUrl;      // Optional bank logo

  Bank({
    required this.bankCode,
    required this.bankName,
    required this.branches,
    this.logoUrl,
  });

  /// Get branch by code
  BankBranch? getBranchByCode(String branchCode) {
    try {
      return branches.firstWhere((b) => b.branchCode == branchCode);
    } catch (e) {
      return null;
    }
  }

  /// Get all branch codes for this bank
  List<String> get allBranchCodes => branches.map((b) => b.branchCode).toList();

  /// Get all branch names for this bank
  List<String> get allBranchNames => branches.map((b) => b.branchName).toList();

  @override
  String toString() => 'Bank($bankCode: $bankName)';
}

class BankBranch {
  final String branchCode;    // e.g., 'ACB001', 'ACB002'
  final String branchName;    // e.g., 'HCM Main Branch'
  final String address;       // e.g., '250 Dong Khoi, Ho Chi Minh City'
  final String? city;         // Optional city
  final String? phone;        // Optional phone number

  BankBranch({
    required this.branchCode,
    required this.branchName,
    required this.address,
    this.city,
    this.phone,
  });

  @override
  String toString() => 'BankBranch($branchCode: $branchName)';
}
