import 'dart:io';
import '../models/disease_model.dart';

/// Represents a species of mosquito with detailed biological and ecological information.
///
/// This model contains comprehensive data about a mosquito species including its
/// scientific classification, habitat preferences, geographical distribution, and
/// the diseases it can transmit. It's used for displaying species information
/// and providing context during mosquito identification.
class MosquitoSpecies {
  final String id;
  final String name;
  final String commonName;
  final String description;
  final String habitat;
  final String distribution;
  final String imageUrl;
  final List<String> diseases;

  MosquitoSpecies({
    required this.id,
    required this.name,
    required this.commonName,
    required this.description,
    required this.habitat,
    required this.distribution,
    required this.imageUrl,
    required this.diseases,
  });
}

/// Represents the result of a mosquito species classification operation.
///
/// This model contains the identified species, confidence score, inference time,
/// related diseases, and the original image file used for classification.
/// It's used to present classification results to users with all relevant
/// contextual information.
class ClassificationResult {
  final MosquitoSpecies species;
  final double confidence;
  final int inferenceTime;
  final List<Disease> relatedDiseases;
  final File imageFile;

  ClassificationResult({
    required this.species,
    required this.confidence,
    required this.inferenceTime,
    required this.relatedDiseases,
    required this.imageFile,
  });
}