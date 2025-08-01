import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../models/mosquito_model.dart';
import '../services/classification_service.dart';
// import 'mosquito_repository.dart';
import '../models/web_prediction_result.dart';
import '../models/observation_model.dart';

class ClassificationRepository {
  final ClassificationService _classificationService;


  ClassificationRepository({
    ClassificationService? classificationService
    // MosquitoRepository? mosquitoRepository,
  }) :
    _classificationService = classificationService ?? ClassificationService();
    // _mosquitoRepository = mosquitoRepository ?? MosquitoRepository();

  final String _mosquitoPredictionUrl = "http://culicidealab.ru/api/predict";
  final String _mosquitoObservationUrl = "http://culicidealab.ru/api/observations";
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

  Future<WebPredictionResult> getWebPrediction(File imageFile) async {
    final url = Uri.parse(_mosquitoPredictionUrl);
    var request = http.MultipartRequest('POST', url);

    // 1. Detect the file's MIME type from its name
    final mimeType = lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8]);
    print("Detected MIME type: $mimeType");

    // 2. Create a MultipartFile with the correct Content-Type
    final multipartFile = await http.MultipartFile.fromPath(
      'file', // This is the field name the backend expects
      imageFile.path,
      // Use the detected MIME type. Fallback to a default if not found.
      contentType: MediaType.parse(mimeType ?? 'image/jpeg'),
    );

    // 3. Add the correctly typed file to the request
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return WebPredictionResult.fromJson(json.decode(response.body));
    } else {
      // Provide a more detailed error message
      throw Exception(
        // TODO: Localize this message
          'Failed to get web prediction. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<Observation> submitObservation({
    required Map<String, dynamic> finalPayload,
  }) async {
    final url = Uri.parse(_mosquitoObservationUrl);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(finalPayload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      return Observation.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to submit observation: ${response.statusCode} - ${response.body}');
    }
  }
}
