#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Simple link checker for markdown documentation
/// 
/// This script specifically focuses on checking internal and external links
/// in markdown files for the CulicidaeLab documentation.
class LinkChecker {
  final List<String> _brokenLinks = [];
  final List<String> _warnings = [];
  
  /// Main entry point for link checking
  static Future<void> main(List<String> arguments) async {
    final checker = LinkChecker();
    
    print('🔗 Checking links in documentation...\n');
    
    try {
      final directory = arguments.isNotEmpty ? arguments[0] : 'docs';
      
      await checker._checkLinksInDirectory(directory);
      
      // Generate report
      checker._generateReport();
      
      // Exit with appropriate code
      if (checker._brokenLinks.isNotEmpty) {
        print('\n❌ Found ${checker._brokenLinks.length} broken links');
        exit(1);
      } else {
        print('\n✅ All links are valid!');
        exit(0);
      }
      
    } catch (e) {
      print('\n❌ Link checking failed: $e');
      exit(1);
    }
  }
  
  /// Check links in all markdown files in a directory
  Future<void> _checkLinksInDirectory(String dirPath) async {
    final directory = Directory(dirPath);
    
    if (!await directory.exists()) {
      throw Exception('Directory not found: $dirPath');
    }
    
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && _isMarkdownFile(entity.path)) {
        await _checkLinksInFile(entity);
      }
    }
  }
  
  /// Check if file is a markdown file
  bool _isMarkdownFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return extension == 'md' || extension == 'markdown';
  }
  
  /// Check links in a specific markdown file
  Future<void> _checkLinksInFile(File file) async {
    print('Checking: ${file.path}');
    
    final content = await file.readAsString();
    
    // Find all markdown links [text](url)
    final linkRegex = RegExp(r'\[([^\]]*)\]\(([^)]+)\)');
    final matches = linkRegex.allMatches(content);
    
    for (final match in matches) {
      final linkText = match.group(1) ?? '';
      final linkUrl = match.group(2) ?? '';
      
      await _checkLink(file.path, linkText, linkUrl);
    }
  }
  
  /// Check a specific link
  Future<void> _checkLink(String filePath, String linkText, String linkUrl) async {
    if (linkUrl.trim().isEmpty) {
      _warnings.add('Empty link in $filePath: [$linkText]');
      return;
    }
    
    if (linkUrl.startsWith('http://') || linkUrl.startsWith('https://')) {
      // External link - we'll just validate the URL format
      await _checkExternalLink(filePath, linkText, linkUrl);
    } else if (linkUrl.startsWith('#')) {
      // Anchor link - skip for now (would need content parsing)
      return;
    } else if (linkUrl.startsWith('mailto:')) {
      // Email link - basic validation
      _checkEmailLink(filePath, linkText, linkUrl);
    } else {
      // Internal link - check if file exists
      await _checkInternalLink(filePath, linkText, linkUrl);
    }
  }
  
  /// Check external link format
  Future<void> _checkExternalLink(String filePath, String linkText, String linkUrl) async {
    try {
      final uri = Uri.parse(linkUrl);
      if (!uri.hasScheme || !uri.hasAuthority) {
        _brokenLinks.add('Invalid external link in $filePath: $linkUrl');
      }
    } catch (e) {
      _brokenLinks.add('Malformed external link in $filePath: $linkUrl');
    }
  }
  
  /// Check email link format
  void _checkEmailLink(String filePath, String linkText, String linkUrl) {
    final emailRegex = RegExp(r'^mailto:[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(linkUrl)) {
      _brokenLinks.add('Invalid email link in $filePath: $linkUrl');
    }
  }
  
  /// Check internal link
  Future<void> _checkInternalLink(String filePath, String linkText, String linkUrl) async {
    // Handle relative paths
    final fileDir = File(filePath).parent;
    final targetPath = File('${fileDir.path}/$linkUrl');
    
    if (!await targetPath.exists()) {
      // Try absolute path from docs root
      final docsPath = File('docs/$linkUrl');
      if (!await docsPath.exists()) {
        _brokenLinks.add('Broken internal link in $filePath: $linkUrl');
      }
    }
  }
  
  /// Generate link checking report
  void _generateReport() {
    print('\n📊 Link Check Report');
    print('=' * 40);
    
    if (_brokenLinks.isNotEmpty) {
      print('\n❌ Broken Links (${_brokenLinks.length}):');
      for (final link in _brokenLinks) {
        print('   • $link');
      }
    }
    
    if (_warnings.isNotEmpty) {
      print('\n⚠️  Warnings (${_warnings.length}):');
      for (final warning in _warnings) {
        print('   • $warning');
      }
    }
    
    print('\nSummary:');
    print('   Broken links: ${_brokenLinks.length}');
    print('   Warnings: ${_warnings.length}');
  }
}

/// Entry point
void main(List<String> arguments) async {
  await LinkChecker.main(arguments);
}