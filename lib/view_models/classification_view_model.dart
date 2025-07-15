import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/mosquito_model.dart';
import '../repositories/classification_repository.dart';

import 'package:culicidaelab/l10n/app_localizations.dart';
import '../models/submission_result_model.dart';

enum ClassificationState { initial, loading, success, error, submitting, submitted }

class ClassificationViewModel extends ChangeNotifier {
  final ClassificationRepository _repository;

  @visibleForTesting
  ClassificationState _state = ClassificationState.initial;
  @visibleForTesting
  File? _imageFile;
  @visibleForTesting
  ClassificationResult? _result;
  @visibleForTesting
  String? _errorMessage; // This will be a pre-localized string set by methods below

  ClassificationViewModel({ClassificationRepository? repository})
    : _repository = repository ?? ClassificationRepository();

  ClassificationState get state => _state;
  File? get imageFile => _imageFile;
  bool get hasImage => _imageFile != null;
  ClassificationResult? get result => _result;
  String? get errorMessage => _errorMessage;
  bool get isProcessing => _state == ClassificationState.loading;
  bool get isSubmitting => _state == ClassificationState.submitting;
  @visibleForTesting
  void setState(ClassificationState state) {
    _state = state;
    notifyListeners();
  }

  @visibleForTesting
  void setImageFile(File? file) {
    _imageFile = file;
    if (file != null) {
      _result = null;
    }
    notifyListeners();
  }

  @visibleForTesting
  void setResult(ClassificationResult? result) {
    _result = result;
    notifyListeners();
  }

  @visibleForTesting
  void setErrorMessage(String? message) {
    // Assumes message is already localized
    _errorMessage = message;
    notifyListeners();
  }

  SubmissionResult? _submissionResult;
  SubmissionResult? get submissionResult => _submissionResult;

  Future<SubmissionResult?> submitObservation({
    required ClassificationResult result,
    required double latitude,
    required double longitude,
    required String notes,
    required AppLocalizations localizations,
  }) async {
    _state = ClassificationState.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final submission = await _repository.submitObservation(
        result: result,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      );
      _submissionResult = submission;
      _state = ClassificationState.submitted;
      notifyListeners();
      return submission;
    } catch (e) {
      _state = ClassificationState.error;
      _errorMessage = localizations.errorSubmissionFailed(e.toString());
      notifyListeners();
      return null;
    }
  }

  Future<void> initModel(AppLocalizations localizations) async {
    try {
      await _repository.loadModel();
    } catch (e) {
      // Check if e.message corresponds to a known key or use a general one
      if (e.toString().contains("Model loading failed")) {
        // Basic check
        _errorMessage =
            localizations.classificationServiceErrorModelLoadingFailed;
      } else {
        _errorMessage = localizations.errorFailedToLoadModel(e.toString());
      }
      notifyListeners();
    }
  }

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

      // Pass the language code to the repository
      final resultFromRepo = await _repository.classifyImage(
        _imageFile!,
        localizations.localeName,
      );

      MosquitoSpecies displaySpecies = resultFromRepo.species;
      if (resultFromRepo.species.id == '0') {
        displaySpecies = MosquitoSpecies(
          id: resultFromRepo.species.id,
          name: resultFromRepo.species.name, // keep original name from model
          commonName:
              localizations.classificationServiceUnknownSpeciesCommonName,
          description:
              localizations.classificationServiceUnknownSpeciesDescription,
          habitat: localizations.classificationServiceUnknownSpeciesHabitat,
          distribution:
              localizations.classificationServiceUnknownSpeciesDistribution,
          imageUrl: resultFromRepo.species.imageUrl,
          diseases: resultFromRepo.species.diseases,
        );
      }
      _result = ClassificationResult(
        species: displaySpecies,
        confidence: resultFromRepo.confidence,
        inferenceTime: resultFromRepo.inferenceTime,
        relatedDiseases: resultFromRepo.relatedDiseases,
        imageFile: resultFromRepo.imageFile,
      );
      _state = ClassificationState.success;
      notifyListeners();
    } catch (e) {
      _state = ClassificationState.error;
      if (e.toString().contains("Model not loaded")) {
        _errorMessage = localizations.classificationServiceErrorModelNotLoaded;
      } else {
        _errorMessage = localizations.errorClassificationFailed(e.toString());
      }
      notifyListeners();
    }
  }

  bool get shouldShowDiseaseRiskButton {
    return _result != null && _result!.relatedDiseases.isNotEmpty;
  }

  void reset() {
    _state = ClassificationState.initial;
    _imageFile = null;
    _result = null;
    _errorMessage = null;
    _submissionResult = null;
    notifyListeners();
  }
}
