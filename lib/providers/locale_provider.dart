import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:culicidaelab/l10n/app_localizations.dart'; // To access supportedLocales

/// A provider class that manages the application's locale settings.
///
/// This class extends [ChangeNotifier] to provide reactive locale state management
/// throughout the Flutter application. It handles locale persistence using
/// [SharedPreferences] and ensures only supported locales are applied.
///
/// The provider initializes with a saved locale preference or defaults to the
/// first supported locale. It provides methods to change the current locale
/// and retrieve human-readable language names.
///
/// Example usage:
/// ```dart
/// // In your widget:
/// Consumer<LocaleProvider>(
///   builder: (context, localeProvider, child) {
///     return Text('Current locale: ${localeProvider.locale}');
///   },
/// )
/// ```
class LocaleProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  Locale? _locale;
  static const String _selectedLanguageCodeKey = 'selectedLanguageCode';

  /// Creates a [LocaleProvider] instance with the given [SharedPreferences].
  ///
  /// The [prefs] parameter is required and should be a properly initialized
  /// SharedPreferences instance for locale persistence.
  LocaleProvider({required SharedPreferences prefs}) : _prefs = prefs;

  /// The currently selected locale for the application.
  ///
  /// Returns `null` if no locale has been initialized yet.
  /// Use [init()] to initialize the locale before accessing this property.
  Locale? get locale => _locale;

  /// List of supported locales from AppLocalizations.
  ///
  /// This getter provides access to all locales supported by the application
  /// as defined in the AppLocalizations class.
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  /// Initializes the locale provider by loading the saved locale preference.
  ///
  /// This method should be called early in the application lifecycle, typically
  /// in your main widget or app initialization code. It loads the previously
  /// selected language code from persistent storage and sets it as the current
  /// locale. If no preference exists, it defaults to the first supported locale.
  ///
  /// After initialization, it calls [notifyListeners()] to update any listening
  /// widgets with the new locale state.
  ///
  /// Example:
  /// ```dart
  /// Future<void> main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   final prefs = await SharedPreferences.getInstance();
  ///   final localeProvider = LocaleProvider(prefs: prefs);
  ///   await localeProvider.init();
  ///   runApp(MyApp(localeProvider: localeProvider));
  /// }
  /// ```
  Future<void> init() async {
    String? languageCode = _prefs.getString(_selectedLanguageCodeKey);

    if (languageCode != null) {
      _locale = Locale(languageCode);
    } else {
      // Default to the first supported locale (e.g., English) if no preference is saved

      if (supportedLocales.isNotEmpty) {
        _locale = supportedLocales.first;
      }
    }
    notifyListeners();
  }

  /// Sets a new locale for the application.
  ///
  /// The [newLocale] parameter specifies the locale to apply. Only locales
  /// that are in the [supportedLocales] list will be accepted. If an
  /// unsupported locale is provided, the method returns early without
  /// making any changes.
  ///
  /// If the new locale differs from the current one, it updates the internal
  /// state, persists the language code to SharedPreferences, and notifies
  /// all listeners about the change.
  ///
  /// Parameters:
  /// - [newLocale]: The locale to set for the application
  ///
  /// Example:
  /// ```dart
  /// // Set Spanish locale
  /// await localeProvider.setLocale(const Locale('es'));
  /// ```
  Future<void> setLocale(Locale newLocale) async {
    if (!supportedLocales.contains(newLocale)) {
      return;
    } // Only allow supported locales

    if (_locale != newLocale) {
      _locale = newLocale;
      await _prefs.setString(_selectedLanguageCodeKey, newLocale.languageCode);
      notifyListeners();
    }
  }

  /// Returns a human-readable name for the given locale.
  ///
  /// This method provides localized display names for supported locales.
  /// Currently returns hardcoded names for supported languages, but could
  /// be enhanced to use the AppLocalizations strings themselves if a
  /// proper dependency injection pattern is implemented.
  ///
  /// Parameters:
  /// - [locale]: The locale for which to get the display name
  /// - [context]: The build context (currently unused but reserved for future
  ///   enhancements that might use AppLocalizations for language names)
  ///
  /// Returns:
  /// A human-readable string representing the locale name, or the uppercase
  /// language code if the locale is not explicitly supported.
  ///
  /// Example:
  /// ```dart
  /// String name = localeProvider.getLanguageName(Locale('es'), context);
  /// print(name); // Outputs: "Español"
  /// ```
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
