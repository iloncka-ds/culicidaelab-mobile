import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mosquito_model.dart';
import '../services/classification_service.dart';
import 'mosquito_repository.dart';
import '../models/submission_result_model.dart';

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

  Future<SubmissionResult> submitObservation({
    required ClassificationResult result,
    required double latitude,
    required double longitude,
    required String notes,
  }) async {
    const String modelName = "mosquito_classifier_v1";
    final url = Uri.parse('https://echo.free.beeceptor.com');

    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', result.imageFile.path));

    final payload = {
      "type": "Feature",
      "properties": {
        "species_scientific_name": result.species.name,
        "observed_at": DateTime.now().toUtc().toIso8601String(),
        "notes": notes.trim().isEmpty ? null : notes.trim(),
        "image_filename": result.imageFile.path.split('/').last,
        "metadata": {
          "confidence": result.confidence,
          "model_id": modelName,
          "species_scientific_name": result.species.name,
        }
      },
      "geometry": {
        "type": "Point",
        "coordinates": [longitude, latitude]
      }
    };

    request.fields['data'] = json.encode(payload);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return SubmissionResult.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to submit observation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error submitting observation: $e');
    }
  }
}
