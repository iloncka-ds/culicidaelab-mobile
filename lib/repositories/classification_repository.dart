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
/// results with species data from the database and handles observation submissions
/// to the CulicidaeLab ecosystem.
///
/// ## Architecture Pattern
///
/// The repository implements the Repository pattern to provide a clean abstraction
/// over multiple data sources and services:
/// - **Local Classification**: On-device PyTorch Lite model inference
/// - **Remote Classification**: Server-based classification with advanced models
/// - **Data Enrichment**: Species and disease information from local database
/// - **Observation Submission**: Integration with CulicidaeLab server API
///
/// ## Classification Workflow
///
/// ### Local Classification
/// 1. Load and initialize PyTorch Lite model
/// 2. Process image through local ML model
/// 3. Enrich results with species data from database
/// 4. Retrieve associated diseases for identified species
/// 5. Return comprehensive [ClassificationResult]
///
/// ### Remote Classification
/// 1. Upload image to CulicidaeLab server
/// 2. Receive prediction with probability distribution
/// 3. Return [WebPredictionResult] with detailed probabilities
///
/// ## Usage Example
///
/// ```dart
/// final repository = ClassificationRepository(
///   classificationService: classificationService,
///   mosquitoRepository: mosquitoRepository,
///   httpClient: http.Client(),
/// );
///
/// // Load local model
/// await repository.loadModel();
///
/// // Classify image locally
/// final result = await repository.classifyImage(imageFile, 'en');
/// print('Species: ${result.species.name}');
/// print('Confidence: ${result.confidencePercentage}');
/// print('Diseases: ${result.relatedDiseases.map((d) => d.name).join(', ')}');
///
/// // Get web prediction
/// final webResult = await repository.getWebPrediction(imageFile);
/// print('Top prediction: ${webResult.scientificName}');
/// print('Alternatives: ${webResult.getTopAlternatives(3)}');
/// ```
///
/// ## Error Handling
///
/// The repository handles various error conditions:
/// - **Model Loading Failures**: Platform compatibility, memory constraints
/// - **Network Errors**: Server unavailability, timeout, connectivity issues
/// - **Data Inconsistencies**: Unknown species, missing translations
/// - **API Errors**: Invalid responses, authentication failures
///
/// ## Integration Points
///
/// - **CulicidaeLab Server**: Remote classification and observation submission
/// - **Local Database**: Species and disease information
/// - **PyTorch Lite**: On-device machine learning inference
/// - **File System**: Image processing and temporary storage
///
/// See also:
/// - [ClassificationService] for local ML model operations
/// - [MosquitoRepository] for species and disease data access
/// - [WebPredictionResult] for server-based classification results
/// - [Observation] for observation data submission
class ClassificationRepository {
  /// The classification service for local ML model operations.
  ///
  /// Handles loading and running the PyTorch Lite model for
  /// on-device mosquito species classification.
  final ClassificationService _classificationService;

  /// The mosquito repository for species and disease data.
  ///
  /// Provides access to the local database containing mosquito
  /// species information, disease data, and their relationships.
  final MosquitoRepository _mosquitoRepository;

  /// The HTTP client for web API calls.
  ///
  /// Used for communication with the CulicidaeLab server for
  /// remote classification and observation submission.
  final http.Client _httpClient;

  /// Creates a new classification repository with required dependencies.
  ///
  /// All parameters are required to ensure the repository has access
  /// to all necessary services for complete classification workflows.
  ///
  /// [classificationService] The service for local ML model operations.
  /// [mosquitoRepository] The repository for species and disease data.
  /// [httpClient] The HTTP client for web API communication.
  ///
  /// Example:
  /// ```dart
  /// final repository = ClassificationRepository(
  ///   classificationService: ClassificationService(
  ///     pytorchWrapper: PytorchWrapper(),
  ///   ),
  ///   mosquitoRepository: MosquitoRepository(
  ///     databaseService: DatabaseService(),
  ///   ),
  ///   httpClient: http.Client(),
  /// );
  /// ```
  ClassificationRepository({
    required ClassificationService classificationService,
    required MosquitoRepository mosquitoRepository,
    required http.Client httpClient,
  }) : _classificationService = classificationService,
       _mosquitoRepository = mosquitoRepository,
       _httpClient = httpClient;

  /// The base URL for mosquito prediction API endpoint.
  ///
  /// This endpoint accepts multipart form data with an image file
  /// and returns species predictions with probability distributions.
  final String _mosquitoPredictionUrl = "https://culicidaelab.ru/api/predict";

  /// The base URL for mosquito observation submission API endpoint.
  ///
  /// This endpoint accepts JSON observation data and returns
  /// the created observation record with server-assigned ID.
  final String _mosquitoObservationUrl =
      "https://culicidaelab.ru/api/observations";

  /// Loads the local mosquito classification model.
  ///
  /// This method initializes the PyTorch Lite model used for local
  /// image classification. It must be called before using [classifyImage]
  /// for local classification operations.
  ///
  /// ## Model Loading Process
  ///
  /// 1. **Asset Extraction**: Copies model file from assets to device storage
  /// 2. **Model Initialization**: Loads the PyTorch Lite model into memory
  /// 3. **Label Loading**: Loads species labels for result mapping
  /// 4. **Validation**: Verifies model is ready for inference
  ///
  /// ## Performance Considerations
  ///
  /// - **Loading Time**: Typically 1-5 seconds depending on device
  /// - **Memory Usage**: ~50-100MB for model storage in memory
  /// - **One-Time Operation**: Model remains loaded for app lifetime
  /// - **Background Loading**: Consider loading during app initialization
  ///
  /// ## Error Conditions
  ///
  /// Throws [Exception] if:
  /// - Platform is not supported (Android/iOS only)
  /// - Model file is missing or corrupted in assets
  /// - Insufficient memory is available for model loading
  /// - PyTorch Lite initialization fails
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await repository.loadModel();
  ///   print('Model loaded successfully');
  /// } catch (e) {
  ///   print('Failed to load model: $e');
  ///   // Handle error - perhaps show web-only classification
  /// }
  /// ```
  ///
  /// See also:
  /// - [classifyImage] which requires the model to be loaded first
  /// - [ClassificationService.loadModel] for the underlying implementation
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
  Future<ClassificationResult> classifyImage(
    File imageFile,
    String languageCode,
  ) async {
    final stopwatch = Stopwatch()..start();

    // 1. Get RAW prediction from the service
    final rawResult = await _classificationService.classifyImage(imageFile);
    final String scientificName = rawResult['scientificName'];
    final double confidence =
        rawResult['confidence'] * 100; // Convert to percentage
    print(
      "[DEBUG] Repository: Searching for species with name: '$scientificName'",
    );
    // 2. ENRICH the result using MosquitoRepository to fetch full data
    MosquitoSpecies? speciesFromDb = await _mosquitoRepository
        .getMosquitoSpeciesByName(scientificName, languageCode);
    print(
      "[DEBUG] Repository: Result from DB is: ${speciesFromDb == null ? 'NULL' : speciesFromDb.name}",
    );
    final MosquitoSpecies finalSpecies;
    if (speciesFromDb == null) {
      // Logic for "unknown" species
      finalSpecies = MosquitoSpecies(
        id: '0', // Special ID for unknown
        name: scientificName, // Show what the model actually predicted
        commonName: "Species Not Identified", // Generic fallback
        description:
            "The details for this species are not available in the local database.",
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
      relatedDiseases = await _mosquitoRepository.getDiseasesByVector(
        finalSpecies.name,
        languageCode,
      );
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
        'Failed to get web prediction. Status: ${response.statusCode}, Body: ${response.body}',
      );
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
      throw Exception(
        'Failed to submit observation: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
