# CulicidaeLab Server API Integration Guide

## Overview

The CulicidaeLab mobile application integrates with the CulicidaeLab server ecosystem to provide enhanced mosquito classification capabilities and contribute to global mosquito surveillance research. This guide provides comprehensive documentation for developers and researchers working with the server API integration.

## Base Configuration

### Server Endpoints

The CulicidaeLab server provides the following primary endpoints:

```dart
// Base server URL
const String baseUrl = "https://culicidaelab.ru";

// API endpoints
const String predictionEndpoint = "/api/predict";
const String observationsEndpoint = "/api/observations";
const String mapEndpoint = "/map";
```

### HTTP Client Setup

The application uses the standard Dart `http` package for server communication:

```dart
import 'package:http/http.dart' as http;

// HTTP client registration in dependency injection
locator.registerLazySingleton(() => http.Client());

// Usage in repositories
final http.Client _httpClient = locator<http.Client>();
```

## Authentication

### Current Implementation

The current API implementation does not require authentication for basic operations:
- Image classification requests
- Observation submissions
- Map data access

### Future Authentication Support

For enhanced features and research access, the API may implement:
- API key authentication for rate limiting
- OAuth2 for user-specific data access
- JWT tokens for session management

```dart
// Future authentication header example
final headers = {
  'Content-Type': 'application/json; charset=UTF-8',
  'Authorization': 'Bearer $apiToken', // Future implementation
};
```

## Image Classification API

### Endpoint: `/api/predict`

Provides server-based mosquito species classification using advanced machine learning models.

#### Request Format

```http
POST https://culicidaelab.ru/api/predict
Content-Type: multipart/form-data

--boundary
Content-Disposition: form-data; name="file"; filename="mosquito.jpg"
Content-Type: image/jpeg

[Binary image data]
--boundary--
```

#### Implementation Example

```dart
Future<WebPredictionResult> getWebPrediction(File imageFile) async {
  final url = Uri.parse("https://culicidaelab.ru/api/predict");
  var request = http.MultipartRequest('POST', url);

  // Detect MIME type from file extension
  String mimeType = 'image/jpeg'; // Default
  if (imageFile.path.toLowerCase().endsWith('.png')) {
    mimeType = 'image/png';
  } else if (imageFile.path.toLowerCase().endsWith('.webp')) {
    mimeType = 'image/webp';
  }

  // Create multipart file
  final multipartFile = await http.MultipartFile.fromPath(
    'file',
    imageFile.path,
    contentType: MediaType.parse(mimeType),
  );

  request.files.add(multipartFile);

  // Send request
  final streamedResponse = await _httpClient.send(request);
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return WebPredictionResult.fromJson(json.decode(response.body));
  } else {
    throw Exception('Prediction failed: ${response.statusCode}');
  }
}
```

#### Response Format

```json
{
  "id": "pred_123456789",
  "scientific_name": "Aedes aegypti",
  "common_name": "Yellow fever mosquito",
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

#### Response Model

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
```

## Observation Submission API

### Endpoint: `/api/observations`

Allows submission of mosquito observation data for research and surveillance purposes.

#### Request Format

```http
POST https://culicidaelab.ru/api/observations
Content-Type: application/json; charset=UTF-8

{
  "species_scientific_name": "Aedes aegypti",
  "species_common_name": "Yellow fever mosquito",
  "confidence": 0.87,
  "latitude": 40.7128,
  "longitude": -74.0060,
  "timestamp": "2024-01-15T10:30:00Z",
  "notes": "Found near standing water",
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

#### Implementation Example

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
    throw Exception('Failed to submit observation: ${response.statusCode} - ${response.body}');
  }
}
```

#### Payload Construction

The application supports two types of observation submissions:

**Local-only predictions:**
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

**Web predictions with full probability distribution:**
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
```

#### Response Format

```json
{
  "id": "obs_987654321",
  "species_scientific_name": "Aedes aegypti",
  "species_common_name": "Yellow fever mosquito",
  "confidence": 0.87,
  "latitude": 40.7128,
  "longitude": -74.0060,
  "timestamp": "2024-01-15T10:30:00Z",
  "notes": "Found near standing water",
  "image_path": "/path/to/image.jpg",
  "prediction_id": "pred_123456789",
  "model_version": "v2.1.0",
  "processing_time_ms": 245,
  "probabilities": {
    "Aedes aegypti": 0.87,
    "Aedes albopictus": 0.09,
    "Culex pipiens": 0.03
  },
  "created_at": "2024-01-15T10:30:15Z",
  "updated_at": "2024-01-15T10:30:15Z",
  "status": "active"
}
```

## Map Integration

### Endpoint: `/map`

Provides access to the interactive mosquito activity map showing observation data and activity patterns.

#### Implementation

```dart
class MosquitoActivityMap extends StatelessWidget {
  final String _mosquitoActivityMapUrl = "https://culicidaelab.ru/map";

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: _mosquitoActivityMapUrl,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        // Configure web view settings
      },
    );
  }
}
```

## Error Handling

### HTTP Status Codes

The API uses standard HTTP status codes:

- `200 OK` - Successful prediction request
- `201 Created` - Successful observation submission
- `400 Bad Request` - Invalid request format or missing parameters
- `413 Payload Too Large` - Image file too large
- `415 Unsupported Media Type` - Invalid image format
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server processing error
- `503 Service Unavailable` - Server maintenance or overload

### Error Response Format

```json
{
  "error": {
    "code": "INVALID_IMAGE_FORMAT",
    "message": "Unsupported image format. Please use JPEG, PNG, or WebP.",
    "details": {
      "supported_formats": ["image/jpeg", "image/png", "image/webp"],
      "max_file_size": "10MB"
    }
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "request_id": "req_123456789"
}
```

### Exception Handling Implementation

```dart
Future<WebPredictionResult> getWebPrediction(File imageFile) async {
  try {
    // API call implementation
    final response = await _httpClient.send(request);

    if (response.statusCode == 200) {
      return WebPredictionResult.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Prediction failed',
        body: response.body,
      );
    }
  } on SocketException {
    throw NetworkException('No internet connection');
  } on TimeoutException {
    throw NetworkException('Request timeout');
  } on FormatException {
    throw ApiException(
      statusCode: 0,
      message: 'Invalid response format',
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

## Rate Limiting and Performance

### Current Limitations

- No explicit rate limiting implemented
- Image size should be optimized before upload
- Network timeouts handled by HTTP client defaults

### Best Practices

```dart
// Image optimization before upload
Future<File> optimizeImageForUpload(File originalImage) async {
  final bytes = await originalImage.readAsBytes();
  final image = img.decodeImage(bytes);

  if (image == null) throw Exception('Invalid image format');

  // Resize if too large (max 1024x1024)
  final resized = image.width > 1024 || image.height > 1024
      ? img.copyResize(image, width: 1024, height: 1024)
      : image;

  // Compress to JPEG with 85% quality
  final compressed = img.encodeJpg(resized, quality: 85);

  // Save optimized image
  final tempDir = await getTemporaryDirectory();
  final optimizedFile = File('${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg');
  await optimizedFile.writeAsBytes(compressed);

  return optimizedFile;
}

// Request timeout configuration
final client = http.Client();
final request = http.MultipartRequest('POST', url);
// Set custom timeout
final response = await client.send(request).timeout(
  const Duration(seconds: 30),
  onTimeout: () => throw TimeoutException('Request timeout'),
);
```

## Testing and Development

### Mock Server Setup

For development and testing, you can create mock responses:

```dart
class MockApiClient implements ApiClient {
  @override
  Future<WebPredictionResult> getWebPrediction(File imageFile) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    return WebPredictionResult(
      id: 'mock_pred_${DateTime.now().millisecondsSinceEpoch}',
      scientificName: 'Aedes aegypti',
      commonName: 'Yellow fever mosquito',
      confidence: 0.87,
      probabilities: {
        'Aedes aegypti': 0.87,
        'Aedes albopictus': 0.09,
        'Culex pipiens': 0.03,
        'Other': 0.01,
      },
      processingTimeMs: 245,
      modelVersion: 'mock_v1.0',
      timestamp: DateTime.now(),
    );
  }
}
```

### Integration Testing

```dart
void main() {
  group('API Integration Tests', () {
    late http.Client httpClient;
    late ClassificationRepository repository;

    setUp(() {
      httpClient = http.Client();
      repository = ClassificationRepository(
        classificationService: MockClassificationService(),
        mosquitoRepository: MockMosquitoRepository(),
        httpClient: httpClient,
      );
    });

    tearDown(() {
      httpClient.close();
    });

    test('should successfully get web prediction', () async {
      final testImage = File('test/fixtures/test_mosquito.jpg');

      final result = await repository.getWebPrediction(testImage);

      expect(result.scientificName, isNotEmpty);
      expect(result.confidence, greaterThan(0.0));
      expect(result.probabilities, isNotEmpty);
    });

    test('should successfully submit observation', () async {
      final payload = {
        'species_scientific_name': 'Aedes aegypti',
        'confidence': 0.87,
        'latitude': 40.7128,
        'longitude': -74.0060,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final result = await repository.submitObservation(finalPayload: payload);

      expect(result.id, isNotEmpty);
      expect(result.speciesScientificName, equals('Aedes aegypti'));
    });
  });
}
```

## Security Considerations

### Data Privacy

- Images are processed server-side but not permanently stored
- Location data is only submitted with explicit user consent
- No personal identification data is collected

### Network Security

- All API communications use HTTPS
- No sensitive authentication tokens in current implementation
- Request/response data is not cached locally

### Input Validation

```dart
// Validate image file before upload
bool isValidImageFile(File imageFile) {
  final extension = path.extension(imageFile.path).toLowerCase();
  final validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

  if (!validExtensions.contains(extension)) {
    return false;
  }

  // Check file size (max 10MB)
  final fileSizeBytes = imageFile.lengthSync();
  const maxSizeBytes = 10 * 1024 * 1024; // 10MB

  return fileSizeBytes <= maxSizeBytes;
}
```

## Future API Enhancements

### Planned Features

1. **Batch Processing**: Submit multiple observations in a single request
2. **Real-time Updates**: WebSocket connections for live map updates
3. **Advanced Filtering**: Query observations by species, location, date range
4. **User Accounts**: Personal observation history and statistics
5. **Data Export**: Download observation data in various formats

### API Versioning

Future API versions will be supported through URL versioning:

```dart
const String apiV2BaseUrl = "https://culicidaelab.ru/api/v2";
const String apiV3BaseUrl = "https://culicidaelab.ru/api/v3";
```

## Troubleshooting

### Common Issues

**Network Connectivity**
```dart
// Check network connectivity before API calls
Future<bool> hasNetworkConnection() async {
  try {
    final result = await InternetAddress.lookup('culicidaelab.ru');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}
```

**Large Image Files**
- Optimize images before upload using image compression
- Consider implementing progressive upload for large files

**Server Timeouts**
- Implement retry logic with exponential backoff
- Show appropriate user feedback during long operations

### Debug Logging

```dart
// Enable detailed HTTP logging for debugging
void enableHttpLogging() {
  HttpOverrides.global = LoggingHttpOverrides();
}

class LoggingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (cert, host, port) {
      print('Bad certificate: $host:$port');
      return false;
    };
    return client;
  }
}
```

## Support and Resources

- **API Documentation**: https://culicidaelab.ru/docs/api
- **Server Status**: https://culicidaelab.ru/health
- **Issue Reporting**: https://github.com/iloncka-ds/culicidaelab-mobile/issues


For additional support or questions about API integration, please contact the development team or create an issue in the project repository.