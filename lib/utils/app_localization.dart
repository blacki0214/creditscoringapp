import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/language_viewmodel.dart';

extension AppLocalizationExtension on BuildContext {
  bool get isVietnamese {
    try {
      final vm = Provider.of<LanguageViewModel?>(this, listen: false);
      if (vm != null) {
        return vm.isVietnamese;
      }
    } catch (_) {}

    return Localizations.localeOf(this).languageCode == 'vi';
  }

  String t(String english, String vietnamese) {
    return isVietnamese ? vietnamese : english;
  }
}