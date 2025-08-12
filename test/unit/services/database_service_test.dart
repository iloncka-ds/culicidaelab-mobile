import 'dart:convert';

import 'package:culicidaelab/services/database_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize FFI
  sqfliteFfiInit();

  // Use an in-memory database for testing
  databaseFactory = databaseFactoryFfi;

  late DatabaseService databaseService;

  setUp(() async {
    databaseService = DatabaseService();

    // Mock the rootBundle to load the test data
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter/assets'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'loadString') {
          final key = methodCall.arguments as String;
          if (key == 'assets/database/database_data.json') {
            return json.encode({
              "mosquito_species": [
                {"id": "1", "name": "Aedes aegypti", "image_url": "url1"}
              ],
              "mosquito_species_translations": [
                {
                  "species_id": "1",
                  "language_code": "en",
                  "common_name": "Yellow Fever Mosquito",
                  "description": "Desc1",
                  "habitat": "Hab1",
                  "distribution": "Dist1"
                }
              ],
              "diseases": [
                {"id": "d1", "name_key": "Dengue", "image_url": "url_d1"}
              ],
              "disease_translations": [
                {
                  "disease_id": "d1",
                  "language_code": "en",
                  "name": "Dengue Fever",
                  "description": "DescD1",
                  "symptoms": "Symp1",
                  "treatment": "Treat1",
                  "prevention": "Prev1",
                  "prevalence": "PrevL1"
                }
              ],
              "mosquito_disease_relations": [
                {"mosquito_id": "1", "disease_id": "d1"}
              ]
            });
          }
        }
        return null;
      },
    );

    // Make sure the database is created and populated
    await databaseService.database;
  });

  tearDown(() async {
    // Because the database is in-memory, it will be gone after the test.
    // However, if it were a file, we would delete it here.
  });

  group('DatabaseService', () {
    test('getAllMosquitoSpecies returns species from the database', () async {
      final species = await databaseService.getAllMosquitoSpecies('en');
      expect(species.length, 1);
      expect(species.first.name, 'Aedes aegypti');
      expect(species.first.diseases.first, 'Dengue Fever');
    });

    test('getAllDiseases returns diseases from the database', () async {
      final diseases = await databaseService.getAllDiseases('en');
      expect(diseases.length, 1);
      expect(diseases.first.name, 'Dengue Fever');
      expect(diseases.first.vectors.first, 'Aedes aegypti');
    });
  });
}
