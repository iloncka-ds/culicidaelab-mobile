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
    final path = join(await getDatabasesPath(), 'mosquito_scan_v2.db');
    // For development, you might want to delete the database to ensure onCreate is called
    // await deleteDatabase(path);
    return await openDatabase(
      path,
      version: 1, // Change version if you are migrating
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // --- MAIN TABLES (Language-Agnostic Data) ---
    await db.execute('''
      CREATE TABLE mosquito_species(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE, -- Scientific name is the universal key
        image_url TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE diseases(
        id TEXT PRIMARY KEY,
        name_key TEXT NOT NULL UNIQUE, -- e.g., 'dengue_fever', used as a universal key
        image_url TEXT NOT NULL
      )
    ''');

    // --- TRANSLATION TABLES ---
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


    // --- RELATION TABLE (Unchanged logic, links main tables) ---
    await db.execute('''
      CREATE TABLE mosquito_disease_relation(
        mosquito_id TEXT NOT NULL,
        disease_id TEXT NOT NULL,
        PRIMARY KEY (mosquito_id, disease_id),
        FOREIGN KEY (mosquito_id) REFERENCES mosquito_species (id) ON DELETE CASCADE,
        FOREIGN KEY (disease_id) REFERENCES diseases (id) ON DELETE CASCADE
      )
    ''');

    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    final batch = db.batch();

    // Mosquito Species (agnostic)
    batch.insert('mosquito_species', {'id': '1', 'name': 'Aedes aegypti', 'image_url': 'assets/images/aedes_aegypti.jpg'});
    batch.insert('mosquito_species', {'id': '2', 'name': 'Anopheles gambiae', 'image_url': 'assets/images/anopheles_gambiae.jpg'});
    batch.insert('mosquito_species', {'id': '3', 'name': 'Culex quinquefasciatus', 'image_url': 'assets/images/culex_quinquefasciatus.jpg'});

    // Mosquito Species Translations (en, es, ru)
    // Aedes aegypti
    batch.insert('mosquito_species_translations', {'species_id': '1', 'language_code': 'en', 'common_name': 'Yellow Fever Mosquito', 'description': 'Small, dark mosquito with white markings on legs and thorax, often found in tropical and subtropical regions.', 'habitat': 'Urban areas, breeds in containers with stagnant water', 'distribution': 'Tropical and subtropical regions worldwide'});
    batch.insert('mosquito_species_translations', {'species_id': '1', 'language_code': 'es', 'common_name': 'Mosquito de la Fiebre Amarilla', 'description': 'Pequeño mosquito oscuro con marcas blancas en las patas y el tórax, que se encuentra a menudo en regiones tropicales y subtropicales.', 'habitat': 'Áreas urbanas, se cría en recipientes con agua estancada', 'distribution': 'Regiones tropicales y subtropicales de todo el mundo'});
    batch.insert('mosquito_species_translations', {'species_id': '1', 'language_code': 'ru', 'common_name': 'Комар желтолихорадочный', 'description': 'Маленький темный комар с белыми отметинами на ногах и груди, часто встречающийся в тропических и субтропических регионах.', 'habitat': 'Городские районы, размножается в контейнерах со стоячей водой', 'distribution': 'Тропические и субтропические регионы по всему миру'});
    // Anopheles gambiae
    batch.insert('mosquito_species_translations', {'species_id': '2', 'language_code': 'en', 'common_name': 'African Malaria Mosquito', 'description': 'Medium-sized mosquito with spotted wings and a distinctive resting position at an angle to the surface.', 'habitat': 'Rural areas, breeds in clean, still water', 'distribution': 'Sub-Saharan Africa'});
    batch.insert('mosquito_species_translations', {'species_id': '2', 'language_code': 'es', 'common_name': 'Mosquito de la Malaria Africano', 'description': 'Mosquito de tamaño mediano con alas manchadas y una posición de reposo distintiva en ángulo con la superficie.', 'habitat': 'Zonas rurales, se reproduce en aguas limpias y tranquilas', 'distribution': 'África subsahariana'});
    batch.insert('mosquito_species_translations', {'species_id': '2', 'language_code': 'ru', 'common_name': 'Африканский малярийный комар', 'description': 'Комар среднего размера с пятнистыми крыльями и характерным положением покоя под углом к поверхности.', 'habitat': 'Сельские районы, размножается в чистой, стоячей воде', 'distribution': 'Африка к югу от Сахары'});
    // Culex quinquefasciatus
    batch.insert('mosquito_species_translations', {'species_id': '3', 'language_code': 'en', 'common_name': 'Southern House Mosquito', 'description': 'Brown mosquito with a rounded abdomen and no distinctive markings.', 'habitat': 'Urban and suburban areas, breeds in polluted water', 'distribution': 'Tropical and subtropical regions worldwide'});
    batch.insert('mosquito_species_translations', {'species_id': '3', 'language_code': 'es', 'common_name': 'Mosquito Doméstico del Sur', 'description': 'Mosquito de color marrón con abdomen redondeado y sin marcas distintivas.', 'habitat': 'Áreas urbanas y suburbanas, se reproduce en aguas contaminadas', 'distribution': 'Regiones tropicales y subtropicales de todo el mundo'});
    batch.insert('mosquito_species_translations', {'species_id': '3', 'language_code': 'ru', 'common_name': 'Южный домашний комар', 'description': 'Коричневый комар с округлым брюшком и без отличительных признаков.', 'habitat': 'Городские и пригородные районы, размножается в загрязненной воде', 'distribution': 'Тропические и субтропические регионы по всему миру'});


    // Diseases (agnostic)
    batch.insert('diseases', {'id': '1', 'name_key': 'dengue_fever', 'image_url': 'assets/images/dengue.jpg'});
    batch.insert('diseases', {'id': '2', 'name_key': 'malaria', 'image_url': 'assets/images/malaria.jpg'});
    batch.insert('diseases', {'id': '3', 'name_key': 'zika_virus', 'image_url': 'assets/images/zika.jpg'});

    // Disease Translations (en, es, ru)
    // Dengue
    batch.insert('disease_translations', {'disease_id': '1', 'language_code': 'en', 'name': 'Dengue Fever', 'description': 'Viral infection causing high fever, severe headache, and joint/muscle pain.', 'symptoms': 'High fever, severe headache, pain behind the eyes, joint and muscle pain, rash, mild bleeding', 'treatment': 'No specific treatment. Rest, fluids, pain relievers (avoiding aspirin). Severe cases require hospitalization.', 'prevention': 'Avoid mosquito bites, eliminate breeding sites, use repellents, wear protective clothing', 'prevalence': 'Tropical and subtropical regions, affecting up to 400 million people annually'});
    batch.insert('disease_translations', {'disease_id': '1', 'language_code': 'es', 'name': 'Dengue', 'description': 'Infección viral que causa fiebre alta, dolor de cabeza intenso y dolor en las articulaciones y músculos.', 'symptoms': 'Fiebre alta, dolor de cabeza severo, dolor detrás de los ojos, dolor en articulaciones y músculos, sarpullido, sangrado leve', 'treatment': 'Sin tratamiento específico. Reposo, líquidos, analgésicos (evitando la aspirina). Los casos graves requieren hospitalización.', 'prevention': 'Evitar las picaduras de mosquitos, eliminar los criaderos, usar repelentes, usar ropa protectora', 'prevalence': 'Regiones tropicales y subtropicales, afectando hasta 400 millones de personas anualmente'});
    batch.insert('disease_translations', {'disease_id': '1', 'language_code': 'ru', 'name': 'Лихорадка денге', 'description': 'Вирусная инфекция, вызывающая высокую температуру, сильную головную боль и боли в суставах/мышцах.', 'symptoms': 'Высокая температура, сильная головная боль, боль за глазами, боли в суставах и мышцах, сыпь, легкое кровотечение', 'treatment': 'Специфического лечения нет. Отдых, жидкости, обезболивающие (избегая аспирина). Тяжелые случаи требуют госпитализации.', 'prevention': 'Избегайте укусов комаров, уничтожайте места размножения, используйте репелленты, носите защитную одежду', 'prevalence': 'Тропические и субтропические регионы, ежегодно поражает до 400 миллионов человек'});
    // ... Add translations for Malaria and Zika similarly ...

    // Relations
    batch.insert('mosquito_disease_relation', {'mosquito_id': '1', 'disease_id': '1'});
    batch.insert('mosquito_disease_relation', {'mosquito_id': '1', 'disease_id': '3'});
    batch.insert('mosquito_disease_relation', {'mosquito_id': '2', 'disease_id': '2'});
    batch.insert('mosquito_disease_relation', {'mosquito_id': '3', 'disease_id': '3'});

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