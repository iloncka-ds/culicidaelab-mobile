import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';

import 'pytorch_lite_model.dart';
import 'pytorch_wrapper.dart';


/// Service for handling mosquito species classification using PyTorch models.
///
/// This service provides functionality to load a pre-trained mosquito classification
/// model and classify images to identify mosquito species. It handles model loading,
/// image preprocessing, and prediction results.
class ClassificationService {
  /// The PyTorch wrapper used for model operations.
  final PytorchWrapper _pytorchWrapper;

  /// The loaded classification model, null if not loaded yet.
  ClassificationModel? _model;

  /// Stopwatch for performance measurement.
  final stopwatch = Stopwatch();

  /// Creates a new classification service with the provided PyTorch wrapper.
  ///
  /// @param pytorchWrapper The wrapper for PyTorch model operations
  ClassificationService({required PytorchWrapper pytorchWrapper})
      : _pytorchWrapper = pytorchWrapper;

  /// Loads the mosquito classification model from the specified path.
  ///
  /// The model is loaded with the specified dimensions for image processing.
  /// Throws an exception if the model fails to load or if the platform
  /// is not supported (Android/iOS only).
  ///
  /// @return A Future that completes when the model is loaded
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
  /// Takes an image file, processes it through the loaded classification model,
  /// and returns the predicted scientific name and confidence score.
  /// The model must be loaded first using [loadModel()].
  ///
  /// @param imageFile The image file to classify
  /// @return A Future containing a map with 'scientificName' and 'confidence' keys
  /// @throws Exception if the model is not loaded
  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    if (_model == null) {
      throw Exception("Model not loaded");
    }

    final imageBytes = await imageFile.readAsBytes();

    // This returns a map like {'label': 'Aedes aegypti', 'probability': 0.98}
    final result = await _model!.getImagePredictionResult(imageBytes);
    print(result['label']);
    print("[DEBUG] Raw name length: ${result['label'].length}");
    // Return the raw prediction directly
    return {
      'scientificName': result['label'].trim(),
      'confidence':  result['probability'],
    };
  }

}