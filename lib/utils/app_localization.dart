import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/language_viewmodel.dart';

final RegExp _mojibakePattern = RegExp(
  r'(Ã.|Â.|Ä.|Å.|Æ.|Ç.|Ð.|Ñ.|Ò.|Ó.|Ô.|Õ.|Ö.|Ø.|Ù.|Ú.|Û.|Ü.|Ý.|Þ.|ß.|áº|á»|á¼|á½|á¾|á¿|â.|�)',
);

String normalizeMojibakeText(String text) {
  if (text.isEmpty) return text;
  if (!_mojibakePattern.hasMatch(text)) return text;

  var best = text;
  var bestScore = _mojibakePattern.allMatches(text).length;
  var current = text;

  for (var i = 0; i < 2; i++) {
    String? repaired;
    try {
      repaired = utf8.decode(latin1.encode(current), allowMalformed: true);
    } catch (_) {
      repaired = null;
    }

    if (repaired == null || repaired == current) {
      break;
    }

    final repairedScore = _mojibakePattern.allMatches(repaired).length;
    if (repairedScore < bestScore) {
      best = repaired;
      bestScore = repairedScore;
    }

    current = repaired;
    if (bestScore == 0) {
      break;
    }
  }

  return best;
}

extension AppLocalizationExtension on BuildContext {
  bool get isVietnamese {
    try {
      return Localizations.localeOf(this).languageCode == 'vi';
    } catch (_) {}

    try {
      final vm = Provider.of<LanguageViewModel?>(this, listen: false);
      if (vm != null) {
        return vm.isVietnamese;
      }
    } catch (_) {}

    return false;
  }

  String t(String english, String vietnamese) {
    if (!isVietnamese) {
      return english;
    }

    final normalized = normalizeMojibakeText(vietnamese);
    // If text is still broken after repair, prefer readable English fallback.
    if (normalized.contains('�')) {
      return english;
    }
    return normalized;
  }
}