import 'package:culicidaelab/services/pytorch_lite_model.dart';

// This class wraps the static methods of PytorchLite to make them testable.
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
