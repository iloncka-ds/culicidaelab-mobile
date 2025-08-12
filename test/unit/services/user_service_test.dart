import 'package:culicidaelab/services/user_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late UserService userService;

  setUp(() {
    userService = UserService();
    SharedPreferences.setMockInitialValues({});
  });

  group('UserService', () {
    test('getUserId should return a new user id if one does not exist',
        () async {
      final userId = await userService.getUserId();
      expect(userId, isA<String>());
      expect(userId, isNotEmpty);
    });

    test('getUserId should return the existing user id if one exists',
        () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', 'test_user_id');

      final userId = await userService.getUserId();
      expect(userId, 'test_user_id');
    });
  });
}
