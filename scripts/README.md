# Documentation Build Scripts

This directory contains scripts for building the CulicidaeLab documentation system.

## Available Scripts

### `build_docs.dart`
The main Dart-based build script that provides comprehensive documentation generation with error handling and logging.

**Usage:**
```bash
dart scripts/build_docs.dart [options]
```

### `build_docs.sh` (Unix/Linux/macOS)
Shell script wrapper for Unix-like systems.

**Usage:**
```bash
./scripts/build_docs.sh [options]
```

### `build_docs.bat` (Windows)
Batch script for Windows systems.

**Usage:**
```cmd
scripts\build_docs.bat [options]
```

## Options

All scripts support the following options:

- `--clean` - Clean previous builds before generating new documentation
- `--no-api` - Skip API documentation generation (dart doc)
- `--no-site` - Skip static site generation (MkDocs)
- `--validate` - Validate generated documentation for broken links
- `--serve` - Start local development server after build (shell/batch scripts only)
- `--help`, `-h` - Show help message

## Examples

```bash
# Build all documentation
dart scripts/build_docs.dart

# Clean and build all documentation
./scripts/build_docs.sh --clean

# Build only static site documentation
scripts\build_docs.bat --no-api

# Build and serve locally
./scripts/build_docs.sh --serve

# Build with validation
dart scripts/build_docs.dart --validate
```

## Prerequisites

### For API Documentation (dart doc)
- Flutter/Dart SDK installed
- Run from project root directory
- `dartdoc_options.yaml` configuration file

### For Static Site (MkDocs)
- Python 3.6+ installed
- pip package manager
- MkDocs and plugins (automatically installed if missing)

Required Python packages:
- mkdocs
- mkdocs-material
- mkdocs-mermaid2-plugin
- mkdocs-minify-plugin
- mkdocs-git-revision-date-localized-plugin

## Output

The scripts generate documentation in the following locations:

- **API Documentation**: `docs/api-reference/generated/`
- **Static Site**: `site/`

## Troubleshooting

### Common Issues

1. **"dart command not found"**
   - Install Flutter SDK and ensure it's in your PATH

2. **"mkdocs command not found"**
   - The script will attempt to install MkDocs automatically
   - Ensure Python and pip are installed

3. **"dartdoc_options.yaml not found"**
   - Run the script from the project root directory

4. **Permission denied (Unix/Linux)**
   - Make the script executable: `chmod +x scripts/build_docs.sh`

### Getting Help

Run any script with `--help` to see detailed usage information:

```bash
dart scripts/build_docs.dart --help
```