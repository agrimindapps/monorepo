import 'package:core/core.dart';

import '../entities/settings_entity.dart';

/// Repository interface for settings operations
///
/// Follows Repository Pattern and Dependency Inversion Principle
abstract class ISettingsRepository {
  /// Get current settings
  Future<Either<Failure, SettingsEntity>> getSettings();

  /// Save settings
  Future<Either<Failure, Unit>> saveSettings(SettingsEntity settings);

  /// Reset settings to defaults
  Future<Either<Failure, Unit>> resetToDefaults();

  /// Update single setting field
  Future<Either<Failure, Unit>> updateSetting(
    String key,
    dynamic value,
  );
}
