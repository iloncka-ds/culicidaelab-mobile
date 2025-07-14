# Performance Test Configuration & Setup

## Overview
This document provides setup instructions and configuration for running performance tests on the mosquito classification app.

## Prerequisites

### Dependencies
Add these dependencies to your `pubspec.yaml` file under `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  build_runner: ^2.4.7
  test: ^1.24.0
  integration_test:
    sdk: flutter
```

### Mock Generation
Run the following command to generate mocks:

```bash
flutter packages pub run build_runner build
```

### Test Directory Structure
```
test/
├── performance/
│   ├── classification_performance_test.dart
│   ├── classification_performance_test.mocks.dart (generated)
│   └── performance_test_utils.dart
├── unit/
├── widget/
└── integration/
```

## Running Performance Tests

### Individual Test Execution
```bash
# Run all performance tests
flutter test test/performance/

# Run specific performance test
flutter test test/performance/classification_performance_test.dart

# Run with verbose output
flutter test test/performance/ --verbose
```

### Performance Test Categories

#### 1. Memory Usage Tests
- **Image Loading Memory**: Tests memory consumption when loading images of various sizes
- **Classification Memory**: Measures memory usage during classification operations
- **Memory Leak Detection**: Ensures proper cleanup of resources

#### 2. Duration Performance Tests
- **Image Processing Time**: Measures time to load and process images
- **Classification Speed**: Tests inference time for mosquito classification
- **Database Query Performance**: Measures database operation speeds
- **UI State Management**: Tests responsiveness of UI state changes

#### 3. Concurrent Operations Tests
- **Multiple Classifications**: Tests performance under multiple simultaneous operations
- **Database Concurrent Access**: Tests concurrent database operations
- **Resource Contention**: Measures performance under resource stress

## Performance Benchmarks

### Acceptable Performance Thresholds

| Operation | Target Time | Maximum Time | Memory Usage |
|-----------|-------------|--------------|--------------|
| Image Loading (1MB) | < 500ms | < 2000ms | < 10MB |
| Classification | < 1000ms | < 5000ms | < 50MB |
| Database Query | < 100ms | < 1000ms | < 5MB |
| UI State Update | < 16ms | < 100ms | < 1MB |

### Memory Benchmarks
- **Image Cache**: Should not exceed 100MB total
- **Classification Results**: Should be garbage collected after reset
- **Database Connections**: Should be properly closed and pooled

## Performance Monitoring Setup

### 1. Development Monitoring
Add performance monitoring to your development workflow:

```dart
// Add to main.dart for development builds
void main() {
  if (kDebugMode) {
    // Enable performance overlay
    runApp(MyApp(
      performanceOverlay: true,
    ));
  } else {
    runApp(MyApp());
  }
}
```

### 2. Production Monitoring
For production apps, consider integrating:
- Firebase Performance Monitoring
- Custom analytics for classification times
- Memory usage tracking

## Test Data Generation

### Mock Image Creation Sizes
The test utility creates images of various sizes to test performance:

```dart
// Small images (typical phone camera compressed)
createMockImageFile(sizeKB: 200)   // 200KB

// Medium images (normal photo quality)
createMockImageFile(sizeKB: 1024)  // 1MB

// Large images (high quality/uncompressed)
createMockImageFile(sizeKB: 4096)  // 4MB
```

## Interpreting Results

### Performance Test Output Example
```
=== Performance Test Results: Image Classification ===
Iterations: 5
Duration (ms) - Avg: 1250.40, Min: 1100, Max: 1450
Memory Delta - Avg: 15.20, Max: 25
========================================
```

### Performance Regression Detection
- **Duration Increase > 20%**: Investigate code changes
- **Memory Delta > 50MB**: Check for memory leaks
- **Failure Rate > 5%**: Review error handling

## Continuous Integration Setup

### GitHub Actions Example
```yaml
name: Performance Tests

on:
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]

jobs:
  performance_tests:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Generate mocks
      run: flutter packages pub run build_runner build
      
    - name: Run performance tests
      run: flutter test test/performance/ --coverage
      
    - name: Upload performance results
      uses: actions/upload-artifact@v3
      with:
        name: performance-results
        path: coverage/
```

## Troubleshooting

### Common Issues

1. **Mock Generation Fails**
   ```bash
   flutter packages pub run build_runner clean
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

2. **Test Timeouts**
   - Increase timeout in test configuration
   - Check for infinite loops in async operations

3. **Memory Test Inconsistencies**
   - Run tests on consistent hardware
   - Close other applications during testing
   - Use average results from multiple runs

4. **File System Access Issues**
   ```dart
   // Ensure proper permissions for test file creation
   await Permission.storage.request();
   ```

## Best Practices

### Test Design
- **Realistic Test Data**: Use images similar to actual user photos
- **Multiple Iterations**: Run tests multiple times for consistent results
- **Resource Cleanup**: Always clean up test files and resources
- **Isolated Tests**: Each test should be independent

### Performance Optimization Tips
- **Image Compression**: Implement image compression before classification
- **Lazy Loading**: Load species/disease data on demand
- **Caching**: Cache classification results for repeated images
- **Background Processing**: Use isolates for heavy computations

## Monitoring in Production

### Key Metrics to Track
- Average classification time
- Memory usage patterns
- Crash rates during image processing
- User abandonment rates during classification

### Alert Thresholds
- Classification time > 10 seconds: Critical
- Memory usage > 200MB: Warning
- App crashes > 1% of sessions: Critical
- Classification accuracy < 80%: Investigation needed

## Additional Resources

- [Flutter Performance Profiling](https://flutter.dev/docs/perf/rendering/ui-performance)
- [Dart Memory Management](https://dart.dev/guides/language/effective-dart)
- [Testing Best Practices](https://flutter.dev/docs/testing)
- [CI/CD for Flutter](https://flutter.dev/docs/deployment/cd)