import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:culicidaelab/models/mosquito_model.dart';
import 'package:culicidaelab/models/disease_model.dart';
import 'package:culicidaelab/view_models/classification_view_model.dart';
import 'package:culicidaelab/screens/classification_screen.dart';
import 'package:culicidaelab/services/classification_service.dart';

// Generate mock classes

@GenerateMocks([ClassificationViewModel, ClassificationService, File])
import 'classification_screen_test.mocks.dart';

void main() {
  late MockClassificationViewModel mockViewModel;
  late MockClassificationService mockClassificationService;
  late MockFile mockFile;

  setUp(() {
    mockViewModel = MockClassificationViewModel();
    mockClassificationService = MockClassificationService();
    mockFile = MockFile();

    when(mockFile.path).thenReturn('/fake/path/to/test_image.jpg');

    // *** Optional: Stub readAsBytesSync/readAsBytes if your code tries to read the file synchronously/asynchronously ***
    // Image.file in tests *might* try to read bytes. Stubbing it is safer.
    // Use Uint8List(0) for an empty byte list, or create a dummy list.
    // when(mockFile.readAsBytesSync()).thenReturn(Uint8List(0));
    // If any async read happens, stub readAsBytes
    // when(mockFile.readAsBytes()).thenAnswer((_) async => Uint8List(0));

    // Stub any methods/getters on mockClassificationService that ClassificationScreen might call
    // For example, if it needs to look up diseases or species details when buttons are tapped:
    // when(mockClassificationService.getDiseasesByVector(any)).thenReturn([]); // Return empty list or dummy data
    // when(mockClassificationService.getMosquitoSpeciesById(any)).thenReturn(null); // Or return a dummy species
    // when(mockClassificationService.getAllMosquitoSpecies()).thenReturn([]); // Or return a dummy list
    // when(mockClassificationService.getAllDiseases()).thenReturn([]); // Or return a dummy list
  });

  Widget createTestableWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<ClassificationViewModel>.value(
        value: mockViewModel,
        child: const ClassificationScreen(),
      ),
    );
  }

  group('ClassificationScreen Widget Tests', () {
    testWidgets('should display empty state when no image is selected', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockViewModel.state).thenReturn(ClassificationState.initial);
      when(mockViewModel.imageFile).thenReturn(null);
      when(mockViewModel.result).thenReturn(null);
      when(mockViewModel.errorMessage).thenReturn(null);
      when(mockViewModel.isProcessing).thenReturn(false);

      // Act
      await tester.pumpWidget(createTestableWidget());

      // Assert
      expect(find.text('No Image Selected'), findsOneWidget);
      expect(find.text('Take a photo or select from gallery'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
    });

    testWidgets('should display error message when there is an error', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockViewModel.state).thenReturn(ClassificationState.error);
      when(mockViewModel.imageFile).thenReturn(null);
      when(mockViewModel.result).thenReturn(null);
      when(mockViewModel.errorMessage).thenReturn('Test error message');
      when(mockViewModel.isProcessing).thenReturn(false);

      // Act
      await tester.pumpWidget(createTestableWidget());

      // Assert
      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('should show loading indicator when processing', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockViewModel.state).thenReturn(ClassificationState.loading);
      when(mockViewModel.imageFile).thenReturn(null);
      when(mockViewModel.result).thenReturn(null);
      when(mockViewModel.errorMessage).thenReturn(null);
      when(mockViewModel.isProcessing).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestableWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Analyzing image...'), findsOneWidget);
    });

    testWidgets('should display result when classification is successful', (
      WidgetTester tester,
    ) async {
      // Arrange
      final mockSpecies = MosquitoSpecies(
        id: '1',
        name: 'Test Species',
        commonName: 'Test Common Name',
        description: 'Test Description',
        habitat: 'Test Habitat',
        distribution: 'Test Distribution',
        imageUrl: 'test_image.jpg',
        diseases: ['Disease 1'],
      );

      final mockDisease = Disease(
        id: '1',
        name: 'Disease 1',
        description: 'Test Disease',
        symptoms: 'Test Symptoms',
        treatment: 'Test Treatment',
        prevention: 'Test Prevention',
        vectors: ['Test Species'],
        prevalence: 'Test Prevalence',
        imageUrl: 'test_disease.jpg',
      );

      final mockResult = ClassificationResult(
        species: mockSpecies,
        confidence: 95.0,
        inferenceTime: 100,
        relatedDiseases: [mockDisease],
        imageFile: mockFile,
      );

      when(mockViewModel.state).thenReturn(ClassificationState.success);
      when(mockViewModel.imageFile).thenReturn(mockFile);
      when(mockViewModel.result).thenReturn(mockResult);
      when(mockViewModel.errorMessage).thenReturn(null);
      when(mockViewModel.isProcessing).thenReturn(false);

      // Act
      await tester.pumpWidget(createTestableWidget());

      // Assert
      expect(find.text('Species: Test Species'), findsOneWidget);
      expect(find.text('Common Name: Test Common Name'), findsOneWidget);
      expect(find.text('Confidence: 95.0%'), findsOneWidget);
      expect(find.text('Time: 100 ms'), findsOneWidget);
      expect(find.text('Species Info'), findsOneWidget);
      expect(find.text('Disease Risks'), findsOneWidget);
    });
  });
}
