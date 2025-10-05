import 'dart:io';
import '../models/disease_model.dart';

/// Represents a species of mosquito with detailed biological and ecological information.
///
/// This model contains comprehensive data about a mosquito species including its
/// scientific classification, habitat preferences, geographical distribution, and
/// the diseases it can transmit. It's used for displaying species information
/// and providing context during mosquito identification.
///
/// ## Usage Example
///
/// ```dart
/// final aedesAegypti = MosquitoSpecies(
///   id: 'aedes_aegypti',
///   name: 'Aedes aegypti',
///   commonName: 'Yellow Fever Mosquito',
///   description: 'A small, dark mosquito with white markings...',
///   habitat: 'Urban areas, containers with standing water',
///   distribution: 'Tropical and subtropical regions worldwide',
///   imageUrl: 'assets/images/species/aedes_aegypti.jpg',
///   diseases: ['dengue', 'zika', 'yellow_fever', 'chikungunya'],
/// );
/// ```
///
/// ## Data Sources
///
/// Species data is typically loaded from:
/// - Local JSON assets (`assets/database/database_data.json`)
/// - Remote CulicidaeLab server API
/// - Scientific literature and taxonomic databases
///
/// See also:
/// - [Disease] for disease information associated with species
/// - [ClassificationResult] for AI-powered species identification results
class MosquitoSpecies {
  /// Unique identifier for the mosquito species.
  ///
  /// This ID is used internally for database operations, API calls,
  /// and cross-referencing with other data models. It should be
  /// consistent across all data sources and follow snake_case convention.
  ///
  /// Example: `'aedes_aegypti'`, `'anopheles_gambiae'`
  final String id;

  /// Scientific name of the mosquito species.
  ///
  /// The binomial nomenclature following standard taxonomic conventions.
  /// This is the authoritative name used in scientific literature and
  /// classification systems.
  ///
  /// Example: `'Aedes aegypti'`, `'Anopheles gambiae'`
  final String name;

  /// Common name(s) of the mosquito species.
  ///
  /// Human-readable name(s) that are commonly used to refer to this species.
  /// May include multiple common names separated by commas.
  ///
  /// Example: `'Yellow Fever Mosquito'`, `'Asian Tiger Mosquito'`
  final String commonName;

  /// Detailed description of the mosquito species.
  ///
  /// Comprehensive text describing the species' physical characteristics,
  /// behavior, life cycle, and other relevant biological information.
  /// This text is displayed in the species detail view.
  final String description;

  /// Habitat preferences and breeding sites.
  ///
  /// Description of where this species typically lives and breeds,
  /// including preferred environmental conditions and breeding sites.
  ///
  /// Example: `'Urban areas, artificial containers, tree holes'`
  final String habitat;

  /// Geographical distribution of the species.
  ///
  /// Description of the regions and countries where this species
  /// is naturally found or has been introduced.
  ///
  /// Example: `'Tropical and subtropical regions worldwide'`
  final String distribution;

  /// URL or path to the species image.
  ///
  /// Reference to the primary image used to represent this species
  /// in the application. Can be a local asset path or remote URL.
  ///
  /// Example: `'assets/images/species/aedes_aegypti.jpg'`
  final String imageUrl;

  /// List of disease IDs that this species can transmit.
  ///
  /// Contains identifiers for diseases that this mosquito species
  /// is known to vector. These IDs correspond to [Disease] model instances.
  ///
  /// Example: `['dengue', 'zika', 'yellow_fever', 'chikungunya']`
  final List<String> diseases;

  /// Creates a new [MosquitoSpecies] instance.
  ///
  /// All parameters are required to ensure complete species information
  /// is available for display and classification purposes.
  ///
  /// Throws [ArgumentError] if any required field is empty or null.
  MosquitoSpecies({
    required this.id,
    required this.name,
    required this.commonName,
    required this.description,
    required this.habitat,
    required this.distribution,
    required this.imageUrl,
    required this.diseases,
  }) : assert(id.isNotEmpty, 'Species ID cannot be empty'),
       assert(name.isNotEmpty, 'Species name cannot be empty'),
       assert(commonName.isNotEmpty, 'Common name cannot be empty');

  /// Creates a [MosquitoSpecies] from a JSON map.
  ///
  /// Used for deserializing species data from JSON sources such as
  /// local asset files or API responses.
  ///
  /// Example:
  /// ```dart
  /// final json = {
  ///   'id': 'aedes_aegypti',
  ///   'name': 'Aedes aegypti',
  ///   'common_name': 'Yellow Fever Mosquito',
  ///   // ... other fields
  /// };
  /// final species = MosquitoSpecies.fromJson(json);
  /// ```
  factory MosquitoSpecies.fromJson(Map<String, dynamic> json) {
    return MosquitoSpecies(
      id: json['id'] as String,
      name: json['name'] as String,
      commonName: json['common_name'] as String,
      description: json['description'] as String,
      habitat: json['habitat'] as String,
      distribution: json['distribution'] as String,
      imageUrl: json['image_url'] as String,
      diseases: List<String>.from(json['diseases'] as List),
    );
  }

  /// Converts this [MosquitoSpecies] to a JSON map.
  ///
  /// Used for serializing species data for storage or API transmission.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'common_name': commonName,
      'description': description,
      'habitat': habitat,
      'distribution': distribution,
      'image_url': imageUrl,
      'diseases': diseases,
    };
  }

  /// Returns a string representation of this species.
  ///
  /// Primarily used for debugging and logging purposes.
  @override
  String toString() {
    return 'MosquitoSpecies(id: $id, name: $name, commonName: $commonName)';
  }

  /// Checks if two [MosquitoSpecies] instances are equal.
  ///
  /// Two species are considered equal if they have the same ID.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MosquitoSpecies && other.id == id;
  }

  /// Returns the hash code for this species.
  ///
  /// Based on the species ID for consistent hashing.
  @override
  int get hashCode => id.hashCode;
}

/// Represents the result of a mosquito species classification operation.
///
/// This model contains the identified species, confidence score, inference time,
/// related diseases, and the original image file used for classification.
/// It's used to present classification results to users with all relevant
/// contextual information.
///
/// ## Usage Example
///
/// ```dart
/// final result = ClassificationResult(
///   species: aedesAegypti,
///   confidence: 0.87,
///   inferenceTime: 1250,
///   relatedDiseases: [dengue, zika, yellowFever],
///   imageFile: File('/path/to/mosquito_image.jpg'),
/// );
///
/// print('Identified: ${result.species.name}');
/// print('Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%');
/// print('Processing time: ${result.inferenceTime}ms');
/// ```
///
/// ## Classification Workflow
///
/// 1. User captures or selects an image
/// 2. Image is processed by PyTorch Lite model
/// 3. Model returns species prediction with confidence
/// 4. Related diseases are fetched based on species
/// 5. [ClassificationResult] is created and displayed
///
/// See also:
/// - [ClassificationService] for the classification logic
/// - [PyTorchLiteModel] for the AI model implementation
/// - [WebPredictionResult] for server-based classification results
class ClassificationResult {
  /// The identified mosquito species.
  ///
  /// Contains complete species information including scientific name,
  /// common name, habitat, distribution, and associated diseases.
  final MosquitoSpecies species;

  /// Confidence score of the classification (0.0 to 1.0).
  ///
  /// Represents the model's confidence in the species identification.
  /// Higher values indicate more confident predictions.
  ///
  /// - 0.9-1.0: Very high confidence
  /// - 0.7-0.9: High confidence  
  /// - 0.5-0.7: Moderate confidence
  /// - 0.0-0.5: Low confidence
  final double confidence;

  /// Time taken for inference in milliseconds.
  ///
  /// Measures the duration of the classification process from
  /// image preprocessing to final prediction. Used for performance
  /// monitoring and user feedback.
  final int inferenceTime;

  /// List of diseases that can be transmitted by the identified species.
  ///
  /// Contains complete [Disease] objects with symptoms, treatment,
  /// and prevention information. This provides immediate context
  /// about health risks associated with the identified species.
  final List<Disease> relatedDiseases;

  /// The original image file used for classification.
  ///
  /// Reference to the image that was analyzed. Used for displaying
  /// the original image alongside results and for potential
  /// re-analysis or sharing.
  final File imageFile;

  /// Creates a new [ClassificationResult] instance.
  ///
  /// All parameters are required to provide complete classification
  /// information to the user.
  ///
  /// Throws [ArgumentError] if confidence is not between 0.0 and 1.0,
  /// or if inference time is negative.
  ClassificationResult({
    required this.species,
    required this.confidence,
    required this.inferenceTime,
    required this.relatedDiseases,
    required this.imageFile,
  }) : assert(confidence >= 0.0 && confidence <= 1.0, 
              'Confidence must be between 0.0 and 1.0'),
       assert(inferenceTime >= 0, 
              'Inference time cannot be negative');

  /// Gets the confidence as a percentage string.
  ///
  /// Returns a formatted string representation of the confidence
  /// score as a percentage with one decimal place.
  ///
  /// Example: `'87.3%'` for confidence of 0.873
  String get confidencePercentage => 
      '${(confidence * 100).toStringAsFixed(1)}%';

  /// Checks if the classification result has high confidence.
  ///
  /// Returns `true` if confidence is 0.7 or higher, indicating
  /// a reliable identification that can be presented to users
  /// with confidence.
  bool get isHighConfidence => confidence >= 0.7;

  /// Gets a human-readable confidence level description.
  ///
  /// Returns a descriptive string based on the confidence score:
  /// - 'Very High' for 0.9+
  /// - 'High' for 0.7-0.9
  /// - 'Moderate' for 0.5-0.7
  /// - 'Low' for below 0.5
  String get confidenceLevel {
    if (confidence >= 0.9) return 'Very High';
    if (confidence >= 0.7) return 'High';
    if (confidence >= 0.5) return 'Moderate';
    return 'Low';
  }

  /// Returns a string representation of this classification result.
  ///
  /// Primarily used for debugging and logging purposes.
  @override
  String toString() {
    return 'ClassificationResult('
           'species: ${species.name}, '
           'confidence: $confidencePercentage, '
           'inferenceTime: ${inferenceTime}ms)';
  }
}