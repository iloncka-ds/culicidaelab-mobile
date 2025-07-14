import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../models/mosquito_model.dart';
import '../models/disease_model.dart';
import 'pytorch_lite_model.dart';
import 'database_service.dart';

// For this service, direct localization of thrown Exception messages or default object values
// is challenging without BuildContext or a similar mechanism to access AppLocalizations.
// The ARB file contains keys for these (e.g., classificationServiceErrorModelNotLoaded,
// classificationServiceUnknownSpeciesCommonName).
// The current implementation relies on the calling layer (ViewModel/UI) to handle
// localization of errors or default/unknown data.
// For example, an Exception might carry a key, or the UI might display a generic
// localized message for a specific type of exception.
// The default MosquitoSpecies created here uses English strings; the ViewModel or UI
// should ideally recognize these as placeholders (e.g., based on ID '0' or specific
// placeholder text) and substitute localized text.

class ClassificationService {
  ClassificationModel? _model;
  final stopwatch = Stopwatch();
  final DatabaseService _databaseService = DatabaseService();

  Future<void> loadModel() async {

    String pathImageModel = "assets/models/mosquito_classifier.pt";
    try {
      _model = await PytorchLite.loadClassificationModel(
        pathImageModel, 224, 224,
        labelPath: "assets/labels/mosquito_species.txt"
      );
    } on PlatformException {
      throw Exception("Model loading failed - only supported for Android/iOS");
    }
  }

  Future<ClassificationResult> classifyImage(File imageFile, String languageCode) async {
    if (_model == null) {
      throw Exception("Model not loaded");
    }

    stopwatch.start();

    final Uint8List imageBytes = await imageFile.readAsBytes();
    final result = await _model!.getImagePredictionResult(imageBytes);

    stopwatch.stop();
    final inferenceTime = stopwatch.elapsedMilliseconds;
    stopwatch.reset();

    final speciesName = result['label']; // This is the scientific name, e.g., "Aedes aegypti"
    final confidence = result['probability'] * 100;

    final allSpecies = await _databaseService.getAllMosquitoSpecies(languageCode);

    final MosquitoSpecies species = allSpecies.firstWhere(
      (s) => s.name.toLowerCase() == speciesName.toLowerCase(),
      orElse: () {
        // Fallback for when the model predicts a species not in our DB
        return MosquitoSpecies(
          id: '0',
          name: speciesName,
          commonName: 'Unknown Species',
          description: 'No detailed information available for this species.',
          habitat: 'Unknown',
          distribution: 'Unknown',
          imageUrl: 'assets/images/unknown_mosquito.jpg',
          diseases: [],
        );
      },
    );

    final List<Disease> relatedDiseases = await _databaseService.getDiseasesByVector(species.name, languageCode);

    return ClassificationResult(
      species: species,
      confidence: confidence,
      inferenceTime: inferenceTime,
      relatedDiseases: relatedDiseases,
      imageFile: imageFile,
    );
  }

  Future<List<MosquitoSpecies>> getAllMosquitoSpecies(String languageCode) async {
    return await _databaseService.getAllMosquitoSpecies(languageCode);
  }

  Future<List<Disease>> getAllDiseases(String languageCode) async {
    return await _databaseService.getAllDiseases(languageCode);
  }

  Future<MosquitoSpecies?> getMosquitoSpeciesById(String id, String languageCode) async {
    return await _databaseService.getMosquitoSpeciesById(id, languageCode);
  }

  Future<Disease?> getDiseaseById(String id, String languageCode) async {
    return await _databaseService.getDiseaseById(id, languageCode);
  }

  Future<List<Disease>> getDiseasesByVector(String speciesName, String languageCode) async {
    return await _databaseService.getDiseasesByVector(speciesName, languageCode);
  }
}