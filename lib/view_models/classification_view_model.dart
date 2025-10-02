import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../services/user_service.dart';
import '../models/mosquito_model.dart';
import '../repositories/classification_repository.dart';
import 'package:culicidaelab/l10n/app_localizations.dart';
import '../models/web_prediction_result.dart';
import '../models/observation_model.dart';

/// Represents the different states of the classification process
enum ClassificationState { initial, loading, success, error, submitting, submitted }

/// A view model that manages the classification of mosquito images.
///
/// This class handles the entire classification workflow including:
/// - Image selection from device
/// - Local image classification
/// - Web-based prediction fallback
/// - Observation submission
class ClassificationViewModel extends ChangeNotifier {
  // --- SECTION 1: FINAL PROPERTIES ---
  final ClassificationRepository _repository;
  final UserService _userService;
  final String modelId = "on-device-model-v1"; // A clear name for the local model

  // --- SECTION 2: STATE VARIABLES ---
  @visibleForTesting
  ClassificationState _state = ClassificationState.initial;
  @visibleForTesting
  File? _imageFile;
  @visibleForTesting
  ClassificationResult? _result; // This is for the on-device (local) result
  @visibleForTesting
  String? _errorMessage;


  // These are for managing the asynchronous web prediction
  @visibleForTesting
  WebPredictionResult? _webPredictionResult; // Use the correct type-safe model
  @visibleForTesting
  bool _isFetchingWebPrediction = false;

  // This holds the final submitted observation
  Observation? _submissionResult;

  // --- SECTION 3: CONSTRUCTOR ---

  ClassificationViewModel({
    required ClassificationRepository repository,
    required UserService userService,
  })  : _repository = repository,
        _userService = userService;

  // --- SECTION 4: GETTERS FOR UI ---
  ClassificationState get state => _state;
  File? get imageFile => _imageFile;
  bool get hasImage => _imageFile != null;
  ClassificationResult? get result => _result;
  String? get errorMessage => _errorMessage;
  bool get isProcessing => _state == ClassificationState.loading;
  bool get isSubmitting => _state == ClassificationState.submitting;

  // --- GETTERS FOR THE WEB PREDICTION STATE ---
  WebPredictionResult? get webPredictionResult => _webPredictionResult;
  bool get isFetchingWebPrediction => _isFetchingWebPrediction;
  Observation? get submissionResult => _submissionResult;

  // --- SECTION 5: PUBLIC METHODS (The "API" of this ViewModel) ---

  /// Initializes the classification model for local predictions.
  ///
  /// Loads the machine learning model required for local image classification.
  ///
  /// Parameters:
  ///   - localizations: Used for localized error messages
  ///
  /// Throws:
  ///   - Exception if model loading fails
  Future<void> initModel(AppLocalizations localizations) async {
    try {
      await _repository.loadModel();
    } catch (e) {
      if (e.toString().contains("Model loading failed")) {
        _errorMessage = localizations.classificationServiceErrorModelLoadingFailed;
      } else {
        _errorMessage = localizations.errorFailedToLoadModel(e.toString());
      }
      notifyListeners();
    }
  }

  /// Picks an image from the specified source for classification.
  ///
  /// Parameters:
  ///   - source: The image source (camera or gallery)
  ///   - localizations: Used for localized error messages
  ///
  /// Updates the UI state and notifies listeners when complete.
  /// Picks an image from the specified source for classification.
  ///
  /// Parameters:
  ///   - source: The image source (camera or gallery)
  ///   - localizations: Used for localized error messages
  ///
  /// Updates the UI state and notifies listeners when complete.
  Future<void> pickImage(
    ImageSource source,
    AppLocalizations localizations,
  ) async {
    final picker = ImagePicker();
    try {
      _state = ClassificationState.initial;
      _result = null;
      _errorMessage = null;
      notifyListeners();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = localizations.errorFailedToPickImage(e.toString());
      notifyListeners();
    }
  }

  /// Classifies the currently selected image using the local model.
  ///
  /// Processes the image and updates the UI with classification results.
  /// Handles unknown species by providing localized descriptions.
  ///
  /// Parameters:
  ///   - localizations: Used for localized strings and error messages
  ///
  /// Updates:
  ///   - _state: Updates to loading/success/error states
  ///   - _result: Contains classification results on success
  ///   - _errorMessage: Contains error details if classification fails
  Future<void> classifyImage(AppLocalizations localizations) async {
    if (_imageFile == null) {
      _errorMessage = localizations.errorNoImageSelected;
      notifyListeners();
      return;
    }
    try {
      _state = ClassificationState.loading;
      _errorMessage = null;
      notifyListeners();

      // 1. Get the enriched (or marked) result from the repository
      final resultFromRepo = await _repository.classifyImage(
        _imageFile!,
        localizations.localeName,
      );

      // 2. Check for the "unknown species" marker
      if (resultFromRepo.species.id == '0') {
        // If it's the unknown species, create a NEW, LOCALIZED species object
        final localizedUnknownSpecies = MosquitoSpecies(
          id: resultFromRepo.species.id,
          name: resultFromRepo.species.name,
          commonName: localizations.classificationServiceUnknownSpeciesCommonName,
          description: localizations.classificationServiceUnknownSpeciesDescription,
          habitat: localizations.classificationServiceUnknownSpeciesHabitat,
          distribution: localizations.classificationServiceUnknownSpeciesDistribution,
          imageUrl: resultFromRepo.species.imageUrl, // Keep the placeholder image
          diseases: [], // Should be empty
        );

        // 3. Update the final result with our new localized object
        _result = ClassificationResult(
          species: localizedUnknownSpecies, // Use the localized version
          confidence: resultFromRepo.confidence,
          inferenceTime: resultFromRepo.inferenceTime,
          relatedDiseases: resultFromRepo.relatedDiseases,
          imageFile: resultFromRepo.imageFile,
        );

      } else {
        // If the species was found, the result from the repo is already perfect
        _result = resultFromRepo;
      }

      _state = ClassificationState.success;
      notifyListeners();

    } catch (e) {
      _state = ClassificationState.error;
      _errorMessage = localizations.errorClassificationFailed(e.toString());
      notifyListeners();
    }
  }

  /// Fetches a prediction from the web-based classification service.
  ///
  /// This is typically used as a fallback when local classification
  /// results in low confidence or unknown species.
  ///
  /// Parameters:
  ///   - localizations: Used for localized error messages
  ///
  /// Updates:
  ///   - _isFetchingWebPrediction: Tracks the web request state
  ///   - _webPredictionResult: Contains the web prediction results
  ///   - _errorMessage: Contains error details if the request fails
  Future<void> fetchWebPrediction(AppLocalizations localizations) async {
    if (_imageFile == null) return;

    _isFetchingWebPrediction = true;
    _webPredictionResult = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getWebPrediction(_imageFile!);

    _webPredictionResult = result;
    } catch (e) {
      print("!!! ERROR fetching web prediction: $e");
      _errorMessage = localizations.errorFailedWebPrediction; // Add this to your ARB files
    } finally {
      _isFetchingWebPrediction = false;
      notifyListeners();
    }
  }


  /// Submits an observation to the server with classification results.
  ///
  /// Handles both local-only and web+local prediction submissions.
  ///
  /// Parameters:
  ///   - localResult: The classification result from the local model
  ///   - webPrediction: Optional web prediction result (for hybrid submissions)
  ///   - latitude: Observation location latitude
  ///   - longitude: Observation location longitude
  ///   - notes: User-provided notes about the observation
  ///   - localizations: Used for localized error messages
  ///
  /// Returns:
  ///   - Observation: The created observation if successful
  ///   - null: If submission fails
  ///
  /// Updates:
  ///   - _state: Updates to submitting/submitted/error states
  ///   - _submissionResult: Contains the created observation on success
  ///   - _errorMessage: Contains error details if submission fails
  Future<Observation?> submitObservation({
    required ClassificationResult localResult,
    required WebPredictionResult? webPrediction,
    required double latitude,
    required double longitude,
    required String notes,
    required AppLocalizations localizations,
  }) async {
    _state = ClassificationState.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final String userId = await _userService.getUserId();
      final Map<String, dynamic> finalPayload;

      if (webPrediction == null) {
        print("Submitting observation with LOCAL prediction only.");
        finalPayload = {
          "species_scientific_name": localResult.species.name,
          "count": 1,
          "location": {"lat": latitude, "lng": longitude},
          "observed_at": DateTime.now().toUtc().toIso8601String(),
          "notes": notes.trim().isEmpty ? null : notes.trim(),
          "user_id": userId,
          "image_filename": localResult.imageFile.path.split('/').last,
          "model_id": modelId, // Uses the modelId defined at the top of the class
          "confidence": localResult.confidence,
          "data_source": "culicidaelab_mobile",
          "metadata": {
            "submission_type": "local_only",
            "local_prediction": {
              "scientific_name": localResult.species.name,
              "confidence": localResult.confidence,
              "inference_time_ms": localResult.inferenceTime,
            }
          }
        };
      } else {
        print("Submitting observation with WEB prediction.");
        finalPayload = {
          "species_scientific_name": webPrediction.scientificName,
          "count": 1,
          "location": {"lat": latitude, "lng": longitude},
          "observed_at": DateTime.now().toUtc().toIso8601String(),
          "notes": notes.trim().isEmpty ? null : notes.trim(),
          "user_id": userId,
          "image_filename": localResult.imageFile.path.split('/').last,
          "model_id": webPrediction.modelId, // Use the web model's ID
          "confidence": webPrediction.confidence,
          "data_source": "culicidaelab_mobile",
          "metadata": {
            "submission_type": "web_and_local",
            "web_prediction": {
              "id": webPrediction.id,
              "probabilities": webPrediction.probabilities,
            },
            "local_prediction": {
              "scientific_name": localResult.species.name,
              "confidence": localResult.confidence,
              "inference_time_ms": localResult.inferenceTime,
            }
          }
        };
      }

      final submission = await _repository.submitObservation(finalPayload: finalPayload);

      _submissionResult = submission;
      _state = ClassificationState.submitted;
      notifyListeners();
      return submission;

    } catch (e) {
      print("!!! ERROR submitting observation: $e");
      _state = ClassificationState.error;
      _errorMessage = localizations.errorSubmissionFailed(e.toString());
      notifyListeners();
      return null;
    }
  }

  /// Determines if the disease risk button should be shown.
  ///
  /// Returns:
  ///   - true: If there are related diseases for the current classification
  ///   - false: Otherwise
  bool get shouldShowDiseaseRiskButton {
    return _result != null && _result!.relatedDiseases.isNotEmpty;
  }

  /// Resets the view model to its initial state.
  ///
  /// Clears all classification results, selected image, and error messages.
  /// Notifies listeners after resetting the state.
  void reset() {
    _state = ClassificationState.initial;
    _imageFile = null;
    _result = null;
    _errorMessage = null;
    _submissionResult = null;
    _webPredictionResult = null;
    _isFetchingWebPrediction = false;
    notifyListeners();
  }

  // --- SECTION 6: PRIVATE/TESTING METHODS (Keep these at the bottom) ---
  /// Updates the current state of the view model.
  ///
  /// This method is visible for testing purposes only.
  ///
  /// Parameters:
  ///   - state: The new state to set
  @visibleForTesting
  void setState(ClassificationState state) {
    _state = state;
    notifyListeners();
  }

  /// Sets the current image file and resets related state if needed.
  ///
  /// This method is visible for testing purposes only.
  ///
  /// Parameters:
  ///   - file: The image file to set, or null to clear
  @visibleForTesting
  void setImageFile(File? file) {
    _imageFile = file;
    if (file != null) {
      _result = null;
    }
    notifyListeners();
  }

  /// Sets the classification result.
  ///
  /// This method is visible for testing purposes only.
  ///
  /// Parameters:
  ///   - result: The classification result to set, or null to clear
  @visibleForTesting
  void setResult(ClassificationResult? result) {
    _result = result;
    notifyListeners();
  }

  /// Sets an error message to be displayed to the user.
  ///
  /// This method is visible for testing purposes only.
  ///
  /// Parameters:
  ///   - message: The error message to set, or null to clear
  @visibleForTesting
  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}