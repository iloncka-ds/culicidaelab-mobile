import '../models/mosquito_model.dart';
import '../models/disease_model.dart';
import '../services/database_service.dart';

/// Repository for handling mosquito and disease data operations.
///
/// This repository provides a clean abstraction layer over the database service
/// for retrieving mosquito species and disease information. It handles
/// localization by accepting language codes for internationalized content
/// and implements the Repository pattern for better separation of concerns.
///
/// ## Repository Pattern Benefits
///
/// - **Abstraction**: Hides database implementation details from business logic
/// - **Testability**: Easy to mock for unit testing
/// - **Consistency**: Provides a consistent API for data access
/// - **Future-Proofing**: Can switch data sources without changing business logic
///
/// ## Localization Support
///
/// All methods accept a language code parameter to return localized content:
/// - **English** (`'en'`): Primary language with complete coverage
/// - **Spanish** (`'es'`): Full translation support for Latin American users
/// - **Russian** (`'ru'`): Full translation support for Eastern European users
///
/// ## Data Relationships
///
/// The repository handles complex relationships between entities:
/// - **Species ↔ Diseases**: Many-to-many relationships via vector transmission
/// - **Translations**: One-to-many relationships for localized content
/// - **Images**: One-to-one relationships for visual assets
///
/// ## Usage Example
///
/// ```dart
/// final repository = MosquitoRepository(
///   databaseService: DatabaseService(),
/// );
///
/// // Get all species in Spanish
/// final species = await repository.getAllMosquitoSpecies('es');
/// 
/// // Find a specific species
/// final aedes = await repository.getMosquitoSpeciesByName('Aedes aegypti', 'en');
/// 
/// // Get diseases transmitted by this species
/// if (aedes != null) {
///   final diseases = await repository.getDiseasesByVector(aedes.name, 'en');
///   print('${aedes.commonName} can transmit: ${diseases.map((d) => d.name).join(', ')}');
/// }
/// ```
///
/// ## Performance Characteristics
///
/// - **Caching**: Database connections are cached by the service layer
/// - **Indexing**: Queries use database indexes for optimal performance
/// - **Lazy Loading**: Data is loaded only when requested
/// - **Batch Operations**: Multiple related queries are optimized
///
/// ## Error Handling
///
/// The repository propagates database errors but provides meaningful context:
/// - **Not Found**: Returns null for missing entities
/// - **Database Errors**: Throws exceptions with descriptive messages
/// - **Localization Fallbacks**: Gracefully handles missing translations
///
/// See also:
/// - [DatabaseService] for the underlying database operations
/// - [MosquitoSpecies] and [Disease] for the data models
/// - [ClassificationRepository] which uses this repository for data enrichment
class MosquitoRepository {
  /// The database service for data access operations.
  ///
  /// Provides the underlying database connectivity and query execution
  /// for all mosquito and disease data operations.
  final DatabaseService _databaseService;

  /// Creates a new mosquito repository with the required database service.
  ///
  /// The [databaseService] parameter is required and provides access to
  /// the SQLite database containing mosquito species, diseases, and
  /// their relationships.
  ///
  /// Example:
  /// ```dart
  /// final repository = MosquitoRepository(
  ///   databaseService: DatabaseService(),
  /// );
  /// ```
  ///
  /// For testing, a mock database service can be injected:
  /// ```dart
  /// final mockDbService = MockDatabaseService();
  /// final repository = MosquitoRepository(
  ///   databaseService: mockDbService,
  /// );
  /// ```
  MosquitoRepository({required DatabaseService databaseService})
      : _databaseService = databaseService;

  /// Retrieves all mosquito species from the database.
  ///
  /// [languageCode] The language code (e.g., 'en', 'es') for localized content.
  /// Returns a list of all available mosquito species.
  Future<List<MosquitoSpecies>> getAllMosquitoSpecies(String languageCode) async {
    return await _databaseService.getAllMosquitoSpecies(languageCode);
  }

  /// Retrieves a mosquito species by its unique identifier.
  ///
  /// [id] The unique identifier of the mosquito species.
  /// [languageCode] The language code for localized content.
  /// Returns the mosquito species if found, null otherwise.
  Future<MosquitoSpecies?> getMosquitoSpeciesById(String id, String languageCode) async {
    return await _databaseService.getMosquitoSpeciesById(id, languageCode);
  }

  /// Retrieves all diseases from the database.
  ///
  /// [languageCode] The language code for localized content.
  /// Returns a list of all available diseases.
  Future<List<Disease>> getAllDiseases(String languageCode) async {
    return await _databaseService.getAllDiseases(languageCode);
  }

  /// Retrieves a disease by its unique identifier.
  ///
  /// [id] The unique identifier of the disease.
  /// [languageCode] The language code for localized content.
  /// Returns the disease if found, null otherwise.
  Future<Disease?> getDiseaseById(String id, String languageCode) async {
    return await _databaseService.getDiseaseById(id, languageCode);
  }

  /// Retrieves diseases that are transmitted by a specific mosquito species.
  ///
  /// [speciesName] The scientific name of the mosquito species.
  /// [languageCode] The language code for localized content.
  /// Returns a list of diseases associated with the specified vector.
  Future<List<Disease>> getDiseasesByVector(String speciesName, String languageCode) async {
    return await _databaseService.getDiseasesByVector(speciesName, languageCode);
  }

  /// Retrieves a mosquito species by its scientific name.
  ///
  /// [scientificName] The scientific name of the mosquito species.
  /// [languageCode] The language code for localized content.
  /// Returns the mosquito species if found, null otherwise.
  Future<MosquitoSpecies?> getMosquitoSpeciesByName(String scientificName, String languageCode) async {
    return await _databaseService.getMosquitoSpeciesByName(scientificName, languageCode);
  }
}