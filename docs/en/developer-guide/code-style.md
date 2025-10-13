# Code Style Guide

## Overview

This document defines the coding standards and style guidelines for the CulicidaeLab Flutter project. Consistent code style improves readability, maintainability, and collaboration among team members.

## General Principles

### Code Quality Standards

1. **Readability First**: Code should be self-documenting and easy to understand
2. **Consistency**: Follow established patterns throughout the codebase
3. **Simplicity**: Prefer simple, clear solutions over complex ones
4. **Performance**: Write efficient code without premature optimization
5. **Testability**: Design code to be easily testable

### SOLID Principles

- **Single Responsibility**: Each class should have one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Subtypes must be substitutable for their base types
- **Interface Segregation**: Depend on abstractions, not concretions
- **Dependency Inversion**: High-level modules should not depend on low-level modules

## Dart Language Guidelines

### Variable Declarations

#### Prefer `final` and `const`
```dart
// Good: Use final for runtime constants
final String userName = getCurrentUser().name;
final List<String> items = ['item1', 'item2'];

// Good: Use const for compile-time constants
const String apiUrl = 'https://api.culicidaelab.org';
const Duration timeout = Duration(seconds: 30);

// Avoid: Unnecessary mutability
String userName = getCurrentUser().name; // Won't change
```

#### Type Annotations
```dart
// Good: Explicit types for public APIs
String getUserName() {
  return _currentUser.name;
}

// Good: Inferred types for local variables
final items = <String>['item1', 'item2'];
final user = await userService.getCurrentUser();

// Avoid: Redundant type annotations
String userName = String('John'); // Type is obvious
```

### Function and Method Design

#### Function Length
- Keep functions under 50 lines when possible
- Extract complex logic into helper functions
- Use descriptive names that explain the function's purpose

```dart
// Good: Focused, single-purpose function
Future<ClassificationResult> classifyMosquitoImage(File imageFile) async {
  _validateImageFile(imageFile);
  final processedImage = await _preprocessImage(imageFile);
  final prediction = await _runInference(processedImage);
  return _createResult(prediction);
}

// Good: Helper functions for complex operations
void _validateImageFile(File imageFile) {
  if (!imageFile.existsSync()) {
    throw ArgumentError('Image file does not exist');
  }
  if (imageFile.lengthSync() > maxImageSize) {
    throw ArgumentError('Image file too large');
  }
}
```

#### Parameter Design
```dart
// Good: Named parameters for clarity
void createObservation({
  required String species,
  required double confidence,
  required DateTime timestamp,
  String? notes,
  Location? location,
}) {
  // Implementation
}

// Good: Use objects for multiple related parameters
void createObservation(ObservationData data) {
  // Implementation
}

// Avoid: Too many positional parameters
void createObservation(String species, double confidence, DateTime timestamp, 
                      String notes, double lat, double lng) {
  // Hard to use correctly
}
```

### Error Handling

#### Exception Types
```dart
// Good: Specific exception types
class ClassificationException implements Exception {
  final String message;
  final String? code;
  
  const ClassificationException(this.message, {this.code});
  
  @override
  String toString() => 'ClassificationException: $message';
}

// Good: Use specific exceptions
Future<ClassificationResult> classify(File image) async {
  if (!image.existsSync()) {
    throw ClassificationException('Image file not found');
  }
  
  try {
    return await _performClassification(image);
  } on ModelException catch (e) {
    throw ClassificationException('Model inference failed: ${e.message}');
  }
}
```

#### Error Propagation
```dart
// Good: Let specific exceptions bubble up
Future<void> saveObservation(Observation observation) async {
  try {
    await database.insert(observation);
  } on DatabaseException {
    // Let database exceptions propagate
    rethrow;
  } catch (e) {
    // Handle unexpected errors
    throw ObservationException('Failed to save observation: $e');
  }
}
```

### Null Safety

#### Null-Aware Operators
```dart
// Good: Use null-aware operators effectively
String getDisplayName(User? user) {
  return user?.name ?? 'Anonymous';
}

// Good: Null-aware method calls
void updateUserPreferences(User? user) {
  user?.preferences?.update();
}

// Good: Null assertion when you're certain
String getUserId() {
  return currentUser!.id; // Only if you're certain currentUser is not null
}
```

#### Nullable vs Non-Nullable
```dart
// Good: Clear nullability contracts
class UserService {
  User? _currentUser;
  
  // Nullable return when user might not exist
  User? getCurrentUser() => _currentUser;
  
  // Non-nullable when user is required
  User getRequiredUser() {
    final user = _currentUser;
    if (user == null) {
      throw StateError('No user logged in');
    }
    return user;
  }
}
```

## Flutter-Specific Guidelines

### Widget Design

#### Widget Composition
```dart
// Good: Compose widgets for reusability
class MosquitoCard extends StatelessWidget {
  final MosquitoModel mosquito;
  final VoidCallback? onTap;
  
  const MosquitoCard({
    Key? key,
    required this.mosquito,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: MosquitoImage(mosquito.imagePath),
        title: Text(mosquito.commonName),
        subtitle: Text(mosquito.scientificName),
        onTap: onTap,
      ),
    );
  }
}
```

#### State Management
```dart
// Good: Clear state management with Provider
class ClassificationViewModel extends ChangeNotifier {
  ClassificationState _state = ClassificationState.idle;
  ClassificationResult? _result;
  String? _error;
  
  ClassificationState get state => _state;
  ClassificationResult? get result => _result;
  String? get error => _error;
  
  Future<void> classifyImage(File image) async {
    _setState(ClassificationState.loading);
    
    try {
      final result = await _classificationService.classify(image);
      _result = result;
      _setState(ClassificationState.success);
    } catch (e) {
      _error = e.toString();
      _setState(ClassificationState.error);
    }
  }
  
  void _setState(ClassificationState newState) {
    _state = newState;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

#### Build Method Organization
```dart
// Good: Organized build method
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(context),
    body: _buildBody(context),
    floatingActionButton: _buildFAB(context),
  );
}

Widget _buildAppBar(BuildContext context) {
  return AppBar(
    title: Text(AppLocalizations.of(context)!.classificationTitle),
    actions: [
      IconButton(
        icon: const Icon(Icons.help),
        onPressed: () => _showHelp(context),
      ),
    ],
  );
}

Widget _buildBody(BuildContext context) {
  return Consumer<ClassificationViewModel>(
    builder: (context, viewModel, child) {
      switch (viewModel.state) {
        case ClassificationState.idle:
          return _buildIdleState(context);
        case ClassificationState.loading:
          return _buildLoadingState(context);
        case ClassificationState.success:
          return _buildSuccessState(context, viewModel.result!);
        case ClassificationState.error:
          return _buildErrorState(context, viewModel.error!);
      }
    },
  );
}
```

### Performance Best Practices

#### Widget Optimization
```dart
// Good: Use const constructors
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

// Good: Extract expensive widgets
class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<DataViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            child!, // Reuse expensive child widget
            Text(viewModel.dynamicData),
          ],
        );
      },
      child: const ExpensiveChildWidget(), // Built once, reused
    );
  }
}
```

#### Memory Management
```dart
// Good: Proper disposal of resources
class ClassificationScreen extends StatefulWidget {
  @override
  _ClassificationScreenState createState() => _ClassificationScreenState();
}

class _ClassificationScreenState extends State<ClassificationScreen> {
  late StreamSubscription _subscription;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _subscription = eventStream.listen(_handleEvent);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _subscription.cancel();
    super.dispose();
  }
  
  // Widget implementation
}
```

## Architecture Patterns

### MVVM Implementation

#### ViewModel Structure
```dart
// Good: Clear ViewModel with proper separation
class MosquitoGalleryViewModel extends ChangeNotifier {
  final MosquitoRepository _repository;
  
  List<MosquitoModel> _mosquitoes = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  
  MosquitoGalleryViewModel({required MosquitoRepository repository})
      : _repository = repository;
  
  // Public getters
  List<MosquitoModel> get mosquitoes => _mosquitoes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  
  // Public methods
  Future<void> loadMosquitoes() async {
    _setLoading(true);
    try {
      _mosquitoes = await _repository.getAllMosquitoes();
      _error = null;
    } catch (e) {
      _error = 'Failed to load mosquitoes: $e';
    } finally {
      _setLoading(false);
    }
  }
  
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _filterMosquitoes();
  }
  
  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _filterMosquitoes() {
    // Filter logic
    notifyListeners();
  }
}
```

#### Repository Pattern
```dart
// Good: Abstract repository interface
abstract class MosquitoRepository {
  Future<List<MosquitoModel>> getAllMosquitoes();
  Future<MosquitoModel?> getMosquitoById(int id);
  Future<List<MosquitoModel>> searchMosquitoes(String query);
}

// Good: Concrete implementation
class MosquitoRepositoryImpl implements MosquitoRepository {
  final DatabaseService _databaseService;
  final NetworkService _networkService;
  
  MosquitoRepositoryImpl({
    required DatabaseService databaseService,
    required NetworkService networkService,
  }) : _databaseService = databaseService,
       _networkService = networkService;
  
  @override
  Future<List<MosquitoModel>> getAllMosquitoes() async {
    try {
      // Try local database first
      final localMosquitoes = await _databaseService.getAllMosquitoes();
      if (localMosquitoes.isNotEmpty) {
        return localMosquitoes;
      }
      
      // Fallback to network
      final networkMosquitoes = await _networkService.fetchMosquitoes();
      await _databaseService.saveMosquitoes(networkMosquitoes);
      return networkMosquitoes;
    } catch (e) {
      throw RepositoryException('Failed to load mosquitoes: $e');
    }
  }
}
```

### Service Layer Design

#### Service Interface
```dart
// Good: Clear service interface
abstract class ClassificationService {
  Future<ClassificationResult> classifyImage(File imageFile);
  Future<void> updateModel(String modelPath);
  bool get isModelLoaded;
}

// Good: Service implementation
class ClassificationServiceImpl implements ClassificationService {
  final PytorchWrapper _pytorchWrapper;
  bool _isModelLoaded = false;
  
  ClassificationServiceImpl({required PytorchWrapper pytorchWrapper})
      : _pytorchWrapper = pytorchWrapper;
  
  @override
  bool get isModelLoaded => _isModelLoaded;
  
  @override
  Future<ClassificationResult> classifyImage(File imageFile) async {
    if (!_isModelLoaded) {
      throw StateError('Model not loaded');
    }
    
    final imageBytes = await _preprocessImage(imageFile);
    final prediction = await _pytorchWrapper.predict(imageBytes);
    return _parseResult(prediction);
  }
  
  // Private helper methods
  Future<Uint8List> _preprocessImage(File imageFile) async {
    // Image preprocessing logic
  }
  
  ClassificationResult _parseResult(List<double> prediction) {
    // Result parsing logic
  }
}
```

## Testing Guidelines

### Unit Test Structure

```dart
// Good: Well-organized test structure
void main() {
  group('ClassificationService', () {
    late ClassificationService service;
    late MockPytorchWrapper mockPytorchWrapper;
    
    setUp(() {
      mockPytorchWrapper = MockPytorchWrapper();
      service = ClassificationServiceImpl(pytorchWrapper: mockPytorchWrapper);
    });
    
    group('classifyImage', () {
      test('should return valid result when model predicts successfully', () async {
        // Arrange
        final imageFile = File('test_image.jpg');
        final expectedPrediction = [0.8, 0.1, 0.1];
        when(mockPytorchWrapper.predict(any))
            .thenAnswer((_) async => expectedPrediction);
        
        // Act
        final result = await service.classifyImage(imageFile);
        
        // Assert
        expect(result.species, equals('Aedes aegypti'));
        expect(result.confidence, equals(0.8));
        verify(mockPytorchWrapper.predict(any)).called(1);
      });
      
      test('should throw StateError when model is not loaded', () async {
        // Arrange
        final imageFile = File('test_image.jpg');
        // Model is not loaded by default
        
        // Act & Assert
        expect(
          () => service.classifyImage(imageFile),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}
```

### Widget Test Patterns

```dart
// Good: Widget test with proper setup
void main() {
  group('ClassificationScreen', () {
    late MockClassificationViewModel mockViewModel;
    
    setUp(() {
      mockViewModel = MockClassificationViewModel();
    });
    
    Widget createWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<ClassificationViewModel>.value(
          value: mockViewModel,
          child: const ClassificationScreen(),
        ),
      );
    }
    
    testWidgets('should display loading indicator when classifying', (tester) async {
      // Arrange
      when(mockViewModel.state).thenReturn(ClassificationState.loading);
      
      // Act
      await tester.pumpWidget(createWidget());
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should display result when classification succeeds', (tester) async {
      // Arrange
      final result = ClassificationResult(
        species: 'Aedes aegypti',
        confidence: 0.85,
      );
      when(mockViewModel.state).thenReturn(ClassificationState.success);
      when(mockViewModel.result).thenReturn(result);
      
      // Act
      await tester.pumpWidget(createWidget());
      
      // Assert
      expect(find.text('Aedes aegypti'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
    });
  });
}
```

## Documentation Standards

### Code Documentation

#### Class Documentation
```dart
/// Service responsible for mosquito species classification using AI models.
///
/// This service handles image preprocessing, model inference, and result
/// interpretation for mosquito identification. It uses PyTorch Lite models
/// trained on mosquito image datasets.
///
/// Example usage:
/// ```dart
/// final service = ClassificationService();
/// await service.loadModel('assets/models/mosquito_classifier.pt');
/// final result = await service.classifyImage(imageFile);
/// print('Species: ${result.species}');
/// ```
class ClassificationService {
  // Implementation
}
```

#### Method Documentation
```dart
/// Classifies a mosquito species from an image file.
///
/// Takes an [imageFile] containing a mosquito photo and returns a
/// [ClassificationResult] with the predicted species and confidence score.
///
/// The image is automatically preprocessed (resized, normalized) before
/// being passed to the AI model. Supported formats: JPEG, PNG.
///
/// Throws [ClassificationException] if:
/// - The image file doesn't exist or is corrupted
/// - The AI model hasn't been loaded
/// - The classification process fails
///
/// Example:
/// ```dart
/// final result = await classifyImage(File('mosquito.jpg'));
/// if (result.confidence > 0.7) {
///   print('High confidence: ${result.species}');
/// }
/// ```
Future<ClassificationResult> classifyImage(File imageFile) async {
  // Implementation
}
```

### README and Documentation

#### Code Examples in Documentation
```dart
// Good: Complete, runnable examples
/// Example: Setting up classification workflow
/// 
/// ```dart
/// // Initialize the service
/// final service = locator<ClassificationService>();
/// 
/// // Classify an image
/// try {
///   final result = await service.classifyImage(imageFile);
///   print('Species: ${result.species}');
///   print('Confidence: ${result.confidence}');
/// } on ClassificationException catch (e) {
///   print('Classification failed: ${e.message}');
/// }
/// ```
```

## Code Review Guidelines

### What to Look For

#### Functionality
- Does the code do what it's supposed to do?
- Are edge cases handled properly?
- Is error handling appropriate?

#### Design
- Is the code well-structured and organized?
- Does it follow SOLID principles?
- Are abstractions appropriate?

#### Style
- Does it follow the project's style guidelines?
- Are naming conventions consistent?
- Is the code readable and self-documenting?

#### Performance
- Are there any obvious performance issues?
- Is memory management handled properly?
- Are expensive operations optimized?

#### Testing
- Is the code testable?
- Are there appropriate tests?
- Do tests cover edge cases?

### Review Checklist

- [ ] Code follows project style guidelines
- [ ] All public APIs are documented
- [ ] Error handling is appropriate
- [ ] Tests are included and comprehensive
- [ ] No obvious performance issues
- [ ] Code is readable and maintainable
- [ ] Follows established architecture patterns
- [ ] No security vulnerabilities
- [ ] Proper resource management (disposal, etc.)
- [ ] Internationalization considerations

## Conclusion

Following these code style guidelines ensures that the CulicidaeLab codebase remains consistent, maintainable, and professional. When in doubt, prioritize readability and consistency with existing code patterns. Regular code reviews help maintain these standards and improve code quality across the team.