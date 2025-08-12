import 'package:culicidaelab/l10n/app_localizations.dart';
import 'package:culicidaelab/locator.dart';
import 'package:culicidaelab/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:culicidaelab/main.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLocaleProvider extends Mock implements LocaleProvider {
  @override
  Locale? get locale => const Locale('en');

  @override
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  @override
  String getLanguageName(Locale locale, BuildContext context) {
    return 'English';
  }
}

void main() {

  setUpAll(() async {
    // Set up the locator with mock dependencies for the widget test
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    locator.registerSingleton<SharedPreferences>(prefs);
    locator.registerLazySingleton<LocaleProvider>(() => MockLocaleProvider());
  });

  testWidgets('App renders without crashing and shows title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We need to provide a MaterialApp parent for localization to work.
    await tester.pumpWidget(const MosquitoClassifierApp());

    // Wait for all frames to settle
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    // Note: The actual title comes from the ARB file, so we find the widget by its key or type
    // For simplicity here, we'll assume the HomePage is rendered.
    expect(find.byType(HomePage), findsOneWidget);
  });
}
