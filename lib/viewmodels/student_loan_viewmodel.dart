import 'package:flutter/foundation.dart';

class StudentLoanViewModel extends ChangeNotifier {
  double gpaLatest = 2.8;
  int academicYear = 1;
  String major = 'Information Technology';
  String livingStatus = 'dormitory';
  String programLevel = 'undergraduate';

  int loanAmount = 5000000;
  bool hasBuffer = false;
  double monthlyIncome = 0.0;
  double monthlyExpenses = 2000000.0;
  final Set<String> supportSources = {'family'};

  int? creditScore;
  int? loanLimitVnd;
  bool? approved;
  String riskLevel = 'MEDIUM';

  static const List<String> majors = [
    'Information Technology',
    'Finance',
    'Marketing',
    'Data Science',
    'Logistics',
    'Business Administration',
    'Civil Engineering',
    'Electrical Engineering',
    'Medicine',
    'Law',
    'Tourism',
    'Education',
  ];

  void updateProfile({
    double? gpa,
    int? year,
    String? selectedMajor,
    String? selectedLivingStatus,
    String? selectedProgramLevel,
    int? selectedLoanAmount,
  }) {
    if (gpa != null) gpaLatest = gpa;
    if (year != null) academicYear = year;
    if (selectedMajor != null) major = selectedMajor;
    if (selectedLivingStatus != null) livingStatus = selectedLivingStatus;
    if (selectedProgramLevel != null) programLevel = selectedProgramLevel;
    if (selectedLoanAmount != null) loanAmount = selectedLoanAmount;

    _refreshPreview();
  }

  void updateFinancial({
    double? income,
    double? expenses,
    bool? buffer,
    Set<String>? sources,
  }) {
    if (income != null) monthlyIncome = income;
    if (expenses != null) monthlyExpenses = expenses;
    if (buffer != null) hasBuffer = buffer;
    if (sources != null) {
      supportSources
        ..clear()
        ..addAll(sources);
    }

    _refreshPreview();
  }

  int get previewScore => _computeScore();

  int get previewLoanLimit {
    final score = _computeScore();
    final rawLimit = _computeLimitForScore(score);
    return rawLimit > loanAmount ? loanAmount : rawLimit;
  }

  bool get suspiciousGpaForYear => gpaLatest > 3.8 && academicYear == 1;

  bool get suspiciousIncomeWithoutSupport =>
      monthlyIncome > 4000000 && supportSources.isEmpty;

  Future<void> calculateLimit() async {
    _refreshPreview();
  }

  Map<String, dynamic> toRequest() {
    return {
      'gpa_latest': gpaLatest,
      'academic_year': academicYear,
      'major_income_potential': major,
      'living_status': livingStatus,
      'program_level': programLevel,
      'loan_amount': loanAmount,
      'has_buffer': hasBuffer,
      'monthly_income': monthlyIncome,
      'monthly_expenses': monthlyExpenses,
      'support_sources': supportSources.toList(),
    };
  }

  void _refreshPreview() {
    final score = _computeScore();
    final limit = _computeLimitForScore(score);

    creditScore = score;
    loanLimitVnd = limit > loanAmount ? loanAmount : limit;
    riskLevel = _riskFromScore(score);
    approved = score >= 650;

    notifyListeners();
  }

  int _computeScore() {
    double score = 560;

    score += (gpaLatest * 45).clamp(0, 180);
    score += (academicYear * 8).clamp(8, 40);

    if (programLevel == 'graduate') {
      score += 20;
    }

    switch (livingStatus) {
      case 'with_parents':
        score += 25;
        break;
      case 'rent':
        score += 8;
        break;
      default:
        score += 12;
    }

    score += (monthlyIncome / 250000).clamp(0, 24);
    score -= (monthlyExpenses / 450000).clamp(0, 24);

    if (hasBuffer) score += 15;
    score += (supportSources.length * 6).clamp(0, 18);

    return score.clamp(300, 850).round();
  }

  int _computeLimitForScore(int score) {
    if (score < 650) {
      return 0;
    }
    if (score < 680) {
      return 5000000;
    }
    if (score < 720) {
      return 8000000;
    }
    return 10000000;
  }

  String _riskFromScore(int score) {
    if (score < 620) return 'VERY_HIGH';
    if (score < 680) return 'HIGH';
    if (score < 740) return 'MEDIUM';
    return 'LOW';
  }
}
