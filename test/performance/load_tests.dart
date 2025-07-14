import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';


import '../../lib/services/classification_service.dart';
import '../../lib/services/database_service.dart';
import '../../lib/models/mosquito_model.dart';
import '../../lib/models/disease_model.dart';
import '../../lib/services/pytorch_lite_model.dart';

// Mock classes for testing
@GenerateMocks([ClassificationModel, File])
import 'load_test.mocks.dart';

// Mock implementations of your models for testing
class MockMosquitoSpecies {
  final String id;
  final String name;
  final String commonName;
  final String description;
  final String habitat;
  final String distribution;
  final String imageUrl;
  final List<String> diseases;

  MockMosquitoSpecies({
    required this.id,
    required this.name,
    required this.commonName,
    required this.description,
    required this.habitat,
    required this.distribution,
    required this.imageUrl,
    required this.diseases,
  });
}

class MockDisease {
  final String id;
  final String name;
  final String description;
  final String symptoms;
  final String treatment;
  final String prevention;
  final List<String> vectors;
  final String prevalence;
  final String imageUrl;

  MockDisease({
    required this.id,
    required this.name,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    required this.vectors,
    required this.prevalence,
    required this.imageUrl,
  });
}

class MockClassificationResult {
  final MockMosquitoSpecies species;
  final double confidence;
  final int inferenceTime;
  final List<MockDisease> relatedDiseases;
  final File imageFile;

  MockClassificationResult({
    required this.species,
    required this.confidence,
    required this.inferenceTime,
    required this.relatedDiseases,
    required this.imageFile,
  });
}

// Simplified DatabaseService for testing
class TestDatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Use in-memory database for testing
    databaseFactory = databaseFactoryFfi;
    return await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mosquito_species(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        common_name TEXT NOT NULL,
        description TEXT NOT NULL,
        habitat TEXT NOT NULL,
        distribution TEXT NOT NULL,
        image_url TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE diseases(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        symptoms TEXT NOT NULL,
        treatment TEXT NOT NULL,
        prevention TEXT NOT NULL,
        prevalence TEXT NOT NULL,
        image_url TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE mosquito_disease_relation(
        mosquito_id TEXT NOT NULL,
        disease_id TEXT NOT NULL,
        PRIMARY KEY (mosquito_id, disease_id),
        FOREIGN KEY (mosquito_id) REFERENCES mosquito_species (id),
        FOREIGN KEY (disease_id) REFERENCES diseases (id)
      )
    ''');

    // Insert test data
    await _insertTestData(db);
  }

  Future<void> _insertTestData(Database db) async {
    // Insert 1000 mosquito species for load testing
    final batch = db.batch();

    for (int i = 1; i <= 1000; i++) {
      batch.insert('mosquito_species', {
        'id': i.toString(),
        'name': 'Test Species $i',
        'common_name': 'Common Name $i',
        'description': 'Description for species $i',
        'habitat': 'Habitat $i',
        'distribution': 'Distribution $i',
        'image_url': 'assets/images/species_$i.jpg',
      });
    }

    // Insert 100 diseases
    for (int i = 1; i <= 100; i++) {
      batch.insert('diseases', {
        'id': i.toString(),
        'name': 'Disease $i',
        'description': 'Description for disease $i',
        'symptoms': 'Symptoms for disease $i',
        'treatment': 'Treatment for disease $i',
        'prevention': 'Prevention for disease $i',
        'prevalence': 'Prevalence info for disease $i',
        'image_url': 'assets/images/disease_$i.jpg',
      });
    }

    // Create random relations
    final random = Random();
    for (int i = 1; i <= 2000; i++) {
      final mosquitoId = (random.nextInt(1000) + 1).toString();
      final diseaseId = (random.nextInt(100) + 1).toString();

      batch.insert('mosquito_disease_relation', {
        'mosquito_id': mosquitoId,
        'disease_id': diseaseId,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await batch.commit(noResult: true);
  }

  Future<List<MockMosquitoSpecies>> getAllMosquitoSpecies() async {
    final db = await database;
    final maps = await db.query('mosquito_species');

    return Future.wait(maps.map((map) async {
      final relationMaps = await db.query(
        'mosquito_disease_relation',
        where: 'mosquito_id = ?',
        whereArgs: [map['id']],
      );

      final diseaseIds = relationMaps.map((r) => r['disease_id'] as String).toList();
      final diseaseNames = <String>[];

      for (var diseaseId in diseaseIds) {
        final diseaseMaps = await db.query(
          'diseases',
          where: 'id = ?',
          whereArgs: [diseaseId],
        );
        if (diseaseMaps.isNotEmpty) {
          diseaseNames.add(diseaseMaps.first['name'] as String);
        }
      }

      return MockMosquitoSpecies(
        id: map['id'] as String,
        name: map['name'] as String,
        commonName: map['common_name'] as String,
        description: map['description'] as String,
        habitat: map['habitat'] as String,
        distribution: map['distribution'] as String,
        imageUrl: map['image_url'] as String,
        diseases: diseaseNames,
      );
    }));
  }

  Future<MockMosquitoSpecies?> getMosquitoSpeciesById(String id) async {
    final db = await database;
    final maps = await db.query(
      'mosquito_species',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final relationMaps = await db.query(
      'mosquito_disease_relation',
      where: 'mosquito_id = ?',
      whereArgs: [id],
    );

    final diseaseIds = relationMaps.map((r) => r['disease_id'] as String).toList();
    final diseaseNames = <String>[];

    for (var diseaseId in diseaseIds) {
      final diseaseMaps = await db.query(
        'diseases',
        where: 'id = ?',
        whereArgs: [diseaseId],
      );
      if (diseaseMaps.isNotEmpty) {
        diseaseNames.add(diseaseMaps.first['name'] as String);
      }
    }

    final map = maps.first;
    return MockMosquitoSpecies(
      id: map['id'] as String,
      name: map['name'] as String,
      commonName: map['common_name'] as String,
      description: map['description'] as String,
      habitat: map['habitat'] as String,
      distribution: map['distribution'] as String,
      imageUrl: map['image_url'] as String,
      diseases: diseaseNames,
    );
  }

  Future<List<MockDisease>> getAllDiseases() async {
    final db = await database;
    final maps = await db.query('diseases');

    return Future.wait(maps.map((map) async {
      final relationMaps = await db.query(
        'mosquito_disease_relation',
        where: 'disease_id = ?',
        whereArgs: [map['id']],
      );

      final mosquitoIds = relationMaps.map((r) => r['mosquito_id'] as String).toList();
      final vectorNames = <String>[];

      for (var mosquitoId in mosquitoIds) {
        final mosquitoMaps = await db.query(
          'mosquito_species',
          where: 'id = ?',
          whereArgs: [mosquitoId],
        );
        if (mosquitoMaps.isNotEmpty) {
          vectorNames.add(mosquitoMaps.first['name'] as String);
        }
      }

      return MockDisease(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String,
        symptoms: map['symptoms'] as String,
        treatment: map['treatment'] as String,
        prevention: map['prevention'] as String,
        vectors: vectorNames,
        prevalence: map['prevalence'] as String,
        imageUrl: map['image_url'] as String,
      );
    }));
  }

  Future<List<MockDisease>> getDiseasesByVector(String speciesName) async {
    final db = await database;

    final mosquitoMaps = await db.query(
      'mosquito_species',
      where: 'name = ?',
      whereArgs: [speciesName],
    );

    if (mosquitoMaps.isEmpty) return [];

    final mosquitoId = mosquitoMaps.first['id'] as String;
    final relationMaps = await db.query(
      'mosquito_disease_relation',
      where: 'mosquito_id = ?',
      whereArgs: [mosquitoId],
    );

    final diseaseIds = relationMaps.map((r) => r['disease_id'] as String).toList();
    final diseases = <MockDisease>[];

    for (var diseaseId in diseaseIds) {
      final diseaseMaps = await db.query(
        'diseases',
        where: 'id = ?',
        whereArgs: [diseaseId],
      );

      if (diseaseMaps.isNotEmpty) {
        final map = diseaseMaps.first;
        diseases.add(MockDisease(
          id: map['id'] as String,
          name: map['name'] as String,
          description: map['description'] as String,
          symptoms: map['symptoms'] as String,
          treatment: map['treatment'] as String,
          prevention: map['prevention'] as String,
          vectors: [speciesName],
          prevalence: map['prevalence'] as String,
          imageUrl: map['image_url'] as String,
        ));
      }
    }

    return diseases;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

// Simplified ClassificationService for testing
class TestClassificationService {
  MockClassificationModel? _model;
  final TestDatabaseService _databaseService = TestDatabaseService();

  Future<void> loadModel() async {
    _model = MockClassificationModel();
    // Simulate model loading delay
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<MockClassificationResult> classifyImage(File imageFile) async {
    if (_model == null) {
      throw Exception("Model not loaded");
    }

    // Simulate inference time
    final random = Random();
    final inferenceTime = 50 + random.nextInt(200); // 50-250ms
    await Future.delayed(Duration(milliseconds: inferenceTime));

    // Mock prediction result
    final speciesNames = ['Test Species 1', 'Test Species 2', 'Test Species 3'];
    final predictedName = speciesNames[random.nextInt(speciesNames.length)];
    final confidence = 0.7 + random.nextDouble() * 0.3; // 70-100%

    final allSpecies = await _databaseService.getAllMosquitoSpecies();
    final species = allSpecies.firstWhere(
      (s) => s.name == predictedName,
      orElse: () => MockMosquitoSpecies(
        id: '0',
        name: predictedName,
        commonName: 'Unknown Species',
        description: 'No detailed information available.',
        habitat: 'Unknown',
        distribution: 'Unknown',
        imageUrl: 'assets/images/unknown_mosquito.jpg',
        diseases: [],
      ),
    );

    final relatedDiseases = await _databaseService.getDiseasesByVector(species.name);

    return MockClassificationResult(
      species: species,
      confidence: confidence * 100,
      inferenceTime: inferenceTime,
      relatedDiseases: relatedDiseases,
      imageFile: imageFile,
    );
  }
}

// Load Test Utilities
class LoadTestMetrics {
  final List<Duration> responseTimes = [];
  final List<String> errors = [];
  int successCount = 0;
  int failureCount = 0;
  late DateTime startTime;
  late DateTime endTime;

  void start() {
    startTime = DateTime.now();
  }

  void end() {
    endTime = DateTime.now();
  }

  void recordSuccess(Duration responseTime) {
    successCount++;
    responseTimes.add(responseTime);
  }

  void recordFailure(String error) {
    failureCount++;
    errors.add(error);
  }

  Duration get averageResponseTime {
    if (responseTimes.isEmpty) return Duration.zero;
    final totalMs = responseTimes.fold<int>(0, (sum, time) => sum + time.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ responseTimes.length);
  }

  Duration get maxResponseTime {
    if (responseTimes.isEmpty) return Duration.zero;
    return responseTimes.reduce((a, b) => a.inMilliseconds > b.inMilliseconds ? a : b);
  }

  Duration get minResponseTime {
    if (responseTimes.isEmpty) return Duration.zero;
    return responseTimes.reduce((a, b) => a.inMilliseconds < b.inMilliseconds ? a : b);
  }

  double get successRate {
    final total = successCount + failureCount;
    return total == 0 ? 0.0 : (successCount / total) * 100.0;
  }

  Duration get totalDuration => endTime.difference(startTime);

  double get throughput {
    final totalSeconds = totalDuration.inSeconds;
    return totalSeconds == 0 ? 0.0 : successCount / totalSeconds;
  }

  void printSummary(String testName) {
    print('\n=== $testName Load Test Results ===');
    print('Total Operations: ${successCount + failureCount}');
    print('Successful Operations: $successCount');
    print('Failed Operations: $failureCount');
    print('Success Rate: ${successRate.toStringAsFixed(2)}%');
    print('Average Response Time: ${averageResponseTime.inMilliseconds}ms');
    print('Min Response Time: ${minResponseTime.inMilliseconds}ms');
    print('Max Response Time: ${maxResponseTime.inMilliseconds}ms');
    print('Total Duration: ${totalDuration.inSeconds}s');
    print('Throughput: ${throughput.toStringAsFixed(2)} ops/sec');

    if (errors.isNotEmpty) {
      print('\nErrors:');
      final errorCounts = <String, int>{};
      for (final error in errors) {
        errorCounts[error] = (errorCounts[error] ?? 0) + 1;
      }
      errorCounts.forEach((error, count) {
        print('  $error: $count times');
      });
    }
    print('=====================================\n');
  }
}

void main() {
  group('Database Service Load Tests', () {
    late TestDatabaseService databaseService;

    setUpAll(() async {
      // Initialize FFI for testing
      sqlfiteFfiInit();
    });

    setUp(() async {
      databaseService = TestDatabaseService();
      // Pre-initialize database
      await databaseService.database;
    });

    tearDown(() async {
      await databaseService.close();
    });

    test('Concurrent Read Operations - getAllMosquitoSpecies', () async {
      final metrics = LoadTestMetrics();
      const concurrentRequests = 50;
      const operationsPerRequest = 10;

      metrics.start();

      final futures = List.generate(concurrentRequests, (index) async {
        for (int i = 0; i < operationsPerRequest; i++) {
          final stopwatch = Stopwatch()..start();
          try {
            await databaseService.getAllMosquitoSpecies();
            stopwatch.stop();
            metrics.recordSuccess(stopwatch.elapsed);
          } catch (e) {
            stopwatch.stop();
            metrics.recordFailure(e.toString());
          }
        }
      });

      await Future.wait(futures);
      metrics.end();
      metrics.printSummary('Concurrent Read Operations');

      expect(metrics.successRate, greaterThan(95.0));
      expect(metrics.averageResponseTime.inMilliseconds, lessThan(1000));
    });

    test('High Volume Single Species Lookups', () async {
      final metrics = LoadTestMetrics();
      const numberOfLookups = 1000;
      final random = Random();

      metrics.start();

      for (int i = 0; i < numberOfLookups; i++) {
        final speciesId = (random.nextInt(1000) + 1).toString();
        final stopwatch = Stopwatch()..start();

        try {
          await databaseService.getMosquitoSpeciesById(speciesId);
          stopwatch.stop();
          metrics.recordSuccess(stopwatch.elapsed);
        } catch (e) {
          stopwatch.stop();
          metrics.recordFailure(e.toString());
        }
      }

      metrics.end();
      metrics.printSummary('High Volume Single Species Lookups');

      expect(metrics.successRate, greaterThan(95.0));
      expect(metrics.averageResponseTime.inMilliseconds, lessThan(100));
    });

    test('Concurrent Disease Queries', () async {
      final metrics = LoadTestMetrics();
      const concurrentUsers = 25;
      const queriesPerUser = 20;

      metrics.start();

      final futures = List.generate(concurrentUsers, (userIndex) async {
        for (int i = 0; i < queriesPerUser; i++) {
          final stopwatch = Stopwatch()..start();
          try {
            await databaseService.getAllDiseases();
            stopwatch.stop();
            metrics.recordSuccess(stopwatch.elapsed);
          } catch (e) {
            stopwatch.stop();
            metrics.recordFailure(e.toString());
          }
        }
      });

      await Future.wait(futures);
      metrics.end();
      metrics.printSummary('Concurrent Disease Queries');

      expect(metrics.successRate, greaterThan(95.0));
      expect(metrics.averageResponseTime.inMilliseconds, lessThan(500));
    });

    test('Mixed Operation Load Test', () async {
      final metrics = LoadTestMetrics();
      const totalOperations = 500;
      final random = Random();

      metrics.start();

      final futures = List.generate(totalOperations, (index) async {
        final stopwatch = Stopwatch()..start();

        try {
          final operationType = random.nextInt(4);
          switch (operationType) {
            case 0:
              await databaseService.getAllMosquitoSpecies();
              break;
            case 1:
              await databaseService.getAllDiseases();
              break;
            case 2:
              final speciesId = (random.nextInt(1000) + 1).toString();
              await databaseService.getMosquitoSpeciesById(speciesId);
              break;
            case 3:
              final speciesName = 'Test Species ${random.nextInt(1000) + 1}';
              await databaseService.getDiseasesByVector(speciesName);
              break;
          }
          stopwatch.stop();
          metrics.recordSuccess(stopwatch.elapsed);
        } catch (e) {
          stopwatch.stop();
          metrics.recordFailure(e.toString());
        }
      });

      // Execute with some concurrency but not all at once
      for (int start = 0; start < futures.length; start += 25) {
        final end = (start + 25).clamp(0, futures.length);
        await Future.wait(futures.sublist(start, end));
      }

      metrics.end();
      metrics.printSummary('Mixed Operation Load Test');

      expect(metrics.successRate, greaterThan(95.0));
      expect(metrics.averageResponseTime.inMilliseconds, lessThan(800));
    });
  });

  group('Classification Service Load Tests', () {
    late TestClassificationService classificationService;
    late MockFile mockImageFile;

    setUp(() async {
      classificationService = TestClassificationService();
      await classificationService.loadModel();

      mockImageFile = MockFile();
      when(mockImageFile.readAsBytes()).thenAnswer((_) async {
        // Return dummy image bytes
        return Uint8List.fromList(List.generate(1024, (i) => i % 256));
      });
    });

    test('Sequential Image Classification Performance', () async {
      final metrics = LoadTestMetrics();
      const numberOfClassifications = 100;

      metrics.start();

      for (int i = 0; i < numberOfClassifications; i++) {
        final stopwatch = Stopwatch()..start();

        try {
          await classificationService.classifyImage(mockImageFile);
          stopwatch.stop();
          metrics.recordSuccess(stopwatch.elapsed);
        } catch (e) {
          stopwatch.stop();
          metrics.recordFailure(e.toString());
        }
      }

      metrics.end();
      metrics.printSummary('Sequential Image Classification');

      expect(metrics.successRate, greaterThan(95.0));
      expect(metrics.averageResponseTime.inMilliseconds, lessThan(500));
    });

    test('Concurrent Image Classification', () async {
      final metrics = LoadTestMetrics();
      const concurrentClassifications = 10; // Limited due to model constraints
      const classificationsPerBatch = 5;

      metrics.start();

      final futures = List.generate(concurrentClassifications, (index) async {
        for (int i = 0; i < classificationsPerBatch; i++) {
          final stopwatch = Stopwatch()..start();
          try {
            await classificationService.classifyImage(mockImageFile);
            stopwatch.stop();
            metrics.recordSuccess(stopwatch.elapsed);
          } catch (e) {
            stopwatch.stop();
            metrics.recordFailure(e.toString());
          }
        }
      });

      await Future.wait(futures);
      metrics.end();
      metrics.printSummary('Concurrent Image Classification');

      expect(metrics.successRate, greaterThan(90.0)); // Slightly lower due to potential resource contention
      expect(metrics.averageResponseTime.inMilliseconds, lessThan(1000));
    });

    test('Model Loading Stress Test', () async {
      final metrics = LoadTestMetrics();
      const numberOfLoads = 20;

      metrics.start();

      for (int i = 0; i < numberOfLoads; i++) {
        final tempService = TestClassificationService();
        final stopwatch = Stopwatch()..start();

        try {
          await tempService.loadModel();
          stopwatch.stop();
          metrics.recordSuccess(stopwatch.elapsed);
        } catch (e) {
          stopwatch.stop();
          metrics.recordFailure(e.toString());
        }
      }

      metrics.end();
      metrics.printSummary('Model Loading Stress Test');

      expect(metrics.successRate, greaterThan(95.0));
      expect(metrics.averageResponseTime.inMilliseconds, lessThan(1000));
    });

    test('Memory Usage Simulation - Rapid Classifications', () async {
      final metrics = LoadTestMetrics();
      const rapidClassifications = 200;

      metrics.start();

      // Simulate rapid-fire classifications that might stress memory
      final futures = <Future>[];
      for (int i = 0; i < rapidClassifications; i++) {
        final future = () async {
          final stopwatch = Stopwatch()..start();
          try {
            await classificationService.classifyImage(mockImageFile);
            stopwatch.stop();
            metrics.recordSuccess(stopwatch.elapsed);
          } catch (e) {
            stopwatch.stop();
            metrics.recordFailure(e.toString());
          }
        }();

        futures.add(future);

        // Add small delays to prevent overwhelming the system
        if (i % 10 == 0) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }

      await Future.wait(futures);
      metrics.end();
      metrics.printSummary('Memory Usage Simulation');

      expect(metrics.successRate, greaterThan(85.0)); // Lower threshold due to stress
      expect(metrics.averageResponseTime.inMilliseconds, lessThan(1500));
    });
  });

  group('Integration Load Tests', () {
    late TestDatabaseService databaseService;
    late TestClassificationService classificationService;
    late MockFile mockImageFile;

    setUp(() async {
      databaseService = TestDatabaseService();
      classificationService = TestClassificationService();
      await classificationService.loadModel();

      mockImageFile = MockFile();
      when(mockImageFile.readAsBytes()).thenAnswer((_) async {
        return Uint8List.fromList(List.generate(1024, (i) => i % 256));
      });
    });

    tearDown(() async {
      await databaseService.close();
    });

    test('End-to-End Classification with Database Lookups', () async {
      final metrics = LoadTestMetrics();
      const numberOfOperations = 50;

      metrics.start();

      for (int i = 0; i < numberOfOperations; i++) {
        final stopwatch = Stopwatch()..start();

        try {
          // Simulate full classification workflow
          final result = await classificationService.classifyImage(mockImageFile);

          // Additional database operations that might happen after classification
          await databaseService.getMosquitoSpeciesById(result.species.id);
          await databaseService.getDiseasesByVector(result.species.name);

          stopwatch.stop();
          metrics.recordSuccess(stopwatch.elapsed);
        } catch (e) {
          stopwatch.stop();
          metrics.recordFailure(e.toString());
        }
      }

      metrics.end();
      metrics.printSummary('End-to-End Classification Workflow');

      expect(metrics.successRate, greaterThan(90.0));
      expect(metrics.averageResponseTime.inMilliseconds, lessThan(2000));
    });

    test('Concurrent Users Simulation', () async {
      final metrics = LoadTestMetrics();
      const concurrentUsers = 15;
      const operationsPerUser = 5;

      metrics.start();

      final futures = List.generate(concurrentUsers, (userIndex) async {
        for (int i = 0; i < operationsPerUser; i++) {
          final stopwatch = Stopwatch()..start();
          try {
            // Each user performs a classification followed by data lookups
            final result = await classificationService.classifyImage(mockImageFile);
            await databaseService.getAllMosquitoSpecies();
            await databaseService.getDiseasesByVector(result.species.name);

            stopwatch.stop();
            metrics.recordSuccess(stopwatch.elapsed);
          } catch (e) {
            stopwatch.stop();
            metrics.recordFailure(e.toString());
          }

          // Small delay between operations to simulate real user behavior
          await Future.delayed(const Duration(milliseconds: 100));
        }
      });

      await Future.wait(futures);
      metrics.end();
      metrics.printSummary('Concurrent Users Simulation');

      expect(metrics.successRate, greaterThan(85.0));
      expect(metrics.averageResponseTime.inMilliseconds, lessThan(3000));
    });
  });
}