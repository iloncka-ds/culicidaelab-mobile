# Руководство по оптимизации производительности

Это руководство предоставляет комплексные стратегии для оптимизации мобильных приложений с поддержкой ИИ, специально фокусируясь на техниках, используемых в проекте CulicidaeLab для эффективной классификации комаров и плавного пользовательского опыта.

## Содержание

1. [Производительность моделей ИИ](#производительность-моделей-ии)
2. [Управление памятью](#управление-памятью)
3. [Производительность UI](#производительность-ui)
4. [Оптимизация обработки изображений](#оптимизация-обработки-изображений)
5. [Производительность сети](#производительность-сети)
6. [Оптимизация базы данных](#оптимизация-базы-данных)
7. [Оптимизация сборки и ресурсов](#оптимизация-сборки-и-ресурсов)
8. [Платформо-специфичные оптимизации](#платформо-специфичные-оптимизации)
9. [Мониторинг производительности](#мониторинг-производительности)

## Производительность моделей ИИ

### Оптимизация загрузки моделей

Приложение CulicidaeLab использует PyTorch Lite для вывода на устройстве. Вот ключевые стратегии оптимизации:

#### Ленивая загрузка моделей

```dart
class ClassificationService {
  ClassificationModel? _model;
  
  // Загружать модель только при необходимости, не при запуске приложения
  Future<void> loadModel() async {
    if (_model != null) return; // Уже загружена
    
    try {
      _model = await _pytorchWrapper.loadClassificationModel(
        "assets/models/mosquito_classifier.pt",
        224, 224,
        labelPath: "assets/labels/mosquito_species.txt"
      );
    } on PlatformException {
      throw Exception("Загрузка модели не удалась - поддерживается только для Android/iOS");
    }
  }
  
  bool get isModelLoaded => _model != null;
}
```

#### Стратегия кэширования моделей

```dart
class ModelCache {
  static final Map<String, ClassificationModel> _cache = {};
  
  static Future<ClassificationModel> getModel(String modelPath) async {
    if (_cache.containsKey(modelPath)) {
      return _cache[modelPath]!;
    }
    
    final model = await PytorchLite.loadClassificationModel(
      modelPath, 224, 224
    );
    
    _cache[modelPath] = model;
    return model;
  }
  
  static void clearCache() {
    _cache.clear();
  }
}
```

### Оптимизация вывода

#### Пакетная обработка для множественных изображений

```dart
class BatchClassificationService {
  Future<List<ClassificationResult>> classifyBatch(
    List<File> imageFiles,
    {int batchSize = 4}
  ) async {
    final results = <ClassificationResult>[];
    
    for (int i = 0; i < imageFiles.length; i += batchSize) {
      final batch = imageFiles.skip(i).take(batchSize).toList();
      final batchResults = await Future.wait(
        batch.map((file) => _classifySingle(file))
      );
      results.addAll(batchResults);
      
      // Позволить UI обновиться между пакетами
      await Future.delayed(Duration(milliseconds: 10));
    }
    
    return results;
  }
}
```

#### Мониторинг времени вывода

```dart
class PerformanceTracker {
  final Stopwatch _stopwatch = Stopwatch();
  
  Future<Map<String, dynamic>> classifyWithTiming(File imageFile) async {
    _stopwatch.reset();
    _stopwatch.start();
    
    final result = await _model!.getImagePredictionResult(
      await imageFile.readAsBytes()
    );
    
    _stopwatch.stop();
    
    return {
      'scientificName': result['label'].trim(),
      'confidence': result['probability'],
      'inferenceTime': _stopwatch.elapsedMilliseconds,
    };
  }
}
```

### Оптимизация размера модели

#### Техники квантования

```python
# Скрипт подготовки модели (Python)
import torch
import torch.quantization

def optimize_model_for_mobile(model_path, output_path):
    # Загрузка обученной модели
    model = torch.load(model_path)
    model.eval()
    
    # Применение динамического квантования
    quantized_model = torch.quantization.quantize_dynamic(
        model, {torch.nn.Linear}, dtype=torch.qint8
    )
    
    # Оптимизация для мобильных устройств
    scripted_model = torch.jit.script(quantized_model)
    optimized_model = torch.utils.mobile_optimizer.optimize_for_mobile(
        scripted_model
    )
    
    # Сохранение оптимизированной модели
    optimized_model._save_for_lite_interpreter(output_path)
```

## Управление памятью

### Оптимизация памяти изображений

#### Эффективная загрузка изображений

```dart
class OptimizedImageLoader {
  static Future<Uint8List> loadOptimizedImage(
    File imageFile, 
    {int maxWidth = 224, int maxHeight = 224}
  ) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Неверный формат изображения');
    
    // Изменение размера изображения для уменьшения использования памяти
    final resized = img.copyResize(
      image,
      width: maxWidth,
      height: maxHeight,
      interpolation: img.Interpolation.linear,
    );
    
    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }
}
```

#### Пул памяти для обработки изображений

```dart
class ImageMemoryPool {
  static final Queue<Uint8List> _pool = Queue<Uint8List>();
  static const int _poolSize = 5;
  static const int _bufferSize = 224 * 224 * 3; // Буфер RGB изображения
  
  static Uint8List getBuffer() {
    if (_pool.isNotEmpty) {
      return _pool.removeFirst();
    }
    return Uint8List(_bufferSize);
  }
  
  static void returnBuffer(Uint8List buffer) {
    if (_pool.length < _poolSize) {
      _pool.add(buffer);
    }
  }
}
```

### Управление памятью ViewModel

#### Паттерн правильного освобождения

```dart
class ClassificationViewModel extends ChangeNotifier {
  Timer? _debounceTimer;
  StreamSubscription? _locationSubscription;
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }
  
  void reset() {
    _state = ClassificationState.initial;
    _imageFile = null;
    _result = null;
    _errorMessage = null;
    
    // Очистка больших объектов для освобождения памяти
    _webPredictionResult = null;
    _submissionResult = null;
    
    notifyListeners();
  }
}
```

## Производительность UI

### Оптимизация виджетов

#### Эффективная отрисовка списков

```dart
class OptimizedMosquitoList extends StatelessWidget {
  final List<MosquitoSpecies> species;
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Использование builder для больших списков
      itemCount: species.length,
      cacheExtent: 500, // Кэширование элементов вне экрана
      itemBuilder: (context, index) {
        return MosquitoListItem(
          key: ValueKey(species[index].id), // Стабильные ключи
          species: species[index],
        );
      },
    );
  }
}

class MosquitoListItem extends StatelessWidget {
  final MosquitoSpecies species;
  
  const MosquitoListItem({Key? key, required this.species}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: species.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 50,
            height: 50,
            color: Colors.grey[300],
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        title: Text(species.name),
        subtitle: Text(species.commonName),
      ),
    );
  }
}
```

#### Селективная перестройка виджетов

```dart
class OptimizedClassificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Перестройка только при изменении изображения
          Selector<ClassificationViewModel, File?>(
            selector: (context, vm) => vm.imageFile,
            builder: (context, imageFile, child) {
              return ImagePreview(imageFile: imageFile);
            },
          ),
          
          // Перестройка только при изменении состояния
          Selector<ClassificationViewModel, ClassificationState>(
            selector: (context, vm) => vm.state,
            builder: (context, state, child) {
              return StateIndicator(state: state);
            },
          ),
          
          // Статические виджеты не перестраиваются
          const ActionButtons(),
        ],
      ),
    );
  }
}
```

### Производительность анимаций

#### Эффективные анимации

```dart
class OptimizedLoadingAnimation extends StatefulWidget {
  @override
  _OptimizedLoadingAnimationState createState() => 
      _OptimizedLoadingAnimationState();
}

class _OptimizedLoadingAnimationState extends State<OptimizedLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    // Использование Tween для плавных анимаций
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * math.pi,
          child: Icon(Icons.refresh, size: 24),
        );
      },
    );
  }
}
```#
# Оптимизация обработки изображений

### Эффективная обработка изображений

#### Стратегия сжатия изображений

```dart
class ImageOptimizer {
  static Future<File> optimizeForClassification(File originalFile) async {
    final bytes = await originalFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Неверное изображение');
    
    // Изменение размера до размера входа модели
    final resized = img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.cubic,
    );
    
    // Сжатие с оптимальным качеством
    final compressed = img.encodeJpg(resized, quality: 90);
    
    // Сохранение во временный файл
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(compressed);
    
    return tempFile;
  }
  
  static Future<void> cleanupTempFiles() async {
    final tempDir = await getTemporaryDirectory();
    final files = tempDir.listSync();
    
    for (final file in files) {
      if (file.path.contains('optimized_')) {
        await file.delete();
      }
    }
  }
}
```

#### Фоновая обработка изображений

```dart
class BackgroundImageProcessor {
  static Future<Uint8List> processImageInBackground(File imageFile) async {
    return await compute(_processImage, imageFile.path);
  }
  
  static Uint8List _processImage(String imagePath) {
    final file = File(imagePath);
    final bytes = file.readAsBytesSync();
    final image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Неверное изображение');
    
    // Выполнение тяжелой обработки в изоляте
    final processed = img.copyResize(
      image,
      width: 224,
      height: 224,
    );
    
    return Uint8List.fromList(img.encodeJpg(processed));
  }
}
```

## Производительность сети

### Оптимизация API вызовов

#### Кэширование запросов

```dart
class CachedApiClient {
  static final Map<String, CacheEntry> _cache = {};
  static const Duration _cacheTimeout = Duration(minutes: 5);
  
  static Future<Map<String, dynamic>> getCachedResponse(
    String url,
    Map<String, String> headers,
  ) async {
    final cacheKey = _generateCacheKey(url, headers);
    final cached = _cache[cacheKey];
    
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }
    
    final response = await http.get(Uri.parse(url), headers: headers);
    final data = json.decode(response.body);
    
    _cache[cacheKey] = CacheEntry(data, DateTime.now().add(_cacheTimeout));
    return data;
  }
  
  static String _generateCacheKey(String url, Map<String, String> headers) {
    return '$url${headers.toString()}';
  }
}

class CacheEntry {
  final Map<String, dynamic> data;
  final DateTime expiry;
  
  CacheEntry(this.data, this.expiry);
  
  bool get isExpired => DateTime.now().isAfter(expiry);
}
```

#### Пулинг соединений

```dart
class OptimizedHttpClient {
  static final http.Client _client = http.Client();
  
  static Future<http.Response> post(
    Uri url,
    {Map<String, String>? headers, Object? body}
  ) async {
    return await _client.post(
      url,
      headers: {
        'Connection': 'keep-alive',
        'Keep-Alive': 'timeout=5, max=1000',
        ...?headers,
      },
      body: body,
    );
  }
  
  static void dispose() {
    _client.close();
  }
}
```

## Оптимизация базы данных

### Производительность SQLite

#### Эффективные запросы

```dart
class OptimizedMosquitoRepository {
  final DatabaseService _databaseService;
  
  // Использование подготовленных выражений и индексов
  Future<List<MosquitoSpecies>> getSpeciesByRegion(String region) async {
    final db = await _databaseService.database;
    
    // Использование параметризованных запросов
    final results = await db.query(
      'mosquito_species',
      where: 'distribution LIKE ? AND active = 1',
      whereArgs: ['%$region%'],
      orderBy: 'name ASC',
      limit: 50, // Ограничение результатов для производительности
    );
    
    return results.map((row) => MosquitoSpecies.fromMap(row)).toList();
  }
  
  // Пакетные операции для лучшей производительности
  Future<void> insertSpeciesBatch(List<MosquitoSpecies> species) async {
    final db = await _databaseService.database;
    final batch = db.batch();
    
    for (final species in species) {
      batch.insert('mosquito_species', species.toMap());
    }
    
    await batch.commit(noResult: true);
  }
}
```

#### Индексирование базы данных

```sql
-- Создание индексов для часто запрашиваемых столбцов
CREATE INDEX idx_species_name ON mosquito_species(name);
CREATE INDEX idx_species_distribution ON mosquito_species(distribution);
CREATE INDEX idx_species_active ON mosquito_species(active);

-- Составной индекс для сложных запросов
CREATE INDEX idx_species_region_active ON mosquito_species(distribution, active);
```

## Оптимизация сборки и ресурсов

### Оптимизация ресурсов

#### Оптимизация ресурсов изображений

```yaml
# pubspec.yaml - Оптимизация загрузки ресурсов
flutter:
  assets:
    - assets/images/species/
    - assets/models/
  
  # Использование разных разрешений для разных плотностей экрана
  assets:
    - assets/images/2.0x/
    - assets/images/3.0x/
```

#### Оптимизация ресурсов моделей

```dart
class AssetOptimizer {
  static Future<void> preloadCriticalAssets() async {
    // Предзагрузка критических ресурсов во время экрана загрузки
    await Future.wait([
      rootBundle.load('assets/models/mosquito_classifier.pt'),
      rootBundle.load('assets/labels/mosquito_species.txt'),
      rootBundle.load('assets/database/database_data.json'),
    ]);
  }
}
```

### Оптимизация сборки

#### Конфигурация Proguard (Android)

```proguard
# android/app/proguard-rules.pro
-keep class com.example.culicidaelab.** { *; }
-keep class org.pytorch.** { *; }
-dontwarn org.pytorch.**

# Оптимизировать, но сохранить классы PyTorch
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
```

#### Оптимизация сборки iOS

```ruby
# ios/Podfile
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Включение оптимизаций
      config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '3'
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
    end
  end
end
```

## Платформо-специфичные оптимизации

### Оптимизации Android

#### Управление памятью

```kotlin
// android/app/src/main/kotlin/MainActivity.kt
class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Включение аппаратного ускорения
        window.setFlags(
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
        )
    }
    
    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        
        // Очистка кэшей при нехватке памяти
        when (level) {
            TRIM_MEMORY_RUNNING_CRITICAL,
            TRIM_MEMORY_COMPLETE -> {
                // Очистка кэшей изображений
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "memory")
                    .invokeMethod("clearCaches", null)
            }
        }
    }
}
```

### Оптимизации iOS

#### Предупреждения о памяти

```swift
// ios/Runner/AppDelegate.swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        super.applicationDidReceiveMemoryWarning(application)
        
        // Очистка кэшей при предупреждении о памяти
        if let controller = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(
                name: "memory",
                binaryMessenger: controller.binaryMessenger
            )
            channel.invokeMethod("clearCaches", arguments: nil)
        }
    }
}
```

## Мониторинг производительности

### Сбор метрик производительности

```dart
class PerformanceMonitor {
  static final Map<String, List<int>> _metrics = {};
  
  static void recordInferenceTime(int milliseconds) {
    _metrics.putIfAbsent('inference_time', () => []).add(milliseconds);
  }
  
  static void recordMemoryUsage(int bytes) {
    _metrics.putIfAbsent('memory_usage', () => []).add(bytes);
  }
  
  static Map<String, double> getAverageMetrics() {
    final averages = <String, double>{};
    
    _metrics.forEach((key, values) {
      if (values.isNotEmpty) {
        averages[key] = values.reduce((a, b) => a + b) / values.length;
      }
    });
    
    return averages;
  }
  
  static void clearMetrics() {
    _metrics.clear();
  }
}
```

### Панель производительности в реальном времени

```dart
class PerformanceDashboard extends StatefulWidget {
  @override
  _PerformanceDashboardState createState() => _PerformanceDashboardState();
}

class _PerformanceDashboardState extends State<PerformanceDashboard> {
  Timer? _updateTimer;
  Map<String, double> _metrics = {};
  
  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _metrics = PerformanceMonitor.getAverageMetrics();
      });
    });
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text('Метрики производительности', style: Theme.of(context).textTheme.headlineSmall),
          ..._metrics.entries.map((entry) => 
            ListTile(
              title: Text(entry.key.replaceAll('_', ' ').toUpperCase()),
              trailing: Text('${entry.value.toStringAsFixed(1)}'),
            )
          ),
        ],
      ),
    );
  }
}
```

## Резюме лучших практик

### Производительность моделей
- Загружайте модели лениво, не при запуске приложения
- Используйте квантование моделей для уменьшения размера и улучшения скорости вывода
- Реализуйте кэширование моделей для часто используемых моделей
- Мониторьте время вывода и оптимизируйте соответственно

### Управление памятью
- Реализуйте правильные паттерны освобождения для ViewModels
- Используйте пулы памяти для частых выделений
- Очищайте большие объекты когда они не нужны
- Обрабатывайте предупреждения о памяти платформы

### Производительность UI
- Используйте виджеты `Selector` для минимизации перестроек
- Реализуйте эффективную отрисовку списков с `ListView.builder`
- Кэшируйте дорогие вычисления
- Используйте `const` конструкторы где возможно

### Обработка изображений
- Изменяйте размер изображений до размера входа модели перед обработкой
- Используйте фоновые изоляты для тяжелой обработки изображений
- Реализуйте стратегии сжатия изображений
- Регулярно очищайте временные файлы

### Оптимизация сети
- Реализуйте кэширование запросов
- Используйте пулинг соединений
- Группируйте API запросы когда возможно
- Обрабатывайте сетевые ошибки грациозно

### Интеграция с платформой
- Настройте платформо-специфичные оптимизации
- Обрабатывайте предупреждения о памяти на обеих платформах
- Используйте аппаратное ускорение когда доступно
- Оптимизируйте конфигурации сборки

Следуя этим стратегиям оптимизации, вы можете обеспечить плавную производительность вашего мобильного приложения с поддержкой ИИ на различных устройствах и сценариях использования.