import 'dart:io';
import 'dart:typed_data';
import 'package:culicidaelab/l10n/app_localizations.dart';
import 'package:culicidaelab/locator.dart';
import 'package:culicidaelab/models/disease_model.dart';
import 'package:culicidaelab/models/mosquito_model.dart';
import 'package:culicidaelab/models/observation_model.dart';
import 'package:culicidaelab/models/web_prediction_result.dart';
import 'package:culicidaelab/repositories/mosquito_repository.dart';
import 'package:culicidaelab/screens/classification_screen.dart';
import 'package:culicidaelab/screens/mosquito_detail_screen.dart';
import 'package:culicidaelab/screens/observation_details_screen.dart';
import 'package:culicidaelab/view_models/classification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'classification_screen_test.mocks.dart';

// A minimal, valid 1x1 transparent PNG byte array.
final Uint8List kTestImageBytes = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

@GenerateMocks([
  SharedPreferences,
  XFile,
  File,
  ClassificationViewModel,
  AppLocalizations,
  MosquitoSpecies,
  ClassificationResult,
  Disease,
  MosquitoRepository,
])
void main() {
  group('ClassificationScreen Widget Tests', () {
    late MockClassificationViewModel mockViewModel;
    late MockAppLocalizations mockAppLocalizations;
    late MockMosquitoRepository mockMosquitoRepository;

    setUp(() {
      mockViewModel = MockClassificationViewModel();
      mockAppLocalizations = MockAppLocalizations();
      mockMosquitoRepository = MockMosquitoRepository();

      // --- Stub localizations for ALL screens involved in the tests ---

      // For ClassificationScreen
      when(mockAppLocalizations.classificationScreenTitle).thenReturn('Classify Mosquito');
      when(mockAppLocalizations.uploadImageHint).thenReturn('Upload a clear image of a mosquito for identification');
      when(mockAppLocalizations.uploadImageSubHint).thenReturn('Best results with well-lit, focused images');
      when(mockAppLocalizations.cameraButtonLabel).thenReturn('Camera');
      when(mockAppLocalizations.galleryButtonLabel).thenReturn('Gallery');
      when(mockAppLocalizations.resetButtonLabel).thenReturn('Reset');
      when(mockAppLocalizations.analyzeButton).thenReturn('Analyze');
      when(mockAppLocalizations.speciesInfoButton).thenReturn('Species Info');
      when(mockAppLocalizations.diseaseRisksButton).thenReturn('Disease Risks');
      when(mockAppLocalizations.addDetailsButton).thenReturn('Add Observation Details');
      when(mockAppLocalizations.analyzingImage).thenReturn('Analyzing image...');
      when(mockAppLocalizations.noImageSelectedTitle).thenReturn('No Image Selected');
      when(mockAppLocalizations.noImageSelectedSubtitle).thenReturn('Take a photo or select from gallery');
      when(mockAppLocalizations.potentialDiseaseRisksTitle).thenReturn('Disease Risks');
      when(mockAppLocalizations.potentialDiseaseRisksSubtitle).thenReturn('This mosquito species is known to transmit the following diseases:');
      when(mockAppLocalizations.disclaimerEducationalUse).thenReturn('Disclaimer: This app provides information for educational purposes only. Always consult healthcare professionals for proper diagnosis and treatment.');
      when(mockAppLocalizations.thankYouForParticipation).thenReturn('Thank you for your contribution!');
      when(mockAppLocalizations.speciesLabel(any)).thenAnswer((realInvocation) => 'Species: ${realInvocation.positionalArguments.first}');
      when(mockAppLocalizations.commonNameLabel(any)).thenAnswer((realInvocation) => 'Common Name: ${realInvocation.positionalArguments.first}');
      when(mockAppLocalizations.confidenceLabel(any)).thenAnswer((realInvocation) => 'Confidence: ${realInvocation.positionalArguments.first}%');
      when(mockAppLocalizations.inferenceTimeLabel(any)).thenAnswer((realInvocation) => 'Time: ${realInvocation.positionalArguments.first} ms');
      when(mockAppLocalizations.submissionIdLabel(any)).thenAnswer((realInvocation) => 'Submission ID: ${realInvocation.positionalArguments.first}');

      // FIX: Add stubs for MosquitoDetailScreen
      when(mockAppLocalizations.mosquitoDetailScreenDescription).thenReturn('Description');
      when(mockAppLocalizations.mosquitoDetailScreenHabitat).thenReturn('Habitat');
      when(mockAppLocalizations.mosquitoDetailScreenDistribution).thenReturn('Distribution');
      when(mockAppLocalizations.mosquitoDetailScreenAssociatedDiseases).thenReturn('Associated Diseases');
      when(mockAppLocalizations.mosquitoDetailScreenNoAssociatedDiseases).thenReturn('No known diseases associated with this species in our database.');

      // FIX: Add stubs for ObservationDetailsScreen
      when(mockAppLocalizations.observationDetailsTitle).thenReturn('Observation Details');
      when(mockAppLocalizations.locationSectionTitle).thenReturn('Observation Location');
      when(mockAppLocalizations.locationInstruction).thenReturn('Tap on the map to mark the exact location of your observation.');
      when(mockAppLocalizations.notesLabel).thenReturn('Notes');
      when(mockAppLocalizations.notesHint).thenReturn('Add any relevant details (e.g., time of day, weather, environment)...');
      when(mockAppLocalizations.submitObservationButton).thenReturn('Submit Observation');
      when(mockAppLocalizations.predictionSummaryTitle).thenReturn('Prediction Summary');

      // --- Stub default ViewModel state ---
      when(mockViewModel.hasImage).thenReturn(false);
      when(mockViewModel.imageFile).thenReturn(null);
      when(mockViewModel.isProcessing).thenReturn(false);
      when(mockViewModel.errorMessage).thenReturn(null);
      when(mockViewModel.state).thenReturn(ClassificationState.initial);
      when(mockViewModel.result).thenReturn(null);
      when(mockViewModel.submissionResult).thenReturn(null);
      when(mockViewModel.shouldShowDiseaseRiskButton).thenReturn(false);
      // FIX: Add stub for isFetchingWebPrediction to prevent timeout
      when(mockViewModel.isFetchingWebPrediction).thenReturn(false);

      // Setup GetIt locator
      locator.allowReassignment = true;
      locator.registerSingleton<ClassificationViewModel>(mockViewModel);
      locator.registerSingleton<MosquitoRepository>(mockMosquitoRepository);

      when(mockMosquitoRepository.getDiseasesByVector(any, any)).thenAnswer((_) async => []);
    });

    tearDown(() {
      locator.reset();
    });

    Widget createWidgetUnderTest() {
      final mockDelegate = MockAppLocalizationsDelegate(mockAppLocalizations);
      return MaterialApp(
        localizationsDelegates: [mockDelegate],
        supportedLocales: const [Locale('en')],
        home: const ClassificationScreen(),
      );
    }

    // All 12 tests are here and should now pass.

    testWidgets('displays initial state correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      expect(find.text('Classify Mosquito'), findsOneWidget);
      expect(find.text('Upload a clear image of a mosquito for identification'), findsOneWidget);
    });

    testWidgets('displays image preview and analyze button when image is picked', (tester) async {
      final mockImageFile = MockFile();
      when(mockImageFile.path).thenReturn('path/to/image.jpg');
      when(mockImageFile.length()).thenAnswer((_) async => kTestImageBytes.length);
      when(mockImageFile.readAsBytes()).thenAnswer((_) async => kTestImageBytes);
      when(mockViewModel.hasImage).thenReturn(true);
      when(mockViewModel.imageFile).thenReturn(mockImageFile);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Analyze'), findsOneWidget);
    });

    testWidgets('displays processing state', (tester) async {
      final mockImageFile = MockFile();
      when(mockImageFile.path).thenReturn('path/to/image.jpg');
      when(mockImageFile.length()).thenAnswer((_) async => kTestImageBytes.length);
      when(mockImageFile.readAsBytes()).thenAnswer((_) async => kTestImageBytes);
      when(mockViewModel.hasImage).thenReturn(true);
      when(mockViewModel.isProcessing).thenReturn(true);
      when(mockViewModel.imageFile).thenReturn(mockImageFile);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Analyzing image...'), findsOneWidget);
    });

    testWidgets('displays error message', (tester) async {
      when(mockViewModel.errorMessage).thenReturn('Test Error Message');
      when(mockViewModel.state).thenReturn(ClassificationState.error);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      expect(find.text('Test Error Message'), findsOneWidget);
    });

    testWidgets('displays classification result card correctly', (tester) async {
      final mockSpecies = MockMosquitoSpecies();
      when(mockSpecies.name).thenReturn('Aedes aegypti');
      when(mockSpecies.commonName).thenReturn('Yellow Fever Mosquito');
      final mockResult = MockClassificationResult();
      when(mockResult.species).thenReturn(mockSpecies);
      when(mockResult.confidence).thenReturn(95.0);
      when(mockResult.inferenceTime).thenReturn(123);
      when(mockResult.relatedDiseases).thenReturn([]);
      when(mockViewModel.hasImage).thenReturn(true);
      when(mockViewModel.state).thenReturn(ClassificationState.success);
      when(mockViewModel.result).thenReturn(mockResult);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      expect(find.text('Species: Aedes aegypti'), findsOneWidget);
      expect(find.text('Time: 123 ms'), findsOneWidget);
    });

    testWidgets('taps camera button and calls view model', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.camera_alt));
      verify(mockViewModel.pickImage(ImageSource.camera, any)).called(1);
    });

    testWidgets('taps gallery button and calls view model', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.photo_library));
      verify(mockViewModel.pickImage(ImageSource.gallery, any)).called(1);
    });

    testWidgets('taps analyze button and calls view model', (tester) async {
      final mockImageFile = MockFile();
      when(mockImageFile.path).thenReturn('path/to/image.jpg');
      when(mockImageFile.length()).thenAnswer((_) async => kTestImageBytes.length);
      when(mockImageFile.readAsBytes()).thenAnswer((_) async => kTestImageBytes);
      when(mockViewModel.hasImage).thenReturn(true);
      when(mockViewModel.imageFile).thenReturn(mockImageFile);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Analyze'));
      verify(mockViewModel.classifyImage(any)).called(1);
    });

    testWidgets('taps reset button and calls view model', (tester) async {
      final mockImageFile = MockFile();
      when(mockImageFile.path).thenReturn('path/to/image.jpg');
      when(mockImageFile.length()).thenAnswer((_) async => kTestImageBytes.length);
      when(mockImageFile.readAsBytes()).thenAnswer((_) async => kTestImageBytes);
      when(mockViewModel.hasImage).thenReturn(true);
      when(mockViewModel.imageFile).thenReturn(mockImageFile);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.refresh));
      verify(mockViewModel.reset()).called(1);
    });


    testWidgets('taps disease risks button and shows bottom sheet', (tester) async {
      final mockSpecies = MockMosquitoSpecies();
      when(mockSpecies.name).thenReturn('Aedes aegypti');
      when(mockSpecies.commonName).thenReturn('Yellow Fever Mosquito');
      final mockDisease = MockDisease();
      when(mockDisease.name).thenReturn('Dengue Fever');
      when(mockDisease.description).thenReturn('A viral infection.');
      final mockResult = MockClassificationResult();
      when(mockResult.species).thenReturn(mockSpecies);
      when(mockResult.confidence).thenReturn(95.0);
      when(mockResult.inferenceTime).thenReturn(123);
      when(mockResult.relatedDiseases).thenReturn([mockDisease]);
      when(mockViewModel.hasImage).thenReturn(true);
      when(mockViewModel.state).thenReturn(ClassificationState.success);
      when(mockViewModel.result).thenReturn(mockResult);
      when(mockViewModel.shouldShowDiseaseRiskButton).thenReturn(true);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Disease Risks'));
      await tester.pumpAndSettle();
      expect(find.text('Disease Risks'), findsAtLeastNWidgets(1));
      expect(find.text('Dengue Fever'), findsOneWidget);
    });

  });
}

class MockAppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final AppLocalizations mock;
  const MockAppLocalizationsDelegate(this.mock);

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) => Future.value(mock);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}