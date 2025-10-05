#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Documentation validation tools for CulicidaeLab
/// 
/// This script provides comprehensive validation for documentation content,
/// including link checking, code example validation, and content consistency checks.
class DocumentationValidator {
  static const List<String> _markdownExtensions = ['.md', '.markdown'];
  static const List<String> _codeLanguages = ['dart', 'yaml', 'json', 'bash', 'shell'];
  
  final List<ValidationError> _errors = [];
  final List<ValidationWarning> _warnings = [];
  
  /// Main entry point for documentation validation
  static Future<void> main(List<String> arguments) async {
    final validator = DocumentationValidator();
    
    print('🔍 Starting CulicidaeLab documentation validation...\n');
    
    try {
      final options = _parseArguments(arguments);
      
      if (options['help'] == true) {
        _printUsage();
        return;
      }
      
      final docsDir = options['directory'] as String? ?? 'docs';
      
      // Validate documentation structure
      await validator._validateDocumentationStructure(docsDir);
      
      // Validate markdown files
      if (options['links'] != false) {
        await validator._validateLinks(docsDir);
      }
      
      // Validate code examples
      if (options['code'] != false) {
        await validator._validateCodeExamples(docsDir);
      }
      
      // Validate images and assets
      if (options['assets'] != false) {
        await validator._validateAssets(docsDir);
      }
      
      // Generate validation report
      validator._generateReport();
      
      // Exit with appropriate code
      if (validator._errors.isNotEmpty) {
        print('\n❌ Validation failed with ${validator._errors.length} errors');
        exit(1);
      } else if (validator._warnings.isNotEmpty) {
        print('\n⚠️  Validation completed with ${validator._warnings.length} warnings');
        exit(0);
      } else {
        print('\n✅ All validation checks passed!');
        exit(0);
      }
      
    } catch (e, stackTrace) {
      print('\n❌ Validation failed: $e');
      if (arguments.contains('--verbose')) {
        print('Stack trace: $stackTrace');
      }
      exit(1);
    }
  }
  
  /// Parse command line arguments
  static Map<String, dynamic> _parseArguments(List<String> arguments) {
    final options = <String, dynamic>{
      'directory': 'docs',
      'links': true,
      'code': true,
      'assets': true,
      'help': false,
      'verbose': false,
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
        case '--no-links':
          options['links'] = false;
          break;
        case '--no-code':
          options['code'] = false;
          break;
        case '--no-assets':
          options['assets'] = false;
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
CulicidaeLab Documentation Validator

Usage: dart scripts/validate_docs.dart [options]

Options:
  -d, --directory <path>  Documentation directory to validate (default: docs)
  --no-links              Skip link validation
  --no-code               Skip code example validation
  --no-assets             Skip asset validation
  --verbose, -v           Enable verbose output
  --help, -h              Show this help message

Examples:
  dart scripts/validate_docs.dart                    # Validate all documentation
  dart scripts/validate_docs.dart -d docs            # Validate specific directory
  dart scripts/validate_docs.dart --no-links         # Skip link checking
  dart scripts/validate_docs.dart --verbose          # Verbose output
''');
  }
  
  /// Validate documentation structure
  Future<void> _validateDocumentationStructure(String docsDir) async {
    print('📁 Validating documentation structure...');
    
    final docsDirectory = Directory(docsDir);
    if (!await docsDirectory.exists()) {
      _addError('Documentation directory not found: $docsDir');
      return;
    }
    
    // Check for required directories
    final requiredDirs = [
      'user-guide',
      'developer-guide',
      'api-reference',
      'contribution',
      'research',
      'assets',
      '_config'
    ];
    
    for (final dir in requiredDirs) {
      final dirPath = '$docsDir/$dir';
      if (!await Directory(dirPath).exists()) {
        _addWarning('Recommended directory missing: $dirPath');
      }
    }
    
    // Check for main README
    final mainReadme = File('$docsDir/README.md');
    if (!await mainReadme.exists()) {
      _addError('Main documentation README.md not found in $docsDir');
    }
    
    print('✅ Structure validation completed\n');
  }
  
  /// Validate links in markdown files
  Future<void> _validateLinks(String docsDir) async {
    print('🔗 Validating links...');
    
    final markdownFiles = await _findMarkdownFiles(docsDir);
    
    for (final file in markdownFiles) {
      await _validateLinksInFile(file);
    }
    
    print('✅ Link validation completed\n');
  }
  
  /// Validate links in a specific file
  Future<void> _validateLinksInFile(File file) async {
    final content = await file.readAsString();
    final relativePath = file.path;
    
    // Regular expressions for different link types
    final markdownLinkRegex = RegExp(r'\[([^\]]*)\]\(([^)]+)\)');
    final referenceLinkRegex = RegExp(r'\[([^\]]*)\]:\s*(.+)');
    
    // Find all markdown links
    final markdownLinks = markdownLinkRegex.allMatches(content);
    for (final match in markdownLinks) {
      final linkText = match.group(1) ?? '';
      final linkUrl = match.group(2) ?? '';
      await _validateLink(relativePath, linkText, linkUrl);
    }
    
    // Find all reference links
    final referenceLinks = referenceLinkRegex.allMatches(content);
    for (final match in referenceLinks) {
      final linkText = match.group(1) ?? '';
      final linkUrl = match.group(2) ?? '';
      await _validateLink(relativePath, linkText, linkUrl);
    }
  }
  
  /// Validate a specific link
  Future<void> _validateLink(String filePath, String linkText, String linkUrl) async {
    // Skip empty links
    if (linkUrl.trim().isEmpty) {
      _addWarning('Empty link found in $filePath: [$linkText]');
      return;
    }
    
    // Handle different link types
    if (linkUrl.startsWith('http://') || linkUrl.startsWith('https://')) {
      // External link - basic validation
      await _validateExternalLink(filePath, linkText, linkUrl);
    } else if (linkUrl.startsWith('#')) {
      // Anchor link - validate within same file
      await _validateAnchorLink(filePath, linkText, linkUrl);
    } else if (linkUrl.startsWith('mailto:')) {
      // Email link - basic validation
      _validateEmailLink(filePath, linkText, linkUrl);
    } else {
      // Internal link - validate file exists
      await _validateInternalLink(filePath, linkText, linkUrl);
    }
  }
  
  /// Validate external links
  Future<void> _validateExternalLink(String filePath, String linkText, String linkUrl) async {
    try {
      final uri = Uri.parse(linkUrl);
      if (!uri.hasScheme || !uri.hasAuthority) {
        _addError('Invalid external link in $filePath: $linkUrl');
      }
      // Note: We don't actually make HTTP requests to avoid rate limiting
      // In a production environment, you might want to add HTTP checking
    } catch (e) {
      _addError('Malformed external link in $filePath: $linkUrl');
    }
  }
  
  /// Validate anchor links
  Future<void> _validateAnchorLink(String filePath, String linkText, String linkUrl) async {
    final file = File(filePath);
    if (await file.exists()) {
      final content = await file.readAsString();
      final anchor = linkUrl.substring(1); // Remove #
      
      // Check for heading that matches the anchor
      final headingRegex = RegExp(r'^#+\s+(.+)$', multiLine: true);
      final headings = headingRegex.allMatches(content);
      
      bool found = false;
      for (final heading in headings) {
        final headingText = heading.group(1) ?? '';
        final headingAnchor = _generateAnchor(headingText);
        if (headingAnchor == anchor) {
          found = true;
          break;
        }
      }
      
      if (!found) {
        _addWarning('Anchor link not found in $filePath: $linkUrl');
      }
    }
  }
  
  /// Validate email links
  void _validateEmailLink(String filePath, String linkText, String linkUrl) {
    final emailRegex = RegExp(r'^mailto:[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(linkUrl)) {
      _addError('Invalid email link in $filePath: $linkUrl');
    }
  }
  
  /// Validate internal links
  Future<void> _validateInternalLink(String filePath, String linkText, String linkUrl) async {
    final fileDir = Directory(File(filePath).parent.path);
    final targetPath = File('${fileDir.path}/$linkUrl').path;
    final targetFile = File(targetPath);
    
    if (!await targetFile.exists()) {
      _addError('Broken internal link in $filePath: $linkUrl -> $targetPath');
    }
  }
  
  /// Generate anchor from heading text
  String _generateAnchor(String headingText) {
    return headingText
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
  
  /// Validate code examples in markdown files
  Future<void> _validateCodeExamples(String docsDir) async {
    print('💻 Validating code examples...');
    
    final markdownFiles = await _findMarkdownFiles(docsDir);
    
    for (final file in markdownFiles) {
      await _validateCodeExamplesInFile(file);
    }
    
    print('✅ Code validation completed\n');
  }
  
  /// Validate code examples in a specific file
  Future<void> _validateCodeExamplesInFile(File file) async {
    final content = await file.readAsString();
    final relativePath = file.path;
    
    // Find code blocks
    final codeBlockRegex = RegExp(r'```(\w+)?\n(.*?)\n```', dotAll: true);
    final codeBlocks = codeBlockRegex.allMatches(content);
    
    for (final match in codeBlocks) {
      final language = match.group(1) ?? '';
      final code = match.group(2) ?? '';
      
      if (language.isNotEmpty && _codeLanguages.contains(language.toLowerCase())) {
        await _validateCodeBlock(relativePath, language, code);
      }
    }
  }
  
  /// Validate a specific code block
  Future<void> _validateCodeBlock(String filePath, String language, String code) async {
    switch (language.toLowerCase()) {
      case 'dart':
        await _validateDartCode(filePath, code);
        break;
      case 'yaml':
        _validateYamlCode(filePath, code);
        break;
      case 'json':
        _validateJsonCode(filePath, code);
        break;
      default:
        // Basic validation for other languages
        if (code.trim().isEmpty) {
          _addWarning('Empty code block in $filePath');
        }
    }
  }
  
  /// Validate Dart code syntax
  Future<void> _validateDartCode(String filePath, String code) async {
    // Create temporary file for syntax checking
    final tempFile = File('temp_dart_validation.dart');
    
    try {
      await tempFile.writeAsString(code);
      
      // Run dart analyze on the temporary file
      final result = await Process.run('dart', ['analyze', tempFile.path]);
      
      if (result.exitCode != 0) {
        _addError('Dart syntax error in $filePath:\n${result.stdout}');
      }
    } catch (e) {
      _addWarning('Could not validate Dart code in $filePath: $e');
    } finally {
      // Clean up temporary file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }
  
  /// Validate YAML syntax
  void _validateYamlCode(String filePath, String code) {
    try {
      // Basic YAML validation - check for common syntax errors
      final lines = code.split('\n');
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.contains('\t')) {
          _addError('YAML contains tabs instead of spaces in $filePath at line ${i + 1}');
        }
      }
    } catch (e) {
      _addError('YAML syntax error in $filePath: $e');
    }
  }
  
  /// Validate JSON syntax
  void _validateJsonCode(String filePath, String code) {
    try {
      jsonDecode(code);
    } catch (e) {
      _addError('JSON syntax error in $filePath: $e');
    }
  }
  
  /// Validate assets (images, videos, etc.)
  Future<void> _validateAssets(String docsDir) async {
    print('🖼️  Validating assets...');
    
    final markdownFiles = await _findMarkdownFiles(docsDir);
    
    for (final file in markdownFiles) {
      await _validateAssetsInFile(file, docsDir);
    }
    
    print('✅ Asset validation completed\n');
  }
  
  /// Validate assets referenced in a specific file
  Future<void> _validateAssetsInFile(File file, String docsDir) async {
    final content = await file.readAsString();
    final relativePath = file.path;
    
    // Find image references
    final imageRegex = RegExp(r'!\[([^\]]*)\]\(([^)]+)\)');
    final images = imageRegex.allMatches(content);
    
    for (final match in images) {
      final altText = match.group(1) ?? '';
      final imagePath = match.group(2) ?? '';
      
      if (!imagePath.startsWith('http')) {
        // Local image - check if file exists
        final fullPath = File('$docsDir/$imagePath').path;
        final imageFile = File(fullPath);
        
        if (!await imageFile.exists()) {
          _addError('Missing image in $relativePath: $imagePath');
        } else {
          // Check image file size (warn if too large)
          final stat = await imageFile.stat();
          if (stat.size > 1024 * 1024) { // 1MB
            _addWarning('Large image file in $relativePath: $imagePath (${(stat.size / 1024 / 1024).toStringAsFixed(1)}MB)');
          }
        }
      }
      
      // Check alt text
      if (altText.trim().isEmpty) {
        _addWarning('Missing alt text for image in $relativePath: $imagePath');
      }
    }
  }
  
  /// Find all markdown files in a directory
  Future<List<File>> _findMarkdownFiles(String docsDir) async {
    final files = <File>[];
    final directory = Directory(docsDir);
    
    if (await directory.exists()) {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          final extension = entity.path.toLowerCase().substring(entity.path.lastIndexOf('.'));
          if (_markdownExtensions.contains(extension)) {
            files.add(entity);
          }
        }
      }
    }
    
    return files;
  }
  
  /// Add validation error
  void _addError(String message) {
    _errors.add(ValidationError(message));
  }
  
  /// Add validation warning
  void _addWarning(String message) {
    _warnings.add(ValidationWarning(message));
  }
  
  /// Generate validation report
  void _generateReport() {
    print('\n📊 Validation Report');
    print('=' * 50);
    
    if (_errors.isNotEmpty) {
      print('\n❌ Errors (${_errors.length}):');
      for (final error in _errors) {
        print('   • ${error.message}');
      }
    }
    
    if (_warnings.isNotEmpty) {
      print('\n⚠️  Warnings (${_warnings.length}):');
      for (final warning in _warnings) {
        print('   • ${warning.message}');
      }
    }
    
    if (_errors.isEmpty && _warnings.isEmpty) {
      print('\n✅ No issues found!');
    }
    
    print('\nSummary:');
    print('   Errors: ${_errors.length}');
    print('   Warnings: ${_warnings.length}');
  }
}

/// Validation error class
class ValidationError {
  final String message;
  ValidationError(this.message);
}

/// Validation warning class
class ValidationWarning {
  final String message;
  ValidationWarning(this.message);
}

/// Entry point
void main(List<String> arguments) async {
  await DocumentationValidator.main(arguments);
}