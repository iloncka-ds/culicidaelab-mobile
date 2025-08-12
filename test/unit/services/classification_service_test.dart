import 'dart:io';

import 'package:culicidaelab/services/classification_service.dart';

import 'package:culicidaelab/services/pytorch_lite_model.dart';
import 'package:culicidaelab/services/pytorch_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:culicidaelab/locator.dart';

class MockPytorchWrapper extends Mock implements PytorchWrapper {}

class MockClassificationModel extends Mock implements ClassificationModel {}

@GenerateMocks([PytorchWrapper])
void main() {
  late ClassificationService classificationService;
  late MockPytorchWrapper mockPytorchWrapper;
  late MockClassificationModel mockClassificationModel;

  setUp(() {
    mockPytorchWrapper = MockPytorchWrapper();
    mockClassificationModel = MockClassificationModel();
    locator.registerSingleton<PytorchWrapper>(mockPytorchWrapper);
    classificationService =
        ClassificationService(pytorchWrapper: locator());
  });

  tearDown(() {
    locator.unregister<PytorchWrapper>();
  });

  group('ClassificationService', () {

    test('classifyImage returns a map of results', () async {
      final imageFile = File('test/fixtures/test_image.jpg');
      final prediction = {'label': 'Aedes aegypti', 'probability': 0.98};


      when(mockPytorchWrapper.loadClassificationModel(any, any, any,
              labelPath: anyNamed('labelPath')))
          .thenAnswer((_) async => mockClassificationModel);
      when(mockClassificationModel.getImagePredictionResult(any))
          .thenAnswer((_) async => prediction);

      await classificationService.loadModel();
      final result = await classificationService.classifyImage(imageFile);

      expect(result['scientificName'], 'Aedes aegypti');
      expect(result['confidence'], 0.98);

    });
  });
}
