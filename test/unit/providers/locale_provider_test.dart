import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:culicidaelab/providers/locale_provider.dart';
import 'package:culicidaelab/locator.dart';

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

      localeProvider = LocaleProvider();
      await Future.delayed(Duration.zero); // allow async _loadLocale to complete

      // This test is tricky because the constructor calls an async method.
      // A better approach would be to have an init method.
      // Given the current implementation, we can't easily test the initial state before loading.
      // We will test the state after loading.


      expect(localeProvider.locale, const Locale('es'));
    });

    test('setLocale should persist the locale', () async {
      when(mockSharedPreferences.setString('selectedLanguageCode', 'ru'))
          .thenAnswer((_) async => true);

      await localeProvider.setLocale(const Locale('ru'));


      expect(prefs.getString('selectedLanguageCode'), 'ru');

      expect(localeProvider.locale, const Locale('ru'));
    });
  });
}
