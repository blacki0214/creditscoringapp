import 'package:flutter/foundation.dart';

class AppEnvironment {
  static const bool _bypassEkycStep1 = bool.fromEnvironment(
    'BYPASS_EKYC_STEP1',
    defaultValue: false,
  );

  static const bool _forceEnableEkyc = bool.fromEnvironment(
    'FORCE_ENABLE_EKYC',
    defaultValue: false,
  );

  static const bool _disableAutoCaptureIdCard = bool.fromEnvironment(
    'DISABLE_AUTO_CAPTURE_ID_CARD',
    defaultValue: false,
  );

  static bool get shouldBypassEkycStep1 {
    return kDebugMode && _bypassEkycStep1;
  }

  static bool get shouldForceEnableEkyc {
    return kDebugMode && _forceEnableEkyc;
  }

  static bool get shouldDisableAutoCaptureIdCard {
    return kDebugMode && _disableAutoCaptureIdCard;
  }

  static bool shouldSkipEkyc({
    required bool hasCompletedEkyc,
    required bool isTestAccountMode,
  }) {
    if (shouldForceEnableEkyc) {
      return false;
    }

    return hasCompletedEkyc || isTestAccountMode || shouldBypassEkycStep1;
  }
}