# Flutter Pattern Examples

This guide provides detailed examples of Flutter patterns used in the CulicidaeLab project, focusing on MVVM implementation with Provider state management and advanced Flutter development techniques.

## Table of Contents

1. [MVVM Architecture Overview](#mvvm-architecture-overview)
2. [Provider State Management](#provider-state-management)
3. [Dependency Injection with GetIt](#dependency-injection-with-getit)
4. [ViewModel Implementation Patterns](#viewmodel-implementation-patterns)
5. [UI State Management](#ui-state-management)
6. [Reactive UI Updates](#reactive-ui-updates)
7. [Error Handling Patterns](#error-handling-patterns)
8. [Testing Patterns](#testing-patterns)

## MVVM Architecture Overview

The CulicidaeLab app implements the Model-View-ViewModel (MVVM) architectural pattern to separate concerns and improve testability.

### Architecture Diagram

```mermaid
graph TB
    subgraph "View Layer"
        V[Screens & Widgets]
        UI[UI Components]
    end
    
    subgraph "ViewModel Layer"
        VM[ViewModels]
        P[Providers]
    end
    
    subgraph "Model Layer"
        M[Data Models]
        R[Repositories]
        S[Services]
    end
    
    V --> VM
    UI --> P
    VM --> R
    VM --> S
    R --> M
    S --> M
    
    VM -.->|notifyListeners()| V
    P -.->|notifyListeners()| UI
```

### Key Components

- **View**: Flutter widgets and screens that display UI
- **ViewModel**: Business logic and state management
- **Model**: Data structures and business entities
- **Repository**: Data access abstraction layer
- **Service**: External integrations and utilities

## Provider State Management

The app uses the Provider package for reactive state management, enabling efficient UI updates when data changes.

### Basic Provider Setup

```dart
// main.dart - Root provider setup
class MosquitoClassifierApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocaleProvider>.value(
      value: locator<LocaleProvider>()..init(),
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            locale: localeProvider.locale,
            // ... other configuration
          );
        },
      ),
    );
  }
}
```

### Multiple Providers Pattern

```dart
// For screens requiring multiple providers
class ComplexScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ClassificationViewModel>.value(
          value: locator<ClassificationViewModel>(),
        ),
        ChangeNotifierProvider<LocaleProvider>.value(
          value: locator<LocaleProvider>(),
        ),
      ],
      child: Consumer2<ClassificationViewModel, LocaleProvider>(
        builder: (context, classificationVM, localeProvider, child) {
          return Scaffold(
            // UI implementation
          );
        },
      ),
    );
  }
}
```

## Dependency Injection with GetIt

The app uses GetIt for dependency injection, providing a clean way to manage service lifecycles and dependencies.

### Service Registration Pattern

```dart
// locator.dart - Dependency registration
Future<void> setupLocator() async {
  // External packages first
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);
  locator.registerLazySingleton(() => const Uuid());
  locator.registerLazySingleton(() => http.Client());

  // Core services
  locator.registerLazySingleton(() => DatabaseService());
  locator.registerLazySingleton(() => PytorchWrapper());
  locator.registerLazySingleton(
    () => UserService(prefs: locator(), uuid: locator())
  );

  // Repositories with dependencies
  locator.registerLazySingleton(
    () => ClassificationRepository(
      classificationService: locator(),
      mosquitoRepository: locator(),
      httpClient: locator(),
    )
  );

  // ViewModels
  locator.registerLazySingleton(
    () => ClassificationViewModel(
      repository: locator(),
      userService: locator(),
    )
  );
}
```

### Service Usage Pattern

```dart
// Accessing services throughout the app
class SomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get service instance
    final userService = locator<UserService>();
    
    return FutureBuilder<String>(
      future: userService.getUserId(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text('User ID: ${snapshot.data}');
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

## ViewModel Implementation Patterns

ViewModels in the CulicidaeLab app follow specific patterns for state management, error handling, and UI communication.

### State Enum Pattern

```dart
// Define clear states for complex workflows
enum ClassificationState { 
  initial, 
  loading, 
  success, 
  error, 
  submitting, 
  submitted 
}

class ClassificationViewModel extends ChangeNotifier {
  ClassificationState _state = ClassificationState.initial;
  
  ClassificationState get state => _state;
  bool get isProcessing => _state == ClassificationState.loading;
  bool get isSubmitting => _state == ClassificationState.submitting;
  
  void _setState(ClassificationState newState) {
    _state = newState;
    notifyListeners();
  }
}
```

### Async Operation Pattern

```dart
class ClassificationViewModel extends ChangeNotifier {
  String? _errorMessage;
  ClassificationResult? _result;
  
  String? get errorMessage => _errorMessage;
  ClassificationResult? get result => _result;
  
  Future<void> classifyImage(AppLocalizations localizations) async {
    if (_imageFile == null) {
      _errorMessage = localizations.errorNoImageSelected;
      notifyListeners();
      return;
    }
    
    try {
      _setState(ClassificationState.loading);
      _errorMessage = null;
      
      final result = await _repository.classifyImage(
        _imageFile!,
        localizations.localeName,
      );
      
      _result = result;
      _setState(ClassificationState.success);
      
    } catch (e) {
      _setState(ClassificationState.error);
      _errorMessage = localizations.errorClassificationFailed(e.toString());
    }
  }
}
```

### Testing-Friendly ViewModel Pattern

```dart
class ClassificationViewModel extends ChangeNotifier {
  // Private fields for internal state
  @visibleForTesting
  ClassificationState _state = ClassificationState.initial;
  
  @visibleForTesting
  File? _imageFile;
  
  // Public getters for UI
  ClassificationState get state => _state;
  File? get imageFile => _imageFile;
  
  // Testing methods
  @visibleForTesting
  void setState(ClassificationState state) {
    _state = state;
    notifyListeners();
  }
  
  @visibleForTesting
  void setImageFile(File? file) {
    _imageFile = file;
    notifyListeners();
  }
}
```

## UI State Management

The app implements reactive UI patterns that respond to ViewModel state changes efficiently.

### Consumer Pattern for State-Dependent UI

```dart
class ClassificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClassificationViewModel>.value(
      value: locator<ClassificationViewModel>(),
      child: Consumer<ClassificationViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: _buildBody(context, viewModel),
            floatingActionButton: _buildFAB(context, viewModel),
          );
        },
      ),
    );
  }
  
  Widget _buildBody(BuildContext context, ClassificationViewModel viewModel) {
    switch (viewModel.state) {
      case ClassificationState.initial:
        return _buildInitialState();
      case ClassificationState.loading:
        return _buildLoadingState();
      case ClassificationState.success:
        return _buildSuccessState(viewModel.result!);
      case ClassificationState.error:
        return _buildErrorState(viewModel.errorMessage!);
      default:
        return Container();
    }
  }
}
```

### Selector Pattern for Performance Optimization

```dart
// Only rebuild when specific properties change
class OptimizedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<ClassificationViewModel, bool>(
      selector: (context, viewModel) => viewModel.isProcessing,
      builder: (context, isProcessing, child) {
        return isProcessing 
          ? CircularProgressIndicator()
          : ElevatedButton(
              onPressed: () => _handleClassify(context),
              child: Text('Classify Image'),
            );
      },
    );
  }
}
```

## Reactive UI Updates

The app uses various patterns to ensure UI stays synchronized with data changes.

### FutureBuilder Integration Pattern

```dart
class AsyncDataWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ClassificationViewModel>(
      builder: (context, viewModel, child) {
        return FutureBuilder<void>(
          future: viewModel.initModel(AppLocalizations.of(context)!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return ErrorWidget(snapshot.error!);
            }
            
            return _buildMainContent(viewModel);
          },
        );
      },
    );
  }
}
```

### StreamBuilder Pattern for Real-time Updates

```dart
class RealTimeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ClassificationState>(
      stream: context.watch<ClassificationViewModel>().stateStream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? ClassificationState.initial;
        
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: _buildForState(state),
        );
      },
    );
  }
}
```

## Error Handling Patterns

The app implements comprehensive error handling at multiple levels.

### ViewModel Error Handling

```dart
class ClassificationViewModel extends ChangeNotifier {
  String? _errorMessage;
  
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  
  Future<void> performOperation(AppLocalizations localizations) async {
    try {
      _clearError();
      await _riskyOperation();
    } on NetworkException catch (e) {
      _setError(localizations.errorNetworkFailed);
    } on ModelException catch (e) {
      _setError(localizations.errorModelFailed);
    } catch (e) {
      _setError(localizations.errorUnknown(e.toString()));
    }
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

### UI Error Display Pattern

```dart
class ErrorHandlingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ClassificationViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            if (viewModel.hasError)
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.red.shade100,
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: viewModel.clearError,
                    ),
                  ],
                ),
              ),
            // Main content
            Expanded(child: _buildMainContent(viewModel)),
          ],
        );
      },
    );
  }
}
```

## Testing Patterns

The MVVM architecture enables comprehensive testing at different levels.

### ViewModel Unit Testing

```dart
// test/unit/view_models/classification_view_model_test.dart
class MockClassificationRepository extends Mock implements ClassificationRepository {}
class MockUserService extends Mock implements UserService {}

void main() {
  group('ClassificationViewModel', () {
    late ClassificationViewModel viewModel;
    late MockClassificationRepository mockRepository;
    late MockUserService mockUserService;
    
    setUp(() {
      mockRepository = MockClassificationRepository();
      mockUserService = MockUserService();
      viewModel = ClassificationViewModel(
        repository: mockRepository,
        userService: mockUserService,
      );
    });
    
    test('should start with initial state', () {
      expect(viewModel.state, ClassificationState.initial);
      expect(viewModel.hasImage, false);
      expect(viewModel.result, null);
    });
    
    test('should update state when classifying image', () async {
      // Arrange
      final testFile = File('test_image.jpg');
      final expectedResult = ClassificationResult(/* ... */);
      
      when(mockRepository.classifyImage(any, any))
          .thenAnswer((_) async => expectedResult);
      
      viewModel.setImageFile(testFile);
      
      // Act
      await viewModel.classifyImage(MockAppLocalizations());
      
      // Assert
      expect(viewModel.state, ClassificationState.success);
      expect(viewModel.result, expectedResult);
      verify(mockRepository.classifyImage(testFile, any)).called(1);
    });
  });
}
```

### Widget Testing with Provider

```dart
// test/widget/classification_screen_test.dart
void main() {
  group('ClassificationScreen Widget Tests', () {
    late MockClassificationViewModel mockViewModel;
    
    setUp(() {
      mockViewModel = MockClassificationViewModel();
    });
    
    testWidgets('should display loading indicator when processing', (tester) async {
      // Arrange
      when(mockViewModel.state).thenReturn(ClassificationState.loading);
      when(mockViewModel.isProcessing).thenReturn(true);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ClassificationViewModel>.value(
            value: mockViewModel,
            child: ClassificationScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

### Integration Testing Pattern

```dart
// integration_test/classification_flow_test.dart
void main() {
  group('Classification Flow Integration Tests', () {
    testWidgets('complete classification workflow', (tester) async {
      // Setup real app with test dependencies
      await setupTestLocator();
      
      await tester.pumpWidget(MosquitoClassifierApp());
      await tester.pumpAndSettle();
      
      // Navigate to classification screen
      await tester.tap(find.byKey(Key('classify_button')));
      await tester.pumpAndSettle();
      
      // Select image from gallery
      await tester.tap(find.byKey(Key('gallery_button')));
      await tester.pumpAndSettle();
      
      // Verify image is displayed
      expect(find.byType(Image), findsOneWidget);
      
      // Trigger classification
      await tester.tap(find.byKey(Key('analyze_button')));
      await tester.pumpAndSettle();
      
      // Verify results are shown
      expect(find.text('Classification Results'), findsOneWidget);
    });
  });
}
```

## Best Practices Summary

### ViewModel Design
- Use clear state enums for complex workflows
- Implement proper error handling with localized messages
- Expose testing methods with `@visibleForTesting`
- Keep ViewModels focused on single responsibilities

### Provider Usage
- Use `Consumer` for reactive UI updates
- Use `Selector` for performance optimization
- Combine multiple providers with `MultiProvider`
- Avoid unnecessary rebuilds with proper widget structure

### Dependency Injection
- Register dependencies in proper order
- Use lazy singletons for services
- Inject dependencies through constructors
- Keep the locator setup centralized

### Testing Strategy
- Unit test ViewModels thoroughly
- Use mocks for external dependencies
- Test UI state changes with widget tests
- Implement integration tests for critical flows

This pattern implementation provides a solid foundation for scalable Flutter applications with clear separation of concerns, testable code, and maintainable architecture.