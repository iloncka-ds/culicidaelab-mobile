# Performance Optimization Guide

This guide provides comprehensive strategies for optimizing AI-powered mobile applications, specifically focusing on techniques used in the CulicidaeLab project for efficient mosquito classification and smooth user experience.

## Table of Contents

1. [AI Model Performance](#ai-model-performance)
2. [Memory Management](#memory-management)
3. [UI Performance](#ui-performance)
4. [Image Processing Optimization](#image-processing-optimization)
5. [Network Performance](#network-performance)
6. [Database Optimization](#database-optimization)
7. [Build and Asset Optimization](#build-and-asset-optimization)
8. [Platform-Specific Optimizations](#platform-specific-optimizations)
9. [Performance Monitoring](#performance-monitoring)

## AI Model Performance

### Model Loading Optimization

The CulicidaeLab app uses PyTorch Lite for on-device inference. Here are key optimization strategies:

#### Lazy Model Loading

```dart
class ClassificationService {
  ClassificationModel? _model;
  
  // Load model only when needed, not at app startup
  Future<void> loadModel() async {
    if (_model != null) return; // Already loaded
    
    try {
      _model = await _pytorchWrapper.loadClassificationModel(
        "assets/models/mosquito_classifier.pt",
        224, 224,
        labelPath: "assets/labels/mosquito_species.txt"
      );
    } on PlatformException {
      throw Exception("Model loading failed - only supported for Android/iOS");
    }
  }
  
  bool get isModelLoaded => _model != null;
}
```

#### Model Caching Strategy

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

### Inference Optimization

#### Batch Processing for Multiple Images

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
      
      // Allow UI to update between batches
      await Future.delayed(Duration(milliseconds: 10));
    }
    
    return results;
  }
}
```

#### Inference Time Monitoring

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

### Model Size Optimization

#### Quantization Techniques

```python
# Model preparation script (Python)
import torch
import torch.quantization

def optimize_model_for_mobile(model_path, output_path):
    # Load the trained model
    model = torch.load(model_path)
    model.eval()
    
    # Apply dynamic quantization
    quantized_model = torch.quantization.quantize_dynamic(
        model, {torch.nn.Linear}, dtype=torch.qint8
    )
    
    # Optimize for mobile
    scripted_model = torch.jit.script(quantized_model)
    optimized_model = torch.utils.mobile_optimizer.optimize_for_mobile(
        scripted_model
    )
    
    # Save optimized model
    optimized_model._save_for_lite_interpreter(output_path)
```

## Memory Management

### Image Memory Optimization

#### Efficient Image Loading

```dart
class OptimizedImageLoader {
  static Future<Uint8List> loadOptimizedImage(
    File imageFile, 
    {int maxWidth = 224, int maxHeight = 224}
  ) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Invalid image format');
    
    // Resize image to reduce memory usage
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

#### Memory Pool for Image Processing

```dart
class ImageMemoryPool {
  static final Queue<Uint8List> _pool = Queue<Uint8List>();
  static const int _poolSize = 5;
  static const int _bufferSize = 224 * 224 * 3; // RGB image buffer
  
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

### ViewModel Memory Management

#### Proper Disposal Pattern

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
    
    // Clear large objects to free memory
    _webPredictionResult = null;
    _submissionResult = null;
    
    notifyListeners();
  }
}
```

## UI Performance

### Widget Optimization

#### Efficient List Rendering

```dart
class OptimizedMosquitoList extends StatelessWidget {
  final List<MosquitoSpecies> species;
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Use builder for large lists
      itemCount: species.length,
      cacheExtent: 500, // Cache off-screen items
      itemBuilder: (context, index) {
        return MosquitoListItem(
          key: ValueKey(species[index].id), // Stable keys
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

#### Selective Widget Rebuilding

```dart
class OptimizedClassificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Only rebuild when image changes
          Selector<ClassificationViewModel, File?>(
            selector: (context, vm) => vm.imageFile,
            builder: (context, imageFile, child) {
              return ImagePreview(imageFile: imageFile);
            },
          ),
          
          // Only rebuild when state changes
          Selector<ClassificationViewModel, ClassificationState>(
            selector: (context, vm) => vm.state,
            builder: (context, state, child) {
              return StateIndicator(state: state);
            },
          ),
          
          // Static widgets don't rebuild
          const ActionButtons(),
        ],
      ),
    );
  }
}
```

### Animation Performance

#### Efficient Animations

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
    
    // Use Tween for smooth animations
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
```

## Image Processing Optimization

### Efficient Image Handling

#### Image Compression Strategy

```dart
class ImageOptimizer {
  static Future<File> optimizeForClassification(File originalFile) async {
    final bytes = await originalFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Invalid image');
    
    // Resize to model input size
    final resized = img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.cubic,
    );
    
    // Compress with optimal quality
    final compressed = img.encodeJpg(resized, quality: 90);
    
    // Save to temporary file
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

#### Background Image Processing

```dart
class BackgroundImageProcessor {
  static Future<Uint8List> processImageInBackground(File imageFile) async {
    return await compute(_processImage, imageFile.path);
  }
  
  static Uint8List _processImage(String imagePath) {
    final file = File(imagePath);
    final bytes = file.readAsBytesSync();
    final image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Invalid image');
    
    // Perform heavy processing in isolate
    final processed = img.copyResize(
      image,
      width: 224,
      height: 224,
    );
    
    return Uint8List.fromList(img.encodeJpg(processed));
  }
}
```

## Network Performance

### API Call Optimization

#### Request Caching

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

#### Connection Pooling

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

## Database Optimization

### SQLite Performance

#### Efficient Queries

```dart
class OptimizedMosquitoRepository {
  final DatabaseService _databaseService;
  
  // Use prepared statements and indexes
  Future<List<MosquitoSpecies>> getSpeciesByRegion(String region) async {
    final db = await _databaseService.database;
    
    // Use parameterized queries
    final results = await db.query(
      'mosquito_species',
      where: 'distribution LIKE ? AND active = 1',
      whereArgs: ['%$region%'],
      orderBy: 'name ASC',
      limit: 50, // Limit results for performance
    );
    
    return results.map((row) => MosquitoSpecies.fromMap(row)).toList();
  }
  
  // Batch operations for better performance
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

#### Database Indexing

```sql
-- Create indexes for frequently queried columns
CREATE INDEX idx_species_name ON mosquito_species(name);
CREATE INDEX idx_species_distribution ON mosquito_species(distribution);
CREATE INDEX idx_species_active ON mosquito_species(active);

-- Composite index for complex queries
CREATE INDEX idx_species_region_active ON mosquito_species(distribution, active);
```

## Build and Asset Optimization

### Asset Optimization

#### Image Asset Optimization

```yaml
# pubspec.yaml - Optimize asset loading
flutter:
  assets:
    - assets/images/species/
    - assets/models/
  
  # Use different resolutions for different screen densities
  assets:
    - assets/images/2.0x/
    - assets/images/3.0x/
```

#### Model Asset Optimization

```dart
class AssetOptimizer {
  static Future<void> preloadCriticalAssets() async {
    // Preload critical assets during splash screen
    await Future.wait([
      rootBundle.load('assets/models/mosquito_classifier.pt'),
      rootBundle.load('assets/labels/mosquito_species.txt'),
      rootBundle.load('assets/database/database_data.json'),
    ]);
  }
}
```

### Build Optimization

#### Proguard Configuration (Android)

```proguard
# android/app/proguard-rules.pro
-keep class com.example.culicidaelab.** { *; }
-keep class org.pytorch.** { *; }
-dontwarn org.pytorch.**

# Optimize but keep PyTorch classes
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
```

#### iOS Build Optimization

```ruby
# ios/Podfile
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Enable optimizations
      config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '3'
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
    end
  end
end
```

## Platform-Specific Optimizations

### Android Optimizations

#### Memory Management

```kotlin
// android/app/src/main/kotlin/MainActivity.kt
class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable hardware acceleration
        window.setFlags(
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
        )
    }
    
    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        
        // Clear caches when memory is low
        when (level) {
            TRIM_MEMORY_RUNNING_CRITICAL,
            TRIM_MEMORY_COMPLETE -> {
                // Clear image caches
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "memory")
                    .invokeMethod("clearCaches", null)
            }
        }
    }
}
```

### iOS Optimizations

#### Memory Warnings

```swift
// ios/Runner/AppDelegate.swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        super.applicationDidReceiveMemoryWarning(application)
        
        // Clear caches on memory warning
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

## Performance Monitoring

### Performance Metrics Collection

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

### Real-time Performance Dashboard

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
          Text('Performance Metrics', style: Theme.of(context).textTheme.headlineSmall),
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

## Best Practices Summary

### Model Performance
- Load models lazily, not at app startup
- Use model quantization to reduce size and improve inference speed
- Implement model caching for frequently used models
- Monitor inference times and optimize accordingly

### Memory Management
- Implement proper disposal patterns for ViewModels
- Use memory pools for frequent allocations
- Clear large objects when not needed
- Handle platform memory warnings

### UI Performance
- Use `Selector` widgets to minimize rebuilds
- Implement efficient list rendering with `ListView.builder`
- Cache expensive computations
- Use `const` constructors where possible

### Image Processing
- Resize images to model input size before processing
- Use background isolates for heavy image processing
- Implement image compression strategies
- Clean up temporary files regularly

### Network Optimization
- Implement request caching
- Use connection pooling
- Batch API requests when possible
- Handle network errors gracefully

### Platform Integration
- Configure platform-specific optimizations
- Handle memory warnings on both platforms
- Use hardware acceleration when available
- Optimize build configurations

By following these optimization strategies, you can ensure your AI-powered mobile application delivers smooth performance across different devices and usage scenarios.