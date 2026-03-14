import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class LanguageViewModel extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isVietnamese => _locale.languageCode == 'vi';

  LanguageViewModel() {
    _loadLanguage();
  }

  void _loadLanguage() {
    try {
      final code = LocalStorageService.getAppLanguage();
      _locale = code == 'vi' ? const Locale('vi') : const Locale('en');
    } catch (_) {
      _locale = const Locale('en');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    final next = languageCode == 'vi' ? const Locale('vi') : const Locale('en');
    if (_locale == next) return;

    _locale = next;
    notifyListeners();
    await LocalStorageService.setAppLanguage(_locale.languageCode);
  }
}
