import '../models/mosquito_model.dart';
import '../models/disease_model.dart';
import '../services/database_service.dart';

class MosquitoRepository {
  final DatabaseService _databaseService;

  MosquitoRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  Future<List<MosquitoSpecies>> getAllMosquitoSpecies(String languageCode) async {
    return await _databaseService.getAllMosquitoSpecies(languageCode);
  }

  Future<MosquitoSpecies?> getMosquitoSpeciesById(String id, String languageCode) async {
    return await _databaseService.getMosquitoSpeciesById(id, languageCode);
  }

  Future<List<Disease>> getAllDiseases(String languageCode) async {
    return await _databaseService.getAllDiseases(languageCode);
  }

  Future<Disease?> getDiseaseById(String id, String languageCode) async {
    return await _databaseService.getDiseaseById(id, languageCode);
  }

  Future<List<Disease>> getDiseasesByVector(String speciesName, String languageCode) async {
    return await _databaseService.getDiseasesByVector(speciesName, languageCode);
  }
}