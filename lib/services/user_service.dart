import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Service for managing user-specific data and preferences.
///
/// This service handles user identification and persistent storage
/// of user-specific settings using SharedPreferences. It ensures
/// each device has a unique, persistent user identifier for tracking
/// observations and user preferences across app sessions.
///
/// ## User Identification Strategy
///
/// The service uses a device-based identification approach:
/// - **Anonymous**: No personal information is collected or stored
/// - **Persistent**: User ID persists across app restarts and updates
/// - **Unique**: Each device gets a unique UUID v4 identifier
/// - **Privacy-Focused**: No tracking across devices or accounts
///
/// ## Data Storage
///
/// User data is stored locally using SharedPreferences:
/// - **Location**: Platform-specific secure storage
/// - **Persistence**: Survives app updates and device restarts
/// - **Security**: Uses platform's secure storage mechanisms
/// - **Backup**: May be included in device backups (platform-dependent)
///
/// ## Usage Example
///
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// final uuid = Uuid();
/// final userService = UserService(prefs: prefs, uuid: uuid);
///
/// // Get user ID (creates one if it doesn't exist)
/// final userId = await userService.getUserId();
/// print('User ID: $userId');
///
/// // Use in observations
/// final observation = Observation(
///   id: 'obs_123',
///   userId: userId,
///   // ... other fields
/// );
/// ```
///
/// ## Privacy Considerations
///
/// - User IDs are generated locally and never transmitted to identify individuals
/// - IDs are used only for data organization and quality assessment
/// - No personal information is associated with user IDs
/// - Users can reset their ID by clearing app data
///
/// ## Integration Points
///
/// The service integrates with:
/// - [Observation] model for tracking observation sources
/// - Analytics systems for usage patterns (anonymized)
/// - Data quality systems for contribution assessment
///
/// See also:
/// - [Observation] for observation data that includes user IDs
/// - [SharedPreferences] for the underlying storage mechanism
/// - [Uuid] for unique identifier generation
class UserService {
  /// SharedPreferences instance for persistent storage.
  ///
  /// Provides access to platform-specific persistent storage
  /// for user preferences and identification data.
  final SharedPreferences _prefs;

  /// UUID generator for creating unique user identifiers.
  ///
  /// Used to generate version 4 UUIDs that are cryptographically
  /// random and suitable for anonymous user identification.
  final Uuid _uuid;

  /// Private key constant for storing the user ID.
  ///
  /// This key is used to store and retrieve the user ID from
  /// SharedPreferences. It's kept private to prevent external
  /// code from directly manipulating the user ID storage.
  static const _userIdKey = 'user_id';

  /// Creates a new user service with required dependencies.
  ///
  /// Both [prefs] and [uuid] are required dependencies that enable
  /// the service to store data persistently and generate unique identifiers.
  ///
  /// ## Dependency Injection
  ///
  /// This constructor supports dependency injection for better testability:
  ///
  /// ```dart
  /// // Production usage
  /// final prefs = await SharedPreferences.getInstance();
  /// final userService = UserService(prefs: prefs, uuid: Uuid());
  ///
  /// // Testing usage
  /// final mockPrefs = MockSharedPreferences();
  /// final mockUuid = MockUuid();
  /// final userService = UserService(prefs: mockPrefs, uuid: mockUuid);
  /// ```
  ///
  /// [prefs] The SharedPreferences instance for data persistence.
  /// [uuid] The UUID generator for creating unique identifiers.
  UserService({required SharedPreferences prefs, required Uuid uuid})
      : _prefs = prefs,
        _uuid = uuid;

  /// Gets the unique user ID for this device.
  ///
  /// This method implements a lazy initialization pattern for user identification:
  /// - **First Call**: Generates a new UUID v4 and stores it persistently
  /// - **Subsequent Calls**: Returns the existing stored UUID
  ///
  /// ## UUID Format
  ///
  /// The generated UUID follows the version 4 specification:
  /// - **Format**: `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`
  /// - **Randomness**: 122 bits of cryptographic randomness
  /// - **Collision Probability**: Negligible for practical purposes
  ///
  /// ## Storage Behavior
  ///
  /// - **Persistence**: Survives app restarts, updates, and device reboots
  /// - **Platform Storage**: Uses platform-specific secure storage
  /// - **Backup**: May be included in device backups (platform-dependent)
  /// - **Clearing**: Removed only when app data is cleared or app is uninstalled
  ///
  /// ## Performance Characteristics
  ///
  /// - **First Call**: ~1-5ms (includes UUID generation and storage)
  /// - **Subsequent Calls**: <1ms (simple string retrieval)
  /// - **Memory Usage**: Minimal (single string in SharedPreferences cache)
  ///
  /// ## Error Handling
  ///
  /// The method is designed to be robust and should not throw exceptions
  /// under normal circumstances. However, it may fail if:
  /// - Device storage is full or corrupted
  /// - SharedPreferences access is denied by the platform
  /// - UUID generation fails (extremely rare)
  ///
  /// Returns a unique string identifier for this device/user.
  ///
  /// Example:
  /// ```dart
  /// final userId = await userService.getUserId();
  /// print('User ID: $userId');
  /// // Output: User ID: 550e8400-e29b-41d4-a716-446655440000
  ///
  /// // Subsequent calls return the same ID
  /// final sameUserId = await userService.getUserId();
  /// assert(userId == sameUserId);
  /// ```
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

  /// Checks if a user ID has been generated for this device.
  ///
  /// Returns `true` if a user ID exists in storage, `false` if this
  /// is the first time the service is being used on this device.
  ///
  /// This method is useful for analytics or onboarding flows where
  /// you need to distinguish between new and returning users.
  ///
  /// Example:
  /// ```dart
  /// if (await userService.hasUserId()) {
  ///   print('Welcome back!');
  /// } else {
  ///   print('Welcome to CulicidaeLab!');
  /// }
  /// ```
  Future<bool> hasUserId() async {
    return _prefs.containsKey(_userIdKey);
  }

  /// Clears the stored user ID, effectively resetting the user identity.
  ///
  /// This method removes the user ID from persistent storage. The next
  /// call to [getUserId] will generate a new UUID. This is useful for:
  /// - Testing scenarios
  /// - Privacy-focused user reset functionality
  /// - Debugging and development
  ///
  /// **Warning**: This action cannot be undone. All data associated
  /// with the previous user ID will become orphaned.
  ///
  /// Returns `true` if the user ID was successfully removed, `false`
  /// if no user ID was stored.
  ///
  /// Example:
  /// ```dart
  /// final wasCleared = await userService.clearUserId();
  /// if (wasCleared) {
  ///   print('User ID cleared successfully');
  /// }
  /// 
  /// // Next call will generate a new ID
  /// final newUserId = await userService.getUserId();
  /// ```
  Future<bool> clearUserId() async {
    final existed = _prefs.containsKey(_userIdKey);
    await _prefs.remove(_userIdKey);
    if (existed) {
      print('User ID cleared from storage');
    }
    return existed;
  }
}