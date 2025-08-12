import 'package:culicidaelab/repositories/classification_repository.dart';
import 'package:culicidaelab/repositories/mosquito_repository.dart';
import 'package:culicidaelab/services/classification_service.dart';
import 'package:culicidaelab/services/database_service.dart';
import 'package:culicidaelab/services/pytorch_wrapper.dart';
import 'package:culicidaelab/services/user_service.dart';
import 'package:culicidaelab/view_models/classification_view_model.dart';
import 'package:culicidaelab/view_models/disease_info_view_model.dart';
import 'package:culicidaelab/providers/locale_provider.dart';
import 'package:culicidaelab/view_models/mosquito_gallery_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // External packages
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);
  locator.registerLazySingleton(() => const Uuid());
  locator.registerLazySingleton(() => http.Client());

  // Services
  locator.registerLazySingleton(() => DatabaseService());
  locator.registerLazySingleton(() => PytorchWrapper());
  locator.registerLazySingleton(
      () => UserService(prefs: locator(), uuid: locator()));
  locator.registerLazySingleton(
      () => ClassificationService(pytorchWrapper: locator()));

  // Repositories
  locator.registerLazySingleton(
      () => MosquitoRepository(databaseService: locator()));
  locator.registerLazySingleton(() => ClassificationRepository(
      classificationService: locator(),
      mosquitoRepository: locator(),
      httpClient: locator()));

  // ViewModels
  locator.registerFactory(() => ClassificationViewModel(
      repository: locator(), userService: locator()));
  locator.registerFactory(
      () => DiseaseInfoViewModel(repository: locator()));
  locator.registerFactory(
      () => MosquitoGalleryViewModel(repository: locator()));

  // Providers
  locator.registerLazySingleton(() => LocaleProvider(prefs: locator()));
}
