import 'package:flutter_test/flutter_test.dart';
import 'package:culicidaelab/models/web_prediction_result.dart';

void main() {
  group('WebPredictionResult', () {
    final webPredictionJson = {
      'id': 'pred1',
      'scientific_name': 'Aedes aegypti',
      'probabilities': {
        'Aedes aegypti': 0.9,
        'Aedes albopictus': 0.1
      },
      'model_id': 'model1',
      'confidence': 0.9,
      'image_url_species': 'image.jpg'
    };

    test('fromJson should correctly parse a map', () {
      final webPrediction = WebPredictionResult.fromJson(webPredictionJson);

      expect(webPrediction.id, 'pred1');
      expect(webPrediction.scientificName, 'Aedes aegypti');
      expect(webPrediction.probabilities, {
        'Aedes aegypti': 0.9,
        'Aedes albopictus': 0.1
      });
      expect(webPrediction.modelId, 'model1');
      expect(webPrediction.confidence, 0.9);
      expect(webPrediction.imageUrlSpecies, 'image.jpg');
    });

    test('fromJsonString should correctly parse a JSON string', () {
      final jsonString = '''
      {
        "id": "pred1",
        "scientific_name": "Aedes aegypti",
        "probabilities": {
          "Aedes aegypti": 0.9,
          "Aedes albopictus": 0.1
        },
        "model_id": "model1",
        "confidence": 0.9,
        "image_url_species": "image.jpg"
      }
      ''';
      final webPrediction = WebPredictionResult.fromJsonString(jsonString);

      expect(webPrediction.id, 'pred1');
    });
  });
}
