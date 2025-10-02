import 'dart:convert';

/// Represents a geographical location with latitude and longitude coordinates.
///
/// This model is used to store precise location data for mosquito observations,
/// supporting both the submission of new observations and the retrieval of
/// existing observation data from external sources.
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

/// Represents a mosquito observation record with comprehensive metadata.
///
/// This model corresponds to the Pydantic 'Observation' model.
/// It contains detailed information about a mosquito
/// including species identification, location, timestamp, and various
/// metadata fields for tracking data quality and provenance.
///
/// The observation data supports both user-submitted sightings and data imported
/// from external sources, providing a unified structure for mosquito surveillance
/// and research applications.
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