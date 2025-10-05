#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Code example validator for documentation
/// 
/// This script validates code examples in markdown files to ensure
/// they are syntactically correct and follow best practices.
class CodeValidator {
  final List<String> _errors = [];
  final List<String> _warnings = [];
  
  /// Main entry point for code validation
  static Future<void> main(List<String> arguments) async {
    final validator = CodeValidator();
    
    print('💻 Validating code examples in documentation...\n');
    
    try {
      final directory = arguments.isNotEmpty ? arguments[0] : 'docs';
      
      await validator._validateCodeInDirectory(directory);
      
      // Generate report
      validator._generateReport();
      
      // Exit with appropriate code
      if (validator._errors.isNotEmpty) {
        print('\n❌ Found ${validator._errors.length} code errors');
        exit(1);
      } else if (validator._warnings.isNotEmpty) {
        print('\n⚠️  Validation completed with ${validator._warnings.length} warnings');
        exit(0);
      } else {
        print('\n✅ All code examples are valid!');
        exit(0);
      }
      
    } catch (e) {
      print('\n❌ Code validation failed: $e');
      exit(1);
    }
  }
  
  /// Validate code in all markdown files in a directory
  Future<void> _validateCodeInDirectory(String dirPath) async {
    final directory = Directory(dirPath);
    
    if (!await directory.exists()) {
      throw Exception('Directory not found: $dirPath');
    }
    
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && _isMarkdownFile(entity.path)) {
        await _validateCodeInFile(entity);
      }
    }
  }
  
  /// Check if file is a markdown file
  bool _isMarkdownFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return extension == 'md' || extension == 'markdown';
  }
  
  /// Validate code examples in a specific markdown file
  Future<void> _validateCodeInFile(File file) async {
    print('Checking: ${file.path}');
    
    final content = await file.readAsString();
    
    // Find code blocks with language specification
    final codeBlockRegex = RegExp(r'```(\w+)?\n(.*?)\n```', dotAll: true);
    final matches = codeBlockRegex.allMatches(content);
    
    int blockIndex = 0;
    for (final match in matches) {
      blockIndex++;
      final language = match.group(1) ?? '';
      final code = match.group(2) ?? '';
      
      if (language.isNotEmpty) {
        await _validateCodeBlock(file.path, language, code, blockIndex);
      } else {
        _warnings.add('Code block without language specification in ${file.path} (block $blockIndex)');
      }
    }
  }
  
  /// Validate a specific code block
  Future<void> _validateCodeBlock(String filePath, String language, String code, int blockIndex) async {
    final location = '$filePath (block $blockIndex)';
    
    // Check for empty code blocks
    if (code.trim().isEmpty) {
      _warnings.add('Empty code block in $location');
      return;
    }
    
    switch (language.toLowerCase()) {
      case 'dart':
        await _validateDartCode(location, code);
        break;
      case 'yaml':
      case 'yml':
        _validateYamlCode(location, code);
        break;
      case 'json':
        _validateJsonCode(location, code);
        break;
      case 'bash':
      case 'shell':
      case 'sh':
        _validateShellCode(location, code);
        break;
      case 'cmd':
      case 'batch':
        _validateBatchCode(location, code);
        break;
      default:
        // For other languages, just check basic formatting
        _validateGenericCode(location, code);
    }
  }
  
  /// Validate Dart code
  Future<void> _validateDartCode(String location, String code) async {
    // Create a temporary file for syntax checking
    final tempDir = Directory.systemTemp.createTempSync('dart_validation');
    final tempFile = File('${tempDir.path}/temp.dart');
    
    try {
      // Wrap code in a basic structure if it's not a complete program
      String wrappedCode = code;
      if (!code.contains('main(') && !code.contains('class ') && !code.contains('import ')) {
        wrappedCode = '''
// Auto-generated wrapper for validation
void main() {
$code
}
''';
      }
      
      await tempFile.writeAsString(wrappedCode);
      
      // Run dart analyze
      final result = await Process.run('dart', ['analyze', '--no-fatal-infos', tempFile.path]);
      
      if (result.exitCode != 0) {
        final output = result.stdout.toString();
        if (output.contains('error') || output.contains('Error')) {
          _errors.add('Dart syntax error in $location:\n${_cleanAnalyzeOutput(output)}');
        } else if (output.contains('warning') || output.contains('Warning')) {
          _warnings.add('Dart warning in $location:\n${_cleanAnalyzeOutput(output)}');
        }
      }
      
      // Additional Dart-specific checks
      _checkDartBestPractices(location, code);
      
    } catch (e) {
      _warnings.add('Could not validate Dart code in $location: $e');
    } finally {
      // Clean up
      try {
        await tempDir.delete(recursive: true);
      } catch (e) {
        // Ignore cleanup errors
      }
    }
  }
  
  /// Clean dart analyze output for better readability
  String _cleanAnalyzeOutput(String output) {
    return output
        .split('\n')
        .where((line) => line.contains('error') || line.contains('warning'))
        .take(3) // Limit to first 3 issues
        .join('\n');
  }
  
  /// Check Dart best practices
  void _checkDartBestPractices(String location, String code) {
    // Check for common issues
    if (code.contains('print(') && !code.contains('// ignore:')) {
      _warnings.add('Consider using debugPrint() instead of print() in $location');
    }
    
    if (code.contains('new ')) {
      _warnings.add('Unnecessary "new" keyword in $location (Dart 2+ style)');
    }
    
    // Check for proper async/await usage
    if (code.contains('async') && !code.contains('await') && !code.contains('return')) {
      _warnings.add('Async function without await in $location');
    }
  }
  
  /// Validate YAML code
  void _validateYamlCode(String location, String code) {
    try {
      // Check for tabs (YAML should use spaces)
      if (code.contains('\t')) {
        _errors.add('YAML contains tabs instead of spaces in $location');
      }
      
      // Check for basic YAML structure
      final lines = code.split('\n');
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        final lineNum = i + 1;
        
        // Check indentation consistency
        if (line.trim().isNotEmpty && line.startsWith(' ')) {
          final spaces = line.length - line.trimLeft().length;
          if (spaces % 2 != 0) {
            _warnings.add('Inconsistent YAML indentation in $location at line $lineNum');
          }
        }
        
        // Check for common YAML errors
        if (line.contains(': ') && line.endsWith(':')) {
          _warnings.add('Possible YAML syntax issue in $location at line $lineNum');
        }
      }
      
    } catch (e) {
      _errors.add('YAML validation error in $location: $e');
    }
  }
  
  /// Validate JSON code
  void _validateJsonCode(String location, String code) {
    try {
      jsonDecode(code);
    } catch (e) {
      _errors.add('JSON syntax error in $location: $e');
    }
  }
  
  /// Validate shell/bash code
  void _validateShellCode(String location, String code) {
    final lines = code.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final lineNum = i + 1;
      
      // Check for common shell issues
      if (line.startsWith('cd ') && !line.contains('&&') && i < lines.length - 1) {
        _warnings.add('Consider using && after cd command in $location at line $lineNum');
      }
      
      if (line.contains('rm -rf') && !line.contains('*')) {
        _warnings.add('Potentially dangerous rm -rf command in $location at line $lineNum');
      }
      
      // Check for unquoted variables
      if (line.contains('\$') && !line.contains('"\$') && !line.contains("'\$")) {
        _warnings.add('Consider quoting variables in $location at line $lineNum');
      }
    }
  }
  
  /// Validate batch/cmd code
  void _validateBatchCode(String location, String code) {
    final lines = code.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final lineNum = i + 1;
      
      // Check for common batch issues
      if (line.toLowerCase().startsWith('del ') && line.contains('*')) {
        _warnings.add('Potentially dangerous del command in $location at line $lineNum');
      }
      
      if (line.toLowerCase().startsWith('rd ') || line.toLowerCase().startsWith('rmdir ')) {
        _warnings.add('Directory deletion command in $location at line $lineNum');
      }
    }
  }
  
  /// Validate generic code
  void _validateGenericCode(String location, String code) {
    // Basic checks for any code
    final lines = code.split('\n');
    
    // Check for very long lines
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].length > 120) {
        _warnings.add('Long line (${lines[i].length} chars) in $location at line ${i + 1}');
      }
    }
    
    // Check for mixed line endings
    if (code.contains('\r\n') && code.contains('\n')) {
      _warnings.add('Mixed line endings in $location');
    }
  }
  
  /// Generate validation report
  void _generateReport() {
    print('\n📊 Code Validation Report');
    print('=' * 50);
    
    if (_errors.isNotEmpty) {
      print('\n❌ Errors (${_errors.length}):');
      for (final error in _errors) {
        print('   • $error');
      }
    }
    
    if (_warnings.isNotEmpty) {
      print('\n⚠️  Warnings (${_warnings.length}):');
      for (final warning in _warnings) {
        print('   • $warning');
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

/// Entry point
void main(List<String> arguments) async {
  await CodeValidator.main(arguments);
}