#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// CI/CD validation orchestrator for CulicidaeLab documentation
/// 
/// This script coordinates all validation checks and provides
/// structured output for CI/CD pipelines.
class CIValidationOrchestrator {
  final List<ValidationResult> _results = [];
  final bool _verbose;
  final bool _failFast;
  
  CIValidationOrchestrator({
    bool verbose = false,
    bool failFast = false,
  }) : _verbose = verbose, _failFast = failFast;
  
  /// Main entry point for CI validation
  static Future<void> main(List<String> arguments) async {
    print('🚀 Starting CulicidaeLab CI/CD Documentation Validation\n');
    
    final options = _parseArguments(arguments);
    
    if (options['help'] == true) {
      _printUsage();
      return;
    }
    
    final orchestrator = CIValidationOrchestrator(
      verbose: options['verbose'] == true,
      failFast: options['fail-fast'] == true,
    );
    
    try {
      await orchestrator._runAllValidations(options);
      orchestrator._generateCIReport();
      
      // Determine exit code
      final hasErrors = orchestrator._results.any((r) => r.hasErrors);
      final hasWarnings = orchestrator._results.any((r) => r.hasWarnings);
      
      if (hasErrors) {
        print('\n❌ CI validation failed with errors');
        exit(1);
      } else if (hasWarnings && options['warnings-as-errors'] == true) {
        print('\n❌ CI validation failed (warnings treated as errors)');
        exit(1);
      } else if (hasWarnings) {
        print('\n⚠️  CI validation completed with warnings');
        exit(0);
      } else {
        print('\n✅ All CI validation checks passed!');
        exit(0);
      }
      
    } catch (e, stackTrace) {
      print('\n❌ CI validation failed: $e');
      if (options['verbose'] == true) {
        print('Stack trace: $stackTrace');
      }
      exit(1);
    }
  }
  
  /// Parse command line arguments
  static Map<String, dynamic> _parseArguments(List<String> arguments) {
    final options = <String, dynamic>{
      'directory': 'docs',
      'skip-links': false,
      'skip-code': false,
      'skip-docs': false,
      'skip-build': false,
      'warnings-as-errors': false,
      'fail-fast': false,
      'verbose': false,
      'help': false,
      'output-format': 'console', // console, json, junit
    };
    
    for (int i = 0; i < arguments.length; i++) {
      final arg = arguments[i];
      switch (arg) {
        case '--directory':
        case '-d':
          if (i + 1 < arguments.length) {
            options['directory'] = arguments[++i];
          }
          break;
        case '--skip-links':
          options['skip-links'] = true;
          break;
        case '--skip-code':
          options['skip-code'] = true;
          break;
        case '--skip-docs':
          options['skip-docs'] = true;
          break;
        case '--skip-build':
          options['skip-build'] = true;
          break;
        case '--warnings-as-errors':
          options['warnings-as-errors'] = true;
          break;
        case '--fail-fast':
          options['fail-fast'] = true;
          break;
        case '--verbose':
        case '-v':
          options['verbose'] = true;
          break;
        case '--output-format':
          if (i + 1 < arguments.length) {
            options['output-format'] = arguments[++i];
          }
          break;
        case '--help':
        case '-h':
          options['help'] = true;
          break;
      }
    }
    
    return options;
  }
  
  /// Print usage information
  static void _printUsage() {
    print('''
CulicidaeLab CI/CD Documentation Validation

Usage: dart scripts/ci_validation.dart [options]

Options:
  -d, --directory <path>      Documentation directory (default: docs)
  --skip-links                Skip link validation
  --skip-code                 Skip code example validation
  --skip-docs                 Skip documentation structure validation
  --skip-build                Skip build verification
  --warnings-as-errors        Treat warnings as errors
  --fail-fast                 Stop on first failure
  --output-format <format>    Output format: console, json, junit (default: console)
  --verbose, -v               Enable verbose output
  --help, -h                  Show this help message

Examples:
  dart scripts/ci_validation.dart                    # Run all validations
  dart scripts/ci_validation.dart --skip-links       # Skip link checking
  dart scripts/ci_validation.dart --warnings-as-errors # Strict mode
  dart scripts/ci_validation.dart --output-format json # JSON output
''');
  }
  
  /// Run all validation checks
  Future<void> _runAllValidations(Map<String, dynamic> options) async {
    final docsDir = options['directory'] as String;
    
    // 1. Documentation structure validation
    if (options['skip-docs'] != true) {
      await _runValidation(
        'Documentation Structure',
        () => _runDocumentationValidation(docsDir),
      );
    }
    
    // 2. Link validation
    if (options['skip-links'] != true) {
      await _runValidation(
        'Link Validation',
        () => _runLinkValidation(docsDir),
      );
    }
    
    // 3. Code example validation
    if (options['skip-code'] != true) {
      await _runValidation(
        'Code Example Validation',
        () => _runCodeValidation(docsDir),
      );
    }
    
    // 4. Build verification
    if (options['skip-build'] != true) {
      await _runValidation(
        'Build Verification',
        () => _runBuildVerification(),
      );
    }
  }
  
  /// Run a single validation with error handling
  Future<void> _runValidation(String name, Future<ValidationResult> Function() validator) async {
    print('🔍 Running $name...');
    
    try {
      final result = await validator();
      _results.add(result);
      
      if (_verbose) {
        print('   ${result.summary}');
      }
      
      if (_failFast && result.hasErrors) {
        throw Exception('Validation failed: $name');
      }
      
    } catch (e) {
      final errorResult = ValidationResult(
        name: name,
        success: false,
        errors: ['Validation execution failed: $e'],
        warnings: [],
        duration: Duration.zero,
      );
      _results.add(errorResult);
      
      if (_failFast) {
        rethrow;
      }
    }
  }
  
  /// Run documentation structure validation
  Future<ValidationResult> _runDocumentationValidation(String docsDir) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await Process.run('dart', ['scripts/validate_docs.dart', '--directory', docsDir]);
      stopwatch.stop();
      
      final output = result.stdout.toString();
      final errors = <String>[];
      final warnings = <String>[];
      
      // Parse output for errors and warnings
      final lines = output.split('\n');
      for (final line in lines) {
        if (line.contains('❌') || line.toLowerCase().contains('error')) {
          errors.add(line.trim());
        } else if (line.contains('⚠️') || line.toLowerCase().contains('warning')) {
          warnings.add(line.trim());
        }
      }
      
      return ValidationResult(
        name: 'Documentation Structure',
        success: result.exitCode == 0,
        errors: errors,
        warnings: warnings,
        duration: stopwatch.elapsed,
        details: _verbose ? output : null,
      );
      
    } catch (e) {
      stopwatch.stop();
      return ValidationResult(
        name: 'Documentation Structure',
        success: false,
        errors: ['Failed to run documentation validation: $e'],
        warnings: [],
        duration: stopwatch.elapsed,
      );
    }
  }
  
  /// Run link validation
  Future<ValidationResult> _runLinkValidation(String docsDir) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await Process.run('dart', ['scripts/check_links.dart', docsDir]);
      stopwatch.stop();
      
      final output = result.stdout.toString();
      final errors = <String>[];
      final warnings = <String>[];
      
      // Parse output for broken links
      final lines = output.split('\n');
      bool inBrokenSection = false;
      bool inWarningSection = false;
      
      for (final line in lines) {
        if (line.contains('❌ Broken Links')) {
          inBrokenSection = true;
          inWarningSection = false;
        } else if (line.contains('⚠️  Warnings')) {
          inBrokenSection = false;
          inWarningSection = true;
        } else if (line.contains('Summary:')) {
          inBrokenSection = false;
          inWarningSection = false;
        } else if (inBrokenSection && line.trim().startsWith('•')) {
          errors.add(line.trim().substring(1).trim());
        } else if (inWarningSection && line.trim().startsWith('•')) {
          warnings.add(line.trim().substring(1).trim());
        }
      }
      
      return ValidationResult(
        name: 'Link Validation',
        success: result.exitCode == 0,
        errors: errors,
        warnings: warnings,
        duration: stopwatch.elapsed,
        details: _verbose ? output : null,
      );
      
    } catch (e) {
      stopwatch.stop();
      return ValidationResult(
        name: 'Link Validation',
        success: false,
        errors: ['Failed to run link validation: $e'],
        warnings: [],
        duration: stopwatch.elapsed,
      );
    }
  }
  
  /// Run code example validation
  Future<ValidationResult> _runCodeValidation(String docsDir) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await Process.run('dart', ['scripts/validate_code.dart', docsDir]);
      stopwatch.stop();
      
      final output = result.stdout.toString();
      final errors = <String>[];
      final warnings = <String>[];
      
      // Parse output for code issues
      final lines = output.split('\n');
      bool inErrorSection = false;
      bool inWarningSection = false;
      
      for (final line in lines) {
        if (line.contains('❌ Errors')) {
          inErrorSection = true;
          inWarningSection = false;
        } else if (line.contains('⚠️  Warnings')) {
          inErrorSection = false;
          inWarningSection = true;
        } else if (line.contains('Summary:')) {
          inErrorSection = false;
          inWarningSection = false;
        } else if (inErrorSection && line.trim().startsWith('•')) {
          errors.add(line.trim().substring(1).trim());
        } else if (inWarningSection && line.trim().startsWith('•')) {
          warnings.add(line.trim().substring(1).trim());
        }
      }
      
      return ValidationResult(
        name: 'Code Example Validation',
        success: result.exitCode == 0,
        errors: errors,
        warnings: warnings,
        duration: stopwatch.elapsed,
        details: _verbose ? output : null,
      );
      
    } catch (e) {
      stopwatch.stop();
      return ValidationResult(
        name: 'Code Example Validation',
        success: false,
        errors: ['Failed to run code validation: $e'],
        warnings: [],
        duration: stopwatch.elapsed,
      );
    }
  }
  
  /// Run build verification
  Future<ValidationResult> _runBuildVerification() async {
    final stopwatch = Stopwatch()..start();
    final errors = <String>[];
    final warnings = <String>[];
    
    try {
      // Check if dartdoc_options.yaml exists
      if (!await File('dartdoc_options.yaml').exists()) {
        warnings.add('dartdoc_options.yaml not found, using defaults');
      }
      
      // Check if mkdocs.yml exists
      if (!await File('mkdocs.yml').exists()) {
        errors.add('mkdocs.yml not found - required for documentation build');
      } else {
        // Verify MkDocs can parse the configuration
        final mkdocsResult = await Process.run('python', ['-c', 'import yaml; yaml.safe_load(open("mkdocs.yml"))']);
        if (mkdocsResult.exitCode != 0) {
          errors.add('mkdocs.yml contains invalid YAML syntax');
        }
      }
      
      // Test dart doc generation (dry run)
      final dartdocResult = await Process.run('dart', ['doc', '--dry-run', '--validate-links']);
      if (dartdocResult.exitCode != 0) {
        errors.add('Dart doc generation failed: ${dartdocResult.stderr}');
      }
      
      // Test MkDocs build (if mkdocs.yml is valid)
      if (errors.isEmpty) {
        final mkdocsBuildResult = await Process.run('mkdocs', ['build', '--strict', '--quiet']);
        if (mkdocsBuildResult.exitCode != 0) {
          errors.add('MkDocs build failed: ${mkdocsBuildResult.stderr}');
        }
      }
      
      stopwatch.stop();
      
      return ValidationResult(
        name: 'Build Verification',
        success: errors.isEmpty,
        errors: errors,
        warnings: warnings,
        duration: stopwatch.elapsed,
      );
      
    } catch (e) {
      stopwatch.stop();
      return ValidationResult(
        name: 'Build Verification',
        success: false,
        errors: ['Build verification failed: $e'],
        warnings: warnings,
        duration: stopwatch.elapsed,
      );
    }
  }
  
  /// Generate CI report
  void _generateCIReport() {
    print('\n📊 CI/CD Validation Report');
    print('=' * 60);
    
    final totalDuration = _results.fold<Duration>(
      Duration.zero,
      (sum, result) => sum + result.duration,
    );
    
    print('\nValidation Summary:');
    for (final result in _results) {
      final status = result.success ? '✅' : '❌';
      final duration = '${result.duration.inMilliseconds}ms';
      print('   $status ${result.name.padRight(25)} ($duration)');
      
      if (!result.success && result.errors.isNotEmpty) {
        for (final error in result.errors.take(3)) {
          print('      • $error');
        }
        if (result.errors.length > 3) {
          print('      ... and ${result.errors.length - 3} more errors');
        }
      }
    }
    
    final totalErrors = _results.fold<int>(0, (sum, r) => sum + r.errors.length);
    final totalWarnings = _results.fold<int>(0, (sum, r) => sum + r.warnings.length);
    final successCount = _results.where((r) => r.success).length;
    
    print('\nOverall Results:');
    print('   Total validations: ${_results.length}');
    print('   Successful: $successCount');
    print('   Failed: ${_results.length - successCount}');
    print('   Total errors: $totalErrors');
    print('   Total warnings: $totalWarnings');
    print('   Total duration: ${totalDuration.inMilliseconds}ms');
    
    // Generate machine-readable output if requested
    _generateMachineReadableOutput();
  }
  
  /// Generate machine-readable output for CI systems
  void _generateMachineReadableOutput() {
    // Create JSON report for CI systems
    final jsonReport = {
      'timestamp': DateTime.now().toIso8601String(),
      'summary': {
        'total_validations': _results.length,
        'successful': _results.where((r) => r.success).length,
        'failed': _results.where((r) => !r.success).length,
        'total_errors': _results.fold<int>(0, (sum, r) => sum + r.errors.length),
        'total_warnings': _results.fold<int>(0, (sum, r) => sum + r.warnings.length),
        'duration_ms': _results.fold<Duration>(Duration.zero, (sum, r) => sum + r.duration).inMilliseconds,
      },
      'validations': _results.map((r) => r.toJson()).toList(),
    };
    
    // Write JSON report
    final jsonFile = File('validation-report.json');
    jsonFile.writeAsStringSync(jsonEncode(jsonReport));
    
    // Create JUnit XML for CI systems that support it
    _generateJUnitReport();
  }
  
  /// Generate JUnit XML report
  void _generateJUnitReport() {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    
    final totalTests = _results.length;
    final failures = _results.where((r) => !r.success).length;
    final totalTime = _results.fold<Duration>(Duration.zero, (sum, r) => sum + r.duration).inSeconds;
    
    buffer.writeln('<testsuite name="Documentation Validation" tests="$totalTests" failures="$failures" time="$totalTime">');
    
    for (final result in _results) {
      final time = result.duration.inSeconds;
      buffer.writeln('  <testcase name="${result.name}" time="$time">');
      
      if (!result.success) {
        buffer.writeln('    <failure message="Validation failed">');
        for (final error in result.errors) {
          buffer.writeln('      $error');
        }
        buffer.writeln('    </failure>');
      }
      
      if (result.warnings.isNotEmpty) {
        buffer.writeln('    <system-out>');
        for (final warning in result.warnings) {
          buffer.writeln('      WARNING: $warning');
        }
        buffer.writeln('    </system-out>');
      }
      
      buffer.writeln('  </testcase>');
    }
    
    buffer.writeln('</testsuite>');
    
    final junitFile = File('validation-junit.xml');
    junitFile.writeAsStringSync(buffer.toString());
  }
}

/// Validation result class
class ValidationResult {
  final String name;
  final bool success;
  final List<String> errors;
  final List<String> warnings;
  final Duration duration;
  final String? details;
  
  ValidationResult({
    required this.name,
    required this.success,
    required this.errors,
    required this.warnings,
    required this.duration,
    this.details,
  });
  
  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  
  String get summary {
    if (success) {
      return '✅ $name completed successfully';
    } else {
      return '❌ $name failed with ${errors.length} errors, ${warnings.length} warnings';
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'success': success,
      'errors': errors,
      'warnings': warnings,
      'duration_ms': duration.inMilliseconds,
      'details': details,
    };
  }
}

/// Entry point
void main(List<String> arguments) async {
  await CIValidationOrchestrator.main(arguments);
}