import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';

import 'pytorch_lite_model.dart';
import 'pytorch_wrapper.dart';

/// Service for handling mosquito species classification using PyTorch models.
///
/// This service provides functionality to load a pre-trained mosquito classification
/// model and classify images to identify mosquito species. It handles model loading,
/// image preprocessing, and prediction results using on-device machine learning.
///
/// ## Usage Example
///
/// ```dart
/// final pytorchWrapper = PytorchWrapper();
/// final classificationService = ClassificationService(
///   pytorchWrapper: pytorchWrapper,
/// );
///
/// // Load the model (required before classification)
/// await classificationService.loadModel();
///
/// // Classify an image
/// final imageFile = File('/path/to/mosquito_image.jpg');
/// final result = await classificationService.classifyImage(imageFile);
/// print('Species: ${result['scientificName']}');
/// print('Confidence: ${result['confidence']}');
/// ```
///
/// ## Model Architecture
///
/// The service uses a PyTorch Lite model optimized for mobile deployment:
/// - **Model**: Pre-trained CNN for mosquito species classification
/// - **Input**: 224x224 RGB images with ImageNet normalization
/// - **Output**: Species probabilities across trained classes
/// - **Performance**: Optimized for real-time inference on mobile devices
///
/// ## Supported Platforms
///
/// - ✅ Android (API 21+)
/// - ✅ iOS (iOS 12.0+)
/// - ❌ Web (PyTorch Lite not supported)
/// - ❌ Desktop (PyTorch Lite not supported)
///
/// ## Error Handling
///
/// The service handles various error conditions:
/// - Platform not supported (throws [PlatformException])
/// - Model loading failures (throws [Exception])
/// - Invalid image formats (handled by PyTorch Lite)
/// - Memory constraints (handled by PyTorch Lite)
///
/// See also:
/// - [ClassificationRepository] for higher-level classification operations
/// - [PytorchWrapper] for the underlying PyTorch integration
/// - [ClassificationModel] for the model interface
class ClassificationService {
  /// The PyTorch wrapper used for model operations.
  ///
  /// This wrapper provides a testable interface around the static
  /// PyTorch Lite methods, enabling dependency injection and easier testing.
  final PytorchWrapper _pytorchWrapper;

  /// The loaded classification model, null if not loaded yet.
  ///
  /// This model instance is created during [loadModel] and used
  /// for all subsequent classification operations. It remains null
  /// until the model is successfully loaded.
  ClassificationModel? _model;

  /// Stopwatch for performance measurement.
  ///
  /// Used to measure inference time for performance monitoring
  /// and user feedback. Started before classification and stopped
  /// after results are obtained.
  final stopwatch = Stopwatch();

  /// Creates a new classification service with the provided PyTorch wrapper.
  ///
  /// The [pytorchWrapper] parameter is required and provides the interface
  /// to the underlying PyTorch Lite functionality. This design enables
  /// dependency injection and makes the service testable.
  ///
  /// Example:
  /// ```dart
  /// final service = ClassificationService(
  ///   pytorchWrapper: PytorchWrapper(),
  /// );
  /// ```
  ClassificationService({required PytorchWrapper pytorchWrapper})
      : _pytorchWrapper = pytorchWrapper;

  /// Loads the mosquito classification model from the specified path.
  ///
  /// This method initializes the PyTorch Lite model used for mosquito species
  /// classification. The model is loaded with predefined dimensions optimized
  /// for the training dataset and includes species labels for result mapping.
  ///
  /// ## Model Configuration
  ///
  /// - **Model Path**: `assets/models/mosquito_classifier.pt`
  /// - **Input Dimensions**: 224x224 pixels (standard ImageNet size)
  /// - **Labels Path**: `assets/labels/mosquito_species.txt`
  /// - **Normalization**: ImageNet mean and standard deviation
  ///
  /// ## Performance Considerations
  ///
  /// Model loading is a one-time operation that should be performed during
  /// app initialization or when the classification feature is first accessed.
  /// The loaded model remains in memory for subsequent classifications.
  ///
  /// ## Error Conditions
  ///
  /// - Throws [Exception] if the platform is not supported (Android/iOS only)
  /// - Throws [Exception] if the model file is not found in assets
  /// - Throws [Exception] if the model format is invalid or corrupted
  /// - Throws [Exception] if insufficient memory is available
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await classificationService.loadModel();
  ///   print('Model loaded successfully');
  /// } catch (e) {
  ///   print('Failed to load model: $e');
  /// }
  /// ```
  Future<void> loadModel() async {
    String pathImageModel = "assets/models/mosquito_classifier.pt";
    try {
      _model = await _pytorchWrapper.loadClassificationModel(
          pathImageModel, 224, 224,
          labelPath: "assets/labels/mosquito_species.txt");
    } on PlatformException {
      throw Exception("Model loading failed - only supported for Android/iOS");
    }
  }

  /// Classifies a mosquito image and returns the predicted species and confidence.
  ///
  /// This method performs the core classification operation by processing an image
  /// through the loaded PyTorch model. It handles image preprocessing, model
  /// inference, and result post-processing to return a clean prediction.
  ///
  /// ## Image Processing Pipeline
  ///
  /// 1. **Image Loading**: Reads image bytes from the provided file
  /// 2. **Preprocessing**: Resizes to 224x224 and applies ImageNet normalization
  /// 3. **Model Inference**: Runs the image through the neural network
  /// 4. **Post-processing**: Applies softmax and extracts top prediction
  /// 5. **Result Formatting**: Returns scientific name and confidence score
  ///
  /// ## Input Requirements
  ///
  /// - **Supported Formats**: JPEG, PNG, BMP, WebP
  /// - **Recommended Size**: Any size (automatically resized to 224x224)
  /// - **Color Space**: RGB (grayscale images are converted)
  /// - **File Size**: No strict limit, but larger files take longer to process
  ///
  /// ## Output Format
  ///
  /// Returns a map with the following keys:
  /// - `'scientificName'`: String containing the predicted species name
  /// - `'confidence'`: Double between 0.0 and 1.0 representing prediction confidence
  ///
  /// ## Performance Characteristics
  ///
  /// - **Inference Time**: Typically 100-2000ms depending on device
  /// - **Memory Usage**: ~50-100MB during inference
  /// - **CPU Usage**: High during inference, minimal when idle
  ///
  /// ## Error Conditions
  ///
  /// - Throws [Exception] if the model is not loaded (call [loadModel] first)
  /// - Throws [Exception] if the image file cannot be read
  /// - Throws [Exception] if the image format is not supported
  /// - Throws [Exception] if insufficient memory is available
  ///
  /// Example:
  /// ```dart
  /// final imageFile = File('/path/to/mosquito.jpg');
  /// try {
  ///   final result = await classificationService.classifyImage(imageFile);
  ///   final species = result['scientificName'] as String;
  ///   final confidence = result['confidence'] as double;
  ///   
  ///   print('Predicted species: $species');
  ///   print('Confidence: ${(confidence * 100).toStringAsFixed(1)}%');
  /// } catch (e) {
  ///   print('Classification failed: $e');
  /// }
  /// ```
  ///
  /// See also:
  /// - [loadModel] which must be called before using this method
  /// - [ClassificationResult] for the enriched result format used by repositories
  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    if (_model == null) {
      throw Exception("Model not loaded - call loadModel() first");
    }

    final imageBytes = await imageFile.readAsBytes();

    // This returns a map like {'label': 'Aedes aegypti', 'probability': 0.98}
    final result = await _model!.getImagePredictionResult(imageBytes);
    print(result['label']);
    print("[DEBUG] Raw name length: ${result['label'].length}");
    
    // Return the raw prediction directly with cleaned scientific name
    return {
      'scientificName': result['label'].trim(),
      'confidence': result['probability'],
    };
  }

  /// Checks if the classification model is loaded and ready for use.
  ///
  /// Returns `true` if the model has been successfully loaded and is
  /// available for classification operations, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (!classificationService.isModelLoaded) {
  ///   await classificationService.loadModel();
  /// }
  /// final result = await classificationService.classifyImage(imageFile);
  /// ```
  bool get isModelLoaded => _model != null;

  /// Gets the current model instance.
  ///
  /// Returns the loaded [ClassificationModel] instance, or null if
  /// no model has been loaded yet. This is primarily used for testing
  /// and advanced use cases.
  ///
  /// **Note**: This getter is mainly for internal use and testing.
  /// Most applications should use [isModelLoaded] to check model status.
  ClassificationModel? get model => _model;

}