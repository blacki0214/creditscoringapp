import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'local_storage_service.dart';

class TestAccountService {
  static const String _defaultPrefillName = 'Test User';
  static const String _defaultPrefillPhone = '(+84) 900000000';
  static const String _defaultPrefillIdNumber = '000000000000';
  static const String _defaultPrefillAddress = 'Test Environment Address';

  static bool get isEnabled {
    final raw = dotenv.env['TEST_ENV_ENABLED']?.trim().toLowerCase() ?? 'false';
    return raw == 'true' || raw == '1' || raw == 'yes';
  }

  static Set<String> get testAccountEmails {
    final raw = dotenv.env['TEST_ACCOUNT_EMAILS'] ?? '';
    if (raw.trim().isEmpty) return <String>{};

    return raw
        .split(',')
        .map((email) => email.trim().toLowerCase())
        .where((email) => email.isNotEmpty)
        .toSet();
  }

  static bool isTestAccountEmail(String? email) {
    if (!isEnabled || email == null) return false;
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    return testAccountEmails.contains(normalized);
  }

  static Future<void> applyLoginMode(String? email) async {
    final shouldEnableTestMode = isTestAccountEmail(email);

    if (shouldEnableTestMode) {
      await LocalStorageService.setTestAccountMode(true);
      await LocalStorageService.markEkycCompleted();
      await LocalStorageService.saveEkycPrefill({
        'fullName': _defaultPrefillName,
        'phoneNumber': _defaultPrefillPhone,
        'idNumber': _defaultPrefillIdNumber,
        'address': _defaultPrefillAddress,
      });
      return;
    }

    final wasTestMode = LocalStorageService.isTestAccountMode();
    await LocalStorageService.clearTestAccountMode();

    // Ensure test bypass does not leak to normal users on shared devices.
    if (wasTestMode) {
      await LocalStorageService.clearEkycCompletion();
      await LocalStorageService.clearEkycPrefill();
    }
  }

  static Future<void> clearOnSignOut() async {
    final wasTestMode = LocalStorageService.isTestAccountMode();
    await LocalStorageService.clearTestAccountMode();

    if (wasTestMode) {
      await LocalStorageService.clearEkycCompletion();
      await LocalStorageService.clearEkycPrefill();
    }
  }
}
