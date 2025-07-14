import 'package:flutter/foundation.dart';
import '../models/disease_model.dart';
import '../repositories/mosquito_repository.dart';

import 'package:culicidaelab/l10n/app_localizations.dart';

enum DiseaseInfoState { initial, loading, loaded, error }

class DiseaseInfoViewModel extends ChangeNotifier {
  final MosquitoRepository _repository;

  DiseaseInfoState _state = DiseaseInfoState.initial;
  List<Disease> _diseases = [];
  String? _errorMessage; // Will be a pre-localized string
  String _searchQuery = '';

  DiseaseInfoViewModel({MosquitoRepository? repository})
    : _repository = repository ?? MosquitoRepository();

  DiseaseInfoState get state => _state;
  List<Disease> get diseases => _diseases;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isLoading => _state == DiseaseInfoState.loading;

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

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

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
