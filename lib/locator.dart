/// Dependency injection locator for the CulicidaeLab mobile application.
///
/// This file configures and manages all service locators using the GetIt dependency
/// injection framework. It provides centralized access to repositories, services,
/// view models, and providers throughout the application.
///
/// The locator pattern ensures proper dependency injection, testability, and
/// separation of concerns by managing the lifecycle of application services.
///
/// Usage:
/// ```dart
/// await setupLocator(); // Initialize all dependencies
/// final service = locator<ServiceType>(); // Retrieve services
/// ```
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

/// Global service locator instance for dependency injection.
///
/// This is the main GetIt instance used throughout the application to access
/// registered services, repositories, view models, and providers. Services
/// are registered during application startup and can be retrieved from anywhere
/// in the application using this locator.
///
/// Example:
/// ```dart
/// final databaseService = locator<DatabaseService>();
/// ```

final GetIt locator = GetIt.instance;

/// Sets up the dependency injection locator with all application services.
///
/// This function initializes and registers all necessary services, repositories,
/// view models, and providers in the correct dependency order. It should be
/// called early in the application lifecycle, typically in main() before
/// running the app.
///
/// The registration order is important:
/// 1. External packages (SharedPreferences, HTTP client, UUID)
/// 2. Core services (Database, PyTorch, User, Classification)
/// 3. Repositories (Data access layer)
/// 4. ViewModels (Business logic layer)
/// 5. Providers (State management)
///
/// All services are registered as lazy singletons to ensure proper
/// initialization and memory management.
///
/// Throws:
/// - Any exception that occurs during service initialization
///
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await setupLocator();
///   runApp(MyApp());
/// }
/// ```
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
  locator.registerLazySingleton(() => ClassificationViewModel(
      repository: locator(), userService: locator()));
  locator.registerLazySingleton(
      () => DiseaseInfoViewModel(repository: locator()));
  locator.registerLazySingleton(
      () => MosquitoGalleryViewModel(repository: locator()));

  // Providers
  locator.registerLazySingleton(() => LocaleProvider(prefs: locator()));
}
