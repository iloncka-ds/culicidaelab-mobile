import 'dart:convert';

/// Represents the result of a web-based mosquito species prediction.
///
/// This model contains prediction results from remote classification services,
/// including species identification, confidence scores, probability distributions
/// across all possible species, and associated metadata. It's used when
/// classification is performed on external servers rather than locally on the device.
///
/// The prediction result includes comprehensive probability data for transparency
/// and supports both single-prediction and multi-class classification scenarios.
class WebPredictionResult {
  final String id;
  final String scientificName;
  final Map<String, double> probabilities;
  final String modelId;
  final double confidence;
  final String? imageUrlSpecies;

  WebPredictionResult({
    required this.id,
    required this.scientificName,
    required this.probabilities,
    required this.modelId,
    required this.confidence,
    this.imageUrlSpecies,
  });

  factory WebPredictionResult.fromJson(Map<String, dynamic> json) {
    return WebPredictionResult(
      id: json['id'] as String,
      scientificName: json['scientific_name'] as String,
      // Safely cast the map values to double
      probabilities: (json['probabilities'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      modelId: json['model_id'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      imageUrlSpecies: json['image_url_species'] as String?,
    );
  }

  static WebPredictionResult fromJsonString(String str) =>
      WebPredictionResult.fromJson(json.decode(str));
}