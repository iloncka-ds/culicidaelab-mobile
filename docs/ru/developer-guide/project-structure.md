# Структура проекта и соглашения

## Обзор

Этот документ описывает организационную структуру проекта CulicidaeLab Flutter и соглашения по кодированию, используемые во всей кодовой базе. Понимание этой структуры необходимо для эффективной разработки и поддержания согласованности в проекте.

## Структура корня проекта

```
culicidaelab/
├── .devcontainer/              # Конфигурация контейнера разработки
├── android/                    # Конфигурация и файлы сборки для Android
├── assets/                     # Ресурсы приложения (изображения, модели, шрифты и т.д.)
├── docs/                       # Документация проекта
├── integration_test/           # Файлы интеграционных тестов
├── ios/                        # Конфигурация и файлы сборки для iOS
├── lib/                        # Основной исходный код Dart
├── scripts/                    # Скрипты сборки и утилиты
├── test/                       # Модульные тесты и тесты виджетов
├── analysis_options.yaml       # Конфигурация анализатора Dart
├── dartdoc_options.yaml        # Опции генерации документации
├── devtools_options.yaml       # Конфигурация Flutter DevTools
├── l10n.yaml                   # Конфигурация локализации
├── pubspec.yaml                # Зависимости и метаданные проекта
└── README.md                   # Обзор проекта и быстрый старт
```

## Структура исходного кода (`lib/`)

Директория `lib/` следует организации на основе функций с четким разделением ответственности:

```
lib/
├── l10n/                       # Интернационализация и локализация
│   ├── app_en.arb             # Переводы на английский
│   ├── app_es.arb             # Переводы на испанский
│   ├── app_ru.arb             # Переводы на русский
│   ├── app_localizations.dart  # Сгенерированный класс локализации
│   └── app_localizations_*.dart # Сгенерированные языко-специфические классы
├── models/                     # Модели данных и сущности
│   ├── disease_model.dart      # Модель информации о заболеваниях
│   ├── mosquito_model.dart     # Модель видов комаров
│   ├── observation_model.dart  # Модель данных наблюдений пользователя
│   └── web_prediction_result.dart # Модель результата предсказания ИИ
├── providers/                  # Провайдеры управления состоянием
│   └── locale_provider.dart   # Управление состоянием языка/локали
├── repositories/               # Слой доступа к данным
│   ├── classification_repository.dart # Доступ к данным классификации ИИ
│   └── mosquito_repository.dart # Доступ к данным комаров и заболеваний
├── screens/                    # Экраны и страницы UI
│   ├── classification_screen.dart # Захват фото и классификация
│   ├── disease_detail_screen.dart # Информация об отдельном заболевании
│   ├── disease_info_screen.dart # Список информации о заболеваниях
│   ├── home_screen.dart        # Основной экран навигации
│   ├── mosquito_detail_screen.dart # Детали отдельного комара
│   ├── mosquito_gallery_screen.dart # Галерея видов комаров
│   ├── observation_details_screen.dart # Детали наблюдения пользователя
│   └── webview_screen.dart     # Отображение веб-контента
├── services/                   # Бизнес-логика и внешние интеграции
│   ├── classification_service.dart # Сервис вывода модели ИИ
│   ├── database_service.dart   # Операции локальной базы данных
│   ├── pytorch_lite_model.dart # Обертка модели PyTorch (устаревшая)
│   ├── pytorch_wrapper.dart   # Интеграция модели PyTorch
│   └── user_service.dart       # Данные пользователя и настройки
├── view_models/                # Слой бизнес-логики MVVM
│   ├── classification_view_model.dart # Логика рабочего процесса классификации
│   ├── disease_info_view_model.dart # Логика информации о заболеваниях
│   └── mosquito_gallery_view_model.dart # Логика просмотра галереи
├── widgets/                    # Переиспользуемые компоненты UI
│   ├── custom_empty_widget.dart # Виджет пустого состояния
│   └── icomoon_icons.dart      # Определения пользовательских иконок
├── locator.dart                # Конфигурация внедрения зависимостей
└── main.dart                   # Точка входа приложения
```

## Архитектурные слои

### 1. Слой представления
- **Расположение**: `lib/screens/`, `lib/widgets/`
- **Назначение**: Компоненты пользовательского интерфейса и обработка взаимодействия пользователя
- **Соглашение именования**: `*_screen.dart` для полных экранов, `*_widget.dart` для переиспользуемых компонентов

### 2. Слой бизнес-логики
- **Расположение**: `lib/view_models/`, `lib/providers/`
- **Назначение**: Управление состоянием приложения и бизнес-правила
- **Соглашение именования**: `*_view_model.dart` для логики MVVM, `*_provider.dart` для провайдеров состояния

### 3. Слой доступа к данным
- **Расположение**: `lib/repositories/`
- **Назначение**: Абстрактный доступ к данным и координация между сервисами
- **Соглашение именования**: `*_repository.dart`

### 4. Сервисный слой
- **Расположение**: `lib/services/`
- **Назначение**: Внешние интеграции, операции с базой данных и специализированная функциональность
- **Соглашение именования**: `*_service.dart`

### 5. Слой данных
- **Расположение**: `lib/models/`
- **Назначение**: Структуры данных и определения сущностей
- **Соглашение именования**: `*_model.dart`

## Организация ресурсов

```
assets/
├── database/                   # Файлы инициализации базы данных
│   └── database_data.json     # Начальные данные для локальной базы данных
├── fonts/                      # Пользовательские шрифты
│   └── icomoon.ttf           # Файл шрифта иконок
├── icons/                      # Иконки приложения
├── images/                     # Статические изображения
│   ├── diseases/              # Изображения, связанные с заболеваниями
│   └── species/               # Изображения видов комаров
├── labels/                     # Файлы меток модели ИИ
├── launcher_icon/              # Иконки запуска приложения
└── models/                     # Файлы модели ИИ
```

## Структура тестирования

```
test/
├── fixtures/                   # Тестовые данные и mock файлы
├── performance/                # Тестирование производительности
├── unit/                       # Модульные тесты
│   ├── models/                # Тесты моделей
│   ├── repositories/          # Тесты репозиториев
│   ├── services/              # Тесты сервисов
│   └── view_models/           # Тесты моделей представления
└── widget/                     # Тесты виджетов
    └── screens/               # Тесты виджетов экранов

integration_test/
└── app_test.dart              # Сквозные интеграционные тесты
```

## Структура документации

```
docs/
├── api-reference/              # Автоматически сгенерированная документация API
├── assets/                     # Ресурсы документации
│   ├── css/                   # Пользовательские стили
│   ├── diagrams/              # Диаграммы архитектуры
│   ├── images/                # Скриншоты и иллюстрации
│   ├── js/                    # Пользовательский JavaScript
│   └── videos/                # Обучающие видео
├── contribution/               # Руководящие принципы для участников
│   └── issue-templates/       # Шаблоны задач GitHub
├── developer-guide/            # Техническая документация
├── developer-guide/            # Техническая и исследовательская документация
├── user-guide/                 # Документация для конечных пользователей
├── _config/                    # Конфигурация сборки документации
│   ├── mkdocs.yml             # Конфигурация MkDocs
│   └── templates/             # Шаблоны документации
├── project_structure.md        # Этот документ
└── README.md                   # Обзор документации
```

## Соглашения именования

### Именование файлов

- **Файлы Dart**: Используйте `snake_case` для всех файлов Dart
  - ✅ `classification_service.dart`
  - ❌ `ClassificationService.dart`
  - ❌ `classification-service.dart`

- **Файлы ресурсов**: Используйте `snake_case` для согласованности
  - ✅ `mosquito_species.json`
  - ❌ `mosquitoSpecies.json`

- **Имена директорий**: Используйте `snake_case` или `kebab-case` согласованно
  - ✅ `user_guide/`
  - ✅ `api-reference/`
  - ❌ `userGuide/`

### Именование классов

- **Классы**: Используйте `PascalCase`
  ```dart
  class ClassificationService { }
  class MosquitoModel { }
  class DiseaseInfoViewModel { }
  ```

- **Интерфейсы**: Используйте `PascalCase` с описательными именами
  ```dart
  abstract class DatabaseRepository { }
  abstract class ClassificationProvider { }
  ```

### Именование переменных и методов

- **Переменные**: Используйте `camelCase`
  ```dart
  String mosquitoSpecies;
  List<DiseaseModel> diseaseList;
  bool isClassifying;
  ```

- **Методы**: Используйте `camelCase` с описательными глаголами
  ```dart
  Future<void> classifyImage() async { }
  List<MosquitoModel> getMosquitoSpecies() { }
  void updateClassificationState() { }
  ```

- **Константы**: Используйте `lowerCamelCase` для локальных констант, `SCREAMING_SNAKE_CASE` для глобальных констант
  ```dart
  const String defaultLanguage = 'en';
  static const int MAX_IMAGE_SIZE = 1024;
  ```

### Именование виджетов

- **Stateless виджеты**: Используйте `PascalCase` с описательным суффиксом
  ```dart
  class MosquitoDetailCard extends StatelessWidget { }
  class ClassificationButton extends StatelessWidget { }
  ```

- **Stateful виджеты**: Используйте `PascalCase` для виджета, `_PascalCaseState` для состояния
  ```dart
  class ClassificationScreen extends StatefulWidget { }
  class _ClassificationScreenState extends State<ClassificationScreen> { }
  ```

## Паттерны организации кода

### Организация импортов

Организуйте импорты в следующем порядке с пустыми строками между группами:

```dart
// 1. Основные библиотеки Dart
import 'dart:async';
import 'dart:io';

// 2. Фреймворк Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Сторонние пакеты
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// 4. Внутренние импорты (относительные пути)
import '../models/mosquito_model.dart';
import '../services/classification_service.dart';
import '../widgets/custom_empty_widget.dart';
```

### Структура класса

Организуйте члены класса в следующем порядке:

```dart
class ExampleClass {
  // 1. Статические константы
  static const String CONSTANT_VALUE = 'value';
  
  // 2. Переменные экземпляра (сначала приватные, затем публичные)
  final String _privateField;
  final String publicField;
  
  // 3. Конструктор
  ExampleClass({
    required this.publicField,
    String? privateField,
  }) : _privateField = privateField ?? 'default';
  
  // 4. Геттеры и сеттеры
  String get privateField => _privateField;
  
  // 5. Публичные методы
  void publicMethod() { }
  
  // 6. Приватные методы
  void _privateMethod() { }
  
  // 7. Переопределенные методы
  @override
  String toString() => 'ExampleClass($_privateField)';
}
```

### Организация методов

- Держите методы сфокусированными и однозначными
- Используйте описательные имена, объясняющие, что делает метод
- Ограничивайте длину метода ~50 строками когда возможно
- Извлекайте сложную логику в приватные вспомогательные методы

```dart
// Хорошо: Описательный и сфокусированный
Future<ClassificationResult> classifyMosquitoImage(File imageFile) async {
  final processedImage = await _preprocessImage(imageFile);
  final prediction = await _runModelInference(processedImage);
  return _parseClassificationResult(prediction);
}

// Вспомогательные методы для сложных операций
Future<Uint8List> _preprocessImage(File imageFile) async { }
Future<List<double>> _runModelInference(Uint8List imageData) async { }
ClassificationResult _parseClassificationResult(List<double> output) { }
```

## Стандарты кодирования

### Руководящие принципы стиля Dart

Проект следует официальному [Руководству по стилю Dart](https://dart.dev/guides/language/effective-dart/style) с этими специфическими соглашениями:

#### Длина строки
- Максимальная длина строки: **120 символов**
- Настроено в `analysis_options.yaml` и настройках IDE

#### Форматирование
- Используйте `flutter format .` для автоматического форматирования кода
- Включите "Format on Save" в вашей IDE
- Используйте завершающие запятые для лучших diff и форматирования

```dart
// Хорошо: Завершающие запятые и правильное форматирование
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

#### Комментарии документации

Используйте dartdoc комментарии для публичных API:

```dart
/// Классифицирует изображение комара, используя обученную модель PyTorch.
///
/// Принимает [imageFile] и возвращает [ClassificationResult], содержащий
/// предсказанный вид и оценку достоверности. Выбрасывает [ClassificationException]
/// если изображение не может быть обработано.
///
/// Пример:
/// ```dart
/// final result = await classifyMosquitoImage(imageFile);
/// print('Species: ${result.species}, Confidence: ${result.confidence}');
/// ```
Future<ClassificationResult> classifyMosquitoImage(File imageFile) async {
  // Реализация
}
```

### Обработка ошибок

#### Обработка исключений
- Используйте специфические типы исключений когда возможно
- Предоставляйте осмысленные сообщения об ошибках
- Логируйте ошибки соответствующим образом для отладки

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
- Эффективно используйте функции null safety
- Предпочитайте non-nullable типы когда возможно
- Используйте null-aware операторы соответствующим образом

```dart
// Хорошо: Четкая обработка null
String? getUserName() {
  return user?.name?.trim().isEmpty == true ? null : user?.name?.trim();
}

// Лучше: Использование null-aware операторов
String? getUserName() => user?.name?.trim().nullIfEmpty;
```

### Паттерны управления состоянием

#### Паттерн Provider
- Используйте `ChangeNotifier` для простого управления состоянием
- Реализуйте правильное освобождение ресурсов
- Используйте `Consumer` виджеты для целевых перестроений

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
    // Очистка ресурсов
    super.dispose();
  }
}
```

### Соглашения тестирования

#### Организация тестовых файлов
- Отражайте структуру `lib/` в `test/`
- Используйте суффикс `_test.dart` для тестовых файлов
- Группируйте связанные тесты используя функцию `group()`

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
        // Реализация теста
      });
      
      test('should throw exception for invalid image', () async {
        // Реализация теста
      });
    });
  });
}
```

#### Именование тестов
- Используйте описательные имена тестов, объясняющие сценарий
- Следуйте паттерну: "should [ожидаемое поведение] when [условие]"

```dart
test('should return Aedes aegypti when image contains yellow fever mosquito', () {
  // Реализация теста
});

test('should throw ClassificationException when image is corrupted', () {
  // Реализация теста
});
```

## Руководящие принципы производительности

### Управление памятью
- Правильно освобождайте контроллеры и потоки
- Используйте `const` конструкторы когда возможно
- Избегайте утечек памяти в долгоживущих объектах

### Обработка изображений
- Сжимайте изображения перед обработкой
- Соответствующим образом кэшируйте обработанные изображения
- Освобождайте ресурсы изображений после использования

### Операции с базой данных
- Используйте пакетные операции для множественных вставок
- Реализуйте правильное индексирование для запросов
- Правильно закрывайте соединения с базой данных

## Соображения безопасности

### Защита данных
- Никогда не фиксируйте чувствительные данные в контроле версий
- Используйте безопасное хранилище для чувствительной информации
- Валидируйте все пользовательские входы

### Безопасность API
- Используйте HTTPS для всех сетевых коммуникаций
- Реализуйте правильную аутентификацию
- Валидируйте ответы сервера

## Руководящие принципы локализации

### Добавление новых языков
1. Создайте новый `.arb` файл в `lib/l10n/`
2. Добавьте переводы для всех существующих ключей
3. Обновите конфигурацию `l10n.yaml`
4. Запустите `flutter gen-l10n` для генерации классов

### Ключи переводов
- Используйте описательные, иерархические ключи
- Группируйте связанные переводы
- Предоставляйте контекст для переводчиков

```json
{
  "classification_screen_title": "Классификация комаров",
  "classification_button_capture": "Сделать фото",
  "classification_button_gallery": "Выбрать из галереи",
  "classification_result_species": "Вид: {species}",
  "classification_result_confidence": "Достоверность: {confidence}%"
}
```

## Рабочий процесс Git

### Именование веток
- `feature/description` для новых функций
- `bugfix/description` для исправления ошибок
- `hotfix/description` для срочных исправлений
- `docs/description` для обновлений документации

### Сообщения коммитов
Следуйте формату conventional commit:
```
type(scope): description

[optional body]

[optional footer]
```

Примеры:
```
feat(classification): add confidence threshold setting
fix(database): resolve migration issue for disease table
docs(api): update classification service documentation
```

## Заключение

Следование этим соглашениям обеспечивает согласованность, поддерживаемость и эффективность сотрудничества в проекте CulicidaeLab. В случае сомнений обращайтесь к официальным руководствам по стилю Dart и Flutter и поддерживайте согласованность с существующими паттернами кода в проекте.