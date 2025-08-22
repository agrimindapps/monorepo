import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/settings/domain/entities/settings_entity.dart';
import 'package:app_agrihurbi/features/settings/domain/repositories/settings_repository.dart';

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
  ResultFuture<BackupInfo> createBackup({
    bool includeImages = false,
  }) async {
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