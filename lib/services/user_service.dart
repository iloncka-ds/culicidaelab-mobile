import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserService {
  // A private constant for the storage key
  static const _userIdKey = 'user_id';

  // Use the Uuid package to generate unique IDs
  final _uuid = const Uuid();

  /// Gets the unique user ID.
  ///
  /// If a user ID has not been created for this device yet, this method
  /// will generate a new one, save it to persistent storage, and then
  /// return it. On subsequent calls, it will return the existing saved ID.
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    // Try to get the existing user ID from storage.
    String? userId = prefs.getString(_userIdKey);

    // If the user ID is not found (null), it's the user's first time.
    if (userId == null) {
      // Generate a new, random, version 4 UUID.
      userId = _uuid.v4();

      // Save the new ID to the device's persistent storage.
      await prefs.setString(_userIdKey, userId);
      print('New user ID generated and saved: $userId');
    } else {
      print('Existing user ID retrieved: $userId');
    }

    return userId;
  }
}