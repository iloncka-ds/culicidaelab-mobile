import 'dart:convert';

/// Represents a geographical location with latitude and longitude coordinates.
///
/// This model is used to store precise location data for mosquito observations,
/// supporting both the submission of new observations and the retrieval of
/// existing observation data from external sources.
///
/// ## Usage Example
///
/// ```dart
/// // Create a location for New York City
/// final location = Location(lat: 40.7128, lng: -74.0060);
///
/// // Serialize to JSON for API transmission
/// final json = location.toJson();
/// // {'lat': 40.7128, 'lng': -74.0060}
///
/// // Deserialize from JSON
/// final locationFromJson = Location.fromJson(json);
/// ```
///
/// ## Coordinate System
///
/// Uses the WGS84 coordinate system (EPSG:4326) which is standard for GPS
/// and web mapping applications. Coordinates are in decimal degrees.
///
/// ## Validation
///
/// - Latitude must be between -90.0 and 90.0 degrees
/// - Longitude must be between -180.0 and 180.0 degrees
///
/// See also:
/// - [Observation] which uses this model for location data
/// - Flutter's `geolocator` package for obtaining device location
class Location {
  /// Latitude coordinate in decimal degrees.
  ///
  /// Valid range: -90.0 to 90.0
  /// - Positive values represent North latitude
  /// - Negative values represent South latitude
  /// - 0.0 represents the Equator
  final double lat;

  /// Longitude coordinate in decimal degrees.
  ///
  /// Valid range: -180.0 to 180.0
  /// - Positive values represent East longitude
  /// - Negative values represent West longitude
  /// - 0.0 represents the Prime Meridian
  final double lng;

  /// Creates a new [Location] instance.
  ///
  /// Validates that coordinates are within valid ranges.
  ///
  /// Throws [ArgumentError] if coordinates are outside valid ranges.
  Location({required this.lat, required this.lng})
      : assert(lat >= -90.0 && lat <= 90.0, 
               'Latitude must be between -90.0 and 90.0'),
        assert(lng >= -180.0 && lng <= 180.0, 
               'Longitude must be between -180.0 and 180.0');

  /// Creates a [Location] from a JSON map.
  ///
  /// Expects a map with 'lat' and 'lng' keys containing numeric values.
  ///
  /// Example:
  /// ```dart
  /// final json = {'lat': 40.7128, 'lng': -74.0060};
  /// final location = Location.fromJson(json);
  /// ```
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  /// Converts this [Location] to a JSON map.
  ///
  /// Returns a map suitable for JSON serialization with 'lat' and 'lng' keys.
  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
      };

  /// Calculates the approximate distance to another location in kilometers.
  ///
  /// Uses the Haversine formula to calculate the great-circle distance
  /// between two points on Earth's surface.
  ///
  /// Example:
  /// ```dart
  /// final nyc = Location(lat: 40.7128, lng: -74.0060);
  /// final la = Location(lat: 34.0522, lng: -118.2437);
  /// final distance = nyc.distanceTo(la); // ~3944 km
  /// ```
  double distanceTo(Location other) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers
    
    final double lat1Rad = lat * (3.14159265359 / 180.0);
    final double lat2Rad = other.lat * (3.14159265359 / 180.0);
    final double deltaLatRad = (other.lat - lat) * (3.14159265359 / 180.0);
    final double deltaLngRad = (other.lng - lng) * (3.14159265359 / 180.0);

    final double a = (deltaLatRad / 2).sin() * (deltaLatRad / 2).sin() +
        lat1Rad.cos() * lat2Rad.cos() *
        (deltaLngRad / 2).sin() * (deltaLngRad / 2).sin();
    
    final double c = 2 * (a.sqrt()).asin();
    
    return earthRadius * c;
  }

  /// Returns a string representation of this location.
  ///
  /// Format: "Location(lat: 40.7128, lng: -74.0060)"
  @override
  String toString() {
    return 'Location(lat: $lat, lng: $lng)';
  }

  /// Checks if two [Location] instances are equal.
  ///
  /// Two locations are considered equal if their coordinates
  /// are identical within a small tolerance (1e-6 degrees).
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Location) return false;
    
    const double tolerance = 1e-6;
    return (lat - other.lat).abs() < tolerance &&
           (lng - other.lng).abs() < tolerance;
  }

  /// Returns the hash code for this location.
  @override
  int get hashCode => Object.hash(lat, lng);
}

/// Represents a mosquito observation record with comprehensive metadata.
///
/// This model corresponds to the Pydantic 'Observation' model used in the
/// CulicidaeLab server API. It contains detailed information about a mosquito
/// sighting including species identification, location, timestamp, and various
/// metadata fields for tracking data quality and provenance.
///
/// The observation data supports both user-submitted sightings and data imported
/// from external sources, providing a unified structure for mosquito surveillance
/// and research applications.
///
/// ## Usage Example
///
/// ```dart
/// // Create a new observation from user input
/// final observation = Observation(
///   id: 'obs_123456',
///   speciesScientificName: 'Aedes aegypti',
///   count: 1,
///   location: Location(lat: 40.7128, lng: -74.0060),
///   observedAt: DateTime.now(),
///   notes: 'Found near standing water in urban area',
///   userId: 'user_789',
///   locationAccuracyM: 10,
///   dataSource: 'mobile_app',
///   imageFilename: 'mosquito_20240115_143022.jpg',
///   modelId: 'culico-net-cls-v1',
///   confidence: 0.87,
/// );
///
/// // Serialize for API transmission
/// final json = observation.toJson();
/// ```
///
/// ## Data Sources
///
/// Observations can originate from various sources:
/// - `'mobile_app'` - User submissions via CulicidaeLab mobile app
/// - `'web_app'` - Submissions via web interface
/// - `'citizen_science'` - Imported from citizen science platforms
/// - `'research'` - Professional research data
/// - `'surveillance'` - Public health surveillance programs
///
/// ## API Integration
///
/// This model is designed to be compatible with the CulicidaeLab server API
/// for submitting observations and retrieving surveillance data.
///
/// See also:
/// - [Location] for geographical coordinate handling
/// - [WebPredictionResult] for AI-powered species identification
/// - CulicidaeLab server API documentation
class Observation {
  /// Unique identifier for the observation.
  ///
  /// Generated by the server upon submission or provided by external
  /// data sources. Used for tracking, updates, and cross-referencing.
  ///
  /// Example: `'obs_123456'`, `'uuid-4-format-string'`
  final String id;

  /// Scientific name of the observed mosquito species.
  ///
  /// The binomial nomenclature following standard taxonomic conventions.
  /// This should match the species names used in [MosquitoSpecies] models.
  ///
  /// Example: `'Aedes aegypti'`, `'Anopheles gambiae'`
  final String speciesScientificName;

  /// Number of individual mosquitoes observed.
  ///
  /// Represents the count of specimens in this observation.
  /// Typically 1 for individual sightings, but can be higher
  /// for swarm observations or research collections.
  final int count;

  /// Geographic location where the observation was made.
  ///
  /// Contains precise latitude and longitude coordinates
  /// using the WGS84 coordinate system.
  final Location location;

  /// Date and time when the observation was made.
  ///
  /// Stored in UTC format for consistency across time zones.
  /// Represents the actual observation time, not submission time.
  final DateTime observedAt;

  /// Optional user notes about the observation.
  ///
  /// Free-text field for additional context, environmental conditions,
  /// behavior observations, or other relevant details provided by the observer.
  ///
  /// Example: `'Found near standing water in urban area'`
  final String? notes;

  /// Identifier of the user who made the observation.
  ///
  /// Links the observation to a specific user account for
  /// tracking contributions and data quality assessment.
  /// May be null for anonymous submissions.
  final String? userId;

  /// GPS accuracy of the location measurement in meters.
  ///
  /// Indicates the precision of the location data. Lower values
  /// represent more accurate positioning. Useful for data quality
  /// assessment and spatial analysis.
  ///
  /// Example: `5` (5-meter accuracy), `50` (50-meter accuracy)
  final int? locationAccuracyM;

  /// Source system or platform that generated this observation.
  ///
  /// Identifies the origin of the data for provenance tracking
  /// and quality assessment. Helps distinguish between different
  /// data collection methods and sources.
  ///
  /// Example: `'mobile_app'`, `'citizen_science'`, `'research'`
  final String? dataSource;

  /// Filename of the associated image, if any.
  ///
  /// Reference to the image file used for species identification
  /// or documentation. The actual image is typically stored
  /// separately in a file storage system.
  ///
  /// Example: `'mosquito_20240115_143022.jpg'`
  final String? imageFilename;

  /// Identifier of the AI model used for species identification.
  ///
  /// References the specific version of the classification model
  /// that was used to identify the species. Important for
  /// tracking model performance and data provenance.
  ///
  /// Example: `'culico-net-cls-v1'`, `'pytorch-mobile-v2'`
  final String? modelId;

  /// Confidence score of the species identification (0.0 to 1.0).
  ///
  /// Represents the AI model's confidence in the species identification.
  /// Only present for AI-assisted identifications. Higher values
  /// indicate more confident predictions.
  final double? confidence;

  /// Additional metadata as key-value pairs.
  ///
  /// Flexible field for storing additional structured data
  /// that doesn't fit in the standard fields. Can include
  /// environmental data, device information, or research-specific fields.
  ///
  /// Example: `{'temperature': 25.5, 'humidity': 78, 'device': 'iPhone12'}`
  final Map<String, dynamic>? metadata;

  /// Creates a new [Observation] instance.
  ///
  /// Required fields ensure minimum data quality for surveillance
  /// and research purposes.
  ///
  /// Throws [ArgumentError] if required fields are invalid.
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
  }) : assert(id.isNotEmpty, 'Observation ID cannot be empty'),
       assert(speciesScientificName.isNotEmpty, 'Species name cannot be empty'),
       assert(count > 0, 'Count must be positive'),
       assert(confidence == null || (confidence >= 0.0 && confidence <= 1.0),
              'Confidence must be between 0.0 and 1.0'),
       assert(locationAccuracyM == null || locationAccuracyM >= 0,
              'Location accuracy cannot be negative');

  /// Creates an [Observation] from a JSON map.
  ///
  /// Used for deserializing observation data from API responses
  /// or local storage. Handles the snake_case to camelCase conversion
  /// for field names.
  ///
  /// Example:
  /// ```dart
  /// final json = {
  ///   'id': 'obs_123',
  ///   'species_scientific_name': 'Aedes aegypti',
  ///   'count': 1,
  ///   'location': {'lat': 40.7128, 'lng': -74.0060},
  ///   'observed_at': '2024-01-15T14:30:22Z',
  ///   // ... other fields
  /// };
  /// final observation = Observation.fromJson(json);
  /// ```
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

  /// Creates an [Observation] from a JSON string.
  ///
  /// Convenience method for parsing JSON strings directly.
  ///
  /// Example:
  /// ```dart
  /// final jsonString = '{"id": "obs_123", "species_scientific_name": "Aedes aegypti", ...}';
  /// final observation = Observation.fromJsonString(jsonString);
  /// ```
  static Observation fromJsonString(String str) =>
      Observation.fromJson(json.decode(str));

  /// Converts this [Observation] to a JSON map.
  ///
  /// Used for serializing observation data for API transmission
  /// or local storage. Converts camelCase field names to snake_case
  /// to match API expectations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'species_scientific_name': speciesScientificName,
      'count': count,
      'location': location.toJson(),
      'observed_at': observedAt.toIso8601String(),
      if (notes != null) 'notes': notes,
      if (userId != null) 'user_id': userId,
      if (locationAccuracyM != null) 'location_accuracy_m': locationAccuracyM,
      if (dataSource != null) 'data_source': dataSource,
      if (imageFilename != null) 'image_filename': imageFilename,
      if (modelId != null) 'model_id': modelId,
      if (confidence != null) 'confidence': confidence,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Checks if this observation has high-quality data.
  ///
  /// Returns `true` if the observation meets quality criteria:
  /// - Has location accuracy better than 100 meters (if provided)
  /// - Has AI confidence above 0.7 (if AI-identified)
  /// - Has a data source specified
  bool get isHighQuality {
    if (locationAccuracyM != null && locationAccuracyM! > 100) return false;
    if (confidence != null && confidence! < 0.7) return false;
    if (dataSource == null) return false;
    return true;
  }

  /// Checks if this observation was AI-identified.
  ///
  /// Returns `true` if the observation has both a model ID and confidence score,
  /// indicating it was identified using an AI classification model.
  bool get isAiIdentified => modelId != null && confidence != null;

  /// Gets the confidence as a percentage string.
  ///
  /// Returns a formatted string representation of the confidence
  /// score as a percentage, or null if no confidence is available.
  String? get confidencePercentage => confidence != null
      ? '${(confidence! * 100).toStringAsFixed(1)}%'
      : null;

  /// Gets a human-readable description of location accuracy.
  ///
  /// Returns a descriptive string based on the location accuracy:
  /// - 'Very High' for < 5m
  /// - 'High' for 5-20m  
  /// - 'Moderate' for 20-100m
  /// - 'Low' for > 100m
  /// - 'Unknown' if not specified
  String get locationAccuracyDescription {
    if (locationAccuracyM == null) return 'Unknown';
    if (locationAccuracyM! < 5) return 'Very High';
    if (locationAccuracyM! < 20) return 'High';
    if (locationAccuracyM! < 100) return 'Moderate';
    return 'Low';
  }

  /// Returns a string representation of this observation.
  ///
  /// Primarily used for debugging and logging purposes.
  @override
  String toString() {
    return 'Observation('
           'id: $id, '
           'species: $speciesScientificName, '
           'count: $count, '
           'location: $location, '
           'observedAt: $observedAt)';
  }

  /// Checks if two [Observation] instances are equal.
  ///
  /// Two observations are considered equal if they have the same ID.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Observation && other.id == id;
  }

  /// Returns the hash code for this observation.
  ///
  /// Based on the observation ID for consistent hashing.
  @override
  int get hashCode => id.hashCode;
}