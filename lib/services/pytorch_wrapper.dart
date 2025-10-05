import 'package:culicidaelab/services/pytorch_lite_model.dart';

/// Wrapper class for PyTorch Lite operations.
///
/// This class provides a testable interface around the static methods
/// of [PytorchLite], allowing for dependency injection and easier testing.
/// It wraps the core functionality for loading classification models while
/// maintaining the same API surface.
///
/// ## Purpose
///
/// The wrapper serves several important purposes:
/// - **Testability**: Enables mocking of PyTorch operations in unit tests
/// - **Dependency Injection**: Allows services to depend on an interface rather than static methods
/// - **Future Extensibility**: Provides a place to add logging, error handling, or caching
/// - **API Consistency**: Maintains a consistent interface even if underlying implementation changes
///
/// ## Usage Example
///
/// ```dart
/// final wrapper = PytorchWrapper();
/// final model = await wrapper.loadClassificationModel(
///   'assets/models/mosquito_classifier.pt',
///   224,
///   224,
///   labelPath: 'assets/labels/mosquito_species.txt',
/// );
/// ```
///
/// ## Testing
///
/// For unit tests, this class can be easily mocked:
///
/// ```dart
/// class MockPytorchWrapper extends Mock implements PytorchWrapper {}
///
/// test('classification service loads model', () async {
///   final mockWrapper = MockPytorchWrapper();
///   final mockModel = MockClassificationModel();
///   
///   when(mockWrapper.loadClassificationModel(any, any, any, labelPath: any))
///       .thenAnswer((_) async => mockModel);
///   
///   final service = ClassificationService(pytorchWrapper: mockWrapper);
///   await service.loadModel();
///   
///   expect(service.isModelLoaded, isTrue);
/// });
/// ```
///
/// See also:
/// - [PytorchLite] for the underlying PyTorch Lite implementation
/// - [ClassificationService] which uses this wrapper
/// - [ClassificationModel] for the model interface
class PytorchWrapper {
  /// Loads a classification model from the specified asset path.
  ///
  /// This method wraps [PytorchLite.loadClassificationModel] to provide
  /// a testable interface while maintaining the same functionality.
  ///
  /// ## Parameters
  ///
  /// - [pathImageModel]: The asset path to the PyTorch model file (`.pt` format)
  /// - [imageWidth]: The expected width for input images (typically 224)
  /// - [imageHeight]: The expected height for input images (typically 224)
  /// - [labelPath]: Optional path to a labels file (`.txt` or `.csv` format)
  ///
  /// ## Model Requirements
  ///
  /// The PyTorch model must be:
  /// - Exported using PyTorch's mobile optimization tools
  /// - Compatible with the specified input dimensions
  /// - Trained for classification tasks (outputs class probabilities)
  ///
  /// ## Label File Format
  ///
  /// If provided, the label file should contain:
  /// - **Text format** (`.txt`): One label per line
  /// - **CSV format** (`.csv`): Comma-separated labels
  ///
  /// Example label file content:
  /// ```
  /// Aedes aegypti
  /// Aedes albopictus
  /// Anopheles gambiae
  /// Culex pipiens
  /// ```
  ///
  /// Returns a [ClassificationModel] instance ready for inference.
  ///
  /// Throws [Exception] if:
  /// - The model file is not found in assets
  /// - The model format is invalid or incompatible
  /// - The platform doesn't support PyTorch Lite
  /// - Insufficient memory is available for model loading
  ///
  /// Example:
  /// ```dart
  /// final wrapper = PytorchWrapper();
  /// try {
  ///   final model = await wrapper.loadClassificationModel(
  ///     'assets/models/mosquito_classifier.pt',
  ///     224,
  ///     224,
  ///     labelPath: 'assets/labels/mosquito_species.txt',
  ///   );
  ///   print('Model loaded successfully');
  /// } catch (e) {
  ///   print('Failed to load model: $e');
  /// }
  /// ```
  Future<ClassificationModel> loadClassificationModel(
    String pathImageModel,
    int imageWidth,
    int imageHeight, {
    String? labelPath,
  }) {
    return PytorchLite.loadClassificationModel(
      pathImageModel,
      imageWidth,
      imageHeight,
      labelPath: labelPath,
    );
  }
}
