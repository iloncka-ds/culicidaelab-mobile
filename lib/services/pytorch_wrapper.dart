import 'package:culicidaelab/services/pytorch_lite_model.dart';


/// Wrapper class for PyTorch Lite operations.
///
/// This class provides a testable interface around the static methods
/// of PytorchLite, allowing for dependency injection and easier testing.
/// It wraps the core functionality for loading classification models.
///
/// @param pathImageModel The asset path to the PyTorch model file
/// @param imageWidth The expected width for input images
/// @param imageHeight The expected height for input images
/// @param labelPath Optional path to a labels file (.txt or .csv format)
/// @return A Future that completes with a ClassificationModel instance
class PytorchWrapper {
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
