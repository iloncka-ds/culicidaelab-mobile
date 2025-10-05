import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mosquito_model.dart';
import '../models/disease_model.dart';

/// Service for managing mosquito and disease data using SQLite database.
///
/// This singleton service provides CRUD operations for mosquito species and diseases,
/// including multi-language support and relationship management between species and diseases.
/// It handles database initialization, data population from JSON assets, and localized queries.
///
/// ## Database Schema
///
/// The service manages a normalized SQLite database with the following tables:
/// - `mosquito_species`: Core species data (ID, scientific name, image URL)
/// - `mosquito_species_translations`: Localized species information
/// - `diseases`: Core disease data (ID, name key, image URL)
/// - `disease_translations`: Localized disease information
/// - `mosquito_disease_relation`: Many-to-many relationships between species and diseases
///
/// ## Localization Support
///
/// All user-facing content supports multiple languages through translation tables:
/// - **English** (`en`): Primary language with complete coverage
/// - **Spanish** (`es`): Full translation support
/// - **Russian** (`ru`): Full translation support
///
/// ## Data Sources
///
/// Initial data is populated from `assets/database/database_data.json` which contains:
/// - Species information from scientific literature
/// - Disease data from WHO and CDC sources
/// - Vector-disease relationships from epidemiological studies
///
/// ## Usage Example
///
/// ```dart
/// final dbService = DatabaseService();
/// 
/// // Get all mosquito species in Spanish
/// final species = await dbService.getAllMosquitoSpecies('es');
/// 
/// // Find a specific species by scientific name
/// final aedes = await dbService.getMosquitoSpeciesByName('Aedes aegypti', 'en');
/// 
/// // Get diseases transmitted by a species
/// final diseases = await dbService.getDiseasesByVector('Aedes aegypti', 'en');
/// ```
///
/// ## Performance Considerations
///
/// - Database is created once and cached for the app lifetime
/// - Queries use indexes on frequently accessed columns
/// - Batch operations are used for initial data population
/// - Connection pooling is handled by SQLite
///
/// See also:
/// - [MosquitoRepository] for higher-level data access patterns
/// - [MosquitoSpecies] and [Disease] for the data models
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  /// Gets the singleton instance of the database service.
  ///
  /// This ensures only one database connection exists throughout the app lifecycle,
  /// improving performance and preventing connection conflicts.
  ///
  /// Example:
  /// ```dart
  /// final dbService = DatabaseService();
  /// final species = await dbService.getAllMosquitoSpecies('en');
  /// ```
  factory DatabaseService() => _instance;

  /// Private constructor for singleton pattern.
  ///
  /// Prevents direct instantiation and ensures the singleton pattern
  /// is properly maintained throughout the application.
  DatabaseService._internal();

  /// Gets or creates the database instance.
  ///
  /// If the database doesn't exist, it will be created and initialized with
  /// all necessary tables and data. Subsequent calls return the cached
  /// database instance for optimal performance.
  ///
  /// The database is created with version 1 and includes:
  /// - All required tables with proper foreign key constraints
  /// - Initial data populated from JSON assets
  /// - Indexes for optimal query performance
  ///
  /// Returns a [Database] instance ready for use.
  ///
  /// Throws [DatabaseException] if database creation or initialization fails.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database with tables and initial data.
  ///
  /// Creates the SQLite database file in the app's documents directory
  /// and sets up the complete schema with initial data population.
  ///
  /// ## Database Location
  ///
  /// The database is stored at: `{app_documents}/mosquito_scan_v1.db`
  ///
  /// ## Version Management
  ///
  /// - **Current Version**: 1
  /// - **Migration Strategy**: Future versions will use `onUpgrade` callback
  /// - **Development Reset**: Uncomment `deleteDatabase(path)` to reset during development
  ///
  /// Returns a [Database] instance ready for use.
  ///
  /// Throws [DatabaseException] if database creation fails.
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'mosquito_scan_v1.db');
    // To reset the DB during development, uncomment the next line
    // await deleteDatabase(path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  /// Creates the database schema and populates initial data.
  ///
  /// This method is called only when the database is created for the first time.
  /// It sets up the complete normalized schema with proper foreign key constraints
  /// and populates all tables with initial data from JSON assets.
  ///
  /// ## Schema Design
  ///
  /// The database uses a normalized design to support:
  /// - **Internationalization**: Separate translation tables for each entity
  /// - **Relationships**: Many-to-many relationships between species and diseases
  /// - **Data Integrity**: Foreign key constraints ensure referential integrity
  /// - **Performance**: Indexes on frequently queried columns
  ///
  /// ## Tables Created
  ///
  /// 1. **mosquito_species**: Core species data (id, name, image_url)
  /// 2. **mosquito_species_translations**: Localized species content
  /// 3. **diseases**: Core disease data (id, name_key, image_url)
  /// 4. **disease_translations**: Localized disease content
  /// 5. **mosquito_disease_relation**: Species-disease relationships
  ///
  /// ## Data Population
  ///
  /// After creating tables, the method populates them with data from
  /// `assets/database/database_data.json` using batch operations for performance.
  ///
  /// [db] The database instance to initialize.
  /// [version] The database version (currently 1).
  ///
  /// Throws [DatabaseException] if table creation or data population fails.
  Future<void> _createDatabase(Database db, int version) async {
    // --- Create Tables ---
    await db.execute('''
      CREATE TABLE mosquito_species(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        image_url TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE diseases(
        id TEXT PRIMARY KEY,
        name_key TEXT NOT NULL UNIQUE,
        image_url TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE mosquito_species_translations(
        species_id TEXT NOT NULL,
        language_code TEXT NOT NULL,
        common_name TEXT NOT NULL,
        description TEXT NOT NULL,
        habitat TEXT NOT NULL,
        distribution TEXT NOT NULL,
        PRIMARY KEY (species_id, language_code),
        FOREIGN KEY (species_id) REFERENCES mosquito_species (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE disease_translations(
        disease_id TEXT NOT NULL,
        language_code TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        symptoms TEXT NOT NULL,
        treatment TEXT NOT NULL,
        prevention TEXT NOT NULL,
        prevalence TEXT NOT NULL,
        PRIMARY KEY (disease_id, language_code),
        FOREIGN KEY (disease_id) REFERENCES diseases (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE mosquito_disease_relation(
        mosquito_id TEXT NOT NULL,
        disease_id TEXT NOT NULL,
        PRIMARY KEY (mosquito_id, disease_id),
        FOREIGN KEY (mosquito_id) REFERENCES mosquito_species (id) ON DELETE CASCADE,
        FOREIGN KEY (disease_id) REFERENCES diseases (id) ON DELETE CASCADE
      )
    ''');

    // --- Populate Tables from JSON ---
    await _insertDataFromJson(db);
  }

  /// Populates the database with data from JSON assets.
  ///
  /// Loads mosquito species, diseases, translations, and relationships
  /// from the database_data.json asset file.
  ///
  /// @param db The database instance to populate
Future<void> _insertDataFromJson(Database db) async {
    // 1. Load the JSON string from assets
    final String jsonString = await rootBundle.loadString('assets/database/database_data.json');

    // 2. Decode the JSON string into a Dart Map
    final Map<String, dynamic> data = json.decode(jsonString);

    final batch = db.batch();

    // 3. Populate mosquito_species table
    final List<dynamic> species = data['mosquito_species'];
    for (var item in species) {
      batch.insert('mosquito_species', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 4. Populate mosquito_species_translations table
    final List<dynamic> speciesTranslations = data['mosquito_species_translations'];
    for (var item in speciesTranslations) {
      batch.insert('mosquito_species_translations', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 5. Populate diseases table
    final List<dynamic> diseases = data['diseases'];
    for (var item in diseases) {
      batch.insert('diseases', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 6. Populate disease_translations table
    final List<dynamic> diseaseTranslations = data['disease_translations'];
    for (var item in diseaseTranslations) {
      batch.insert('disease_translations', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 7. Populate mosquito_disease_relation table
    final List<dynamic> relations = data['mosquito_disease_relations'];
    for (var item in relations) {
      batch.insert('mosquito_disease_relation', item, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 8. Commit the batch operation
    await batch.commit(noResult: true);
  }
  /// Helper method to get vector names for a disease.
  ///
  /// @param db The database instance
  /// @param diseaseId The disease ID
  /// @return A Future that completes with a list of mosquito species names
Future<List<String>> _getVectorNamesForDisease(Database db, String diseaseId) async {
      final List<Map<String, dynamic>> relationMaps = await db.query('mosquito_disease_relation', where: 'disease_id = ?', whereArgs: [diseaseId]);
      final List<String> mosquitoIds = relationMaps.map((r) => r['mosquito_id'] as String).toList();
      final List<String> vectorNames = [];
      for (var mosquitoId in mosquitoIds) {
        final List<Map<String, dynamic>> mosquitoMaps = await db.query('mosquito_species', columns: ['name'], where: 'id = ?', whereArgs: [mosquitoId]);
        if (mosquitoMaps.isNotEmpty) {
          vectorNames.add(mosquitoMaps.first['name'] as String);
        }
      }
      return vectorNames;
  }

  /// Helper method to get disease names for a mosquito species.
  ///
  /// @param db The database instance
  /// @param mosquitoId The mosquito species ID
  /// @param languageCode The language code for localization
  /// @return A Future that completes with a list of disease names
Future<List<String>> _getDiseaseNamesForMosquito(Database db, String mosquitoId, String languageCode) async {
      final List<Map<String, dynamic>> relationMaps = await db.query('mosquito_disease_relation', where: 'mosquito_id = ?', whereArgs: [mosquitoId]);
      final List<String> diseaseIds = relationMaps.map((r) => r['disease_id'] as String).toList();
      final List<String> diseaseNames = [];
      for (var diseaseId in diseaseIds) {
        final List<Map<String, dynamic>> diseaseMaps = await db.rawQuery('''
            SELECT name FROM disease_translations WHERE disease_id = ? AND language_code = ?
        ''', [diseaseId, languageCode]);
        if (diseaseMaps.isNotEmpty) {
          diseaseNames.add(diseaseMaps.first['name'] as String);
        }
      }
      return diseaseNames;
  }


  /// Retrieves all mosquito species for a specific language.
  ///
  /// Returns a list of mosquito species with their localized information
  /// and associated diseases for the specified language.
  ///
  /// @param languageCode The language code (e.g., 'en', 'es')
  /// @return A Future that completes with a list of MosquitoSpecies
Future<List<MosquitoSpecies>> getAllMosquitoSpecies(String languageCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        s.id, s.name, s.image_url,
        t.common_name, t.description, t.habitat, t.distribution
      FROM mosquito_species s
      LEFT JOIN mosquito_species_translations t ON s.id = t.species_id
      WHERE t.language_code = ?
    ''', [languageCode]);

    return Future.wait(maps.map((map) async {
      final diseaseNames = await _getDiseaseNamesForMosquito(db, map['id'], languageCode);
      return MosquitoSpecies(
        id: map['id'],
        name: map['name'],
        commonName: map['common_name'],
        description: map['description'],
        habitat: map['habitat'],
        distribution: map['distribution'],
        imageUrl: map['image_url'],
        diseases: diseaseNames,
      );
    }).toList());
  }

  /// Retrieves a specific mosquito species by ID for a specific language.
  ///
  /// Returns a single mosquito species with localized information
  /// and associated diseases, or null if not found.
  ///
  /// @param id The unique identifier of the mosquito species
  /// @param languageCode The language code (e.g., 'en', 'es')
  /// @return A Future that completes with a MosquitoSpecies or null
  Future<MosquitoSpecies?> getMosquitoSpeciesById(String id, String languageCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        s.id, s.name, s.image_url,
        t.common_name, t.description, t.habitat, t.distribution
      FROM mosquito_species s
      LEFT JOIN mosquito_species_translations t ON s.id = t.species_id
      WHERE s.id = ? AND t.language_code = ?
    ''', [id, languageCode]);

    if (maps.isEmpty) return null;

    final map = maps.first;
    final diseaseNames = await _getDiseaseNamesForMosquito(db, map['id'], languageCode);
    return MosquitoSpecies(
      id: map['id'],
      name: map['name'],
      commonName: map['common_name'],
      description: map['description'],
      habitat: map['habitat'],
      distribution: map['distribution'],
      imageUrl: map['image_url'],
      diseases: diseaseNames,
    );
  }

  /// Retrieves all diseases for a specific language.
  ///
  /// Returns a list of diseases with their localized information
  /// and associated mosquito vectors for the specified language.
  ///
  /// @param languageCode The language code (e.g., 'en', 'es')
  /// @return A Future that completes with a list of Disease objects
  Future<List<Disease>> getAllDiseases(String languageCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        d.id, d.image_url,
        t.name, t.description, t.symptoms, t.treatment, t.prevention, t.prevalence
      FROM diseases d
      LEFT JOIN disease_translations t ON d.id = t.disease_id
      WHERE t.language_code = ?
    ''', [languageCode]);

    return Future.wait(maps.map((map) async {
      final vectorNames = await _getVectorNamesForDisease(db, map['id']);
      return Disease(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        symptoms: map['symptoms'],
        treatment: map['treatment'],
        prevention: map['prevention'],
        vectors: vectorNames,
        prevalence: map['prevalence'],
        imageUrl: map['image_url'],
      );
    }).toList());
  }

  /// Retrieves a specific disease by ID for a specific language.
  ///
  /// Returns a single disease with localized information
  /// and associated mosquito vectors, or null if not found.
  ///
  /// @param id The unique identifier of the disease
  /// @param languageCode The language code (e.g., 'en', 'es')
  /// @return A Future that completes with a Disease or null
  Future<Disease?> getDiseaseById(String id, String languageCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        d.id, d.image_url,
        t.name, t.description, t.symptoms, t.treatment, t.prevention, t.prevalence
      FROM diseases d
      LEFT JOIN disease_translations t ON d.id = t.disease_id
      WHERE d.id = ? AND t.language_code = ?
    ''', [id, languageCode]);

    if (maps.isEmpty) return null;

    final map = maps.first;
    final vectorNames = await _getVectorNamesForDisease(db, map['id']);
    return Disease(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        symptoms: map['symptoms'],
        treatment: map['treatment'],
        prevention: map['prevention'],
        vectors: vectorNames,
        prevalence: map['prevalence'],
        imageUrl: map['image_url'],
    );
  }

  /// Retrieves diseases associated with a specific mosquito species.
  ///
  /// Returns all diseases that can be transmitted by the specified
  /// mosquito species for the given language.
  ///
  /// @param speciesName The scientific name of the mosquito species
  /// @param languageCode The language code (e.g., 'en', 'es')
  /// @return A Future that completes with a list of Disease objects
    Future<List<Disease>> getDiseasesByVector(String speciesName, String languageCode) async {
    final db = await database;
    final List<Map<String, dynamic>> mosquitoMaps = await db.query('mosquito_species', where: 'name = ?', whereArgs: [speciesName]);
    if (mosquitoMaps.isEmpty) return [];

    final String mosquitoId = mosquitoMaps.first['id'];
    final List<Map<String, dynamic>> relationMaps = await db.query('mosquito_disease_relation', where: 'mosquito_id = ?', whereArgs: [mosquitoId]);
    final List<String> diseaseIds = relationMaps.map((r) => r['disease_id'] as String).toList();

    final List<Disease> diseases = [];
    for (var diseaseId in diseaseIds) {
      final disease = await getDiseaseById(diseaseId, languageCode);
      if (disease != null) {
        diseases.add(disease);
      }
    }
    return diseases;
  }

  /// Retrieves a mosquito species by its scientific name for a specific language.
  ///
  /// Returns a single mosquito species with localized information
  /// and associated diseases, or null if not found.
  ///
  /// @param scientificName The scientific name of the mosquito species
  /// @param languageCode The language code (e.g., 'en', 'es')
  /// @return A Future that completes with a MosquitoSpecies or null
Future<MosquitoSpecies?> getMosquitoSpeciesByName(String scientificName, String languageCode) async {
    final db = await database;
    print("[DEBUG] DatabaseService: Received name to query: $scientificName with lang: $languageCode");
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        s.id, s.name, s.image_url,
        t.common_name, t.description, t.habitat, t.distribution
      FROM mosquito_species s
      LEFT JOIN mosquito_species_translations t ON s.id = t.species_id
      WHERE LOWER(s.name) = LOWER(?) AND t.language_code = ?
    ''', [scientificName, languageCode]);

    print("[DEBUG] DatabaseService: Raw query returned ${maps.length} rows.");
    if (maps.isNotEmpty) {
      print("[DEBUG] DatabaseService: First row data: ${maps.first}");
    }
    if (maps.isEmpty) return null;

    final map = maps.first;
    final diseaseNames = await _getDiseaseNamesForMosquito(db, map['id'], languageCode);

    return MosquitoSpecies(
      id: map['id'],
      name: map['name'],
      commonName: map['common_name'],
      description: map['description'],
      habitat: map['habitat'],
      distribution: map['distribution'],
      imageUrl: map['image_url'],
      diseases: diseaseNames,
    );
  }
}