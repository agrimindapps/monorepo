import 'package:dartz/dartz.dart';
import 'package:core/core.dart' hide Column;

import '../entities/app_settings.dart';

/// Repository interface for settings operations
/// Follows Repository Pattern from Clean Architecture
abstract class SettingsRepository {
  /// Get current app settings
  Future<Either<Failure, AppSettings>> getSettings();

  /// Update theme mode (dark/light)
  Future<Either<Failure, Unit>> updateTheme(bool isDarkMode);

  /// Update TTS settings
  Future<Either<Failure, Unit>> updateTTSSettings({
    double? speed,
    double? pitch,
    double? volume,
    String? language,
  });

  /// Save complete settings
  Future<Either<Failure, Unit>> saveSettings(AppSettings settings);
}
