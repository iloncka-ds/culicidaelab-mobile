import 'package:culicidaelab/l10n/app_localizations.dart';
import 'package:culicidaelab/models/mosquito_model.dart';
import 'package:culicidaelab/repositories/mosquito_repository.dart';
import 'package:culicidaelab/view_models/mosquito_gallery_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:culicidaelab/locator.dart';

import 'package:culicidaelab/locator.dart';


import 'mosquito_gallery_view_model_test.mocks.dart';

// Manual mock for AppLocalizations since it's generated
class MockAppLocalizations extends Mock implements AppLocalizations {
  @override
  Locale get locale => const Locale('en');
  @override
  String get localeName => 'en';

  @override
  String viewModelErrorFailedToLoadMosquitoSpecies(String error) {
    return 'Failed to load mosquito species: $error';
  }
}

@GenerateMocks([MosquitoRepository])
void main() {
  late MosquitoGalleryViewModel mosquitoGalleryViewModel;
  late MockMosquitoRepository mockMosquitoRepository;
  late MockAppLocalizations mockAppLocalizations;

  setUp(() {
    mockMosquitoRepository = MockMosquitoRepository();

    locator.registerSingleton<MosquitoRepository>(mockMosquitoRepository);
    mockAppLocalizations = MockAppLocalizations();
    mosquitoGalleryViewModel =
        MosquitoGalleryViewModel(repository: locator());
  });

  tearDown(() {
    locator.unregister<MosquitoRepository>();

  });

  group('MosquitoGalleryViewModel', () {
    final species = [
      MosquitoSpecies(
          id: '1',
          name: 'Aedes aegypti',
          commonName: 'Yellow Fever Mosquito',
          description: 'Desc',
          habitat: 'Hab',
          distribution: 'Dist',
          imageUrl: 'url',
          diseases: []),
    ];

    test('loadMosquitoSpecies should load species from the repository',
        () async {
      when(mockMosquitoRepository.getAllMosquitoSpecies('en'))
          .thenAnswer((_) async => species);

      await mosquitoGalleryViewModel.loadMosquitoSpecies(mockAppLocalizations);

      expect(mosquitoGalleryViewModel.state, GalleryState.loaded);
      expect(mosquitoGalleryViewModel.mosquitoSpecies, species);
    });

    test('loadMosquitoSpecies should handle errors', () async {
      when(mockMosquitoRepository.getAllMosquitoSpecies('en'))
          .thenThrow(Exception('Failed'));

      await mosquitoGalleryViewModel.loadMosquitoSpecies(mockAppLocalizations);

      expect(mosquitoGalleryViewModel.state, GalleryState.error);
      expect(mosquitoGalleryViewModel.errorMessage,
          'Failed to load mosquito species: Exception: Failed');
    });
  });
}
