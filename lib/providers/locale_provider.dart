import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('pt', 'BR')) {
    _carregarLocaleSalva();
  }

  Future<void> _carregarLocaleSalva() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('app_language');
    if (langCode == 'en') {
      state = const Locale('en', 'US');
    } else if (langCode == 'de') {
      state = const Locale('de', 'DE');
    } else if (langCode == 'it') {
      state = const Locale('it', 'IT');
    } else if (langCode == 'es') {
      state = const Locale('es', 'ES');
    } else if (langCode == 'fr') {
      state = const Locale('fr', 'FR');
    } else if (langCode == 'pt') {
      state = const Locale('pt', 'BR');
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    state = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', newLocale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
