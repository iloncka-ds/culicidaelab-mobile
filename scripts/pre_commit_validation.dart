#!/usr/bin/env dart

import 'dart:io';

/// Pre-commit validation for documentation changes
/// 
/// This script runs quick validation checks on documentation
/// files that have been modified in the current git working directory.
class PreCommitValidator {
  final bool _verbose;
  final List<String> _errors = [];
  final List<String> _warnings = [];
  
  PreCommitValidator({bool verbose = false}) : _verbose = verbose;
  
  /// Main entry point for pre-commit validation
  static Future<void> main(List<String> arguments) async {
    final verbose = arguments.contains('--verbose') || arguments.contains('-v');
    final validator = PreCommitValidator(verbose: verbose);
    
    if (arguments.contains('--help') || arguments.contains('-h')) {
      _printUsage();
      return;
    }
    
    print('🔍 Running pre-commit documentation validation...\n');
    
    try {
      await validator._runPreCommitChecks();
      validator._generateReport();
      
      if (validator._errors.isNotEmpty) {
        print('\n❌ Pre-commit validation failed');
        print('Please fix the issues above before committing.');
        exit(1);
      } else if (validator._warnings.isNotEmpty) {
        print('\n⚠️  Pre-commit validation completed with warnings');
        print('Consider addressing the warnings above.');
        exit(0);
      } else {
        print('\n✅ Pre-commit validation passed!');
        exit(0);
      }
      
    } catch (e) {
      print('\n❌ Pre-commit validation failed: $e');
      exit(1);
    }
  }
  
  /// Print usage information
  static void _printUsage() {
    print('''
CulicidaeLab Pre-commit Documentation Validation

Usage: dart scripts/pre_commit_validation.dart [options]

Options:
  --verbose, -v    Enable verbose output
  --help, -h       Show this help message

This script validates only the documentation files that have been
modified in the current git working directory.

To set up as a git pre-commit hook:
  ln -s ../../scripts/pre_commit_validation.dart .git/hooks/pre-commit
''');
  }
  
  /// Run pre-commit validation checks
  Future<void> _runPreCommitChecks() async {
    // Get list of modified documentation files
    final modifiedFiles = await _getModifiedDocumentationFiles();
    
    if (modifiedFiles.isEmpty) {
      print('No documentation files modified, skipping validation.');
      return;
    }
    
    print('Modified documentation files:');
    for (final file in modifiedFiles) {
      print('  • $file');
    }
    print('');
    
    // Run quick validation checks on modified files
    await _validateModifiedFiles(modifiedFiles);
  }
  
  /// Get list of modified documentation files
  Future<List<String>> _getModifiedDocumentationFiles() async {
    final result = await Process.run('git', ['diff', '--name-only', 'HEAD']);
    
    if (result.exitCode != 0) {
      // Fallback to staged files if no HEAD (initial commit)
      final stagedResult = await Process.run('git', ['diff', '--cached', '--name-only']);
      if (stagedResult.exitCode != 0) {
        throw Exception('Failed to get modified files from git');
      }
      result = stagedResult;
    }
    
    final allFiles = result.stdout.toString().split('\n').where((f) => f.isNotEmpty);
    
    // Filter for documentation-related files
    final docFiles = allFiles.where((file) {
      return file.startsWith('docs/') ||
             file.endsWith('.md') ||
             file == 'README.md' ||
             file == 'dartdoc_options.yaml' ||
             file == 'mkdocs.yml';
    }).toList();
    
    return docFiles;
  }
  
  /// Validate modified files
  Future<void> _validateModifiedFiles(List<String> files) async {
    for (final file in files) {
      await _validateFile(file);
    }
  }
  
  /// Validate a specific file
  Future<void> _validateFile(String filePath) async {
    final file = File(filePath);
    
    if (!await file.exists()) {
      _warnings.add('File marked as modified but not found: $filePath');
      return;
    }
    
    if (_verbose) {
      print('Validating: $filePath');
    }
    
    if (filePath.endsWith('.md')) {
      await _validateMarkdownFile(file);
    } else if (filePath == 'dartdoc_options.yaml') {
      await _validateDartdocOptions(file);
    } else if (filePath == 'mkdocs.yml') {
      await _validateMkdocsConfig(file);
    }
  }
  
  /// Validate markdown file
  Future<void> _validateMarkdownFile(File file) async {
    final content = await file.readAsString();
    final filePath = file.path;
    
    // Check for basic markdown issues
    await _checkMarkdownSyntax(filePath, content);
    await _checkMarkdownLinks(filePath, content);
    await _checkMarkdownCodeBlocks(filePath, content);
    await _checkMarkdownImages(filePath, content);
  }
  
  /// Check markdown syntax
  Future<void> _checkMarkdownSyntax(String filePath, String content) async {
    final lines = content.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNum = i + 1;
      
      // Check for common markdown issues
      if (line.contains('](') && !line.contains('](http') && !line.contains('](#') && !line.contains('](mailto:')) {
        // Potential internal link - check if it's properly formatted
        final linkMatch = RegExp(r'\]\(([^)]+)\)').firstMatch(line);
        if (linkMatch != null) {
          final linkPath = linkMatch.group(1)!;
          if (linkPath.contains(' ') && !linkPath.startsWith('"') && !linkPath.endsWith('"')) {
            _warnings.add('$filePath:$lineNum: Link path contains spaces, consider URL encoding: $linkPath');
          }
        }
      }
      
      // Check for trailing whitespace
      if (line.endsWith(' ') || line.endsWith('\t')) {
        _warnings.add('$filePath:$lineNum: Line has trailing whitespace');
      }
      
      // Check for very long lines
      if (line.length > 120) {
        _warnings.add('$filePath:$lineNum: Line is very long (${line.length} characters)');
      }
    }
  }
  
  /// Check markdown links
  Future<void> _checkMarkdownLinks(String filePath, String content) async {
    final linkRegex = RegExp(r'\[([^\]]*)\]\(([^)]+)\)');
    final matches = linkRegex.allMatches(content);
    
    for (final match in matches) {
      final linkText = match.group(1) ?? '';
      final linkUrl = match.group(2) ?? '';
      
      if (linkUrl.trim().isEmpty) {
        _errors.add('$filePath: Empty link URL for text: [$linkText]');
        continue;
      }
      
      // Check internal links
      if (!linkUrl.startsWith('http') && !linkUrl.startsWith('#') && !linkUrl.startsWith('mailto:')) {
        final targetFile = File(linkUrl);
        if (!await targetFile.exists()) {
          // Try relative to the current file's directory
          final currentDir = File(filePath).parent;
          final relativeTarget = File('${currentDir.path}/$linkUrl');
          if (!await relativeTarget.exists()) {
            _errors.add('$filePath: Broken internal link: $linkUrl');
          }
        }
      }
      
      // Check for empty link text
      if (linkText.trim().isEmpty) {
        _warnings.add('$filePath: Link has empty text: $linkUrl');
      }
    }
  }
  
  /// Check markdown code blocks
  Future<void> _checkMarkdownCodeBlocks(String filePath, String content) async {
    final codeBlockRegex = RegExp(r'```(\w+)?\n(.*?)\n```', dotAll: true);
    final matches = codeBlockRegex.allMatches(content);
    
    int blockIndex = 0;
    for (final match in matches) {
      blockIndex++;
      final language = match.group(1) ?? '';
      final code = match.group(2) ?? '';
      
      if (language.isEmpty) {
        _warnings.add('$filePath: Code block $blockIndex missing language specification');
      }
      
      if (code.trim().isEmpty) {
        _warnings.add('$filePath: Empty code block $blockIndex');
      }
      
      // Quick syntax check for Dart code
      if (language.toLowerCase() == 'dart') {
        await _quickDartSyntaxCheck(filePath, code, blockIndex);
      }
    }
  }
  
  /// Quick Dart syntax check
  Future<void> _quickDartSyntaxCheck(String filePath, String code, int blockIndex) async {
    // Check for common Dart syntax issues
    if (code.contains('print(') && !code.contains('// ignore:')) {
      _warnings.add('$filePath: Code block $blockIndex uses print() - consider debugPrint()');
    }
    
    if (code.contains('new ')) {
      _warnings.add('$filePath: Code block $blockIndex uses "new" keyword (not needed in Dart 2+)');
    }
    
    // Check for unmatched braces (basic check)
    final openBraces = '{'.allMatches(code).length;
    final closeBraces = '}'.allMatches(code).length;
    if (openBraces != closeBraces) {
      _warnings.add('$filePath: Code block $blockIndex may have unmatched braces');
    }
  }
  
  /// Check markdown images
  Future<void> _checkMarkdownImages(String filePath, String content) async {
    final imageRegex = RegExp(r'!\[([^\]]*)\]\(([^)]+)\)');
    final matches = imageRegex.allMatches(content);
    
    for (final match in matches) {
      final altText = match.group(1) ?? '';
      final imagePath = match.group(2) ?? '';
      
      // Check for missing alt text
      if (altText.trim().isEmpty) {
        _warnings.add('$filePath: Image missing alt text: $imagePath');
      }
      
      // Check if local image exists
      if (!imagePath.startsWith('http')) {
        final imageFile = File(imagePath);
        if (!await imageFile.exists()) {
          // Try relative to docs directory
          final docsImage = File('docs/$imagePath');
          if (!await docsImage.exists()) {
            _errors.add('$filePath: Missing image file: $imagePath');
          }
        }
      }
    }
  }
  
  /// Validate dartdoc options
  Future<void> _validateDartdocOptions(File file) async {
    final content = await file.readAsString();
    
    // Basic YAML syntax check
    if (content.contains('\t')) {
      _errors.add('${file.path}: YAML file contains tabs instead of spaces');
    }
    
    // Check for required dartdoc sections
    if (!content.contains('dartdoc:')) {
      _warnings.add('${file.path}: Missing dartdoc configuration section');
    }
  }
  
  /// Validate MkDocs configuration
  Future<void> _validateMkdocsConfig(File file) async {
    final content = await file.readAsString();
    
    // Basic YAML syntax check
    if (content.contains('\t')) {
      _errors.add('${file.path}: YAML file contains tabs instead of spaces');
    }
    
    // Check for required MkDocs sections
    final requiredSections = ['site_name', 'theme', 'nav'];
    for (final section in requiredSections) {
      if (!content.contains('$section:')) {
        _warnings.add('${file.path}: Missing recommended section: $section');
      }
    }
  }
  
  /// Generate validation report
  void _generateReport() {
    if (_errors.isNotEmpty) {
      print('\n❌ Errors found:');
      for (final error in _errors) {
        print('   • $error');
      }
    }
    
    if (_warnings.isNotEmpty) {
      print('\n⚠️  Warnings:');
      for (final warning in _warnings) {
        print('   • $warning');
      }
    }
    
    print('\nSummary:');
    print('   Errors: ${_errors.length}');
    print('   Warnings: ${_warnings.length}');
  }
}

/// Entry point
void main(List<String> arguments) async {
  await PreCommitValidator.main(arguments);
}