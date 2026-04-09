import 'package:flutter/foundation.dart';
import 'dart:convert';

import '../services/api_service.dart';

class StudentLoanViewModel extends ChangeNotifier {
  StudentLoanViewModel({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

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
  String? apiMessage;
  String? decisionBand;
  bool? manualReview;
  double? defaultProbability;
  int? approvalThreshold;
  String? scoreModel;
  String? scoreRange;
  bool isCalculating = false;
  String? errorMessage;

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
    isCalculating = true;
    errorMessage = null;
    notifyListeners();

    try {
      final request = _buildStudentRequest();

      // Keep score-only step to align with the guide's student flow,
      // then request official limit from the second endpoint.
      final scoreResponse = await _apiService.calculateStudentCreditScore(request);
      final limitResponse = await _apiService.calculateStudentLimit(request);

      creditScore = limitResponse.creditScore > 0
          ? limitResponse.creditScore
          : scoreResponse.creditScore;
      loanLimitVnd = limitResponse.loanLimitVnd.round();
      approved = limitResponse.approved;
      riskLevel = limitResponse.riskLevel;
      apiMessage = limitResponse.message.isNotEmpty
          ? limitResponse.message
          : scoreResponse.message;
      decisionBand = limitResponse.decisionBand ?? scoreResponse.decisionBand;
      manualReview = limitResponse.manualReview ?? scoreResponse.manualReview;
      defaultProbability =
          limitResponse.defaultProbability ?? scoreResponse.defaultProbability;
      approvalThreshold =
          limitResponse.approvalThreshold ?? scoreResponse.approvalThreshold;
      scoreModel = limitResponse.scoreModel ?? scoreResponse.scoreModel;
      scoreRange = limitResponse.scoreRange ?? scoreResponse.scoreRange;
    } on ApiServiceException catch (e) {
      if (e.statusCode != null && e.statusCode! >= 500) {
        _refreshPreview();
        errorMessage = null;
        apiMessage =
            'Hệ thống chấm điểm đang tạm thời gián đoạn. Kết quả hiện tại là ước tính cục bộ, vui lòng thử lại sau để nhận kết quả chính thức.\nScoring service is temporarily unavailable. Current result is a local estimate; please retry later for official results.';
      } else {
        errorMessage = _userFriendlyError(e);
        _refreshPreview();
      }
    } catch (_) {
      errorMessage =
          'Kết nối tạm thời gián đoạn. Vui lòng thử lại.\nTemporary connection issue. Please try again.';
      _refreshPreview();
    } finally {
      isCalculating = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> toRequest() {
    return {
      'age': _estimateAge(),
      'gpa_latest': gpaLatest,
      'academic_year': academicYear,
      'major': _mapMajorToApi(major),
      'living_status': livingStatus,
      'program_level': programLevel,
      'has_buffer': hasBuffer,
      'monthly_income': monthlyIncome,
      'monthly_expenses': monthlyExpenses,
      'support_sources': supportSources.map(_mapSupportSourceToApi).toList(),
    };
  }

  StudentScoringRequest _buildStudentRequest() {
    return StudentScoringRequest(
      age: _estimateAge(),
      gpaLatest: gpaLatest,
      academicYear: academicYear,
      major: _mapMajorToApi(major),
      programLevel: programLevel,
      livingStatus: livingStatus,
      hasBuffer: hasBuffer,
      supportSources: supportSources.map(_mapSupportSourceToApi).toList(),
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenses,
    );
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

  int _estimateAge() {
    final estimated = 17 + academicYear;
    if (estimated < 18) return 18;
    if (estimated > 35) return 35;
    return estimated;
  }

  String _mapMajorToApi(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized.contains('data') || normalized.contains('technology')) {
      return 'technology';
    }
    if (normalized.contains('engineer')) {
      return 'engineering';
    }
    if (normalized.contains('finance')) {
      return 'finance';
    }
    if (normalized.contains('business') || normalized.contains('marketing')) {
      return 'business';
    }
    if (normalized.contains('medicine')) {
      return 'medicine';
    }
    if (normalized.contains('law')) {
      return 'law';
    }
    if (normalized.contains('education')) {
      return 'education';
    }
    return 'other';
  }

  String _mapSupportSourceToApi(String source) {
    switch (source) {
      case 'work':
        return 'part_time';
      default:
        return source;
    }
  }

  String _userFriendlyError(ApiServiceException error) {
    final code = error.statusCode;
    final backendReason = _extractBackendMessage(error.message);
    if (code == 401) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.\nYour session has expired. Please sign in again.';
    }
    if (code == 429) {
      return 'Bạn đang thao tác quá nhanh. Vui lòng thử lại sau ít phút.\nToo many requests. Please try again shortly.';
    }
    if (code == 403) {
      if (backendReason != null && backendReason.isNotEmpty) {
        return 'Không đủ quyền truy cập dịch vụ chấm điểm: $backendReason\nAccess denied by scoring service: $backendReason';
      }
      return 'Không đủ quyền truy cập dịch vụ chấm điểm. Vui lòng liên hệ hỗ trợ hoặc thử lại sau.\nAccess denied by scoring service. Please contact support or try again later.';
    }
    if (code != null && code >= 500) {
      return 'Hệ thống đang bận. Vui lòng thử lại sau.\nService is temporarily unavailable. Please try again.';
    }
    return 'Không thể xử lý hồ sơ sinh viên lúc này. Vui lòng kiểm tra thông tin và thử lại.\nUnable to process student application right now. Please review your data and retry.';
  }

  String? _extractBackendMessage(String raw) {
    if (raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final candidates = [
          decoded['message'],
          decoded['detail'],
          decoded['error'],
          decoded['code'],
        ];

        for (final candidate in candidates) {
          final text = candidate?.toString().trim();
          if (text != null && text.isNotEmpty) {
            return text;
          }
        }
      }
    } catch (_) {
      // Raw response is not JSON, fallback to plain text below.
    }

    final text = raw.trim();
    return text.isEmpty ? null : text;
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
