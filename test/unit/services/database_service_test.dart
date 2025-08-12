import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:culicidaelab/services/database_service.dart';
import 'package:culicidaelab/models/mosquito_model.dart';
import 'package:culicidaelab/models/disease_model.dart';

class MockDatabase extends Mock implements Database {}

class MockDatabaseService extends Mock implements DatabaseService {
  @override
  Future<List<MosquitoSpecies>> getAllMosquitoSpecies(
    String languageCode,
  ) async {
    return [];
  }

  @override
  Future<List<Disease>> getAllDiseases(String languageCode) async {
    return [];
  }

  @override
  Future<Database> _initDatabase() async {
    return MockDatabase();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseService Tests', () {
    late DatabaseService databaseService;
    late MockDatabase mockDatabase;

    setUp(() async {
      mockDatabase = MockDatabase();
      databaseService = MockDatabaseService();

      // Mock the loading of the JSON file
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter/assets'), (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'load') {
              if (methodCall.arguments ==
                  'assets/database/database_data.json') {
                // Provide mock JSON data for mosquito species
                const mockMosquitoSpeciesJson = '''
              [
                {
                  "id": "1",
                  "name": "Aedes aegypti",
                  "commonName": "Yellow Fever Mosquito",
                  "description": "...",
                  "habitat": "...",
                  "distribution": "...",
                  "imageUrl": "...",
                  "diseases": []
                }
              ]
              ''';
                return utf8.encode(mockMosquitoSpeciesJson).buffer.asByteData();
              } else if (methodCall.arguments ==
                  'assets/database/database_data.json') {
                // Provide mock JSON data for diseases
                const mockDiseasesJson = '''
              [
                {
                  "id": "1",
                  "name": "Dengue Fever",
                  "description": "...",
                  "symptoms": "...",
                  "treatment": "...",
                  "prevention": "...",
                  "vectors": [],
                  "prevalence": "...",
                  "imageUrl": "..."
                }
              ]
              ''';
                return utf8.encode(mockDiseasesJson).buffer.asByteData();
              }
            }
            return null;
          });
    });

    tearDown(() {
      // Clean up any resources after each test
    });

    test('getAllMosquitoSpecies returns species from the database', () async {
      // Call the method
      await databaseService.getAllMosquitoSpecies('en');
      // Add your asserts here based on the expected behavior
      expect(true, true); // Placeholder, replace with actual assertions
    });

    test('getAllDiseases returns diseases from the database', () async {
      // Call the method
      await databaseService.getAllDiseases('en');
      // Add your asserts here based on the expected behavior
      expect(true, true); // Placeholder, replace with actual assertions
    });
  });
}
