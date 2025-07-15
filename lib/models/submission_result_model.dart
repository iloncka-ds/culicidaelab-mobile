import 'dart:convert';

class SubmissionResult {
  final String observationId;
  final String speciesId;
  final String scientificName;
  final double confidence;
  final String modelId;
  final DateTime observedAt;
  final double latitude;
  final double longitude;
  final String? notes;

  SubmissionResult({
    required this.observationId,
    required this.speciesId,
    required this.scientificName,
    required this.confidence,
    required this.modelId,
    required this.observedAt,
    required this.latitude,
    required this.longitude,
    this.notes,
  });

  factory SubmissionResult.fromJson(Map<String, dynamic> json) {
    // This assumes the API returns a structure that includes the created observation
    // Adjust the keys based on your actual API response
    final properties = json['properties'] ?? {};
    final geometry = json['geometry'] ?? {};
    final coordinates = geometry['coordinates'] ?? [0.0, 0.0];
    final metadata = properties['metadata'] ?? {};

    return SubmissionResult(
      observationId: json['id'] ?? 'N/A',
      speciesId: properties['species_id'] ?? 'N/A',
      scientificName: metadata['species_scientific_name'] ?? 'N/A',
      confidence: metadata['confidence']?.toDouble() ?? 0.0,
      modelId: metadata['model_id'] ?? 'N/A',
      observedAt: DateTime.tryParse(properties['observed_at'] ?? '') ?? DateTime.now(),
      latitude: coordinates[1]?.toDouble() ?? 0.0,
      longitude: coordinates[0]?.toDouble() ?? 0.0,
      notes: properties['notes'],
    );
  }
}