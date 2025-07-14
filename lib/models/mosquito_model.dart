import 'dart:io';
import '../models/disease_model.dart';

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