import 'package:culicidaelab/l10n/app_localizations.dart';
import 'package:culicidaelab/models/disease_model.dart';
import 'package:culicidaelab/repositories/mosquito_repository.dart';
import 'package:culicidaelab/view_models/disease_info_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:culicidaelab/locator.dart';



import 'disease_info_view_model_test.mocks.dart';

// Manual mock for AppLocalizations since it's generated
class MockAppLocalizations extends Mock implements AppLocalizations {
  @override
  Locale get locale => const Locale('en');
  @override
  String get localeName => 'en';

  @override
  String viewModelErrorFailedToLoadDiseases(String error) {
    return 'Failed to load diseases: $error';
  }
}

@GenerateMocks([MosquitoRepository])
void main() {
  late DiseaseInfoViewModel diseaseInfoViewModel;
  late MockMosquitoRepository mockMosquitoRepository;
  late MockAppLocalizations mockAppLocalizations;

  setUp(() {
    mockMosquitoRepository = MockMosquitoRepository();

    locator.registerSingleton<MosquitoRepository>(mockMosquitoRepository);
    mockAppLocalizations = MockAppLocalizations();
    diseaseInfoViewModel =
        DiseaseInfoViewModel(repository: locator());
  });

  tearDown(() {
    locator.unregister<MosquitoRepository>();

  });

  group('DiseaseInfoViewModel', () {
    final diseases = [
      Disease(
          id: '1',
          name: 'Dengue',
          description: 'Desc',
          symptoms: 'Symp',
          treatment: 'Treat',
          prevention: 'Prev',
          vectors: [],
          prevalence: 'PrevL',
          imageUrl: 'url'),
    ];

    test('loadDiseases should load diseases from the repository', () async {
      when(mockMosquitoRepository.getAllDiseases('en'))
          .thenAnswer((_) async => diseases);

      await diseaseInfoViewModel.loadDiseases(mockAppLocalizations);

      expect(diseaseInfoViewModel.state, DiseaseInfoState.loaded);
      expect(diseaseInfoViewModel.diseases, diseases);
    });

    test('loadDiseases should handle errors', () async {
      when(mockMosquitoRepository.getAllDiseases('en'))
          .thenThrow(Exception('Failed'));

      await diseaseInfoViewModel.loadDiseases(mockAppLocalizations);

      expect(diseaseInfoViewModel.state, DiseaseInfoState.error);
      expect(diseaseInfoViewModel.errorMessage,
          'Failed to load diseases: Exception: Failed');
    });
  });
}
