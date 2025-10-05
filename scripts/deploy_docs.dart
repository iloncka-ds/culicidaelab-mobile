#!/usr/bin/env dart

import 'dart:io';

/// Documentation deployment script for CulicidaeLab
/// 
/// This script handles the deployment of documentation to GitHub Pages
/// and can be used both locally and in CI/CD environments.
class DocumentationDeployer {
  final bool _verbose;
  final String _environment;
  
  DocumentationDeployer({
    bool verbose = false,
    String environment = 'production',
  }) : _verbose = verbose, _environment = environment;
  
  /// Main entry point for documentation deployment
  static Future<void> main(List<String> arguments) async {
    final options = _parseArguments(arguments);
    
    if (options['help'] == true) {
      _printUsage();
      return;
    }
    
    final deployer = DocumentationDeployer(
      verbose: options['verbose'] == true,
      environment: options['environment'] as String? ?? 'production',
    );
    
    print('🚀 Starting CulicidaeLab documentation deployment...\n');
    
    try {
      await deployer._deployDocumentation(options);
      print('\n✅ Documentation deployment completed successfully!');
      
    } catch (e, stackTrace) {
      print('\n❌ Documentation deployment failed: $e');
      if (options['verbose'] == true) {
        print('Stack trace: $stackTrace');
      }
      exit(1);
    }
  }
  
  /// Parse command line arguments
  static Map<String, dynamic> _parseArguments(List<String> arguments) {
    final options = <String, dynamic>{
      'environment': 'production',
      'skip-build': false,
      'skip-validation': false,
      'dry-run': false,
      'verbose': false,
      'help': false,
    };
    
    for (int i = 0; i < arguments.length; i++) {
      final arg = arguments[i];
      switch (arg) {
        case '--environment':
        case '-e':
          if (i + 1 < arguments.length) {
            options['environment'] = arguments[++i];
          }
          break;
        case '--skip-build':
          options['skip-build'] = true;
          break;
        case '--skip-validation':
          options['skip-validation'] = true;
          break;
        case '--dry-run':
          options['dry-run'] = true;
          break;
        case '--verbose':
        case '-v':
          options['verbose'] = true;
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
CulicidaeLab Documentation Deployment

Usage: dart scripts/deploy_docs.dart [options]

Options:
  -e, --environment <env>    Deployment environment (default: production)
  --skip-build               Skip the build step
  --skip-validation          Skip validation checks
  --dry-run                  Show what would be deployed without actually deploying
  --verbose, -v              Enable verbose output
  --help, -h                 Show this help message

Environments:
  production                 Deploy to GitHub Pages (main branch)
  staging                    Deploy to staging environment
  local                      Build for local testing

Examples:
  dart scripts/deploy_docs.dart                    # Deploy to production
  dart scripts/deploy_docs.dart -e staging         # Deploy to staging
  dart scripts/deploy_docs.dart --dry-run          # Preview deployment
  dart scripts/deploy_docs.dart --skip-validation  # Skip validation
''');
  }
  
  /// Deploy documentation
  Future<void> _deployDocumentation(Map<String, dynamic> options) async {
    // Step 1: Pre-deployment validation
    if (options['skip-validation'] != true) {
      await _runPreDeploymentValidation();
    }
    
    // Step 2: Build documentation
    if (options['skip-build'] != true) {
      await _buildDocumentation();
    }
    
    // Step 3: Deploy based on environment
    if (options['dry-run'] != true) {
      await _deployToEnvironment(_environment);
    } else {
      await _showDeploymentPreview();
    }
  }
  
  /// Run pre-deployment validation
  Future<void> _runPreDeploymentValidation() async {
    print('🔍 Running pre-deployment validation...');
    
    // Check required files
    final requiredFiles = [
      'mkdocs.yml',
      'docs/README.md',
      'dartdoc_options.yaml',
    ];
    
    for (final file in requiredFiles) {
      if (!await File(file).exists()) {
        throw Exception('Required file not found: $file');
      }
    }
    
    // Run comprehensive validation
    final validationResult = await Process.run('dart', ['scripts/ci_validation.dart', '--warnings-as-errors']);
    
    if (validationResult.exitCode != 0) {
      throw Exception('Pre-deployment validation failed:\n${validationResult.stdout}');
    }
    
    print('✅ Pre-deployment validation passed');
  }
  
  /// Build documentation
  Future<void> _buildDocumentation() async {
    print('🔨 Building documentation...');
    
    // Step 1: Generate API documentation
    print('  📚 Generating API documentation...');
    final dartdocResult = await Process.run('dart', ['doc', '--output', 'docs/api-reference']);
    
    if (dartdocResult.exitCode != 0) {
      throw Exception('API documentation generation failed:\n${dartdocResult.stderr}');
    }
    
    // Step 2: Build MkDocs site
    print('  🏗️  Building MkDocs site...');
    final mkdocsResult = await Process.run('mkdocs', ['build', '--strict']);
    
    if (mkdocsResult.exitCode != 0) {
      throw Exception('MkDocs build failed:\n${mkdocsResult.stderr}');
    }
    
    // Step 3: Verify build output
    await _verifyBuildOutput();
    
    print('✅ Documentation build completed');
  }
  
  /// Verify build output
  Future<void> _verifyBuildOutput() async {
    final siteDir = Directory('site');
    
    if (!await siteDir.exists()) {
      throw Exception('Build output directory not found: site/');
    }
    
    // Check for essential files
    final essentialFiles = [
      'site/index.html',
      'site/search/search_index.json',
      'site/sitemap.xml',
    ];
    
    for (final file in essentialFiles) {
      if (!await File(file).exists()) {
        throw Exception('Essential build file missing: $file');
      }
    }
    
    // Check site size
    final siteSize = await _calculateDirectorySize(siteDir);
    if (_verbose) {
      print('  📊 Site size: ${(siteSize / 1024 / 1024).toStringAsFixed(2)} MB');
    }
    
    // Warn if site is very large
    if (siteSize > 100 * 1024 * 1024) { // 100MB
      print('  ⚠️  Warning: Site is very large (${(siteSize / 1024 / 1024).toStringAsFixed(2)} MB)');
    }
  }
  
  /// Calculate directory size
  Future<int> _calculateDirectorySize(Directory directory) async {
    int totalSize = 0;
    
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        final stat = await entity.stat();
        totalSize += stat.size;
      }
    }
    
    return totalSize;
  }
  
  /// Deploy to specific environment
  Future<void> _deployToEnvironment(String environment) async {
    switch (environment) {
      case 'production':
        await _deployToGitHubPages();
        break;
      case 'staging':
        await _deployToStaging();
        break;
      case 'local':
        await _deployLocally();
        break;
      default:
        throw Exception('Unknown deployment environment: $environment');
    }
  }
  
  /// Deploy to GitHub Pages
  Future<void> _deployToGitHubPages() async {
    print('🌐 Deploying to GitHub Pages...');
    
    // Check if we're in a CI environment
    final isCI = Platform.environment.containsKey('GITHUB_ACTIONS');
    
    if (isCI) {
      print('  🤖 Detected CI environment, deployment will be handled by GitHub Actions');
      return;
    }
    
    // For local deployment, use gh-pages or similar tool
    print('  📤 Deploying from local environment...');
    
    // Check if gh CLI is available
    final ghResult = await Process.run('gh', ['--version']);
    if (ghResult.exitCode == 0) {
      await _deployWithGitHubCLI();
    } else {
      await _deployWithGit();
    }
    
    print('✅ Deployment to GitHub Pages completed');
  }
  
  /// Deploy using GitHub CLI
  Future<void> _deployWithGitHubCLI() async {
    print('  🔧 Using GitHub CLI for deployment...');
    
    // Create a deployment
    final deployResult = await Process.run('gh', [
      'api',
      'repos/:owner/:repo/pages',
      '--method', 'POST',
      '--field', 'source[branch]=gh-pages',
      '--field', 'source[path]=/',
    ]);
    
    if (deployResult.exitCode != 0) {
      print('  ⚠️  GitHub CLI deployment failed, falling back to git...');
      await _deployWithGit();
    }
  }
  
  /// Deploy using git commands
  Future<void> _deployWithGit() async {
    print('  🔧 Using git for deployment...');
    
    // This is a simplified version - in practice, you'd want to use
    // a tool like mike or gh-pages for proper GitHub Pages deployment
    print('  ℹ️  For local deployment, consider using:');
    print('     mkdocs gh-deploy --clean --message "Deploy documentation"');
    
    // Run mkdocs gh-deploy if available
    final deployResult = await Process.run('mkdocs', ['gh-deploy', '--clean', '--message', 'Deploy documentation']);
    
    if (deployResult.exitCode != 0) {
      throw Exception('Git deployment failed:\n${deployResult.stderr}');
    }
  }
  
  /// Deploy to staging environment
  Future<void> _deployToStaging() async {
    print('🧪 Deploying to staging environment...');
    
    // For staging, you might deploy to a different branch or subdirectory
    print('  📝 Staging deployment not yet implemented');
    print('  💡 Consider setting up a staging branch or environment');
  }
  
  /// Deploy locally for testing
  Future<void> _deployLocally() async {
    print('🏠 Setting up local deployment...');
    
    // Start a local server for testing
    print('  🌐 Starting local server...');
    print('  📍 Documentation will be available at: http://localhost:8000');
    print('  🛑 Press Ctrl+C to stop the server');
    
    // Start mkdocs serve
    final serverProcess = await Process.start('mkdocs', ['serve', '--dev-addr', '0.0.0.0:8000']);
    
    // Handle process output
    serverProcess.stdout.transform(SystemEncoding().decoder).listen((data) {
      print('  📄 $data');
    });
    
    serverProcess.stderr.transform(SystemEncoding().decoder).listen((data) {
      print('  ⚠️  $data');
    });
    
    // Wait for the process to complete (or be interrupted)
    final exitCode = await serverProcess.exitCode;
    print('  🛑 Local server stopped (exit code: $exitCode)');
  }
  
  /// Show deployment preview
  Future<void> _showDeploymentPreview() async {
    print('👀 Deployment Preview (Dry Run)');
    print('=' * 50);
    
    print('\nEnvironment: $_environment');
    print('Build directory: site/');
    
    // Show site structure
    final siteDir = Directory('site');
    if (await siteDir.exists()) {
      print('\nSite structure:');
      await _showDirectoryStructure(siteDir, '  ');
      
      final siteSize = await _calculateDirectorySize(siteDir);
      print('\nSite size: ${(siteSize / 1024 / 1024).toStringAsFixed(2)} MB');
    }
    
    print('\n🚀 Ready for deployment to $_environment');
    print('   Run without --dry-run to actually deploy');
  }
  
  /// Show directory structure
  Future<void> _showDirectoryStructure(Directory directory, String prefix, {int maxDepth = 2, int currentDepth = 0}) async {
    if (currentDepth >= maxDepth) return;
    
    final entities = await directory.list().toList();
    entities.sort((a, b) => a.path.compareTo(b.path));
    
    for (final entity in entities.take(10)) { // Limit to first 10 items
      final name = entity.path.split('/').last;
      if (entity is Directory) {
        print('$prefix📁 $name/');
        await _showDirectoryStructure(entity, '$prefix  ', maxDepth: maxDepth, currentDepth: currentDepth + 1);
      } else {
        print('$prefix📄 $name');
      }
    }
    
    if (entities.length > 10) {
      print('$prefix... and ${entities.length - 10} more items');
    }
  }
}

/// Entry point
void main(List<String> arguments) async {
  await DocumentationDeployer.main(arguments);
}