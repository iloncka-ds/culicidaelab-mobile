import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../models/mosquito_model.dart';
import '../models/disease_model.dart';
import '../services/classification_service.dart';
import 'mosquito_repository.dart';

import '../models/web_prediction_result.dart';
import '../models/observation_model.dart';

/// Repository for handling mosquito image classification and observation operations.
///
/// This repository orchestrates the classification of mosquito images using both
/// local ML models and web-based prediction services. It enriches classification
/// results with species data from the database and handles observation submissions.
///
/// The repository coordinates between:
/// - [ClassificationService] for local ML model inference
/// - [MosquitoRepository] for species and disease data
/// - HTTP client for web API calls
class ClassificationRepository {
  final ClassificationService _classificationService;
  final MosquitoRepository _mosquitoRepository;
  final http.Client _httpClient;

  ClassificationRepository({
    required ClassificationService classificationService,
    required MosquitoRepository mosquitoRepository,
    required http.Client httpClient,
  })  : _classificationService = classificationService,
        _mosquitoRepository = mosquitoRepository,
        _httpClient = httpClient;

  /// The base URL for mosquito prediction API endpoint.
  final String _mosquitoPredictionUrl = "https://culicidealab.ru/api/predict";
  /// The base URL for mosquito observation submission API endpoint.
  final String _mosquitoObservationUrl = "https://culicidealab.ru/api/observations";
/// Loads the local mosquito classification model.
///
/// This method initializes the machine learning model used for local
/// image classification. Must be called before using [classifyImage].
/// Throws an exception if the model fails to load.

  Future<void> loadModel() async {
    await _classificationService.loadModel();
  }

  /// Classifies a mosquito image and returns enriched results with species data.
  ///
  /// This method performs a complete classification workflow:
  /// 1. Runs local ML model inference on the image
  /// 2. Enriches results with species data from database
  /// 3. Retrieves associated diseases for identified species
  /// 4. Returns comprehensive classification results
  ///
  /// [imageFile] The image file to classify.
  /// [languageCode] The language code (e.g., 'en', 'es') for localized content.
  /// Returns a [ClassificationResult] with species, confidence, and related diseases.
  /// Throws an exception if classification fails.
Future<ClassificationResult> classifyImage(File imageFile, String languageCode) async {
    final stopwatch = Stopwatch()..start();

    // 1. Get RAW prediction from the service
    final rawResult = await _classificationService.classifyImage(imageFile);
    final String scientificName = rawResult['scientificName'];
    final double confidence = rawResult['confidence'] * 100; // Convert to percentage
    print("[DEBUG] Repository: Searching for species with name: '$scientificName'");
    // 2. ENRICH the result using MosquitoRepository to fetch full data
    MosquitoSpecies? speciesFromDb = await _mosquitoRepository.getMosquitoSpeciesByName(scientificName, languageCode);
    print("[DEBUG] Repository: Result from DB is: ${speciesFromDb == null ? 'NULL' : speciesFromDb.name}");
    final MosquitoSpecies finalSpecies;
    if (speciesFromDb == null) {
      // Logic for "unknown" species
      finalSpecies = MosquitoSpecies(
        id: '0', // Special ID for unknown
        name: scientificName, // Show what the model actually predicted
        commonName: "Species Not Identified", // Generic fallback
        description: "The details for this species are not available in the local database.",
        habitat: "N/A",
        distribution: "N/A",
        imageUrl: "assets/images/species/species_not_defined.jpg",
        diseases: [],
      );
    } else {
      finalSpecies = speciesFromDb;
    }

    // 3. Fetch full Disease objects for the related diseases
    List<Disease> relatedDiseases = [];
    if (finalSpecies.id != '0') {
      relatedDiseases = await _mosquitoRepository.getDiseasesByVector(finalSpecies.name, languageCode);
    }

    stopwatch.stop();

    // 4. Assemble and return the complete, rich ClassificationResult
    return ClassificationResult(
      species: finalSpecies,
      confidence: confidence,
      inferenceTime: stopwatch.elapsedMilliseconds,
      relatedDiseases: relatedDiseases,
      imageFile: imageFile,
    );
  }
/// Gets a web-based prediction for a mosquito image.
///
/// Sends the image to a remote prediction service for classification.
/// This provides an alternative to local model classification.
///
/// [imageFile] The image file to get prediction for.
/// Returns a [WebPredictionResult] with prediction data.
/// Throws an exception if the web request fails.
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

    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return WebPredictionResult.fromJson(json.decode(response.body));
    } else {
            throw Exception(
          'Failed to get web prediction. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  /// Submits a mosquito observation to the remote server.
  ///
  /// Sends observation data including location, species information,
  /// and other metadata to the central database.
  ///
  /// [finalPayload] A map containing all observation data to submit.
  /// Returns an [Observation] object representing the submitted record.
  /// Throws an exception if submission fails.
  Future<Observation> submitObservation({
    required Map<String, dynamic> finalPayload,
  }) async {
    final url = Uri.parse(_mosquitoObservationUrl);

    final response = await _httpClient.post(
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
