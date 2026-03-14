import 'package:flutter/foundation.dart';

class AppEnvironment {
  static const bool _bypassEkycStep1 = bool.fromEnvironment(
    'BYPASS_EKYC_STEP1',
    defaultValue: false,
  );

  static bool get shouldBypassEkycStep1 {
    return kDebugMode && _bypassEkycStep1;
  }

  static bool shouldSkipEkyc({
    required bool hasCompletedEkyc,
    required bool isTestAccountMode,
  }) {
    return hasCompletedEkyc || isTestAccountMode || shouldBypassEkycStep1;
  }
}