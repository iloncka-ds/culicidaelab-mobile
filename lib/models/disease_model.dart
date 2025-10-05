/// Represents a disease that can be transmitted by mosquitoes or other vectors.
///
/// This model contains comprehensive information about a specific disease including
/// its symptoms, treatment options, prevention methods, and associated vectors.
/// It's used throughout the application to display disease information to users
/// and provide context for mosquito identification results.
///
/// ## Usage Example
///
/// ```dart
/// final dengue = Disease(
///   id: 'dengue',
///   name: 'Dengue Fever',
///   description: 'A viral infection transmitted by Aedes mosquitoes...',
///   symptoms: 'High fever, severe headache, muscle and joint pain...',
///   treatment: 'Supportive care, pain relief, fluid replacement...',
///   prevention: 'Eliminate standing water, use mosquito repellent...',
///   vectors: ['aedes_aegypti', 'aedes_albopictus'],
///   prevalence: 'Endemic in tropical and subtropical regions',
///   imageUrl: 'assets/images/diseases/dengue.jpg',
/// );
/// ```
///
/// ## Data Integration
///
/// Disease information is integrated with:
/// - [MosquitoSpecies] for vector-disease relationships
/// - [ClassificationResult] to show health risks
/// - External health databases and WHO data
///
/// See also:
/// - [MosquitoSpecies] for vector species information
/// - [ClassificationResult] for disease context in identification
class Disease {
  /// Unique identifier for the disease.
  ///
  /// Used for database operations, API calls, and cross-referencing
  /// with mosquito species data. Should follow snake_case convention
  /// and match WHO or medical database identifiers when possible.
  ///
  /// Example: `'dengue'`, `'zika'`, `'yellow_fever'`
  final String id;

  /// Common name of the disease.
  ///
  /// The widely recognized name used in medical literature and
  /// public health communications. This is displayed to users
  /// as the primary disease identifier.
  ///
  /// Example: `'Dengue Fever'`, `'Zika Virus Disease'`
  final String name;

  /// Detailed description of the disease.
  ///
  /// Comprehensive overview including the causative agent,
  /// transmission mechanism, affected populations, and general
  /// disease characteristics. This provides context for users.
  final String description;

  /// Clinical symptoms and manifestations.
  ///
  /// Detailed description of the signs and symptoms that patients
  /// typically experience. Organized from early symptoms to
  /// severe manifestations when applicable.
  ///
  /// Example: `'High fever, severe headache, muscle and joint pain, nausea, vomiting, skin rash'`
  final String symptoms;

  /// Treatment and management options.
  ///
  /// Current medical approaches for treating the disease, including
  /// supportive care, specific medications, and management strategies.
  /// Should include both acute treatment and long-term care when relevant.
  ///
  /// Example: `'Supportive care, pain relief with acetaminophen, fluid replacement, avoid aspirin'`
  final String treatment;

  /// Prevention methods and strategies.
  ///
  /// Comprehensive prevention guidance including vector control,
  /// personal protective measures, vaccination (if available),
  /// and community-level interventions.
  ///
  /// Example: `'Eliminate standing water, use mosquito repellent, wear long sleeves, vaccination where available'`
  final String prevention;

  /// List of vector species IDs that can transmit this disease.
  ///
  /// Contains identifiers for mosquito species known to vector
  /// this disease. These IDs correspond to [MosquitoSpecies] instances
  /// and enable cross-referencing between diseases and vectors.
  ///
  /// Example: `['aedes_aegypti', 'aedes_albopictus']`
  final List<String> vectors;

  /// Geographic prevalence and distribution information.
  ///
  /// Description of where the disease is endemic, epidemic patterns,
  /// seasonal variations, and current global distribution.
  /// Helps users understand regional risk factors.
  ///
  /// Example: `'Endemic in tropical and subtropical regions, seasonal outbreaks during rainy season'`
  final String prevalence;

  /// URL or path to the disease-related image.
  ///
  /// Reference to an image representing the disease, which could be
  /// a microscopic view of the pathogen, symptom illustration,
  /// or educational diagram.
  ///
  /// Example: `'assets/images/diseases/dengue.jpg'`
  final String imageUrl;

  /// Creates a new [Disease] instance.
  ///
  /// All parameters are required to ensure complete disease information
  /// is available for educational and informational purposes.
  ///
  /// Throws [ArgumentError] if any required field is empty.
  Disease({
    required this.id,
    required this.name,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    required this.vectors,
    required this.prevalence,
    required this.imageUrl,
  }) : assert(id.isNotEmpty, 'Disease ID cannot be empty'),
       assert(name.isNotEmpty, 'Disease name cannot be empty'),
       assert(vectors.isNotEmpty, 'Disease must have at least one vector');

  /// Creates a [Disease] from a JSON map.
  ///
  /// Used for deserializing disease data from JSON sources such as
  /// local asset files or health database APIs.
  ///
  /// Example:
  /// ```dart
  /// final json = {
  ///   'id': 'dengue',
  ///   'name': 'Dengue Fever',
  ///   'description': 'A viral infection...',
  ///   // ... other fields
  /// };
  /// final disease = Disease.fromJson(json);
  /// ```
  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      symptoms: json['symptoms'] as String,
      treatment: json['treatment'] as String,
      prevention: json['prevention'] as String,
      vectors: List<String>.from(json['vectors'] as List),
      prevalence: json['prevalence'] as String,
      imageUrl: json['image_url'] as String,
    );
  }

  /// Converts this [Disease] to a JSON map.
  ///
  /// Used for serializing disease data for storage or API transmission.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'symptoms': symptoms,
      'treatment': treatment,
      'prevention': prevention,
      'vectors': vectors,
      'prevalence': prevalence,
      'image_url': imageUrl,
    };
  }

  /// Checks if this disease is transmitted by a specific mosquito species.
  ///
  /// Returns `true` if the given species ID is listed as a vector
  /// for this disease.
  ///
  /// Example:
  /// ```dart
  /// if (dengue.isTransmittedBy('aedes_aegypti')) {
  ///   print('Aedes aegypti can transmit dengue');
  /// }
  /// ```
  bool isTransmittedBy(String speciesId) {
    return vectors.contains(speciesId);
  }

  /// Gets the primary vector species for this disease.
  ///
  /// Returns the first vector in the list, which is typically
  /// the most important or common vector species.
  String get primaryVector => vectors.isNotEmpty ? vectors.first : '';

  /// Returns a string representation of this disease.
  ///
  /// Primarily used for debugging and logging purposes.
  @override
  String toString() {
    return 'Disease(id: $id, name: $name, vectors: ${vectors.length})';
  }

  /// Checks if two [Disease] instances are equal.
  ///
  /// Two diseases are considered equal if they have the same ID.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Disease && other.id == id;
  }

  /// Returns the hash code for this disease.
  ///
  /// Based on the disease ID for consistent hashing.
  @override
  int get hashCode => id.hashCode;
}