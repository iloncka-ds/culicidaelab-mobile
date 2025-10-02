import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
/// Service for managing user-specific data and preferences.
///
/// This service handles user identification and persistent storage
/// of user-specific settings using SharedPreferences. It ensures
/// each device has a unique, persistent user identifier.
class UserService {
  /// SharedPreferences instance for persistent storage.
  final SharedPreferences _prefs;

  /// UUID generator for creating unique user identifiers.
  final Uuid _uuid;

  /// Private key constant for storing the user ID.
  static const _userIdKey = 'user_id';

  /// Creates a new user service with required dependencies.
  ///
  /// @param prefs The SharedPreferences instance for data persistence
  /// @param uuid The UUID generator for creating unique identifiers
  UserService({required SharedPreferences prefs, required Uuid uuid})
      : _prefs = prefs,
        _uuid = uuid;

  /// Gets the unique user ID.
  ///
  /// If a user ID has not been created for this device yet, this method
  /// will generate a new one, save it to persistent storage, and then
  /// return it. On subsequent calls, it will return the existing saved ID.
  Future<String> getUserId() async {
    // Try to get the existing user ID from storage.
    String? userId = _prefs.getString(_userIdKey);

    // If the user ID is not found (null), it's the user's first time.
    if (userId == null) {
      // Generate a new, random, version 4 UUID.
      userId = _uuid.v4();

      // Save the new ID to the device's persistent storage.
      await _prefs.setString(_userIdKey, userId);
      print('New user ID generated and saved: $userId');
    } else {
      print('Existing user ID retrieved: $userId');
    }

    return userId;
  }
}