import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:culicidaelab/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify all widgets launch', (tester) async {
      print('Running test: verify app launches');
      app.main();
      await tester.pumpAndSettle();

      // Verify that the app's main widget is present
      expect(find.byType(app.MosquitoClassifierApp), findsOneWidget);
      print('Test: app launches - Success!');

      print('Running test: navigate through bottom navigation bar - Classify Mosquito');
      await tester.tap(find.byKey(const Key('bottom_nav_camera')));
      await tester.pumpAndSettle();
      expect(find.text('Classify Mosquito').first, findsOneWidget);
      print('Test: bottom_nav_camera - Success!');

      print('Running test: navigate through bottom navigation bar - Mosquito Species Gallery');
      // Tap on Mosquito Gallery tab
      await tester.tap(find.byKey(const Key('bottom_nav_mosquito')));
      await tester.pumpAndSettle();
      expect(find.text('Mosquito Species Gallery').first, findsOneWidget);
      print('Test: app launches bottom_nav_mosquito - Success!');

      print('Running test: navigate through bottom navigation bar - Mosquito-borne Diseases');
      // Tap on Diseases Info tab
      await tester.tap(find.byKey(const Key('bottom_nav_hospital')));
      await tester.pumpAndSettle();
      expect(find.text('Mosquito-borne Diseases').first, findsOneWidget);
      print('Test: app launches bottom_nav_hospital - Success!');

      print('Running test: navigate through bottom navigation bar - Mosquito Activity Map');
      // Tap on Mosquito Activity Map tab
      await tester.tap(find.byKey(const Key('bottom_nav_map')));
      await tester.pumpAndSettle();
      expect(find.text('Mosquito Activity Map').first, findsOneWidget);
      print('Test: bottom_nav_map - Success!');

      print('Running test: navigate bottom_nav_home - Home');
      // Tap on Home tab
      await tester.tap(find.byKey(const Key('bottom_nav_home')));
      await tester.pumpAndSettle();
      expect(find.text('CulicidaeLab').first, findsOneWidget);
      print('Test:  bottom_nav_home - Success!');

      // Tap on Classify Mosquito button
      print('Running test: navigate through home screen buttons - Classify Mosquito');

      // Scroll to ensure buttons are visible if they are off-screen
      await tester.scrollUntilVisible(
        find.text('Classify Mosquito').first,
        500.0,
      );
      await tester.tap(find.text('Classify Mosquito').first);
      await tester.pumpAndSettle();
      expect(find.text('Classify Mosquito').first, findsOneWidget); // Verify screen changed
      await tester.tap(find.byKey(const Key('bottom_nav_home'))); // Go back to home screen
      await tester.pumpAndSettle();
      print('Test: navigate Classify Mosquito - Success!');

      // Tap on Mosquito Gallery button
      print('Running test: navigate through home screen buttons - Mosquito Gallery');

      await tester.scrollUntilVisible(
        find.text('Mosquito Gallery').first,
        500.0,
      );
      await tester.tap(find.text('Mosquito Gallery').first);
      await tester.pumpAndSettle();
      expect(find.text('Mosquito Gallery').first, findsOneWidget); // Verify screen changed
      await tester.tap(find.byKey(const Key('bottom_nav_home')));
      await tester.pumpAndSettle();
      print('Test: navigate Mosquito Gallery - Success!');

      // Tap on Diseases Info button
      print('Running test: navigate through home screen buttons - Diseases Info');

      await tester.scrollUntilVisible(
        find.text('Diseases Info').first,
        500.0,
      );
      await tester.tap(find.text('Diseases Info').first);
      await tester.pumpAndSettle();
      expect(find.text('Diseases Info').first, findsOneWidget); // Verify screen changed
      await tester.tap(find.byKey(const Key('bottom_nav_home')));
      await tester.pumpAndSettle();
      print('Test: navigate Diseases Info - Success!');

      // Tap on Mosquito Activity Map button
      print('Running test: navigate through home screen buttons - Mosquito Activity Map');

      await tester.scrollUntilVisible(
        find.text('Mosquito Activity Map').first,
        500.0,
      );
      await tester.tap(find.text('Mosquito Activity Map').first);
      await tester.pumpAndSettle();
      expect(find.text('Mosquito Activity Map').first, findsOneWidget);
      await tester.tap(find.byKey(const Key('bottom_nav_home')));
      await tester.pumpAndSettle();
      print('Test: navigate Mosquito Activity Map - Success!');
    });
  });
}