# Примеры паттернов Flutter

Это руководство предоставляет подробные примеры паттернов Flutter, используемых в проекте CulicidaeLab, с фокусом на реализацию MVVM с управлением состоянием Provider и продвинутые техники разработки Flutter.

## Содержание

1. [Обзор архитектуры MVVM](#обзор-архитектуры-mvvm)
2. [Управление состоянием Provider](#управление-состоянием-provider)
3. [Внедрение зависимостей с GetIt](#внедрение-зависимостей-с-getit)
4. [Паттерны реализации ViewModel](#паттерны-реализации-viewmodel)
5. [Управление состоянием UI](#управление-состоянием-ui)
6. [Реактивные обновления UI](#реактивные-обновления-ui)
7. [Паттерны обработки ошибок](#паттерны-обработки-ошибок)
8. [Паттерны тестирования](#паттерны-тестирования)

## Обзор архитектуры MVVM

Приложение CulicidaeLab реализует архитектурный паттерн Model-View-ViewModel (MVVM) для разделения ответственности и улучшения тестируемости.

### Диаграмма архитектуры

```mermaid
graph TB
    subgraph "Слой представления"
        V[Экраны и виджеты]
        UI[UI компоненты]
    end
    
    subgraph "Слой ViewModel"
        VM[ViewModels]
        P[Providers]
    end
    
    subgraph "Слой модели"
        M[Модели данных]
        R[Репозитории]
        S[Сервисы]
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

### Ключевые компоненты

- **View**: Flutter виджеты и экраны, отображающие UI
- **ViewModel**: Бизнес-логика и управление состоянием
- **Model**: Структуры данных и бизнес-сущности
- **Repository**: Слой абстракции доступа к данным
- **Service**: Внешние интеграции и утилиты

## Управление состоянием Provider

Приложение использует пакет Provider для реактивного управления состоянием, обеспечивая эффективные обновления UI при изменении данных.

### Базовая настройка Provider

```dart
// main.dart - Настройка корневого провайдера
class MosquitoClassifierApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocaleProvider>.value(
      value: locator<LocaleProvider>()..init(),
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            locale: localeProvider.locale,
            // ... другая конфигурация
          );
        },
      ),
    );
  }
}
```

### Паттерн множественных провайдеров

```dart
// Для экранов, требующих множественных провайдеров
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
            // Реализация UI
          );
        },
      ),
    );
  }
}
```

## Внедрение зависимостей с GetIt

Приложение использует GetIt для внедрения зависимостей, предоставляя чистый способ управления жизненными циклами сервисов и зависимостями.

### Паттерн регистрации сервисов

```dart
// locator.dart - Регистрация зависимостей
Future<void> setupLocator() async {
  // Сначала внешние пакеты
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);
  locator.registerLazySingleton(() => const Uuid());
  locator.registerLazySingleton(() => http.Client());

  // Основные сервисы
  locator.registerLazySingleton(() => DatabaseService());
  locator.registerLazySingleton(() => PytorchWrapper());
  locator.registerLazySingleton(
    () => UserService(prefs: locator(), uuid: locator())
  );

  // Репозитории с зависимостями
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

### Паттерн использования сервисов

```dart
// Доступ к сервисам по всему приложению
class SomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Получение экземпляра сервиса
    final userService = locator<UserService>();
    
    return FutureBuilder<String>(
      future: userService.getUserId(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text('ID пользователя: ${snapshot.data}');
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

## Паттерны реализации ViewModel

ViewModels в приложении CulicidaeLab следуют специфическим паттернам для управления состоянием, обработки ошибок и коммуникации с UI.

### Паттерн перечисления состояний

```dart
// Определение четких состояний для сложных рабочих процессов
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

### Паттерн асинхронных операций

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

### Паттерн ViewModel, дружественный к тестированию

```dart
class ClassificationViewModel extends ChangeNotifier {
  // Приватные поля для внутреннего состояния
  @visibleForTesting
  ClassificationState _state = ClassificationState.initial;
  
  @visibleForTesting
  File? _imageFile;
  
  // Публичные геттеры для UI
  ClassificationState get state => _state;
  File? get imageFile => _imageFile;
  
  // Методы для тестирования
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
```## Упр
авление состоянием UI

Приложение реализует реактивные паттерны UI, которые эффективно реагируют на изменения состояния ViewModel.

### Паттерн Consumer для UI, зависящего от состояния

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

### Паттерн Selector для оптимизации производительности

```dart
// Перестройка только при изменении конкретных свойств
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
              child: Text('Классифицировать изображение'),
            );
      },
    );
  }
}
```

## Реактивные обновления UI

Приложение использует различные паттерны для обеспечения синхронизации UI с изменениями данных.

### Паттерн интеграции FutureBuilder

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

### Паттерн StreamBuilder для обновлений в реальном времени

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

## Паттерны обработки ошибок

Приложение реализует комплексную обработку ошибок на нескольких уровнях.

### Обработка ошибок в ViewModel

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

### Паттерн отображения ошибок в UI

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
            // Основной контент
            Expanded(child: _buildMainContent(viewModel)),
          ],
        );
      },
    );
  }
}
```

## Паттерны тестирования

Архитектура MVVM обеспечивает комплексное тестирование на разных уровнях.

### Модульное тестирование ViewModel

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
    
    test('должен начинать с начального состояния', () {
      expect(viewModel.state, ClassificationState.initial);
      expect(viewModel.hasImage, false);
      expect(viewModel.result, null);
    });
    
    test('должен обновлять состояние при классификации изображения', () async {
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

### Тестирование виджетов с Provider

```dart
// test/widget/classification_screen_test.dart
void main() {
  group('Тесты виджета ClassificationScreen', () {
    late MockClassificationViewModel mockViewModel;
    
    setUp(() {
      mockViewModel = MockClassificationViewModel();
    });
    
    testWidgets('должен отображать индикатор загрузки при обработке', (tester) async {
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

### Паттерн интеграционного тестирования

```dart
// integration_test/classification_flow_test.dart
void main() {
  group('Интеграционные тесты потока классификации', () {
    testWidgets('полный рабочий процесс классификации', (tester) async {
      // Настройка реального приложения с тестовыми зависимостями
      await setupTestLocator();
      
      await tester.pumpWidget(MosquitoClassifierApp());
      await tester.pumpAndSettle();
      
      // Переход к экрану классификации
      await tester.tap(find.byKey(Key('classify_button')));
      await tester.pumpAndSettle();
      
      // Выбор изображения из галереи
      await tester.tap(find.byKey(Key('gallery_button')));
      await tester.pumpAndSettle();
      
      // Проверка отображения изображения
      expect(find.byType(Image), findsOneWidget);
      
      // Запуск классификации
      await tester.tap(find.byKey(Key('analyze_button')));
      await tester.pumpAndSettle();
      
      // Проверка отображения результатов
      expect(find.text('Результаты классификации'), findsOneWidget);
    });
  });
}
```

## Резюме лучших практик

### Дизайн ViewModel
- Используйте четкие перечисления состояний для сложных рабочих процессов
- Реализуйте правильную обработку ошибок с локализованными сообщениями
- Предоставляйте методы тестирования с `@visibleForTesting`
- Держите ViewModels сфокусированными на единственной ответственности

### Использование Provider
- Используйте `Consumer` для реактивных обновлений UI
- Используйте `Selector` для оптимизации производительности
- Объединяйте множественные провайдеры с `MultiProvider`
- Избегайте ненужных перестроек с правильной структурой виджетов

### Внедрение зависимостей
- Регистрируйте зависимости в правильном порядке
- Используйте ленивые синглтоны для сервисов
- Внедряйте зависимости через конструкторы
- Держите настройку локатора централизованной

### Стратегия тестирования
- Тщательно тестируйте ViewModels модульными тестами
- Используйте моки для внешних зависимостей
- Тестируйте изменения состояния UI с тестами виджетов
- Реализуйте интеграционные тесты для критических потоков

Эта реализация паттернов обеспечивает прочную основу для масштабируемых Flutter приложений с четким разделением ответственности, тестируемым кодом и поддерживаемой архитектурой.