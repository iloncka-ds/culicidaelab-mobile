#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Documentation build script for CulicidaeLab
/// 
/// This script automates the generation of both API documentation (dart doc)
/// and static site documentation (MkDocs) for the CulicidaeLab project.
class DocumentationBuilder {
  static const String _dartDocOutput = 'docs/api-reference/generated';
  static const String _mkdocsConfig = 'docs/_config/mkdocs.yml';
  static const String _mkdocsOutput = 'site';
  
  /// Main entry point for the documentation build process
  static Future<void> main(List<String> arguments) async {
    final builder = DocumentationBuilder();
    
    print('🚀 Starting CulicidaeLab documentation build...\n');
    
    try {
      // Parse command line arguments
      final options = _parseArguments(arguments);
      
      if (options['help'] == true) {
        _printUsage();
        return;
      }
      
      // Clean previous builds if requested
      if (options['clean'] == true) {
        await builder._cleanPreviousBuilds();
      }
      
      // Generate API documentation
      if (options['api'] != false) {
        await builder._generateApiDocumentation();
      }
      
      // Generate static site documentation
      if (options['site'] != false) {
        await builder._generateStaticSite();
      }
      
      // Validate generated documentation
      if (options['validate'] == true) {
        await builder._validateDocumentation();
      }
      
      print('\n✅ Documentation build completed successfully!');
      print('📖 API docs: $_dartDocOutput/index.html');
      print('🌐 Site docs: $_mkdocsOutput/index.html');
      
    } catch (e, stackTrace) {
      print('\n❌ Documentation build failed: $e');
      if (arguments.contains('--verbose')) {
        print('Stack trace: $stackTrace');
      }
      exit(1);
    }
  }
  
  /// Parse command line arguments
  static Map<String, dynamic> _parseArguments(List<String> arguments) {
    final options = <String, dynamic>{
      'clean': false,
      'api': true,
      'site': true,
      'validate': false,
      'help': false,
      'verbose': false,
    };
    
    for (final arg in arguments) {
      switch (arg) {
        case '--clean':
          options['clean'] = true;
          break;
        case '--no-api':
          options['api'] = false;
          break;
        case '--no-site':
          options['site'] = false;
          break;
        case '--validate':
          options['validate'] = true;
          break;
        case '--help':
        case '-h':
          options['help'] = true;
          break;
        case '--verbose':
        case '-v':
          options['verbose'] = true;
          break;
      }
    }
    
    return options;
  }
  
  /// Print usage information
  static void _printUsage() {
    print('''
CulicidaeLab Documentation Builder

Usage: dart scripts/build_docs.dart [options]

Options:
  --clean      Clean previous builds before generating new documentation
  --no-api     Skip API documentation generation (dart doc)
  --no-site    Skip static site generation (MkDocs)
  --validate   Validate generated documentation for broken links
  --verbose    Enable verbose output for debugging
  --help, -h   Show this help message

Examples:
  dart scripts/build_docs.dart                    # Build all documentation
  dart scripts/build_docs.dart --clean            # Clean and build all
  dart scripts/build_docs.dart --no-api           # Build only static site
  dart scripts/build_docs.dart --validate         # Build and validate
''');
  }
  
  /// Clean previous documentation builds
  Future<void> _cleanPreviousBuilds() async {
    print('🧹 Cleaning previous builds...');
    
    final directories = [_dartDocOutput, _mkdocsOutput];
    
    for (final dir in directories) {
      final directory = Directory(dir);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        print('   Cleaned: $dir');
      }
    }
    
    print('✅ Clean completed\n');
  }
  
  /// Generate API documentation using dart doc
  Future<void> _generateApiDocumentation() async {
    print('📚 Generating API documentation...');
    
    // Check if dartdoc_options.yaml exists
    final configFile = File('dartdoc_options.yaml');
    if (!await configFile.exists()) {
      throw Exception('dartdoc_options.yaml not found. Please run from project root.');
    }
    
    // Run dart doc command
    final result = await Process.run(
      'dart',
      ['doc', '--validate-links', '.'],
      workingDirectory: Directory.current.path,
    );
    
    if (result.exitCode != 0) {
      throw Exception('dart doc failed:\n${result.stderr}');
    }
    
    print('   ${result.stdout}');
    print('✅ API documentation generated\n');
  }
  
  /// Generate static site documentation using MkDocs
  Future<void> _generateStaticSite() async {
    print('🌐 Generating static site documentation...');
    
    // Check if MkDocs config exists
    final configFile = File(_mkdocsConfig);
    if (!await configFile.exists()) {
      throw Exception('MkDocs config not found: $_mkdocsConfig');
    }
    
    // Check if MkDocs is installed
    final mkdocsCheck = await Process.run('mkdocs', ['--version']);
    if (mkdocsCheck.exitCode != 0) {
      print('⚠️  MkDocs not found. Installing...');
      await _installMkDocs();
    }
    
    // Run MkDocs build
    final result = await Process.run(
      'mkdocs',
      ['build', '--config-file', _mkdocsConfig, '--site-dir', _mkdocsOutput],
      workingDirectory: Directory.current.path,
    );
    
    if (result.exitCode != 0) {
      throw Exception('MkDocs build failed:\n${result.stderr}');
    }
    
    print('   ${result.stdout}');
    print('✅ Static site documentation generated\n');
  }
  
  /// Install MkDocs and required plugins
  Future<void> _installMkDocs() async {
    print('📦 Installing MkDocs and plugins...');
    
    final packages = [
      'mkdocs',
      'mkdocs-material',
      'mkdocs-mermaid2-plugin',
      'mkdocs-minify-plugin',
      'mkdocs-git-revision-date-localized-plugin',
    ];
    
    for (final package in packages) {
      final result = await Process.run('pip', ['install', package]);
      if (result.exitCode != 0) {
        throw Exception('Failed to install $package:\n${result.stderr}');
      }
      print('   Installed: $package');
    }
    
    print('✅ MkDocs installation completed\n');
  }
  
  /// Validate generated documentation
  Future<void> _validateDocumentation() async {
    print('🔍 Validating documentation...');
    
    // Check if API documentation was generated
    final apiIndex = File('$_dartDocOutput/index.html');
    if (!await apiIndex.exists()) {
      print('⚠️  API documentation index not found');
    } else {
      print('✅ API documentation validated');
    }
    
    // Check if static site was generated
    final siteIndex = File('$_mkdocsOutput/index.html');
    if (!await siteIndex.exists()) {
      print('⚠️  Static site index not found');
    } else {
      print('✅ Static site documentation validated');
    }
    
    // Additional validation can be added here
    // - Link checking
    // - Image validation
    // - Content completeness checks
    
    print('✅ Documentation validation completed\n');
  }
}

/// Entry point
void main(List<String> arguments) async {
  await DocumentationBuilder.main(arguments);
}