import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:culicidaelab/providers/locale_provider.dart';
import 'package:culicidaelab/locator.dart';

// Generate mock classes
@GenerateMocks([SharedPreferences])
import 'locale_provider_test.mocks.dart';

void main() {
  late LocaleProvider localeProvider;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    locator.registerSingleton<SharedPreferences>(mockSharedPreferences);
    localeProvider = LocaleProvider(prefs: locator());
  });

  tearDown(() {
    locator.unregister<SharedPreferences>();
  });

  group('LocaleProvider', () {
    test('initial locale is null and loads from prefs', () async {
      when(mockSharedPreferences.getString('selectedLanguageCode'))
          .thenReturn('es');

      await localeProvider.init();

      expect(localeProvider.locale, const Locale('es'));
    });

    test('setLocale should persist the locale', () async {
      when(mockSharedPreferences.setString('selectedLanguageCode', 'ru'))
          .thenAnswer((_) async => true);

      await localeProvider.setLocale(const Locale('ru'));

      verify(mockSharedPreferences.setString('selectedLanguageCode', 'ru'))
          .called(1);
      expect(localeProvider.locale, const Locale('ru'));
    });
  });
}
