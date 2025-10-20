# Руководство по интеграции API сервера CulicidaeLab

## Обзор

Мобильное приложение CulicidaeLab интегрируется с экосистемой сервера CulicidaeLab для предоставления расширенных возможностей классификации комаров и вклада в глобальные исследования наблюдения за комарами. Это руководство предоставляет комплексную документацию для разработчиков и исследователей, работающих с интеграцией серверного API.

## Базовая конфигурация

### Конечные точки сервера

Сервер CulicidaeLab предоставляет следующие основные конечные точки:

```dart
// Базовый URL сервера
const String baseUrl = "https://culicidaelab.ru";

// Конечные точки API
const String predictionEndpoint = "/api/predict";
const String observationsEndpoint = "/api/observations";
const String mapEndpoint = "/map";
```

### Настройка HTTP клиента

Приложение использует стандартный пакет Dart `http` для связи с сервером:

```dart
import 'package:http/http.dart' as http;

// Регистрация HTTP клиента во внедрении зависимостей
locator.registerLazySingleton(() => http.Client());

// Использование в репозиториях
final http.Client _httpClient = locator<http.Client>();
```

## Аутентификация

### Текущая реализация

Текущая реализация API не требует аутентификации для базовых операций:
- Запросы классификации изображений
- Отправка наблюдений
- Доступ к данным карты

### Будущая поддержка аутентификации

Для расширенных функций и исследовательского доступа API может реализовать:
- Аутентификацию по API ключу для ограничения скорости
- OAuth2 для доступа к пользовательским данным
- JWT токены для управления сессиями

```dart
// Пример будущего заголовка аутентификации
final headers = {
  'Content-Type': 'application/json; charset=UTF-8',
  'Authorization': 'Bearer $apiToken', // Будущая реализация
};
```#
# API классификации изображений

### Конечная точка: `/api/predict`

Предоставляет серверную классификацию видов комаров с использованием продвинутых моделей машинного обучения.

#### Формат запроса

```http
POST https://culicidaelab.ru/api/predict
Content-Type: multipart/form-data

--boundary
Content-Disposition: form-data; name="file"; filename="mosquito.jpg"
Content-Type: image/jpeg

[Бинарные данные изображения]
--boundary--
```

#### Пример реализации

```dart
Future<WebPredictionResult> getWebPrediction(File imageFile) async {
  final url = Uri.parse("https://culicidaelab.ru/api/predict");
  var request = http.MultipartRequest('POST', url);

  // Определить MIME тип из расширения файла
  String mimeType = 'image/jpeg'; // По умолчанию
  if (imageFile.path.toLowerCase().endsWith('.png')) {
    mimeType = 'image/png';
  } else if (imageFile.path.toLowerCase().endsWith('.webp')) {
    mimeType = 'image/webp';
  }

  // Создать multipart файл
  final multipartFile = await http.MultipartFile.fromPath(
    'file',
    imageFile.path,
    contentType: MediaType.parse(mimeType),
  );

  request.files.add(multipartFile);

  // Отправить запрос
  final streamedResponse = await _httpClient.send(request);
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return WebPredictionResult.fromJson(json.decode(response.body));
  } else {
    throw Exception('Предсказание не удалось: ${response.statusCode}');
  }
}
```

#### Формат ответа

```json
{
  "id": "pred_123456789",
  "scientific_name": "Aedes aegypti",
  "common_name": "Комар желтой лихорадки",
  "confidence": 0.87,
  "probabilities": {
    "Aedes aegypti": 0.87,
    "Aedes albopictus": 0.09,
    "Culex pipiens": 0.03,
    "Other": 0.01
  },
  "processing_time_ms": 245,
  "model_version": "v2.1.0",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

#### Модель ответа

```dart
class WebPredictionResult {
  final String id;
  final String scientificName;
  final String commonName;
  final double confidence;
  final Map<String, double> probabilities;
  final int processingTimeMs;
  final String modelVersion;
  final DateTime timestamp;

  WebPredictionResult({
    required this.id,
    required this.scientificName,
    required this.commonName,
    required this.confidence,
    required this.probabilities,
    required this.processingTimeMs,
    required this.modelVersion,
    required this.timestamp,
  });

  factory WebPredictionResult.fromJson(Map<String, dynamic> json) {
    return WebPredictionResult(
      id: json['id'] as String,
      scientificName: json['scientific_name'] as String,
      commonName: json['common_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      probabilities: Map<String, double>.from(
        json['probabilities'].map((k, v) => MapEntry(k, (v as num).toDouble()))
      ),
      processingTimeMs: json['processing_time_ms'] as int,
      modelVersion: json['model_version'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
```#
# API отправки наблюдений

### Конечная точка: `/api/observations`

Позволяет отправку данных наблюдений комаров для исследовательских целей и наблюдения.

#### Формат запроса

```http
POST https://culicidaelab.ru/api/observations
Content-Type: application/json; charset=UTF-8

{
  "species_scientific_name": "Aedes aegypti",
  "species_common_name": "Комар желтой лихорадки",
  "confidence": 0.87,
  "latitude": 40.7128,
  "longitude": -74.0060,
  "timestamp": "2024-01-15T10:30:00Z",
  "notes": "Найден рядом со стоячей водой",
  "image_path": "/path/to/image.jpg",
  "prediction_id": "pred_123456789",
  "model_version": "v2.1.0",
  "processing_time_ms": 245,
  "probabilities": {
    "Aedes aegypti": 0.87,
    "Aedes albopictus": 0.09,
    "Culex pipiens": 0.03
  }
}
```

#### Пример реализации

```dart
Future<Observation> submitObservation({
  required Map<String, dynamic> finalPayload,
}) async {
  final url = Uri.parse("https://culicidaelab.ru/api/observations");

  final response = await _httpClient.post(
    url,
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: json.encode(finalPayload),
  );

  if (response.statusCode == 201) {
    return Observation.fromJson(json.decode(response.body));
  } else {
    throw Exception('Не удалось отправить наблюдение: ${response.statusCode} - ${response.body}');
  }
}
```

#### Конструирование полезной нагрузки

Приложение поддерживает два типа отправки наблюдений:

**Только локальные предсказания:**
```dart
final localOnlyPayload = {
  "species_scientific_name": localResult.species.name,
  "species_common_name": localResult.species.commonName,
  "confidence": localResult.confidence,
  "latitude": latitude,
  "longitude": longitude,
  "timestamp": DateTime.now().toIso8601String(),
  "notes": userNotes,
  "image_path": imagePath,
  "prediction_source": "local_model",
  "model_version": "local_v1.0",
  "processing_time_ms": localResult.processingTimeMs,
};
```

**Веб-предсказания с полным распределением вероятностей:**
```dart
final webPredictionPayload = {
  "species_scientific_name": webPrediction.scientificName,
  "species_common_name": webPrediction.commonName,
  "confidence": webPrediction.confidence,
  "latitude": latitude,
  "longitude": longitude,
  "timestamp": DateTime.now().toIso8601String(),
  "notes": userNotes,
  "image_path": imagePath,
  "prediction_id": webPrediction.id,
  "model_version": webPrediction.modelVersion,
  "processing_time_ms": webPrediction.processingTimeMs,
  "probabilities": webPrediction.probabilities,
  "prediction_source": "server_model",
};
```#
# Обработка ошибок

### HTTP коды состояния

API использует стандартные HTTP коды состояния:

- `200 OK` - Успешный запрос предсказания
- `201 Created` - Успешная отправка наблюдения
- `400 Bad Request` - Неверный формат запроса или отсутствующие параметры
- `413 Payload Too Large` - Файл изображения слишком большой
- `415 Unsupported Media Type` - Неверный формат изображения
- `429 Too Many Requests` - Превышен лимит скорости
- `500 Internal Server Error` - Ошибка обработки сервера
- `503 Service Unavailable` - Обслуживание сервера или перегрузка

### Формат ответа об ошибке

```json
{
  "error": {
    "code": "INVALID_IMAGE_FORMAT",
    "message": "Неподдерживаемый формат изображения. Используйте JPEG, PNG или WebP.",
    "details": {
      "supported_formats": ["image/jpeg", "image/png", "image/webp"],
      "max_file_size": "10MB"
    }
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "request_id": "req_123456789"
}
```

### Реализация обработки исключений

```dart
Future<WebPredictionResult> getWebPrediction(File imageFile) async {
  try {
    // Реализация вызова API
    final response = await _httpClient.send(request);

    if (response.statusCode == 200) {
      return WebPredictionResult.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Предсказание не удалось',
        body: response.body,
      );
    }
  } on SocketException {
    throw NetworkException('Нет интернет-соединения');
  } on TimeoutException {
    throw NetworkException('Тайм-аут запроса');
  } on FormatException {
    throw ApiException(
      statusCode: 0,
      message: 'Неверный формат ответа',
      body: '',
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String body;

  ApiException({
    required this.statusCode,
    required this.message,
    required this.body,
  });

  @override
  String toString() => 'ApiException: $statusCode - $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
```

## Ограничения скорости и производительность

### Текущие ограничения

- Явные ограничения скорости не реализованы
- Размер изображения должен быть оптимизирован перед загрузкой
- Тайм-ауты сети обрабатываются настройками HTTP клиента по умолчанию

### Лучшие практики

```dart
// Оптимизация изображения перед загрузкой
Future<File> optimizeImageForUpload(File originalImage) async {
  final bytes = await originalImage.readAsBytes();
  final image = img.decodeImage(bytes);

  if (image == null) throw Exception('Неверный формат изображения');

  // Изменить размер если слишком большое (макс 1024x1024)
  final resized = image.width > 1024 || image.height > 1024
      ? img.copyResize(image, width: 1024, height: 1024)
      : image;

  // Сжать в JPEG с качеством 85%
  final compressed = img.encodeJpg(resized, quality: 85);

  // Сохранить оптимизированное изображение
  final tempDir = await getTemporaryDirectory();
  final optimizedFile = File('${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg');
  await optimizedFile.writeAsBytes(compressed);

  return optimizedFile;
}

// Конфигурация тайм-аута запроса
final client = http.Client();
final request = http.MultipartRequest('POST', url);
// Установить пользовательский тайм-аут
final response = await client.send(request).timeout(
  const Duration(seconds: 30),
  onTimeout: () => throw TimeoutException('Тайм-аут запроса'),
);
```#
# Соображения безопасности

### Конфиденциальность данных

- Изображения обрабатываются на сервере, но не сохраняются постоянно
- Данные о местоположении отправляются только с явного согласия пользователя
- Персональные идентификационные данные не собираются

### Сетевая безопасность

- Все API коммуникации используют HTTPS
- Нет чувствительных токенов аутентификации в текущей реализации
- Данные запроса/ответа не кэшируются локально

### Валидация входных данных

```dart
// Валидировать файл изображения перед загрузкой
bool isValidImageFile(File imageFile) {
  final extension = path.extension(imageFile.path).toLowerCase();
  final validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

  if (!validExtensions.contains(extension)) {
    return false;
  }

  // Проверить размер файла (макс 10МБ)
  final fileSizeBytes = imageFile.lengthSync();
  const maxSizeBytes = 10 * 1024 * 1024; // 10МБ

  return fileSizeBytes <= maxSizeBytes;
}
```

## Будущие улучшения API

### Запланированные функции

1. **Пакетная обработка**: Отправка нескольких наблюдений в одном запросе
2. **Обновления в реальном времени**: WebSocket соединения для живых обновлений карты
3. **Продвинутая фильтрация**: Запрос наблюдений по видам, местоположению, диапазону дат
4. **Пользовательские аккаунты**: Личная история наблюдений и статистика
5. **Экспорт данных**: Загрузка данных наблюдений в различных форматах

### Версионирование API

Будущие версии API будут поддерживаться через версионирование URL:

```dart
const String apiV2BaseUrl = "https://culicidaelab.ru/api/v2";
const String apiV3BaseUrl = "https://culicidaelab.ru/api/v3";
```

## Устранение неполадок

### Распространенные проблемы

**Сетевое подключение**
```dart
// Проверить сетевое подключение перед вызовами API
Future<bool> hasNetworkConnection() async {
  try {
    final result = await InternetAddress.lookup('culicidaelab.ru');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}
```

**Большие файлы изображений**
- Оптимизируйте изображения перед загрузкой используя сжатие изображений
- Рассмотрите реализацию прогрессивной загрузки для больших файлов

**Тайм-ауты сервера**
- Реализуйте логику повторных попыток с экспоненциальной задержкой
- Показывайте соответствующую обратную связь пользователю во время длительных операций

## Поддержка и ресурсы

- **Документация API**: https://culicidaelab.ru/docs/api
- **Статус сервера**: https://culicidaelab.ru/health
- **Сообщение о проблемах**: https://github.com/iloncka-ds/culicidaelab-mobile/issues

Для дополнительной поддержки или вопросов об интеграции API, пожалуйста, свяжитесь с командой разработчиков или создайте задачу в репозитории проекта.