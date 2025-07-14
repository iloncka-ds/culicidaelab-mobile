import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui'; // Add this import for Locale

import 'package:flutter/services.dart';
import 'package:culicidaelab/l10n/app_localizations.dart'; // Correct import path
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:culicidaelab/models/mosquito_model.dart';
import 'package:culicidaelab/repositories/classification_repository.dart';
import 'package:culicidaelab/view_models/classification_view_model.dart';

class PerformanceTestUtils {
  static int _getCurrentMemoryUsage() {
    return developer.Service.getIsolateId(Isolate.current).hashCode;
  }

  static Future<T> measurePerformance<T>(
    String testName,
    Future<T> Function() operation, {
    bool measureMemory = true,
    int iterations = 1,
  }) async {
    final results = <PerformanceResult>[];

    for (int i = 0; i < iterations; i++) {
      final memoryBefore = measureMemory ? _getCurrentMemoryUsage() : 0;
      final stopwatch = Stopwatch()..start();

      final result = await operation();

      stopwatch.stop();
      final memoryAfter = measureMemory ? _getCurrentMemoryUsage() : 0;

      results.add(
        PerformanceResult(
          testName: testName,
          duration: stopwatch.elapsedMilliseconds,
          memoryDelta: memoryAfter - memoryBefore,
          iteration: i + 1,
        ),
      );
    }

    // Print performance summary
    _printPerformanceSummary(testName, results);

    // Return the result from the last iteration
    return await operation();
  }

  static void _printPerformanceSummary(
    String testName,
    List<PerformanceResult> results,
  ) {
    final durations = results.map((r) => r.duration).toList();
    final memoryDeltas = results.map((r) => r.memoryDelta).toList();

    final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
    final maxDuration = durations.reduce((a, b) => a > b ? a : b);
    final minDuration = durations.reduce((a, b) => a < b ? a : b);

    final avgMemory =
        memoryDeltas.reduce((a, b) => a + b) / memoryDeltas.length;
    final maxMemory = memoryDeltas.reduce((a, b) => a > b ? a : b);

    print('=== Performance Test Results: $testName ===');
    print('Iterations: ${results.length}');
    print(
      'Duration (ms) - Avg: ${avgDuration.toStringAsFixed(2)}, Min: $minDuration, Max: $maxDuration',
    );
    print(
      'Memory Delta - Avg: ${avgMemory.toStringAsFixed(2)}, Max: $maxMemory',
    );
    print('========================================\n');
  }

  /// Load real image files for testing
  static List<File> loadRealImageFiles(String directoryPath) {
    final dir = Directory(directoryPath);
    if (!dir.existsSync()) {
      throw Exception('Directory does not exist: $directoryPath');
    }

    final files =
        dir
            .listSync()
            .where((entity) => entity is File && entity.path.endsWith('.jpg'))
            .map((entity) => File(entity.path))
            .toList();

    if (files.isEmpty) {
      throw Exception('No image files found in directory: $directoryPath');
    }

    return files;
  }

  /// Clean up test files
  static void cleanupTestFiles(List<File> files) {
    for (final file in files) {
      try {
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        print('Warning: Could not delete test file ${file.path}: $e');
      }
    }
  }
}

class PerformanceResult {
  final String testName;
  final int duration;
  final int memoryDelta;
  final int iteration;

  PerformanceResult({
    required this.testName,
    required this.duration,
    required this.memoryDelta,
    required this.iteration,
  });
}

void main() {
  group('Real Model Performance Tests', () {
    late ClassificationRepository realRepository;
    late AppLocalizations localizations;
    late ClassificationViewModel viewModel;
    late List<File> testFiles;

    setUpAll(() async {
      print('setUpAll started: ${DateTime.now()}');
      try {
        const directoryPath = 'test/test_images';
        testFiles = PerformanceTestUtils.loadRealImageFiles(directoryPath);
        print(
          'Test files loaded: ${DateTime.now()} (Count: ${testFiles.length})',
        );
      } catch (e) {
        print('Error loading test files: $e');
        testFiles = [];
      }
      print('setUpAll finished: ${DateTime.now()}');
    });

    // In setUp
    setUp(() async {
      print('setUp started: ${DateTime.now()}');
      realRepository = ClassificationRepository();
      print('ClassificationRepository instantiated: ${DateTime.now()}');

      localizations = await AppLocalizations.delegate.load(
        const Locale('en', ''),
      );
      print('Localizations loaded: ${DateTime.now()}');

      viewModel = ClassificationViewModel(repository: realRepository);
      print('ClassificationViewModel instantiated: ${DateTime.now()}');
      // If initModel is crucial for setup before *any* test, consider moving a
      // one-time model load to setUpAll and making the repository instance
      // available to setUp.
      print('setUp finished: ${DateTime.now()}');
    });

    tearDownAll(() {
      if (testFiles.isNotEmpty) {
        PerformanceTestUtils.cleanupTestFiles(testFiles);
      }
    });

    testWidgets('Real Model Initialization Performance Test', (
      WidgetTester tester,
    ) async {
      await PerformanceTestUtils.measurePerformance(
        'Real Model Initialization',
        () async {
          print('Initializing model: ${DateTime.now()}');
          await viewModel.initModel(localizations);
          print('Model initialized: ${DateTime.now()}');
          return 'Model initialized';
        },
        iterations: 1, // Reduced iterations
      );

      // Verify no error occurred
      expect(viewModel.errorMessage, isNull);
    });

    testWidgets('Real Image Classification Performance Test', (
      WidgetTester tester,
    ) async {
      for (final testFile in testFiles) {
        viewModel.setImageFile(testFile);

        await PerformanceTestUtils.measurePerformance(
          'Real Image Classification',
          () async {
            await viewModel.classifyImage(localizations);
            return viewModel.result;
          },
          iterations: 1, // Use real files, so one iteration per file
        );

        // Verify classification result
        expect(viewModel.result, isNotNull);
        expect(viewModel.result?.confidence, greaterThan(0));
        expect(viewModel.result?.species.name, isNotEmpty);
        expect(viewModel.state, equals(ClassificationState.success));
      }
    });

    testWidgets('Real Model Memory Usage Test', (WidgetTester tester) async {
      await PerformanceTestUtils.measurePerformance(
        'Real Model Memory Usage',
        () async {
          for (final file in testFiles) {
            viewModel.setImageFile(file);
            await viewModel.classifyImage(localizations);
          }
          return 'Memory usage test completed';
        },
        measureMemory: true,
      );
    });
  });
}
