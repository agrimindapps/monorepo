import 'package:core/core.dart';

import '../entities/tts_settings_entity.dart';
import '../entities/user_settings_entity.dart';

/// Composite repository that provides unified access to all settings repositories.
/// Cross-platform: funciona em Web, Mobile e Desktop
abstract class ISettingsCompositeRepository {
  // ============================================================================
  // USER SETTINGS DELEGATION
  // ============================================================================

  /// Gets current user settings
  Future<Either<Failure, UserSettingsEntity?>> getUserSettings(String userId);

  /// Saves user settings
  Future<Either<Failure, Unit>> saveUserSettings(UserSettingsEntity settings);

  /// Updates specific user setting
  Future<Either<Failure, Unit>> updateUserSetting(
    String userId,
    String key,
    dynamic value,
  );

  // ============================================================================
  // TTS SETTINGS DELEGATION
  // ============================================================================

  /// Get TTS settings for user
  Future<Either<Failure, TTSSettingsEntity>> getTTSSettings(String userId);

  /// Save TTS settings for user
  Future<Either<Failure, Unit>> saveTTSSettings(
    String userId,
    TTSSettingsEntity settings,
  );

  /// Reset TTS settings to default
  Future<Either<Failure, Unit>> resetTTSSettings(String userId);

  // ============================================================================
  // PROFILE OPERATIONS DELEGATION
  // ============================================================================

  /// Upload profile image (Cross-platform)
  Future<Either<Failure, ProfileImageResult>> uploadProfileImage(
    PickedImage image, {
    void Function(double)? onProgress,
  });

  /// Delete profile image
  Future<Either<Failure, Unit>> deleteProfileImage();

  /// Get current profile image URL
  String? getCurrentProfileImageUrl();

  /// Check if user has profile image
  bool hasProfileImage();

  // ============================================================================
  // UNIFIED COMPOSITE OPERATIONS
  // ============================================================================

  /// Resets ALL settings to default (composite operation)
  Future<Either<Failure, Unit>> resetAllSettings(String userId);

  /// Exports ALL settings for backup (composite operation)
  Future<Either<Failure, Map<String, dynamic>>> exportAllSettings(
    String userId,
  );

  /// Imports ALL settings from backup (composite operation)
  Future<Either<Failure, Unit>> importAllSettings(
    String userId,
    Map<String, dynamic> data,
  );

  /// Checks if any settings have pending sync
  Future<Either<Failure, bool>> hasPendingSync(String userId);

  /// Gets summary of all settings (composite operation)
  Future<Either<Failure, SettingsSummary>> getSettingsSummary(String userId);
}

/// Summary of all settings for display purposes
class SettingsSummary {
  final bool hasUserSettings;
  final bool hasTTSSettings;
  final bool hasProfileImage;
  final int totalSettingsCount;
  final DateTime? lastUpdated;

  const SettingsSummary({
    required this.hasUserSettings,
    required this.hasTTSSettings,
    required this.hasProfileImage,
    required this.totalSettingsCount,
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'hasUserSettings': hasUserSettings,
      'hasTTSSettings': hasTTSSettings,
      'hasProfileImage': hasProfileImage,
      'totalSettingsCount': totalSettingsCount,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }
}
