import 'dart:io';

import 'package:culicidaelab/models/disease_model.dart';
import 'package:culicidaelab/models/mosquito_model.dart';
import 'package:culicidaelab/repositories/classification_repository.dart';
import 'package:culicidaelab/repositories/mosquito_repository.dart';
import 'package:culicidaelab/services/classification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:culicidaelab/locator.dart';

import 'classification_repository_test.mocks.dart';

@GenerateMocks([ClassificationService, MosquitoRepository, http.Client])
void main() {
  late ClassificationRepository classificationRepository;
  late MockClassificationService mockClassificationService;
  late MockMosquitoRepository mockMosquitoRepository;
  late MockClient mockHttpClient;

  setUp(() {
    mockClassificationService = MockClassificationService();
    mockMosquitoRepository = MockMosquitoRepository();
    mockHttpClient = MockClient();
    locator
        .registerSingleton<ClassificationService>(mockClassificationService);
    locator.registerSingleton<MosquitoRepository>(mockMosquitoRepository);
    locator.registerSingleton<http.Client>(mockHttpClient);
    classificationRepository = ClassificationRepository(
      classificationService: locator(),
      mosquitoRepository: locator(),
      httpClient: locator(),
    );
  });

  tearDown(() {
    locator.unregister<ClassificationService>();
    locator.unregister<MosquitoRepository>();
    locator.unregister<http.Client>();
  });

  group('classifyImage', () {
    test('should return a ClassificationResult when species is found',
        () async {
      final imageFile = File('test/fixtures/test_image.jpg');
      const languageCode = 'en';
      final rawResult = {
        'scientificName': 'Aedes aegypti',
        'confidence': 0.98
      };
      final species = MosquitoSpecies(
        id: '1',
        name: 'Aedes aegypti',
        commonName: 'Yellow Fever Mosquito',
        description:
            'A mosquito that can spread dengue fever, chikungunya, Zika fever, Mayaro and yellow fever viruses, and other disease agents.',
        habitat: 'Urban areas',
        distribution: 'Tropical and subtropical regions',
        imageUrl: 'assets/images/species/aedes_aegypti.jpg',
        diseases: ['Dengue', 'Yellow Fever'],
      );
      final diseases = [
        Disease(
          id: '1',
          name: 'Dengue',
          description:
              'A viral infection that causes flu-like illness, and occasionally develops into a potentially lethal complication called severe dengue.',
          symptoms:
              'High fever, headache, vomiting, muscle and joint pains, and a characteristic skin rash.',
          treatment: 'No specific treatment',
          prevention: 'Mosquito control',
          vectors: ['Aedes aegypti'],
          prevalence: 'Worldwide',
          imageUrl: 'assets/images/diseases/dengue_fever.jpg',
        )
      ];

      when(mockClassificationService.classifyImage(imageFile))
          .thenAnswer((_) async => rawResult);
      when(mockMosquitoRepository.getMosquitoSpeciesByName(
              'Aedes aegypti', languageCode))
          .thenAnswer((_) async => species);
      when(mockMosquitoRepository.getDiseasesByVector(
              'Aedes aegypti', languageCode))
          .thenAnswer((_) async => diseases);

      final result = await classificationRepository.classifyImage(
          imageFile, languageCode);

      expect(result, isA<ClassificationResult>());
      expect(result.species, species);
      expect(result.confidence, 98.0);
      expect(result.relatedDiseases, diseases);
    });
  });
}
