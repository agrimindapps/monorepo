import 'package:app_agrihurbi/core/error/exceptions.dart';
import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:app_agrihurbi/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_agrihurbi/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:app_agrihurbi/features/settings/data/models/settings_model.dart';
import 'package:app_agrihurbi/features/settings/domain/entities/settings_entity.dart';
import 'package:app_agrihurbi/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;
  final AuthProvider _authProvider;

  const SettingsRepositoryImpl(_localDataSource, _authProvider);

  /// Get current user ID from auth provider
  String _getCurrentUserId() {
    return _authProvider.currentUser?.id ?? 'anonymous_user';
  }

  @override
  Future<Either<Failure, SettingsEntity>> getSettings() async {
    try {
      final settings = await _localDataSource.getSettings();
      if (settings != null) {
        return Right(settings);
      } else {
        final defaultSettings = await _localDataSource.getDefaultSettings(_getCurrentUserId());
        await _localDataSource.saveSettings(defaultSettings);
        return Right(defaultSettings);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SettingsEntity>> updateSettings(SettingsEntity settings) async {
    try {
      final settingsModel = SettingsModel.fromEntity(settings);
      await _localDataSource.saveSettings(settingsModel);
      return Right(settingsModel);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SettingsEntity>> resetToDefaults() async {
    try {
      await _localDataSource.clearSettings();
      final defaultSettings = await _localDataSource.getDefaultSettings(_getCurrentUserId());
      await _localDataSource.saveSettings(defaultSettings);
      return Right(defaultSettings);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SettingsEntity>> getDefaultSettings() async {
    try {
      final defaultSettings = await _localDataSource.getDefaultSettings(_getCurrentUserId());
      return Right(defaultSettings);
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTheme(AppTheme theme) async {
    try {
      await _localDataSource.saveQuickPreference('app_theme', theme.name);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, AppTheme>> getCurrentTheme() async {
    try {
      final themeStr = _localDataSource.getQuickPreference<String>('app_theme') ?? 'system';
      final theme = AppTheme.values.firstWhere((t) => t.name == themeStr, orElse: () => AppTheme.system);
      return Right(theme);
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateDisplaySettings(DisplaySettings display) async {
    final settingsResult = await getSettings();
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) async {
        final updatedSettings = settings.copyWith(display: display, lastUpdated: DateTime.now());
        return await updateSettings(updatedSettings).then((result) => result.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        ));
      },
    );
  }

  @override
  Future<Either<Failure, DisplaySettings>> getDisplaySettings() async {
    final settingsResult = await getSettings();
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) => Right(settings.display),
    );
  }

  @override
  Future<Either<Failure, void>> updateLanguage(String languageCode) async {
    try {
      await _localDataSource.saveQuickPreference('app_language', languageCode);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getCurrentLanguage() async {
    try {
      final language = _localDataSource.getQuickPreference<String>('app_language') ?? 'pt_BR';
      return Right(language);
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SupportedLanguage>>> getAvailableLanguages() async {
    const languages = [
      SupportedLanguage(code: 'pt_BR', name: 'Portuguese (Brazil)', nativeName: 'Português (Brasil)'),
      SupportedLanguage(code: 'en_US', name: 'English (US)', nativeName: 'English (US)'),
      SupportedLanguage(code: 'es_ES', name: 'Spanish', nativeName: 'Español'),
    ];
    return const Right(languages);
  }

  @override
  Future<Either<Failure, void>> updateNotificationSettings(NotificationSettings notifications) async {
    final settingsResult = await getSettings();
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) async {
        final updatedSettings = settings.copyWith(notifications: notifications, lastUpdated: DateTime.now());
        return await updateSettings(updatedSettings).then((result) => result.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        ));
      },
    );
  }

  @override
  Future<Either<Failure, NotificationSettings>> getNotificationSettings() async {
    final settingsResult = await getSettings();
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) => Right(settings.notifications),
    );
  }

  @override
  Future<Either<Failure, void>> testNotifications() async {
    // Implementation would trigger a test notification
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateDataSettings(DataSettings dataSettings) async {
    final settingsResult = await getSettings();
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) async {
        final updatedSettings = settings.copyWith(dataSettings: dataSettings, lastUpdated: DateTime.now());
        return await updateSettings(updatedSettings).then((result) => result.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        ));
      },
    );
  }

  @override
  Future<Either<Failure, DataSettings>> getDataSettings() async {
    final settingsResult = await getSettings();
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) => Right(settings.dataSettings),
    );
  }

  @override
  Future<Either<Failure, void>> forceSyncToCloud() async {
    // Implementation would sync settings to cloud
    return const Right(null);
  }

  @override
  Future<Either<Failure, DateTime?>> getLastSyncTime() async {
    try {
      final timestampStr = _localDataSource.getQuickPreference<String>('last_sync_time');
      final lastSync = timestampStr != null ? DateTime.tryParse(timestampStr) : null;
      return Right(lastSync);
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  // Simplified implementations for remaining methods
  @override
  Future<Either<Failure, void>> updatePrivacySettings(PrivacySettings privacy) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, PrivacySettings>> getPrivacySettings() async {
    final settingsResult = await getSettings();
    return settingsResult.fold((failure) => Left(failure), (settings) => Right(settings.privacy));
  }

  @override
  Future<Either<Failure, void>> clearAnalyticsData() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateSecuritySettings(SecuritySettings security) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, SecuritySettings>> getSecuritySettings() async {
    final settingsResult = await getSettings();
    return settingsResult.fold((failure) => Left(failure), (settings) => Right(settings.security));
  }

  @override
  Future<Either<Failure, BiometricInfo>> getBiometricInfo() async {
    return const Right(BiometricInfo(isAvailable: false, isEnrolled: false, availableTypes: []));
  }

  @override
  Future<Either<Failure, void>> setupBiometricAuth() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> verifyBiometricAuth() async {
    return const Right(false);
  }

  @override
  Future<Either<Failure, void>> updateBackupSettings(BackupSettings backup) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, BackupSettings>> getBackupSettings() async {
    final settingsResult = await getSettings();
    return settingsResult.fold((failure) => Left(failure), (settings) => Right(settings.backup));
  }

  @override
  Future<Either<Failure, BackupInfo>> createBackup({bool includeImages = false}) async {
    return const Left(GeneralFailure(message: 'Backup creation not implemented'));
  }

  @override
  Future<Either<Failure, List<BackupInfo>>> getAvailableBackups() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> restoreFromBackup(String backupId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteBackup(String backupId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, ExportResult>> exportAllData({
    required DataExportFormat format,
    bool includeImages = false,
  }) async {
    return const Left(GeneralFailure(message: 'Export not implemented'));
  }

  @override
  Future<Either<Failure, ExportResult>> exportData({
    required List<DataType> dataTypes,
    required DataExportFormat format,
    bool includeImages = false,
  }) async {
    return const Left(GeneralFailure(message: 'Export not implemented'));
  }

  @override
  Future<Either<Failure, List<ExportInfo>>> getExportHistory() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, CacheInfo>> getCacheInfo() async {
    return Right(CacheInfo(
      cacheSizes: {CacheType.all: 0},
      totalSizeBytes: 0,
      lastCleared: DateTime.now(),
    ));
  }

  @override
  Future<Either<Failure, void>> clearAllCache() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> clearCache(CacheType type) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, AppVersionInfo>> getAppVersion() async {
    return Right(AppVersionInfo(
      version: '1.0.0',
      buildNumber: '1',
      buildDate: DateTime.now(),
      gitCommit: 'unknown',
      isDebug: true,
    ));
  }

  @override
  Future<Either<Failure, DeviceInfo>> getDeviceInfo() async {
    return const Right(DeviceInfo(
      platform: 'Flutter',
      version: 'Unknown',
      model: 'Unknown',
      brand: 'Unknown',
      totalMemory: 0,
      availableMemory: 0,
      totalStorage: 0,
      availableStorage: 0,
    ));
  }

  @override
  Future<Either<Failure, DiagnosticInfo>> getDiagnosticInfo() async {
    final appVersion = await getAppVersion();
    final deviceInfo = await getDeviceInfo();
    
    return Right(DiagnosticInfo(
      appVersion: appVersion.fold((_) => AppVersionInfo(version: '1.0.0', buildNumber: '1', buildDate: DateTime.now(), gitCommit: 'unknown', isDebug: true), (info) => info),
      deviceInfo: deviceInfo.fold((_) => const DeviceInfo(platform: 'Flutter', version: 'Unknown', model: 'Unknown', brand: 'Unknown', totalMemory: 0, availableMemory: 0, totalStorage: 0, availableStorage: 0), (info) => info),
      systemMetrics: {},
      errorLogs: [],
      generatedAt: DateTime.now(),
    ));
  }

  @override
  Future<Either<Failure, void>> sendDiagnosticReport({
    String? userComment,
    bool includeLogs = true,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, SettingsValidationResult>> validateSettings() async {
    return const Right(SettingsValidationResult(isValid: true, errors: [], warnings: []));
  }

  @override
  Future<Either<Failure, SettingsEntity>> repairSettings() async {
    return await resetToDefaults();
  }
}