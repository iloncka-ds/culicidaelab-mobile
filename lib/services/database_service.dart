import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mosquito_model.dart';
import '../models/disease_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

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

  /// Loads data from the JSON asset and populates all tables.
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
  // Helper to get all disease vectors (mosquito names) for a given disease ID
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

  // Helper to get all disease names for a given mosquito ID
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


  // --- CRUD Operations (now with languageCode) ---

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
}