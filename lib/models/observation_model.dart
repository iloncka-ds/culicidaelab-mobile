import 'dart:convert';

// Corresponds to the Pydantic 'Location' model
class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
  };
}

// Corresponds to the Pydantic 'Observation' model
// This REPLACES the old SubmissionResult model
class Observation {
  final String id; // This was observationId
  final String speciesScientificName; // This was scientificName
  final int count;
  final Location location;
  final DateTime observedAt;
  final String? notes;
  final String? userId;
  final int? locationAccuracyM;
  final String? dataSource;
  final String? imageFilename;
  final String? modelId;
  final double? confidence;
  final Map<String, dynamic>? metadata;

  Observation({
    required this.id,
    required this.speciesScientificName,
    required this.count,
    required this.location,
    required this.observedAt,
    this.notes,
    this.userId,
    this.locationAccuracyM,
    this.dataSource,
    this.imageFilename,
    this.modelId,
    this.confidence,
    this.metadata,
  });

  factory Observation.fromJson(Map<String, dynamic> json) {
    return Observation(
      id: json['id'] as String,
      speciesScientificName: json['species_scientific_name'] as String,
      count: json['count'] as int,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      observedAt: DateTime.parse(json['observed_at'] as String),
      notes: json['notes'] as String?,
      userId: json['user_id'] as String?,
      locationAccuracyM: json['location_accuracy_m'] as int?,
      dataSource: json['data_source'] as String?,
      imageFilename: json['image_filename'] as String?,
      modelId: json['model_id'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  static Observation fromJsonString(String str) =>
      Observation.fromJson(json.decode(str));
}