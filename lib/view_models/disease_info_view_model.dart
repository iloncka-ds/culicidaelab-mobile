import 'package:flutter/foundation.dart';
import '../models/disease_model.dart';
import '../repositories/mosquito_repository.dart';

import 'package:culicidaelab/l10n/app_localizations.dart';

/// Represents the possible states of the disease information loading process.
///
/// - [initial]: The initial state before any data is loaded
/// - [loading]: Disease data is currently being loaded
/// - [loaded]: Disease data has been successfully loaded
/// - [error]: An error occurred while loading disease data
enum DiseaseInfoState { initial, loading, loaded, error }

/// Manages the state and business logic for displaying disease information.
///
/// This view model handles:
/// - Loading disease data from the repository
/// - Filtering diseases by search query
/// - Managing disease-related UI state
/// - Error handling for data loading
///
/// It extends [ChangeNotifier] to provide reactive state updates to the UI.
class DiseaseInfoViewModel extends ChangeNotifier {
  /// Repository for fetching disease and mosquito-related data
  final MosquitoRepository _repository;

  /// Current state of disease data loading
  DiseaseInfoState _state = DiseaseInfoState.initial;
  /// List of all loaded diseases
  List<Disease> _diseases = [];
  /// Error message if loading diseases failed
  String? _errorMessage; // Will be a pre-localized string
  /// Current search query for filtering diseases
  String _searchQuery = '';

  DiseaseInfoViewModel({required MosquitoRepository repository})
    : _repository = repository;

  /// Current state of the view model
  DiseaseInfoState get state => _state;
  /// List of all loaded diseases
  List<Disease> get diseases => _diseases;
  /// Error message if loading diseases failed
  String? get errorMessage => _errorMessage;
  /// Current search query for filtering diseases
  String get searchQuery => _searchQuery;
  /// Whether disease data is currently being loaded
  bool get isLoading => _state == DiseaseInfoState.loading;

  /// Gets the list of diseases filtered by the current search query
  ///
  /// Returns all diseases if no search query is present, otherwise returns
  /// only diseases whose name or description contains the search query
  /// (case-insensitive).
  List<Disease> get filteredDiseases {
    if (_searchQuery.isEmpty) {
      return _diseases;
    }

    final query = _searchQuery.toLowerCase();
    return _diseases.where((disease) {
      return disease.name.toLowerCase().contains(query) ||
          disease.description.toLowerCase().contains(query);
    }).toList();
  }

  /// Loads all diseases from the repository
  ///
  /// Updates the state to loading while fetching and notifies listeners
  /// when complete. Handles any errors that occur during loading.
  ///
  /// - [localizations]: Localization instance for error messages
  Future<void> loadDiseases(AppLocalizations localizations) async {
    try {
      _state = DiseaseInfoState.loading;
      _errorMessage = null; // Clear previous errors
      notifyListeners();

      final diseasesList = await _repository.getAllDiseases(
        localizations.localeName,
      );

      _diseases = diseasesList;
      _state = DiseaseInfoState.loaded;
      notifyListeners();
    } catch (e) {
      _state = DiseaseInfoState.error;
      _errorMessage = localizations.viewModelErrorFailedToLoadDiseases(
        e.toString(),
      );
      notifyListeners();
    }
  }

  /// Updates the current search query and notifies listeners
  ///
  /// - [query]: The new search query string
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Gets a disease by its ID
  ///
  /// - [id]: The ID of the disease to retrieve
  /// - [localizations]: Localization instance for error messages
  ///
  /// Returns the disease if found, or null if an error occurs
  Future<Disease?> getDiseaseById(
    String id,
    AppLocalizations localizations,
  ) async {
    try {
      return await _repository.getDiseaseById(id, localizations.localeName);
    } catch (e) {
      _errorMessage = localizations.viewModelErrorFailedToLoadDisease(
        e.toString(),
      );
      notifyListeners();
      return null;
    }
  }

  /// Gets all diseases associated with a specific mosquito vector
  ///
  /// - [speciesName]: The name of the mosquito species
  /// - [localizations]: Localization instance for error messages
  ///
  /// Returns a list of diseases associated with the vector, or an empty list
  /// if an error occurs
  Future<List<Disease>> getDiseasesByVector(
    String speciesName,
    AppLocalizations localizations,
  ) async {
    try {
      if (_state != DiseaseInfoState.loaded &&
          _state != DiseaseInfoState.loading) {
        await loadDiseases(localizations);
      }

      return await _repository.getDiseasesByVector(
        speciesName,
        localizations.localeName,
      );
    } catch (e) {
      _errorMessage = localizations.viewModelErrorFailedToLoadDiseasesForVector(
        e.toString(),
      );
      notifyListeners();
      return [];
    }
  }
}
