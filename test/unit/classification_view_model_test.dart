import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:culicidaelab/models/mosquito_model.dart';
import 'package:culicidaelab/models/disease_model.dart';
import 'package:culicidaelab/repositories/classification_repository.dart';
import 'package:culicidaelab/view_models/classification_view_model.dart';
import 'package:culicidaelab/l10n/app_localizations.dart';

// Generate mock classes
@GenerateMocks([ClassificationRepository, File, ImagePicker, AppLocalizations])
import 'classification_view_model_test.mocks.dart';
void main() {
  late MockAppLocalizations mockLocalizations;
  late ClassificationViewModel viewModel;
  late MockClassificationRepository mockRepository;
  late MockFile mockFile;
  late MockImagePicker mockImagePicker;

  setUp(() {
    mockRepository = MockClassificationRepository();
    mockFile = MockFile();
    mockImagePicker = MockImagePicker();
    mockLocalizations = MockAppLocalizations();
    viewModel = ClassificationViewModel(
      repository: mockRepository,
      imagePicker: mockImagePicker
    );
  });

  group('ClassificationViewModel Tests', () {
    test('Initial state should be correct', () {
      expect(viewModel.state, equals(ClassificationState.initial));
      expect(viewModel.imageFile, isNull);
      expect(viewModel.result, isNull);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isProcessing, isFalse);
    });

    test('initModel should call repository.loadModel', () async {
      await viewModel.initModel(mockLocalizations);

      verify(mockRepository.loadModel()).called(1);
    });

    test('initModel should throw if loadModel throws', () async {
      when(mockRepository.loadModel()).thenThrow(Exception('Test error'));

      try {
        await viewModel.initModel(mockLocalizations);
        fail('Should throw an exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('pickImage should set imageFile and update state', () async {
      final mockXFile = XFile('test/path');
      when(mockImagePicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => mockXFile);

      viewModel.pickImage(ImageSource.gallery, mockLocalizations);

      expect(viewModel.state, equals(ClassificationState.success));
      expect(viewModel.imageFile, equals(mockXFile));
    });

    test('classifyImage should update state and result on success', () async {
      final mockResult = ClassificationResult(
        species: MosquitoSpecies(
          id: '1',
          name: 'Test Species',
          commonName: 'Common Test Species',
          description: 'Test Description',
          habitat: 'Test Habitat',
          distribution: 'Test Distribution',
          imageUrl: 'test.jpg',
          diseases: [],
        ),
        confidence: 0.9,
        inferenceTime: 100,
        imageFile: mockFile,
        relatedDiseases: [],
      );

      when(mockRepository.classifyImage(any))
          .thenAnswer((_) async => mockResult);

      await viewModel.classifyImage(mockLocalizations);

      expect(viewModel.state, equals(ClassificationState.success));
      expect(viewModel.result, equals(mockResult));
      expect(viewModel.isProcessing, isFalse);
    });

    test('classifyImage should update state and error on failure', () async {
      when(mockRepository.classifyImage(any))
          .thenThrow(Exception('Test error'));

      await viewModel.classifyImage(mockLocalizations);

    test('classifyImage should update state correctly on success', () async {
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

      when(
        mockRepository.classifyImage(any),
      ).thenAnswer((_) async => mockResult);

      // Set image file
      viewModel = ClassificationViewModel(repository: mockRepository);
      viewModel.pickImage(ImageSource.gallery, mockLocalizations);

      // Mock that pickImage worked
      final mockImageFile = MockFile();
      viewModel = ClassificationViewModel(repository: mockRepository);
      viewModel.setImageFile(mockImageFile);

      // Act
      await viewModel.classifyImage(fakeLocalizations);

      // Assert
      expect(viewModel.state, equals(ClassificationState.success));
      expect(viewModel.result, equals(mockResult));
      expect(viewModel.isProcessing, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('classifyImage should handle errors', () async {
      // Arrange
      when(
        mockRepository.classifyImage(any),
      ).thenThrow(Exception('Classification error'));

      // Set image file
      final mockImageFile = MockFile();
      viewModel = ClassificationViewModel(repository: mockRepository);
      viewModel.setImageFile(mockImageFile);

      // Act
      await viewModel.classifyImage(fakeLocalizations);

      // Assert
      expect(viewModel.state, equals(ClassificationState.error));
      expect(viewModel.result, isNull);
      expect(viewModel.isProcessing, isFalse);
      expect(viewModel.errorMessage, contains('Classification error'));
    });

    test('reset should clear all state', () {
      // Arrange
      viewModel = ClassificationViewModel(repository: mockRepository);
      viewModel.setState(ClassificationState.success);
      viewModel.setImageFile(mockFile);
      viewModel.setResult(
        ClassificationResult(
          species: MosquitoSpecies(
            id: '1',
            name: 'Test Species',
            commonName: 'Test Common Name',
            description: 'Test Description',
            habitat: 'Test Habitat',
            distribution: 'Test Distribution',
            imageUrl: 'test_image.jpg',
            diseases: ['Disease 1'],
          ),
          confidence: 95.0,
          inferenceTime: 100,
          relatedDiseases: [],
          imageFile: mockFile,
        ),
      );
      viewModel.setErrorMessage('Test error');

      // Act
      viewModel.reset();

      // Assert
      expect(viewModel.state, equals(ClassificationState.initial));
      expect(viewModel.imageFile, isNull);
      expect(viewModel.result, isNull);
      expect(viewModel.errorMessage, isNull);
    });
  });
}
