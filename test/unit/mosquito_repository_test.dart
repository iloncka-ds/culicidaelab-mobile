import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:culicidaelab/models/mosquito_model.dart';
import 'package:culicidaelab/models/disease_model.dart';
import 'package:culicidaelab/repositories/mosquito_repository.dart';
import 'package:culicidaelab/services/database_service.dart';

// Generate mock classes
@GenerateMocks([DatabaseService])
import 'mosquito_repository_test.mocks.dart';

void main() {
  late MosquitoRepository repository;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    repository = MosquitoRepository(databaseService: mockDatabaseService);
  });

  group('MosquitoRepository Tests', () {
    final mockMosquitoSpecies = [
      MosquitoSpecies(
        id: '1',
        name: 'Aedes aegypti',
        commonName: 'Yellow Fever Mosquito',
        description: 'Test description',
        habitat: 'Test habitat',
        distribution: 'Test distribution',
        imageUrl: 'test_image.jpg',
        diseases: ['Dengue', 'Yellow Fever'],
      ),
      MosquitoSpecies(
        id: '2',
        name: 'Anopheles gambiae',
        commonName: 'African Malaria Mosquito',
        description: 'Test description 2',
        habitat: 'Test habitat 2',
        distribution: 'Test distribution 2',
        imageUrl: 'test_image2.jpg',
        diseases: ['Malaria'],
      ),
    ];

    final mockDiseases = [
      Disease(
        id: '1',
        name: 'Dengue Fever',
        description: 'Test disease description',
        symptoms: 'Test symptoms',
        treatment: 'Test treatment',
        prevention: 'Test prevention',
        vectors: ['Aedes aegypti'],
        prevalence: 'Test prevalence',
        imageUrl: 'test_disease.jpg',
      ),
      Disease(
        id: '2',
        name: 'Malaria',
        description: 'Test disease description 2',
        symptoms: 'Test symptoms 2',
        treatment: 'Test treatment 2',
        prevention: 'Test prevention 2',
        vectors: ['Anopheles gambiae'],
        prevalence: 'Test prevalence 2',
        imageUrl: 'test_disease2.jpg',
      ),
    ];

    test(
      'getAllMosquitoSpecies should return list of mosquito species',
      () async {
        // Arrange
        when(
          mockDatabaseService.getAllMosquitoSpecies(),
        ).thenAnswer((_) async => mockMosquitoSpecies);

        // Act
        final result = await repository.getAllMosquitoSpecies();

        // Assert
        expect(result, equals(mockMosquitoSpecies));
        verify(mockDatabaseService.getAllMosquitoSpecies()).called(1);
      },
    );

    test(
      'getMosquitoSpeciesById should return a specific mosquito species',
      () async {
        // Arrange
        when(
          mockDatabaseService.getMosquitoSpeciesById('1'),
        ).thenAnswer((_) async => mockMosquitoSpecies[0]);

        // Act
        final result = await repository.getMosquitoSpeciesById('1');

        // Assert
        expect(result, equals(mockMosquitoSpecies[0]));
        verify(mockDatabaseService.getMosquitoSpeciesById('1')).called(1);
      },
    );

    test(
      'getMosquitoSpeciesById should return null for non-existent ID',
      () async {
        // Arrange
        when(
          mockDatabaseService.getMosquitoSpeciesById('999'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await repository.getMosquitoSpeciesById('999');

        // Assert
        expect(result, isNull);
        verify(mockDatabaseService.getMosquitoSpeciesById('999')).called(1);
      },
    );

    test('getAllDiseases should return list of diseases', () async {
      // Arrange
      when(
        mockDatabaseService.getAllDiseases(),
      ).thenAnswer((_) async => mockDiseases);

      // Act
      final result = await repository.getAllDiseases();

      // Assert
      expect(result, equals(mockDiseases));
      verify(mockDatabaseService.getAllDiseases()).called(1);
    });

    test('getDiseaseById should return a specific disease', () async {
      // Arrange
      when(
        mockDatabaseService.getDiseaseById('1'),
      ).thenAnswer((_) async => mockDiseases[0]);

      // Act
      final result = await repository.getDiseaseById('1');

      // Assert
      expect(result, equals(mockDiseases[0]));
      verify(mockDatabaseService.getDiseaseById('1')).called(1);
    });

    test('getDiseaseById should return null for non-existent ID', () async {
      // Arrange
      when(
        mockDatabaseService.getDiseaseById('999'),
      ).thenAnswer((_) async => null);

      // Act
      final result = await repository.getDiseaseById('999');

      // Assert
      expect(result, isNull);
      verify(mockDatabaseService.getDiseaseById('999')).called(1);
    });

    test(
      'getDiseasesByVector should return diseases associated with a vector',
      () async {
        // Arrange
        when(
          mockDatabaseService.getDiseasesByVector('Aedes aegypti'),
        ).thenAnswer((_) async => [mockDiseases[0]]);

        // Act
        final result = await repository.getDiseasesByVector('Aedes aegypti');

        // Assert
        expect(result, equals([mockDiseases[0]]));
        verify(
          mockDatabaseService.getDiseasesByVector('Aedes aegypti'),
        ).called(1);
      },
    );

    test(
      'getDiseasesByVector should return empty list for non-existent vector',
      () async {
        // Arrange
        when(
          mockDatabaseService.getDiseasesByVector('Non-existent'),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getDiseasesByVector('Non-existent');

        // Assert
        expect(result, isEmpty);
        verify(
          mockDatabaseService.getDiseasesByVector('Non-existent'),
        ).called(1);
      },
    );
  });
}
