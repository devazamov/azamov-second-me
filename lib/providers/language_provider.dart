/// ═══════════════════════════════════════════════════════════════
/// Language Provider - AZAMOV Academy
/// Multi-language UI support (UZ, EN, RU)
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported languages
class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final Locale locale;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.locale,
  });

  static const List<AppLanguage> supported = [
    AppLanguage(code: 'uz', name: 'Uzbek', nativeName: 'O\'zbek', locale: Locale('uz', 'UZ')),
    AppLanguage(code: 'en', name: 'English', nativeName: 'English', locale: Locale('en', 'US')),
    AppLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский', locale: Locale('ru', 'RU')),
  ];

  static AppLanguage fromCode(String code) {
    return supported.firstWhere(
      (l) => l.code == code,
      orElse: () => supported.first,
    );
  }
}

/// Language state
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('uz', 'UZ')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? 'uz';
    state = AppLanguage.fromCode(code).locale;
  }

  Future<void> setLocale(String code) async {
    final lang = AppLanguage.fromCode(code);
    state = lang.locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', code);
  }

  String get currentCode => state.languageCode;
}
