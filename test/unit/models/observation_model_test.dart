import 'package:flutter_test/flutter_test.dart';
import 'package:culicidaelab/models/observation_model.dart';

void main() {
  group('Location', () {
    test('fromJson should correctly parse a map', () {
      final json = {'lat': 10.0, 'lng': 20.0};
      final location = Location.fromJson(json);

      expect(location.lat, 10.0);
      expect(location.lng, 20.0);
    });

    test('toJson should correctly encode the object', () {
      final location = Location(lat: 10.0, lng: 20.0);
      final json = location.toJson();

      expect(json, {'lat': 10.0, 'lng': 20.0});
    });
  });

  group('Observation', () {
    final observationJson = {
      'id': 'obs1',
      'species_scientific_name': 'Aedes aegypti',
      'count': 1,
      'location': {'lat': 10.0, 'lng': 20.0},
      'observed_at': '2023-01-01T12:00:00.000Z',
      'notes': 'Test note',
      'user_id': 'user1',
      'location_accuracy_m': 10,
      'data_source': 'test',
      'image_filename': 'image.jpg',
      'model_id': 'model1',
      'confidence': 0.9,
      'metadata': {'key': 'value'}
    };

    test('fromJson should correctly parse a map', () {
      final observation = Observation.fromJson(observationJson);

      expect(observation.id, 'obs1');
      expect(observation.speciesScientificName, 'Aedes aegypti');
      expect(observation.count, 1);
      expect(observation.location.lat, 10.0);
      expect(observation.location.lng, 20.0);
      expect(observation.observedAt, DateTime.parse('2023-01-01T12:00:00.000Z'));
      expect(observation.notes, 'Test note');
      expect(observation.userId, 'user1');
      expect(observation.locationAccuracyM, 10);
      expect(observation.dataSource, 'test');
      expect(observation.imageFilename, 'image.jpg');
      expect(observation.modelId, 'model1');
      expect(observation.confidence, 0.9);
      expect(observation.metadata, {'key': 'value'});
    });

    test('fromJsonString should correctly parse a JSON string', () {
      final jsonString = '''
      {
        "id": "obs1",
        "species_scientific_name": "Aedes aegypti",
        "count": 1,
        "location": {"lat": 10.0, "lng": 20.0},
        "observed_at": "2023-01-01T12:00:00.000Z",
        "notes": "Test note",
        "user_id": "user1",
        "location_accuracy_m": 10,
        "data_source": "test",
        "image_filename": "image.jpg",
        "model_id": "model1",
        "confidence": 0.9,
        "metadata": {"key": "value"}
      }
      ''';
      final observation = Observation.fromJsonString(jsonString);

      expect(observation.id, 'obs1');
    });
  });
}
