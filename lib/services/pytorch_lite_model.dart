import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pytorch_lite/pigeon.dart';
import 'dart:math' as math;

const TORCHVISION_NORM_MEAN_RGB = [0.485, 0.456, 0.406];
const TORCHVISION_NORM_STD_RGB = [0.229, 0.224, 0.225];

/// Utility class for loading and using PyTorch Lite models.
///
/// Provides static methods for loading classification and object detection models,
/// as well as helper functions for processing model outputs and loading labels.
/// This class serves as a bridge between the Flutter app and the native PyTorch implementation.

  /// Loads a classification model from the specified asset path.
  ///
  /// Creates a ClassificationModel instance with the loaded PyTorch model
  /// and optional label mappings for prediction results.
  ///
  /// @param path The asset path to the PyTorch model file
  /// @param imageWidth The expected width for input images
  /// @param imageHeight The expected height for input images
  /// @param labelPath Optional path to a labels file (.txt or .csv format)
  /// @return A Future that completes with a ClassificationModel instance
class PytorchLite {

  ///Sets pytorch model path and returns Model
  static Future<ClassificationModel> loadClassificationModel(
      String path, int imageWidth, int imageHeight,
      {String? labelPath}) async {
    String absPathModelPath = await _getAbsolutePath(path);
    int index = await ModelApi()
        .loadModel(absPathModelPath, null, imageWidth, imageHeight, 0);
    List<String> labels = [];
    if (labelPath != null) {
      if (labelPath.endsWith(".txt")) {
        labels = await _getLabelsTxt(labelPath);
      } else {
        labels = await _getLabelsCsv(labelPath);
      }
    }

    return ClassificationModel(index, labels);
  }

  /// Loads an object detection model from the specified asset path.
  ///
  /// Creates a ModelObjectDetection instance with the loaded PyTorch model,
  /// configured dimensions, and optional label mappings.
  ///
  /// @param path The asset path to the PyTorch model file
  /// @param numberOfClasses The number of classes the model can detect
  /// @param imageWidth The expected width for input images
  /// @param imageHeight The expected height for input images
  /// @param labelPath Optional path to a labels file (.txt or .csv format)
  /// @return A Future that completes with a ModelObjectDetection instance
  static Future<ModelObjectDetection> loadObjectDetectionModel(
      String path, int numberOfClasses, int imageWidth, int imageHeight,
      {String? labelPath}) async {
    String absPathModelPath = await _getAbsolutePath(path);

    int index = await ModelApi()
        .loadModel(absPathModelPath, numberOfClasses, imageWidth, imageHeight, 0);
    List<String> labels = [];
    if (labelPath != null) {
      if (labelPath.endsWith(".txt")) {
        labels = await _getLabelsTxt(labelPath);
      } else {
        labels = await _getLabelsCsv(labelPath);
      }
    }
    return ModelObjectDetection(index, imageWidth, imageHeight, labels);
  }

  /// Copies an asset file to the device's documents directory.
  ///
  /// Creates necessary subdirectories and returns the absolute path
  /// to the copied file for use with native code.
  ///
  /// @param path The asset path to copy
  /// @return A Future that completes with the absolute file path
static Future<String> _getAbsolutePath(String path) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String dirPath = join(dir.path, path);
    ByteData data = await rootBundle.load(path);
    //copy asset to documents directory
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    //create non existant directories
    List split = path.split("/");
    String nextDir = "";
    for (int i = 0; i < split.length; i++) {
      if (i != split.length - 1) {
        nextDir += split[i];
        await Directory(join(dir.path, nextDir)).create();
        nextDir += "/";
      }
    }
    await File(dirPath).writeAsBytes(bytes);

    return dirPath;
  }
}

/// Parses labels from a CSV format string.
///
/// Labels are expected to be separated by commas.
///
/// @param labelPath The path to the CSV labels file
/// @return A Future that completes with a list of label strings
Future<List<String>> _getLabelsCsv(String labelPath) async {
  String labelsData = await rootBundle.loadString(labelPath);
  return labelsData.split(",");
}

/// Parses labels from a text format file.
///
/// Each line in the file represents a single label.
///
/// @param labelPath The path to the text labels file
/// @return A Future that completes with a list of label strings
Future<List<String>> _getLabelsTxt(String labelPath) async {
  String labelsData = await rootBundle.loadString(labelPath);
  return labelsData.split("\n");
}


/// Model wrapper for PyTorch classification tasks.
///
/// Provides methods for running image classification predictions
/// with various output formats including labels, probabilities,
/// and raw prediction scores.
class ClassificationModel {
  final int _index;
  final List<String> labels;
  ClassificationModel(this._index, this.labels);

  /// Runs image classification and returns the predicted label.
  ///
  /// Processes the image through the model and returns the label
  /// with the highest confidence score.
  ///
  /// @param imageAsBytes The raw image bytes
  /// @param mean Optional normalization mean values (default: ImageNet means)
  /// @param std Optional normalization std values (default: ImageNet stds)
  /// @return A Future that completes with the predicted label string
  Future<String> getImagePrediction(Uint8List imageAsBytes,
      {List<double> mean = TORCHVISION_NORM_MEAN_RGB,
      List<double> std = TORCHVISION_NORM_STD_RGB}) async {
    // Assert mean std
    assert(mean.length == 3, "mean should have size of 3");
    assert(std.length == 3, "std should have size of 3");

    final List<double?> prediction = await ModelApi().getImagePredictionList(
        _index, imageAsBytes, null, null, null, mean, std);

    double maxScore = double.negativeInfinity;
    int maxScoreIndex = -1;
    for (int i = 0; i < prediction.length; i++) {
      if (prediction[i]! > maxScore) {
        maxScore = prediction[i]!;
        maxScoreIndex = i;
      }
    }

    return labels[maxScoreIndex];
  }

  /// Runs image classification and returns label with confidence.
  ///
  /// Processes the image through the model and returns both the predicted
  /// label and its confidence probability.
  ///
  /// @param imageAsBytes The raw image bytes
  /// @param mean Optional normalization mean values (default: ImageNet means)
  /// @param std Optional normalization std values (default: ImageNet stds)
  /// @return A Future that completes with a map containing 'label' and 'probability' keys
Future<Map<String, dynamic>> getImagePredictionResult(Uint8List imageAsBytes,
      {List<double> mean = TORCHVISION_NORM_MEAN_RGB,
      List<double> std = TORCHVISION_NORM_STD_RGB}) async {
    // Assert mean std
    assert(mean.length == 3, "mean should have size of 3");
    assert(std.length == 3, "std should have size of 3");

    final List<double?> prediction = await ModelApi().getImagePredictionList(
        _index, imageAsBytes, null, null, null, mean, std);

    // Get the index of the max score
    int maxScoreIndex = 0;
    for (int i = 1; i < prediction.length; i++) {
      if (prediction[i]! > prediction[maxScoreIndex]!) {
        maxScoreIndex = i;
      }
    }

    //Getting sum of exp
    double sumExp = 0.0;
    for (var element in prediction) {
      sumExp = sumExp + math.exp(element!);
    }

    final predictionProbabilities =
        prediction.map((element) => math.exp(element!) / sumExp).toList();

    return {
      "label": labels[maxScoreIndex],
      "probability": predictionProbabilities[maxScoreIndex]
    };
  }

  /// Runs image classification and returns raw prediction scores with probabilities.
  ///
  /// Returns both the raw prediction scores and their softmax probabilities.
  /// Useful for advanced analysis or custom confidence thresholds.
  ///
  /// @param imageAsBytes The raw image bytes
  /// @param mean Optional normalization mean values (default: ImageNet means)
  /// @param std Optional normalization std values (default: ImageNet stds)
  /// @return A Future that completes with a map containing 'predList' and 'predListProba' keys
  Future<Map<String, List<double?>>> getImagePredictionListAndProbs(
      Uint8List imageAsBytes,
      {List<double> mean = TORCHVISION_NORM_MEAN_RGB,
      List<double> std = TORCHVISION_NORM_STD_RGB}) async {
    // Assert mean std
    assert(mean.length == 3, "Mean should have size of 3");
    assert(std.length == 3, "STD should have size of 3");
    final List<double?> prediction = await ModelApi().getImagePredictionList(
        _index, imageAsBytes, null, null, null, mean, std);

    List<double?>? predictionProbabilities = [];

    //Getting sum of exp
    double? sumExp;
    for (var element in prediction) {
      if (sumExp == null) {
        sumExp = exp(element!);
      } else {
        sumExp = sumExp + exp(element!);
      }
    }
    for (var element in prediction) {
      predictionProbabilities.add(exp(element!) / sumExp!);
    }

    Map<String, List<double?>> result = {
      'predList': prediction,
      'predListProba': predictionProbabilities,
    };

    return result;
  }

  /// Runs image classification and returns raw prediction scores.
  ///
  /// Returns the raw output scores from the neural network before
  /// applying softmax or argmax operations.
  ///
  /// @param imageAsBytes The raw image bytes
  /// @param mean Optional normalization mean values (default: ImageNet means)
  /// @param std Optional normalization std values (default: ImageNet stds)
  /// @return A Future that completes with a list of raw prediction scores
  Future<List<double?>?> getImagePredictionList(Uint8List imageAsBytes,
      {List<double> mean = TORCHVISION_NORM_MEAN_RGB,
      List<double> std = TORCHVISION_NORM_STD_RGB}) async {
    // Assert mean std
    assert(mean.length == 3, "Mean should have size of 3");
    assert(std.length == 3, "STD should have size of 3");
    final List<double?> prediction = await ModelApi().getImagePredictionList(
        _index, imageAsBytes, null, null, null, mean, std);
    return prediction;
  }

  /// Runs image classification and returns softmax probabilities.
  ///
  /// Returns the prediction scores converted to probabilities using softmax.
  /// All probabilities sum to 1.0.
  ///
  /// @param imageAsBytes The raw image bytes
  /// @param mean Optional normalization mean values (default: ImageNet means)
  /// @param std Optional normalization std values (default: ImageNet stds)
  /// @return A Future that completes with a list of prediction probabilities
  Future<List<double?>?> getImagePredictionListProbabilities(
      Uint8List imageAsBytes,
      {List<double> mean = TORCHVISION_NORM_MEAN_RGB,
      List<double> std = TORCHVISION_NORM_STD_RGB}) async {
    // Assert mean std
    assert(mean.length == 3, "Mean should have size of 3");
    assert(std.length == 3, "STD should have size of 3");
    List<double?>? prediction = await ModelApi().getImagePredictionList(
        _index, imageAsBytes, null, null, null, mean, std);
    List<double?>? predictionProbabilities = [];

    //Getting sum of exp
    double? sumExp;
    for (var element in prediction) {
      if (sumExp == null) {
        sumExp = exp(element!);
      } else {
        sumExp = sumExp + exp(element!);
      }
    }
    for (var element in prediction) {
      predictionProbabilities.add(exp(element!) / sumExp!);
    }

    return predictionProbabilities;
  }

  /// Runs batch image classification and returns predicted labels.
  ///
  /// Processes multiple images in a single batch for improved performance.
  /// Returns the label with the highest confidence for each image.
  ///
  /// @param imageAsBytesList List of raw image bytes
  /// @param imageWidth The width to resize images to
  /// @param imageHeight The height to resize images to
  /// @param mean Optional normalization mean values (default: ImageNet means)
  /// @param std Optional normalization std values (default: ImageNet stds)
  /// @return A Future that completes with the predicted label string
  Future<String> getImagePredictionFromBytesList(
      List<Uint8List> imageAsBytesList, int imageWidth, int imageHeight,
      {List<double> mean = TORCHVISION_NORM_MEAN_RGB,
      List<double> std = TORCHVISION_NORM_STD_RGB}) async {
    // Assert mean std
    assert(mean.length == 3, "mean should have size of 3");
    assert(std.length == 3, "std should have size of 3");

    final List<double?> prediction = await ModelApi().getImagePredictionList(
        _index, null, imageAsBytesList, imageWidth, imageHeight, mean, std);

    double maxScore = double.negativeInfinity;
    int maxScoreIndex = -1;
    for (int i = 0; i < prediction.length; i++) {
      if (prediction[i]! > maxScore) {
        maxScore = prediction[i]!;
        maxScoreIndex = i;
      }
    }

    return labels[maxScoreIndex];
  }

  /// Runs batch image classification and returns raw prediction scores.
  ///
  /// Processes multiple images in a single batch and returns raw scores.
  /// Useful for custom post-processing or ensemble methods.
  ///
  /// @param imageAsBytesList List of raw image bytes
  /// @param imageWidth The width to resize images to
  /// @param imageHeight The height to resize images to
  /// @param mean Optional normalization mean values (default: ImageNet means)
  /// @param std Optional normalization std values (default: ImageNet stds)
  /// @return A Future that completes with a list of raw prediction scores
  Future<List<double?>?> getImagePredictionListFromBytesList(
      List<Uint8List> imageAsBytesList, int imageWidth, int imageHeight,
      {List<double> mean = TORCHVISION_NORM_MEAN_RGB,
      List<double> std = TORCHVISION_NORM_STD_RGB}) async {
    // Assert mean std
    assert(mean.length == 3, "Mean should have size of 3");
    assert(std.length == 3, "STD should have size of 3");
    final List<double?> prediction = await ModelApi().getImagePredictionList(
        _index, null, imageAsBytesList, imageWidth, imageHeight, mean, std);
    return prediction;
  }

  /// Runs batch image classification and returns softmax probabilities.
  ///
  /// Processes multiple images in a single batch and returns probability
  /// distributions. All probabilities for each image sum to 1.0.
  ///
  /// @param imageAsBytesList List of raw image bytes
  /// @param imageWidth The width to resize images to
  /// @param imageHeight The height to resize images to
  /// @param mean Optional normalization mean values (default: ImageNet means)
  /// @param std Optional normalization std values (default: ImageNet stds)
  /// @return A Future that completes with a list of prediction probabilities
  Future<List<double?>?> getImagePredictionListProbabilitiesFromBytesList(
      List<Uint8List> imageAsBytesList, int imageWidth, int imageHeight,
      {List<double> mean = TORCHVISION_NORM_MEAN_RGB,
      List<double> std = TORCHVISION_NORM_STD_RGB}) async {
    // Assert mean std
    assert(mean.length == 3, "Mean should have size of 3");
    assert(std.length == 3, "STD should have size of 3");
    List<double?>? prediction = await ModelApi().getImagePredictionList(
        _index, null, imageAsBytesList, imageWidth, imageHeight, mean, std);
    List<double?>? predictionProbabilities = [];

    //Getting sum of exp
    double? sumExp;
    for (var element in prediction) {
      if (sumExp == null) {
        sumExp = exp(element!);
      } else {
        sumExp = sumExp + exp(element!);
      }
    }
    for (var element in prediction) {
      predictionProbabilities.add(exp(element!) / sumExp!);
    }

    return predictionProbabilities;
  }
}

/// Model wrapper for PyTorch object detection tasks.
///
/// Provides methods for running object detection predictions
/// with configurable confidence thresholds and result filtering.
/// Also includes functionality to render detection results on images.
class ModelObjectDetection {
  final int _index;
  final int imageWidth;
  final int imageHeight;
  final List<String> labels;

  ModelObjectDetection(
      this._index, this.imageWidth, this.imageHeight, this.labels);

  /// Runs object detection and returns filtered results.
  ///
  /// Processes the image through the model and returns detections
  /// that meet the specified confidence and overlap thresholds.
  ///
  /// @param imageAsBytes The raw image bytes
  /// @param minimumScore Minimum confidence score for detections (0.0-1.0)
  /// @param IOUThershold Maximum overlap allowed between detections
  /// @param boxesLimit Maximum number of detections to return
  /// @return A Future that completes with a list of detection results
Future<List<ResultObjectDetection?>> getImagePrediction(
      Uint8List imageAsBytes,
      {double minimumScore = 0.5,
      double IOUThershold = 0.5,
      int boxesLimit = 10}) async {
    List<ResultObjectDetection?> prediction = await ModelApi()
        .getImagePredictionListObjectDetection(_index, imageAsBytes, null, null,
            null, minimumScore, IOUThershold, boxesLimit);

    for (var element in prediction) {
      element?.className = labels[element.classIndex];
    }

    return prediction;
  }

  /// Runs batch object detection and returns filtered results.
  ///
  /// Processes multiple images in a single batch for improved performance.
  /// Returns detections that meet the specified confidence thresholds.
  ///
  /// @param imageAsBytesList List of raw image bytes
  /// @param imageWidth The width to resize images to
  /// @param imageHeight The height to resize images to
  /// @param minimumScore Minimum confidence score for detections (0.0-1.0)
  /// @param IOUThershold Maximum overlap allowed between detections
  /// @param boxesLimit Maximum number of detections to return
  /// @return A Future that completes with a list of detection results
  Future<List<ResultObjectDetection?>> getImagePredictionFromBytesList(
      List<Uint8List> imageAsBytesList, int imageWidth, int imageHeight,
      {double minimumScore = 0.5,
      double IOUThershold = 0.5,
      int boxesLimit = 10}) async {
    List<ResultObjectDetection?> prediction = await ModelApi()
        .getImagePredictionListObjectDetection(_index, null, imageAsBytesList,
            imageWidth, imageHeight, minimumScore, IOUThershold, boxesLimit);

    for (var element in prediction) {
      element?.className = labels[element.classIndex];
    }

    return prediction;
  }

  /// Runs object detection and returns raw results.
  ///
  /// Returns all raw detection results without filtering.
  /// Useful for custom post-processing or different threshold requirements.
  ///
  /// @param imageAsBytes The raw image bytes
  /// @param minimumScore Minimum confidence score for detections (0.0-1.0)
  /// @param IOUThershold Maximum overlap allowed between detections
  /// @param boxesLimit Maximum number of detections to return
  /// @return A Future that completes with a list of raw detection results
  Future<List<ResultObjectDetection?>> getImagePredictionList(
      Uint8List imageAsBytes,
      {double minimumScore = 0.5,
      double IOUThershold = 0.5,
      int boxesLimit = 10}) async {
    final List<ResultObjectDetection?> prediction = await ModelApi()
        .getImagePredictionListObjectDetection(_index, imageAsBytes, null, null,
            null, minimumScore, IOUThershold, boxesLimit);
    return prediction;
  }

  /// Runs batch object detection and returns raw results.
  ///
  /// Processes multiple images and returns all raw detection results.
  /// Useful for custom filtering or when batch processing is needed.
  ///
  /// @param imageAsBytesList List of raw image bytes
  /// @param imageWidth The width to resize images to
  /// @param imageHeight The height to resize images to
  /// @param minimumScore Minimum confidence score for detections (0.0-1.0)
  /// @param IOUThershold Maximum overlap allowed between detections
  /// @param boxesLimit Maximum number of detections to return
  /// @return A Future that completes with a list of raw detection results
    Future<List<ResultObjectDetection?>> getImagePredictionListFromBytesList(
      List<Uint8List> imageAsBytesList, int imageWidth, int imageHeight,
      {double minimumScore = 0.5,
      double IOUThershold = 0.5,
      int boxesLimit = 10}) async {
    final List<ResultObjectDetection?> prediction = await ModelApi()
        .getImagePredictionListObjectDetection(_index, null, imageAsBytesList,
            imageWidth, imageHeight, minimumScore, IOUThershold, boxesLimit);
    return prediction;
  }

  /// Renders object detection results as an overlay on the original image.
  ///
  /// Creates a Flutter widget that displays the original image with
  /// bounding boxes and labels overlaid on detected objects.
  ///
  /// @param image The original image file
  /// @param recognitions List of detection results to display
  /// @param boxesColor Optional color for bounding boxes
  /// @param showPercentage Whether to show confidence percentages
  /// @return A widget displaying the image with detection overlays
  Widget renderBoxesOnImage(
      File image, List<ResultObjectDetection?> recognitions,
      {Color? boxesColor, bool showPercentage = true}) {

    print(recognitions.length);
    return LayoutBuilder(builder: (context, constraints) {
      debugPrint(
          'Max height: ${constraints.maxHeight}, max width: ${constraints.maxWidth}');
      double factorX = constraints.maxWidth;
      double factorY = constraints.maxHeight;
      return Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: factorX,
            height: factorY,
            child: Container(
                child: Image.file(
              image,
              fit: BoxFit.fill,
            )),
          ),
          ...recognitions.map((re) {
            if (re == null) {
              return Container();
            }
            Color usedColor;
            if (boxesColor == null) {
              //change colors for each label
              usedColor = Colors.primaries[
                  ((re.className ?? re.classIndex.toString()).length +
                          (re.className ?? re.classIndex.toString())
                              .codeUnitAt(0) +
                          re.classIndex) %
                      Colors.primaries.length];
            } else {
              usedColor = boxesColor;
            }

            print({
              "left": re.rect.left.toDouble() * factorX,
              "top": re.rect.top.toDouble() * factorY,
              "width": re.rect.width.toDouble() * factorX,
              "height": re.rect.height.toDouble() * factorY,
            });
            return Positioned(
              left: re.rect.left * factorX,
              top: re.rect.top * factorY - 20,

              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    alignment: Alignment.centerRight,
                    color: usedColor,
                    child: Text(
                      "${re.className ?? re.classIndex.toString()}_${showPercentage
                              ? "${(re.score * 100).toStringAsFixed(2)}%"
                              : ""}",
                    ),
                  ),
                  Container(
                    width: re.rect.width.toDouble() * factorX,
                    height: re.rect.height.toDouble() * factorY,
                    decoration: BoxDecoration(
                        border: Border.all(color: usedColor, width: 3),
                        borderRadius: const BorderRadius.all(Radius.circular(2))),
                    child: Container(),
                  ),
                ],
              ),

            );
          })
        ],
      );
    });
  }

}