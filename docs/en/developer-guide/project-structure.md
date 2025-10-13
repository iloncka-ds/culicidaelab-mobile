# Project Structure and Conventions

## Overview

This document outlines the organizational structure of the CulicidaeLab Flutter project and the coding conventions used throughout the codebase. Understanding this structure is essential for effective development and maintaining consistency across the project.

## Project Root Structure

```
culicidaelab/
├── .devcontainer/              # Development container configuration
├── android/                    # Android-specific configuration and build files
├── assets/                     # Application assets (images, models, fonts, etc.)
├── docs/                       # Project documentation
├── integration_test/           # Integration test files
├── ios/                        # iOS-specific configuration and build files
├── lib/                        # Main Dart source code
├── scripts/                    # Build and utility scripts
├── test/                       # Unit and widget tests
├── analysis_options.yaml       # Dart analyzer configuration
├── dartdoc_options.yaml        # Documentation generation options
├── devtools_options.yaml       # Flutter DevTools configuration
├── l10n.yaml                   # Localization configuration
├── pubspec.yaml                # Project dependencies and metadata
└── README.md                   # Project overview and quick start
```

## Source Code Structure (`lib/`)

The `lib/` directory follows a feature-based organization with clear separation of concerns:

```
lib/
├── l10n/                       # Internationalization and localization
│   ├── app_en.arb             # English translations
│   ├── app_es.arb             # Spanish translations
│   ├── app_ru.arb             # Russian translations
│   ├── app_localizations.dart  # Generated localization class
│   └── app_localizations_*.dart # Generated language-specific classes
├── models/                     # Data models and entities
│   ├── disease_model.dart      # Disease information model
│   ├── mosquito_model.dart     # Mosquito species model
│   ├── observation_model.dart  # User observation data model
│   └── web_prediction_result.dart # AI prediction result model
├── providers/                  # State management providers
│   └── locale_provider.dart   # Language/locale state management
├── repositories/               # Data access layer
│   ├── classification_repository.dart # AI classification data access
│   └── mosquito_repository.dart # Mosquito and disease data access
├── screens/                    # UI screens and pages
│   ├── classification_screen.dart # Photo capture and classification
│   ├── disease_detail_screen.dart # Individual disease information
│   ├── disease_info_screen.dart # Disease information listing
│   ├── home_screen.dart        # Main navigation screen
│   ├── mosquito_detail_screen.dart # Individual mosquito details
│   ├── mosquito_gallery_screen.dart # Mosquito species gallery
│   ├── observation_details_screen.dart # User observation details
│   └── webview_screen.dart     # Web content display
├── services/                   # Business logic and external integrations
│   ├── classification_service.dart # AI model inference service
│   ├── database_service.dart   # Local database operations
│   ├── pytorch_lite_model.dart # PyTorch model wrapper (legacy)
│   ├── pytorch_wrapper.dart   # PyTorch model integration
│   └── user_service.dart       # User data and preferences
├── view_models/                # MVVM business logic layer
│   ├── classification_view_model.dart # Classification workflow logic
│   ├── disease_info_view_model.dart # Disease information logic
│   └── mosquito_gallery_view_model.dart # Gallery browsing logic
├── widgets/                    # Reusable UI components
│   ├── custom_empty_widget.dart # Empty state widget
│   └── icomoon_icons.dart      # Custom icon definitions
├── locator.dart                # Dependency injection configuration
└── main.dart                   # Application entry point
```

## Architecture Layers

### 1. Presentation Layer
- **Location**: `lib/screens/`, `lib/widgets/`
- **Purpose**: User interface components and user interaction handling
- **Naming Convention**: `*_screen.dart` for full screens, `*_widget.dart` for reusable components

### 2. Business Logic Layer
- **Location**: `lib/view_models/`, `lib/providers/`
- **Purpose**: Application state management and business rules
- **Naming Convention**: `*_view_model.dart` for MVVM logic, `*_provider.dart` for state providers

### 3. Data Access Layer
- **Location**: `lib/repositories/`
- **Purpose**: Abstract data access and coordination between services
- **Naming Convention**: `*_repository.dart`

### 4. Service Layer
- **Location**: `lib/services/`
- **Purpose**: External integrations, database operations, and specialized functionality
- **Naming Convention**: `*_service.dart`

### 5. Data Layer
- **Location**: `lib/models/`
- **Purpose**: Data structures and entity definitions
- **Naming Convention**: `*_model.dart`

## Assets Organization

```
assets/
├── database/                   # Database initialization files
│   └── database_data.json     # Initial data for local database
├── fonts/                      # Custom fonts
│   └── icomoon.ttf           # Icon font file
├── icons/                      # Application icons
├── images/                     # Static images
│   ├── diseases/              # Disease-related images
│   └── species/               # Mosquito species images
├── labels/                     # AI model label files
├── launcher_icon/              # App launcher icons
└── models/                     # AI model files
```

## Testing Structure

```
test/
├── fixtures/                   # Test data and mock files
├── performance/                # Performance testing
├── unit/                       # Unit tests
│   ├── models/                # Model tests
│   ├── repositories/          # Repository tests
│   ├── services/              # Service tests
│   └── view_models/           # ViewModel tests
└── widget/                     # Widget tests
    └── screens/               # Screen widget tests

integration_test/
└── app_test.dart              # End-to-end integration tests
```

## Documentation Structure

```
docs/
├── api-reference/              # Auto-generated API documentation
├── assets/                     # Documentation assets
│   ├── css/                   # Custom styling
│   ├── diagrams/              # Architecture diagrams
│   ├── images/                # Screenshots and illustrations
│   ├── js/                    # Custom JavaScript
│   └── videos/                # Tutorial videos
├── contribution/               # Contributor guidelines
│   └── issue-templates/       # GitHub issue templates
├── developer-guide/            # Technical documentation
├── developer-guide/            # Technical and research documentation
├── user-guide/                 # End-user documentation
├── _config/                    # Documentation build configuration
│   ├── mkdocs.yml             # MkDocs configuration
│   └── templates/             # Documentation templates
├── project_structure.md        # This document
└── README.md                   # Documentation overview
```

## Naming Conventions

### File Naming

- **Dart Files**: Use `snake_case` for all Dart files
  - ✅ `classification_service.dart`
  - ❌ `ClassificationService.dart`
  - ❌ `classification-service.dart`

- **Asset Files**: Use `snake_case` for consistency
  - ✅ `mosquito_species.json`
  - ❌ `mosquitoSpecies.json`

- **Directory Names**: Use `snake_case` or `kebab-case` consistently
  - ✅ `user_guide/`
  - ✅ `api-reference/`
  - ❌ `userGuide/`

### Class Naming

- **Classes**: Use `PascalCase`
  ```dart
  class ClassificationService { }
  class MosquitoModel { }
  class DiseaseInfoViewModel { }
  ```

- **Interfaces**: Use `PascalCase` with descriptive names
  ```dart
  abstract class DatabaseRepository { }
  abstract class ClassificationProvider { }
  ```

### Variable and Method Naming

- **Variables**: Use `camelCase`
  ```dart
  String mosquitoSpecies;
  List<DiseaseModel> diseaseList;
  bool isClassifying;
  ```

- **Methods**: Use `camelCase` with descriptive verbs
  ```dart
  Future<void> classifyImage() async { }
  List<MosquitoModel> getMosquitoSpecies() { }
  void updateClassificationState() { }
  ```

- **Constants**: Use `lowerCamelCase` for local constants, `SCREAMING_SNAKE_CASE` for global constants
  ```dart
  const String defaultLanguage = 'en';
  static const int MAX_IMAGE_SIZE = 1024;
  ```

### Widget Naming

- **Stateless Widgets**: Use `PascalCase` ending with descriptive suffix
  ```dart
  class MosquitoDetailCard extends StatelessWidget { }
  class ClassificationButton extends StatelessWidget { }
  ```

- **Stateful Widgets**: Use `PascalCase` for the widget, `_PascalCaseState` for the state
  ```dart
  class ClassificationScreen extends StatefulWidget { }
  class _ClassificationScreenState extends State<ClassificationScreen> { }
  ```

## Code Organization Patterns

### Import Organization

Organize imports in the following order with blank lines between groups:

```dart
// 1. Dart core libraries
import 'dart:async';
import 'dart:io';

// 2. Flutter framework
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// 4. Internal imports (relative paths)
import '../models/mosquito_model.dart';
import '../services/classification_service.dart';
import '../widgets/custom_empty_widget.dart';
```

### Class Structure

Organize class members in the following order:

```dart
class ExampleClass {
  // 1. Static constants
  static const String CONSTANT_VALUE = 'value';
  
  // 2. Instance variables (private first, then public)
  final String _privateField;
  final String publicField;
  
  // 3. Constructor
  ExampleClass({
    required this.publicField,
    String? privateField,
  }) : _privateField = privateField ?? 'default';
  
  // 4. Getters and setters
  String get privateField => _privateField;
  
  // 5. Public methods
  void publicMethod() { }
  
  // 6. Private methods
  void _privateMethod() { }
  
  // 7. Override methods
  @override
  String toString() => 'ExampleClass($_privateField)';
}
```

### Method Organization

- Keep methods focused and single-purpose
- Use descriptive names that explain what the method does
- Limit method length to ~50 lines when possible
- Extract complex logic into private helper methods

```dart
// Good: Descriptive and focused
Future<ClassificationResult> classifyMosquitoImage(File imageFile) async {
  final processedImage = await _preprocessImage(imageFile);
  final prediction = await _runModelInference(processedImage);
  return _parseClassificationResult(prediction);
}

// Helper methods for complex operations
Future<Uint8List> _preprocessImage(File imageFile) async { }
Future<List<double>> _runModelInference(Uint8List imageData) async { }
ClassificationResult _parseClassificationResult(List<double> output) { }
```

## Coding Standards

### Dart Style Guidelines

The project follows the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) with these specific conventions:

#### Line Length
- Maximum line length: **120 characters**
- Configured in `analysis_options.yaml` and IDE settings

#### Formatting
- Use `flutter format .` to automatically format code
- Enable "Format on Save" in your IDE
- Use trailing commas for better diffs and formatting

```dart
// Good: Trailing commas and proper formatting
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Classification'),
      backgroundColor: Colors.teal,
    ),
    body: Column(
      children: [
        ClassificationButton(),
        ResultsDisplay(),
      ],
    ),
  );
}
```

#### Documentation Comments

Use dartdoc comments for public APIs:

```dart
/// Classifies a mosquito image using the trained PyTorch model.
///
/// Takes an [imageFile] and returns a [ClassificationResult] containing
/// the predicted species and confidence score. Throws [ClassificationException]
/// if the image cannot be processed.
///
/// Example:
/// ```dart
/// final result = await classifyMosquitoImage(imageFile);
/// print('Species: ${result.species}, Confidence: ${result.confidence}');
/// ```
Future<ClassificationResult> classifyMosquitoImage(File imageFile) async {
  // Implementation
}
```

### Error Handling

#### Exception Handling
- Use specific exception types when possible
- Provide meaningful error messages
- Log errors appropriately for debugging

```dart
try {
  final result = await classificationService.classify(image);
  return result;
} on ClassificationException catch (e) {
  logger.error('Classification failed: ${e.message}');
  throw ClassificationException('Unable to classify image: ${e.message}');
} catch (e) {
  logger.error('Unexpected error during classification: $e');
  throw Exception('An unexpected error occurred');
}
```

#### Null Safety
- Use null safety features effectively
- Prefer non-nullable types when possible
- Use null-aware operators appropriately

```dart
// Good: Clear null handling
String? getUserName() {
  return user?.name?.trim().isEmpty == true ? null : user?.name?.trim();
}

// Better: Using null-aware operators
String? getUserName() => user?.name?.trim().nullIfEmpty;
```

### State Management Patterns

#### Provider Pattern
- Use `ChangeNotifier` for simple state management
- Implement proper disposal of resources
- Use `Consumer` widgets for targeted rebuilds

```dart
class ClassificationViewModel extends ChangeNotifier {
  bool _isClassifying = false;
  ClassificationResult? _result;
  
  bool get isClassifying => _isClassifying;
  ClassificationResult? get result => _result;
  
  Future<void> classifyImage(File image) async {
    _isClassifying = true;
    notifyListeners();
    
    try {
      _result = await _repository.classifyImage(image);
    } finally {
      _isClassifying = false;
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}
```

### Testing Conventions

#### Test File Organization
- Mirror the `lib/` structure in `test/`
- Use `_test.dart` suffix for test files
- Group related tests using `group()` function

```dart
// test/unit/services/classification_service_test.dart
void main() {
  group('ClassificationService', () {
    late ClassificationService service;
    
    setUp(() {
      service = ClassificationService();
    });
    
    group('classifyImage', () {
      test('should return valid result for valid image', () async {
        // Test implementation
      });
      
      test('should throw exception for invalid image', () async {
        // Test implementation
      });
    });
  });
}
```

#### Test Naming
- Use descriptive test names that explain the scenario
- Follow the pattern: "should [expected behavior] when [condition]"

```dart
test('should return Aedes aegypti when image contains yellow fever mosquito', () {
  // Test implementation
});

test('should throw ClassificationException when image is corrupted', () {
  // Test implementation
});
```

## Performance Guidelines

### Memory Management
- Dispose of controllers and streams properly
- Use `const` constructors when possible
- Avoid memory leaks in long-lived objects

### Image Handling
- Compress images before processing
- Cache processed images appropriately
- Dispose of image resources after use

### Database Operations
- Use batch operations for multiple inserts
- Implement proper indexing for queries
- Close database connections properly

## Security Considerations

### Data Protection
- Never commit sensitive data to version control
- Use secure storage for sensitive information
- Validate all user inputs

### API Security
- Use HTTPS for all network communications
- Implement proper authentication
- Validate server responses

## Localization Guidelines

### Adding New Languages
1. Create new `.arb` file in `lib/l10n/`
2. Add translations for all existing keys
3. Update `l10n.yaml` configuration
4. Run `flutter gen-l10n` to generate classes

### Translation Keys
- Use descriptive, hierarchical keys
- Group related translations
- Provide context for translators

```json
{
  "classification_screen_title": "Mosquito Classification",
  "classification_button_capture": "Capture Photo",
  "classification_button_gallery": "Choose from Gallery",
  "classification_result_species": "Species: {species}",
  "classification_result_confidence": "Confidence: {confidence}%"
}
```

## Git Workflow

### Branch Naming
- `feature/description` for new features
- `bugfix/description` for bug fixes
- `hotfix/description` for urgent fixes
- `docs/description` for documentation updates

### Commit Messages
Follow conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

Examples:
```
feat(classification): add confidence threshold setting
fix(database): resolve migration issue for disease table
docs(api): update classification service documentation
```

## Conclusion

Following these conventions ensures consistency, maintainability, and collaboration effectiveness across the CulicidaeLab project. When in doubt, refer to the official Dart and Flutter style guides, and maintain consistency with existing code patterns in the project.