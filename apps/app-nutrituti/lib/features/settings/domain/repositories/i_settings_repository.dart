import '../entities/settings_entity.dart';

/// Interface for Settings Repository
/// Follows Repository Pattern from Clean Architecture
abstract class ISettingsRepository {
  /// Get current settings
  Future<SettingsEntity> getSettings();

  /// Save settings
  Future<void> saveSettings(SettingsEntity settings);

  /// Reset settings to default
  Future<void> resetSettings();

  /// Listen to settings changes (stream)
  Stream<SettingsEntity> watchSettings();
}
