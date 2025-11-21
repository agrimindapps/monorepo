import 'dart:io';

import 'package:core/core.dart';

import '../../domain/entities/tts_settings_entity.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/repositories/i_settings_composite_repository.dart';
import '../../domain/repositories/i_tts_settings_repository.dart';
import '../../domain/repositories/i_user_settings_repository.dart';
import '../../domain/repositories/profile_repository.dart';

/// Composite repository implementation that provides unified access to all settings.
/// Delegates to specialized repositories following the Composite Pattern.
@LazySingleton(as: ISettingsCompositeRepository)
class SettingsCompositeRepositoryImpl implements ISettingsCompositeRepository {
  final IUserSettingsRepository _userSettingsRepo;
  final ITTSSettingsRepository _ttsSettingsRepo;
  final ProfileRepository _profileRepo;

  SettingsCompositeRepositoryImpl(
    this._userSettingsRepo,
    this._ttsSettingsRepo,
    this._profileRepo,
  );

  // ============================================================================
  // USER SETTINGS DELEGATION
  // ============================================================================

  @override
  Future<Either<Failure, UserSettingsEntity?>> getUserSettings(
    String userId,
  ) async {
    try {
      final settings = await _userSettingsRepo.getUserSettings(userId);
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure('Failed to get user settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveUserSettings(
    UserSettingsEntity settings,
  ) async {
    try {
      await _userSettingsRepo.saveUserSettings(settings);
      return const Right(unit);
    } catch (e) {
      return Left(
        CacheFailure('Failed to save user settings: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUserSetting(
    String userId,
    String key,
    dynamic value,
  ) async {
    try {
      await _userSettingsRepo.updateSetting(userId, key, value);
      return const Right(unit);
    } catch (e) {
      return Left(
        CacheFailure('Failed to update user setting: ${e.toString()}'),
      );
    }
  }

  // ============================================================================
  // TTS SETTINGS DELEGATION
  // ============================================================================

  @override
  Future<Either<Failure, TTSSettingsEntity>> getTTSSettings(
    String userId,
  ) async {
    return _ttsSettingsRepo.getSettings(userId);
  }

  @override
  Future<Either<Failure, Unit>> saveTTSSettings(
    String userId,
    TTSSettingsEntity settings,
  ) async {
    final result = await _ttsSettingsRepo.saveSettings(userId, settings);
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }

  @override
  Future<Either<Failure, Unit>> resetTTSSettings(String userId) async {
    final result = await _ttsSettingsRepo.resetToDefault(userId);
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }

  // ============================================================================
  // PROFILE OPERATIONS DELEGATION
  // ============================================================================

  @override
  Future<Either<Failure, ProfileImageResult>> uploadProfileImage(
    File imageFile, {
    void Function(double)? onProgress,
  }) async {
    return _profileRepo.uploadProfileImage(imageFile, onProgress: onProgress);
  }

  @override
  Future<Either<Failure, Unit>> deleteProfileImage() async {
    return _profileRepo.deleteProfileImage();
  }

  @override
  String? getCurrentProfileImageUrl() {
    return _profileRepo.getCurrentProfileImageUrl();
  }

  @override
  bool hasProfileImage() {
    return _profileRepo.hasProfileImage();
  }

  // ============================================================================
  // UNIFIED COMPOSITE OPERATIONS
  // ============================================================================

  @override
  Future<Either<Failure, Unit>> resetAllSettings(String userId) async {
    try {
      // Reset user settings
      await _userSettingsRepo.resetToDefault(userId);

      // Reset TTS settings
      final ttsResult = await _ttsSettingsRepo.resetToDefault(userId);
      if (ttsResult.isLeft()) {
        return const Left(
          CacheFailure('Failed to reset TTS settings'),
        );
      }

      // Note: Profile image is not reset as it's not a setting per se
      // User must explicitly delete profile image if needed

      return const Right(unit);
    } catch (e) {
      return Left(
        CacheFailure('Failed to reset all settings: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportAllSettings(
    String userId,
  ) async {
    try {
      final exportData = <String, dynamic>{};

      // Export user settings
      final userSettings = await _userSettingsRepo.exportSettings(userId);
      exportData['userSettings'] = userSettings;

      // Export TTS settings
      final ttsResult = await _ttsSettingsRepo.getSettings(userId);
      ttsResult.fold(
        (failure) => exportData['ttsSettings'] = null,
        (settings) => exportData['ttsSettings'] = settings.toJson(),
      );

      // Export profile info (but not the actual image)
      exportData['profile'] = {
        'hasImage': _profileRepo.hasProfileImage(),
        'imageUrl': _profileRepo.getCurrentProfileImageUrl(),
        'initials': _profileRepo.getUserInitials(),
      };

      // Add metadata
      exportData['metadata'] = {
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'userId': userId,
      };

      return Right(exportData);
    } catch (e) {
      return Left(
        CacheFailure('Failed to export settings: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> importAllSettings(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Validate data structure
      if (!data.containsKey('metadata')) {
        return const Left(
          ValidationFailure('Invalid export data: missing metadata'),
        );
      }

      // Import user settings
      if (data.containsKey('userSettings')) {
        await _userSettingsRepo.importSettings(
          userId,
          data['userSettings'] as Map<String, dynamic>,
        );
      }

      // Import TTS settings
      if (data.containsKey('ttsSettings') && data['ttsSettings'] != null) {
        final ttsSettings = TTSSettingsEntity.fromJson(
          data['ttsSettings'] as Map<String, dynamic>,
        );
        final result = await _ttsSettingsRepo.saveSettings(userId, ttsSettings);
        if (result.isLeft()) {
          return const Left(
            CacheFailure('Failed to import TTS settings'),
          );
        }
      }

      // Note: Profile image cannot be imported from JSON
      // User must upload new image manually

      return const Right(unit);
    } catch (e) {
      return Left(
        CacheFailure('Failed to import settings: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> hasPendingSync(String userId) async {
    try {
      // Check if user settings sync is enabled
      final syncEnabled = await _userSettingsRepo.isSyncEnabled(userId);

      // Check if there are settings to sync
      final userSettings = await _userSettingsRepo.getUserSettings(userId);
      final hasPending = syncEnabled && userSettings != null;

      return Right(hasPending);
    } catch (e) {
      return Left(
        CacheFailure('Failed to check pending sync: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, SettingsSummary>> getSettingsSummary(
    String userId,
  ) async {
    try {
      // Gather settings information
      final userSettings = await _userSettingsRepo.getUserSettings(userId);
      final ttsResult = await _ttsSettingsRepo.getSettings(userId);

      var settingsCount = 0;
      DateTime? lastUpdated;

      if (userSettings != null) {
        settingsCount++;
        lastUpdated = userSettings.lastUpdated;
      }

      ttsResult.fold(
        (_) {},
        (_) {
          settingsCount++;
          // TTS settings don't have lastModified, use user settings timestamp
        },
      );

      final hasProfile = _profileRepo.hasProfileImage();
      if (hasProfile) {
        settingsCount++;
      }

      final summary = SettingsSummary(
        hasUserSettings: userSettings != null,
        hasTTSSettings: ttsResult.isRight(),
        hasProfileImage: hasProfile,
        totalSettingsCount: settingsCount,
        lastUpdated: lastUpdated,
      );

      return Right(summary);
    } catch (e) {
      return Left(
        CacheFailure('Failed to get settings summary: ${e.toString()}'),
      );
    }
  }
}
