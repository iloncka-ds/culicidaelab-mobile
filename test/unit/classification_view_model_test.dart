import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:culicidaelab/models/mosquito_model.dart';
import 'package:culicidaelab/models/disease_model.dart';
import 'package:culicidaelab/repositories/classification_repository.dart';
import 'package:culicidaelab/view_models/classification_view_model.dart';

// Generate mock classes
@GenerateMocks([ClassificationRepository, File, ImagePicker])
import 'classification_view_model_test.mocks.dart';

void main() {
  late ClassificationViewModel viewModel;
  late MockClassificationRepository mockRepository;
  late MockFile mockFile;

  setUp(() {
    mockRepository = MockClassificationRepository();
    mockFile = MockFile();
    viewModel = ClassificationViewModel(repository: mockRepository);
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
      // Arrange
      when(mockRepository.loadModel()).thenAnswer((_) async {});

      // Act
      await viewModel.initModel();

      // Assert
      verify(mockRepository.loadModel()).called(1);
    });

    test('initModel should handle errors', () async {
      // Arrange
      when(mockRepository.loadModel()).thenThrow(Exception('Test error'));

      // Act
      await viewModel.initModel();

      // Assert
      expect(viewModel.errorMessage, contains('Test error'));
    });

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
      viewModel.pickImage(ImageSource.gallery);

      // Mock that pickImage worked
      final mockImageFile = MockFile();
      viewModel = ClassificationViewModel(repository: mockRepository);
      viewModel.setImageFile(mockImageFile);

      // Act
      await viewModel.classifyImage();

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
      await viewModel.classifyImage();

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
