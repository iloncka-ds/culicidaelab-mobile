import 'package:flutter/foundation.dart';
import '../models/mosquito_model.dart';
import '../repositories/mosquito_repository.dart';

import 'package:culicidaelab/l10n/app_localizations.dart';

enum GalleryState { initial, loading, loaded, error }

class MosquitoGalleryViewModel extends ChangeNotifier {
  final MosquitoRepository _repository;

  GalleryState _state = GalleryState.initial;
  List<MosquitoSpecies> _mosquitoSpecies = [];
  String? _errorMessage; // Will be a pre-localized string
  String _searchQuery = '';

  MosquitoGalleryViewModel({MosquitoRepository? repository})
    : _repository = repository ?? MosquitoRepository();

  GalleryState get state => _state;
  List<MosquitoSpecies> get mosquitoSpecies => _mosquitoSpecies;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isLoading => _state == GalleryState.loading;

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

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

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
