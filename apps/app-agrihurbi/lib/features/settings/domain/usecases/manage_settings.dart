import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/settings/domain/entities/settings_entity.dart';
import 'package:app_agrihurbi/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:core/core.dart' show injectable;

/// Manage Settings Use Case
///
/// Handles all settings management operations
@injectable
class ManageSettings {
  final SettingsRepository _repository;

  const ManageSettings(this._repository);

  /// Get current settings
  ResultFuture<SettingsEntity> getSettings() async {
    return await _repository.getSettings();
  }

  /// Update complete settings
  ResultFuture<SettingsEntity> updateSettings(SettingsEntity settings) async {
    return await _repository.updateSettings(settings);
  }

  /// Reset to default settings
  ResultFuture<SettingsEntity> resetToDefaults() async {
    return await _repository.resetToDefaults();
  }

  /// Get default settings
  ResultFuture<SettingsEntity> getDefaults() async {
    return await _repository.getDefaultSettings();
  }

  /// Export settings to Map for sharing/backup
  ResultFuture<Map<String, dynamic>> exportSettings() async {
    try {
      final settingsResult = await _repository.getSettings();
      return settingsResult.fold((failure) => Left(failure), (settings) {
        final exportData = {
          'version': '1.0',
          'exportedAt': DateTime.now().toIso8601String(),
          'settings': {
            'userId': settings.userId,
            'theme': settings.theme.name,
            'language': settings.language,
            'notifications': {
              'pushNotifications': settings.notifications.pushNotifications,
              'newsNotifications': settings.notifications.newsNotifications,
              'marketAlerts': settings.notifications.marketAlerts,
              'weatherAlerts': settings.notifications.weatherAlerts,
              'animalReminders': settings.notifications.animalReminders,
              'calculatorReminders': settings.notifications.calculatorReminders,
              'quietHoursStart': settings.notifications.quietHoursStart,
              'quietHoursEnd': settings.notifications.quietHoursEnd,
            },
            'dataSettings': {
              'autoSync': settings.dataSettings.autoSync,
              'wifiOnlySync': settings.dataSettings.wifiOnlySync,
              'cacheImages': settings.dataSettings.cacheImages,
              'cacheRetentionDays': settings.dataSettings.cacheRetentionDays,
              'compressBackups': settings.dataSettings.compressBackups,
              'exportFormat': settings.dataSettings.exportFormat.name,
            },
            'privacy': {
              'analyticsEnabled': settings.privacy.analyticsEnabled,
              'crashReportingEnabled': settings.privacy.crashReportingEnabled,
              'shareUsageData': settings.privacy.shareUsageData,
              'personalizedAds': settings.privacy.personalizedAds,
              'locationTracking': settings.privacy.locationTracking,
            },
            'display': {
              'fontSize': settings.display.fontSize,
              'highContrast': settings.display.highContrast,
              'animations': settings.display.animations,
              'showTutorials': settings.display.showTutorials,
              'dateFormat': settings.display.dateFormat,
              'timeFormat': settings.display.timeFormat,
              'currency': settings.display.currency,
              'unitSystem': settings.display.unitSystem,
            },
            'security': {
              'biometricAuth': settings.security.biometricAuth,
              'requireAuthOnOpen': settings.security.requireAuthOnOpen,
              'autoLockMinutes': settings.security.autoLockMinutes,
              'hideDataInRecents': settings.security.hideDataInRecents,
              'encryptBackups': settings.security.encryptBackups,
            },
            'backup': {
              'autoBackup': settings.backup.autoBackup,
              'frequency': settings.backup.frequency.name,
              'includeImages': settings.backup.includeImages,
              'lastBackupDate': settings.backup.lastBackupDate,
              'storage': settings.backup.storage.name,
            },
            'lastUpdated': settings.lastUpdated.toIso8601String(),
          },
        };
        return Right(exportData);
      });
    } catch (e) {
      return Left(
        GeneralFailure(message: 'Erro ao exportar configurações: $e'),
      );
    }
  }

  /// Import settings from Map data
  ResultFuture<SettingsEntity> importSettings(Map<String, dynamic> data) async {
    try {
      // Validate import data structure
      if (!data.containsKey('settings') || !data.containsKey('version')) {
        return const Left(
          GeneralFailure(message: 'Formato de dados inválido para importação'),
        );
      }

      final settingsData = data['settings'] as Map<String, dynamic>;

      // Get current settings as base
      final currentSettingsResult = await _repository.getSettings();
      return currentSettingsResult.fold((failure) => Left(failure), (
        currentSettings,
      ) async {
        try {
          // Parse imported data
          final importedSettings = SettingsEntity(
            userId: settingsData['userId'] as String? ?? currentSettings.userId,
            theme: _parseTheme(settingsData['theme'] as String?),
            language:
                settingsData['language'] as String? ?? currentSettings.language,
            notifications: _parseNotificationSettings(
              settingsData['notifications'] as Map<String, dynamic>?,
              currentSettings.notifications,
            ),
            dataSettings: _parseDataSettings(
              settingsData['dataSettings'] as Map<String, dynamic>?,
              currentSettings.dataSettings,
            ),
            privacy: _parsePrivacySettings(
              settingsData['privacy'] as Map<String, dynamic>?,
              currentSettings.privacy,
            ),
            display: _parseDisplaySettings(
              settingsData['display'] as Map<String, dynamic>?,
              currentSettings.display,
            ),
            security: _parseSecuritySettings(
              settingsData['security'] as Map<String, dynamic>?,
              currentSettings.security,
            ),
            backup: _parseBackupSettings(
              settingsData['backup'] as Map<String, dynamic>?,
              currentSettings.backup,
            ),
            lastUpdated: DateTime.now(),
          );

          // Save imported settings
          return await _repository.updateSettings(importedSettings);
        } catch (e) {
          return Left(
            GeneralFailure(message: 'Erro ao processar dados importados: $e'),
          );
        }
      });
    } catch (e) {
      return Left(
        GeneralFailure(message: 'Erro ao importar configurações: $e'),
      );
    }
  }

  // Helper methods for parsing imported data
  AppTheme _parseTheme(String? themeStr) {
    if (themeStr == null) return AppTheme.system;
    return AppTheme.values.firstWhere(
      (theme) => theme.name == themeStr,
      orElse: () => AppTheme.system,
    );
  }

  NotificationSettings _parseNotificationSettings(
    Map<String, dynamic>? data,
    NotificationSettings fallback,
  ) {
    if (data == null) return fallback;
    return NotificationSettings(
      pushNotifications:
          data['pushNotifications'] as bool? ?? fallback.pushNotifications,
      newsNotifications:
          data['newsNotifications'] as bool? ?? fallback.newsNotifications,
      marketAlerts: data['marketAlerts'] as bool? ?? fallback.marketAlerts,
      weatherAlerts: data['weatherAlerts'] as bool? ?? fallback.weatherAlerts,
      animalReminders:
          data['animalReminders'] as bool? ?? fallback.animalReminders,
      calculatorReminders:
          data['calculatorReminders'] as bool? ?? fallback.calculatorReminders,
      quietHoursStart:
          data['quietHoursStart'] as String? ?? fallback.quietHoursStart,
      quietHoursEnd: data['quietHoursEnd'] as String? ?? fallback.quietHoursEnd,
    );
  }

  DataSettings _parseDataSettings(
    Map<String, dynamic>? data,
    DataSettings fallback,
  ) {
    if (data == null) return fallback;
    return DataSettings(
      autoSync: data['autoSync'] as bool? ?? fallback.autoSync,
      wifiOnlySync: data['wifiOnlySync'] as bool? ?? fallback.wifiOnlySync,
      cacheImages: data['cacheImages'] as bool? ?? fallback.cacheImages,
      cacheRetentionDays:
          data['cacheRetentionDays'] as int? ?? fallback.cacheRetentionDays,
      compressBackups:
          data['compressBackups'] as bool? ?? fallback.compressBackups,
      exportFormat: _parseExportFormat(data['exportFormat'] as String?),
    );
  }

  DataExportFormat _parseExportFormat(String? formatStr) {
    if (formatStr == null) return DataExportFormat.json;
    return DataExportFormat.values.firstWhere(
      (format) => format.name == formatStr,
      orElse: () => DataExportFormat.json,
    );
  }

  PrivacySettings _parsePrivacySettings(
    Map<String, dynamic>? data,
    PrivacySettings fallback,
  ) {
    if (data == null) return fallback;
    return PrivacySettings(
      analyticsEnabled:
          data['analyticsEnabled'] as bool? ?? fallback.analyticsEnabled,
      crashReportingEnabled:
          data['crashReportingEnabled'] as bool? ??
          fallback.crashReportingEnabled,
      shareUsageData:
          data['shareUsageData'] as bool? ?? fallback.shareUsageData,
      personalizedAds:
          data['personalizedAds'] as bool? ?? fallback.personalizedAds,
      locationTracking:
          data['locationTracking'] as bool? ?? fallback.locationTracking,
    );
  }

  DisplaySettings _parseDisplaySettings(
    Map<String, dynamic>? data,
    DisplaySettings fallback,
  ) {
    if (data == null) return fallback;
    return DisplaySettings(
      fontSize: (data['fontSize'] as num?)?.toDouble() ?? fallback.fontSize,
      highContrast: data['highContrast'] as bool? ?? fallback.highContrast,
      animations: data['animations'] as bool? ?? fallback.animations,
      showTutorials: data['showTutorials'] as bool? ?? fallback.showTutorials,
      dateFormat: data['dateFormat'] as String? ?? fallback.dateFormat,
      timeFormat: data['timeFormat'] as String? ?? fallback.timeFormat,
      currency: data['currency'] as String? ?? fallback.currency,
      unitSystem: data['unitSystem'] as String? ?? fallback.unitSystem,
    );
  }

  SecuritySettings _parseSecuritySettings(
    Map<String, dynamic>? data,
    SecuritySettings fallback,
  ) {
    if (data == null) return fallback;
    return SecuritySettings(
      biometricAuth: data['biometricAuth'] as bool? ?? fallback.biometricAuth,
      requireAuthOnOpen:
          data['requireAuthOnOpen'] as bool? ?? fallback.requireAuthOnOpen,
      autoLockMinutes:
          data['autoLockMinutes'] as int? ?? fallback.autoLockMinutes,
      hideDataInRecents:
          data['hideDataInRecents'] as bool? ?? fallback.hideDataInRecents,
      encryptBackups:
          data['encryptBackups'] as bool? ?? fallback.encryptBackups,
    );
  }

  BackupSettings _parseBackupSettings(
    Map<String, dynamic>? data,
    BackupSettings fallback,
  ) {
    if (data == null) return fallback;
    return BackupSettings(
      autoBackup: data['autoBackup'] as bool? ?? fallback.autoBackup,
      frequency: _parseBackupFrequency(data['frequency'] as String?),
      includeImages: data['includeImages'] as bool? ?? fallback.includeImages,
      lastBackupDate:
          data['lastBackupDate'] as String? ?? fallback.lastBackupDate,
      storage: _parseBackupStorage(data['storage'] as String?),
    );
  }

  BackupFrequency _parseBackupFrequency(String? frequencyStr) {
    if (frequencyStr == null) return BackupFrequency.weekly;
    return BackupFrequency.values.firstWhere(
      (frequency) => frequency.name == frequencyStr,
      orElse: () => BackupFrequency.weekly,
    );
  }

  BackupStorage _parseBackupStorage(String? storageStr) {
    if (storageStr == null) return BackupStorage.cloud;
    return BackupStorage.values.firstWhere(
      (storage) => storage.name == storageStr,
      orElse: () => BackupStorage.cloud,
    );
  }
}

/// Manage Theme Settings Use Case
@injectable
class ManageThemeSettings {
  final SettingsRepository _repository;

  const ManageThemeSettings(this._repository);

  /// Update app theme
  ResultVoid updateTheme(AppTheme theme) async {
    return await _repository.updateTheme(theme);
  }

  /// Get current theme
  ResultFuture<AppTheme> getCurrentTheme() async {
    return await _repository.getCurrentTheme();
  }

  /// Update display settings
  ResultVoid updateDisplaySettings(DisplaySettings display) async {
    return await _repository.updateDisplaySettings(display);
  }

  /// Get display settings
  ResultFuture<DisplaySettings> getDisplaySettings() async {
    return await _repository.getDisplaySettings();
  }
}

/// Manage Language Settings Use Case
@injectable
class ManageLanguageSettings {
  final SettingsRepository _repository;

  const ManageLanguageSettings(this._repository);

  /// Update app language
  ResultVoid updateLanguage(String languageCode) async {
    return await _repository.updateLanguage(languageCode);
  }

  /// Get current language
  ResultFuture<String> getCurrentLanguage() async {
    return await _repository.getCurrentLanguage();
  }

  /// Get available languages
  ResultFuture<List<SupportedLanguage>> getAvailableLanguages() async {
    return await _repository.getAvailableLanguages();
  }
}

/// Manage Notification Settings Use Case
@injectable
class ManageNotificationSettings {
  final SettingsRepository _repository;

  const ManageNotificationSettings(this._repository);

  /// Update notification settings
  ResultVoid updateNotifications(NotificationSettings notifications) async {
    return await _repository.updateNotificationSettings(notifications);
  }

  /// Get notification settings
  ResultFuture<NotificationSettings> getNotifications() async {
    return await _repository.getNotificationSettings();
  }

  /// Test notifications
  ResultVoid testNotifications() async {
    return await _repository.testNotifications();
  }
}

/// Manage Security Settings Use Case
@injectable
class ManageSecuritySettings {
  final SettingsRepository _repository;

  const ManageSecuritySettings(this._repository);

  /// Update security settings
  ResultVoid updateSecurity(SecuritySettings security) async {
    return await _repository.updateSecuritySettings(security);
  }

  /// Get security settings
  ResultFuture<SecuritySettings> getSecurity() async {
    return await _repository.getSecuritySettings();
  }

  /// Get biometric info
  ResultFuture<BiometricInfo> getBiometricInfo() async {
    return await _repository.getBiometricInfo();
  }

  /// Setup biometric authentication
  ResultVoid setupBiometricAuth() async {
    return await _repository.setupBiometricAuth();
  }

  /// Verify biometric authentication
  ResultFuture<bool> verifyBiometricAuth() async {
    return await _repository.verifyBiometricAuth();
  }
}

/// Manage Backup Settings Use Case
@injectable
class ManageBackupSettings {
  final SettingsRepository _repository;

  const ManageBackupSettings(this._repository);

  /// Update backup settings
  ResultVoid updateBackup(BackupSettings backup) async {
    return await _repository.updateBackupSettings(backup);
  }

  /// Get backup settings
  ResultFuture<BackupSettings> getBackup() async {
    return await _repository.getBackupSettings();
  }

  /// Create manual backup
  ResultFuture<BackupInfo> createBackup({bool includeImages = false}) async {
    return await _repository.createBackup(includeImages: includeImages);
  }

  /// Get available backups
  ResultFuture<List<BackupInfo>> getAvailableBackups() async {
    return await _repository.getAvailableBackups();
  }

  /// Restore from backup
  ResultVoid restoreFromBackup(String backupId) async {
    return await _repository.restoreFromBackup(backupId);
  }

  /// Delete backup
  ResultVoid deleteBackup(String backupId) async {
    return await _repository.deleteBackup(backupId);
  }
}

/// Export Data Use Case
@injectable
class ExportData {
  final SettingsRepository _repository;

  const ExportData(this._repository);

  /// Export all data
  ResultFuture<ExportResult> exportAllData({
    required DataExportFormat format,
    bool includeImages = false,
  }) async {
    return await _repository.exportAllData(
      format: format,
      includeImages: includeImages,
    );
  }

  /// Export specific data types
  ResultFuture<ExportResult> exportSpecificData({
    required List<DataType> dataTypes,
    required DataExportFormat format,
    bool includeImages = false,
  }) async {
    return await _repository.exportData(
      dataTypes: dataTypes,
      format: format,
      includeImages: includeImages,
    );
  }

  /// Get export history
  ResultFuture<List<ExportInfo>> getExportHistory() async {
    return await _repository.getExportHistory();
  }
}

/// Manage Cache Use Case
@injectable
class ManageCache {
  final SettingsRepository _repository;

  const ManageCache(this._repository);

  /// Get cache information
  ResultFuture<CacheInfo> getCacheInfo() async {
    return await _repository.getCacheInfo();
  }

  /// Clear all cache
  ResultVoid clearAllCache() async {
    return await _repository.clearAllCache();
  }

  /// Clear specific cache type
  ResultVoid clearCache(CacheType type) async {
    return await _repository.clearCache(type);
  }
}

/// Get App Info Use Case
@injectable
class GetAppInfo {
  final SettingsRepository _repository;

  const GetAppInfo(this._repository);

  /// Get app version info
  ResultFuture<AppVersionInfo> getAppVersion() async {
    return await _repository.getAppVersion();
  }

  /// Get device info
  ResultFuture<DeviceInfo> getDeviceInfo() async {
    return await _repository.getDeviceInfo();
  }

  /// Get diagnostic info
  ResultFuture<DiagnosticInfo> getDiagnosticInfo() async {
    return await _repository.getDiagnosticInfo();
  }

  /// Send diagnostic report
  ResultVoid sendDiagnosticReport({
    String? userComment,
    bool includeLogs = true,
  }) async {
    return await _repository.sendDiagnosticReport(
      userComment: userComment,
      includeLogs: includeLogs,
    );
  }
}

/// Validate Settings Use Case
@injectable
class ValidateSettings {
  final SettingsRepository _repository;

  const ValidateSettings(this._repository);

  /// Validate settings integrity
  ResultFuture<SettingsValidationResult> validateSettings() async {
    return await _repository.validateSettings();
  }

  /// Repair corrupted settings
  ResultFuture<SettingsEntity> repairSettings() async {
    return await _repository.repairSettings();
  }
}
