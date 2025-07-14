import 'dart:io';
import '../models/mosquito_model.dart';
import '../services/classification_service.dart';
import 'mosquito_repository.dart';

class ClassificationRepository {
  final ClassificationService _classificationService;
  final MosquitoRepository _mosquitoRepository;

  ClassificationRepository({
    ClassificationService? classificationService,
    MosquitoRepository? mosquitoRepository,
  }) :
    _classificationService = classificationService ?? ClassificationService(),
    _mosquitoRepository = mosquitoRepository ?? MosquitoRepository();

  /// Load the classification model
  Future<void> loadModel() async {

    await _classificationService.loadModel();

  }

  /// Classify a mosquito image and return the result with related data
  Future<ClassificationResult> classifyImage(File imageFile, String languageCode) async {
    // Get the raw classification result (this part is language-agnostic)
    final result = await _classificationService.classifyImage(imageFile, languageCode);

    // Enrich the result with related diseases from the repository
    // The service has already fetched the localized species data.
    // The related diseases are also fetched within the service call.
    // We can just use the result directly.
    return result;
  }
}