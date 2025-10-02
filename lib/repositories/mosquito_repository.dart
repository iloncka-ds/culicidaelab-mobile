import '../models/mosquito_model.dart';
import '../models/disease_model.dart';
import '../services/database_service.dart';

/// Repository for handling mosquito and disease data operations.
///
/// This repository provides an abstraction layer over the database service
/// for retrieving mosquito species and disease information. It handles
/// localization by accepting language codes for internationalized content.
///
/// The repository requires a [DatabaseService] to be injected for data access.
class MosquitoRepository {
  final DatabaseService _databaseService;

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