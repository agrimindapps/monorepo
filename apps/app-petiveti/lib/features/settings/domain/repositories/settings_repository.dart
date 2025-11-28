import 'package:core/core.dart';

import '../entities/app_settings.dart';

/// Repository interface for Settings operations
abstract class SettingsRepository {
  /// Get current settings
  Future<Either<Failure, AppSettings>> getSettings();

  /// Update settings
  Future<Either<Failure, AppSettings>> updateSettings(AppSettings settings);

  /// Reset settings to defaults
  Future<Either<Failure, AppSettings>> resetSettings();
}
