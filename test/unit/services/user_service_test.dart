import 'package:culicidaelab/services/user_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:culicidaelab/locator.dart';


import 'user_service_test.mocks.dart';

@GenerateMocks([SharedPreferences, Uuid])
void main() {
  late UserService userService;
  late MockSharedPreferences mockSharedPreferences;
  late MockUuid mockUuid;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockUuid = MockUuid();
    locator.registerSingleton<SharedPreferences>(mockSharedPreferences);
    locator.registerSingleton<Uuid>(mockUuid);
    userService = UserService(prefs: locator(), uuid: locator());
  });

  tearDown(() {
    locator.unregister<SharedPreferences>();
    locator.unregister<Uuid>();

  });

  group('UserService', () {
    test('getUserId should return a new user id if one does not exist',
        () async {

      when(mockSharedPreferences.getString(any)).thenReturn(null);
      when(mockUuid.v4()).thenReturn('new_uuid');
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);

      final userId = await userService.getUserId();

      expect(userId, 'new_uuid');
      verify(mockSharedPreferences.setString('user_id', 'new_uuid')).called(1);

    });

    test('getUserId should return the existing user id if one exists',
        () async {

      when(mockSharedPreferences.getString(any)).thenReturn('existing_uuid');

      final userId = await userService.getUserId();

      expect(userId, 'existing_uuid');
      verifyNever(mockSharedPreferences.setString(any, any));

    });
  });
}
