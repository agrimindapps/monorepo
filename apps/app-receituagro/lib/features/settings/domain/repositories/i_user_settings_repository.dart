import '../entities/user_settings_entity.dart';

/// Repository interface for user settings following the Repository pattern.
/// This defines the contract that data layer implementations must follow.
abstract class IUserSettingsRepository {
  /// Gets current user settings
  Future<UserSettingsEntity?> getUserSettings(String userId);

  /// Saves user settings
  Future<void> saveUserSettings(UserSettingsEntity settings);

  /// Updates specific setting
  Future<void> updateSetting(String userId, String key, dynamic value);

  /// Resets settings to default
  Future<void> resetToDefault(String userId);

  /// Exports settings for backup
  Future<Map<String, dynamic>> exportSettings(String userId);

  /// Imports settings from backup
  Future<void> importSettings(String userId, Map<String, dynamic> data);

  /// Deletes user settings (for account deletion)
  Future<void> deleteUserSettings(String userId);

  /// Gets settings synchronization status
  Future<bool> isSyncEnabled(String userId);

  /// Enables/disables settings sync
  Future<void> setSyncEnabled(String userId, bool enabled);
}
