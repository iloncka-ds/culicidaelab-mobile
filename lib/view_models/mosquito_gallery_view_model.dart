import 'package:flutter/foundation.dart';
import '../models/mosquito_model.dart';
import '../repositories/mosquito_repository.dart';

import 'package:culicidaelab/l10n/app_localizations.dart';

/// Represents the possible states of the mosquito gallery loading process.
///
/// - [initial]: The initial state before any data is loaded
/// - [loading]: Mosquito species data is currently being loaded
/// - [loaded]: Mosquito species data has been successfully loaded
/// - [error]: An error occurred while loading mosquito species data
enum GalleryState { initial, loading, loaded, error }

/// Manages the state and business logic for displaying mosquito species information.
///
/// This view model handles:
/// - Loading mosquito species data from the repository
/// - Filtering species by search query
/// - Managing species gallery UI state
/// - Error handling for data loading
///
/// It extends [ChangeNotifier] to provide reactive state updates to the UI.
class MosquitoGalleryViewModel extends ChangeNotifier {
  /// Repository for fetching mosquito species data
  final MosquitoRepository _repository;

  /// Current state of mosquito species data loading
  GalleryState _state = GalleryState.initial;
  /// List of all loaded mosquito species
  List<MosquitoSpecies> _mosquitoSpecies = [];
  /// Error message if loading mosquito species failed
  String? _errorMessage; // Will be a pre-localized string
  /// Current search query for filtering mosquito species
  String _searchQuery = '';

  MosquitoGalleryViewModel({required MosquitoRepository repository})
    : _repository = repository;

  /// Current state of the view model
  GalleryState get state => _state;
  /// List of all loaded mosquito species
  List<MosquitoSpecies> get mosquitoSpecies => _mosquitoSpecies;
  /// Error message if loading mosquito species failed
  String? get errorMessage => _errorMessage;
  /// Current search query for filtering mosquito species
  String get searchQuery => _searchQuery;
  /// Whether mosquito species data is currently being loaded
  bool get isLoading => _state == GalleryState.loading;

  /// Gets the list of mosquito species filtered by the current search query
  ///
  /// Returns all species if no search query is present, otherwise returns
  /// only species whose name or common name contains the search query
  /// (case-insensitive).
  List<MosquitoSpecies> get filteredSpecies {
    if (_searchQuery.isEmpty) {
      return _mosquitoSpecies;
    }

    final query = _searchQuery.toLowerCase();
    return _mosquitoSpecies.where((species) {
      return species.name.toLowerCase().contains(query) ||
          species.commonName.toLowerCase().contains(query);
    }).toList();
  }

  /// Loads all mosquito species from the repository
  ///
  /// Updates the state to loading while fetching and notifies listeners
  /// when complete. Handles any errors that occur during loading.
  ///
  /// - [localizations]: Localization instance for error messages
  Future<void> loadMosquitoSpecies(AppLocalizations localizations) async {
    try {
      _state = GalleryState.loading;
      _errorMessage = null; // Clear previous errors
      notifyListeners();

      final speciesList = await _repository.getAllMosquitoSpecies(
        localizations.localeName,
      );

      _mosquitoSpecies = speciesList;
      _state = GalleryState.loaded;
      notifyListeners();
    } catch (e) {
      _state = GalleryState.error;
      _errorMessage = localizations.viewModelErrorFailedToLoadMosquitoSpecies(
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

  /// Gets a mosquito species by its ID
  ///
  /// - [id]: The ID of the mosquito species to retrieve
  /// - [localizations]: Localization instance for error messages
  ///
  /// Returns the mosquito species if found, or null if an error occurs
  Future<MosquitoSpecies?> getMosquitoSpeciesById(
    String id,
    AppLocalizations localizations,
  ) async {
    try {
      return await _repository.getMosquitoSpeciesById(
        id,
        localizations.localeName,
      );
    } catch (e) {
      _errorMessage = localizations.viewModelErrorFailedToLoadMosquitoSpecies(
        e.toString(),
      );
      notifyListeners();
      return null;
    }
  }
}
