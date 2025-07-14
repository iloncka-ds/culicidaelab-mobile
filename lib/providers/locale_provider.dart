import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:culicidaelab/l10n/app_localizations.dart'; // To access supportedLocales

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  static const String _selectedLanguageCodeKey = 'selectedLanguageCode';

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  // List of supported locales from AppLocalizations
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString(_selectedLanguageCodeKey);

    if (languageCode != null) {
      _locale = Locale(languageCode);
    } else {
      // Default to the first supported locale (e.g., English) if no preference is saved
      // Or, you could try to match the system locale if it's supported.
      // For simplicity, we'll default to the first one.
      if (supportedLocales.isNotEmpty) {
        _locale = supportedLocales.first;
      }
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    if (!supportedLocales.contains(newLocale))
      return; // Only allow supported locales

    if (_locale != newLocale) {
      _locale = newLocale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedLanguageCodeKey, newLocale.languageCode);
      notifyListeners();
    }
  }

  String getLanguageName(Locale locale, BuildContext context) {
    // You might want more sophisticated display names
    // For now, we'll use built-in names if possible, or language codes
    // This part would ideally use AppLocalizations itself for language names
    // but that creates a circular dependency if AppLocalizations needs LocaleProvider.
    // So, hardcoding for simplicity here or using a separate map.
    switch (locale.languageCode) {
      case 'en':
        return "English"; // Or AppLocalizations.of(context)!.languageEnglish if you set it up
      case 'es':
        return "Español"; // Or AppLocalizations.of(context)!.languageSpanish
      case 'ru':
        return "Русский"; // Or AppLocalizations.of(context)!.languageRussian
      default:
        return locale.languageCode.toUpperCase();
    }
  }
}
