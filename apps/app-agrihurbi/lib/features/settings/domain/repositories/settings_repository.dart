import 'package:app_agrihurbi/features/settings/domain/entities/settings_entity.dart';
import 'package:core/core.dart' show Failure;
import 'package:dartz/dartz.dart';

/// Settings Repository Interface
/// 
/// Defines contract for app settings management,
/// user preferences, and configuration persistence
abstract class SettingsRepository {
  // === GENERAL SETTINGS ===
  
  /// Get user settings
  Future<Either<Failure, SettingsEntity>> getSettings();

  /// Update complete settings
  Future<Either<Failure, SettingsEntity>> updateSettings(SettingsEntity settings);

  /// Reset settings to defaults
  Future<Either<Failure, SettingsEntity>> resetToDefaults();

  /// Get default settings
  Future<Either<Failure, SettingsEntity>> getDefaultSettings();

  // === THEME & APPEARANCE ===
  
  /// Update app theme
  Future<Either<Failure, void>> updateTheme(AppTheme theme);

  /// Get current theme
  Future<Either<Failure, AppTheme>> getCurrentTheme();

  /// Update display settings
  Future<Either<Failure, void>> updateDisplaySettings(DisplaySettings display);

  /// Get display settings
  Future<Either<Failure, DisplaySettings>> getDisplaySettings();

  // === LANGUAGE & LOCALIZATION ===
  
  /// Update app language
  Future<Either<Failure, void>> updateLanguage(String languageCode);

  /// Get current language
  Future<Either<Failure, String>> getCurrentLanguage();

  /// Get available languages
  Future<Either<Failure, List<SupportedLanguage>>> getAvailableLanguages();

  // === NOTIFICATION SETTINGS ===
  
  /// Update notification settings
  Future<Either<Failure, void>> updateNotificationSettings(NotificationSettings notifications);

  /// Get notification settings
  Future<Either<Failure, NotificationSettings>> getNotificationSettings();

  /// Test notification settings
  Future<Either<Failure, void>> testNotifications();

  // === DATA & SYNC SETTINGS ===
  
  /// Update data settings
  Future<Either<Failure, void>> updateDataSettings(DataSettings dataSettings);

  /// Get data settings
  Future<Either<Failure, DataSettings>> getDataSettings();

  /// Force sync settings to cloud
  Future<Either<Failure, void>> forceSyncToCloud();

  /// Get last sync timestamp
  Future<Either<Failure, DateTime?>> getLastSyncTime();

  // === PRIVACY SETTINGS ===
  
  /// Update privacy settings
  Future<Either<Failure, void>> updatePrivacySettings(PrivacySettings privacy);

  /// Get privacy settings
  Future<Either<Failure, PrivacySettings>> getPrivacySettings();

  /// Clear all analytics data
  Future<Either<Failure, void>> clearAnalyticsData();

  // === SECURITY SETTINGS ===
  
  /// Update security settings
  Future<Either<Failure, void>> updateSecuritySettings(SecuritySettings security);

  /// Get security settings
  Future<Either<Failure, SecuritySettings>> getSecuritySettings();

  /// Check biometric availability
  Future<Either<Failure, BiometricInfo>> getBiometricInfo();

  /// Setup biometric authentication
  Future<Either<Failure, void>> setupBiometricAuth();

  /// Verify biometric authentication
  Future<Either<Failure, bool>> verifyBiometricAuth();

  // === BACKUP & RESTORE ===
  
  /// Update backup settings
  Future<Either<Failure, void>> updateBackupSettings(BackupSettings backup);

  /// Get backup settings
  Future<Either<Failure, BackupSettings>> getBackupSettings();

  /// Create manual backup
  Future<Either<Failure, BackupInfo>> createBackup({
    bool includeImages = false,
  });

  /// Get available backups
  Future<Either<Failure, List<BackupInfo>>> getAvailableBackups();

  /// Restore from backup
  Future<Either<Failure, void>> restoreFromBackup(String backupId);

  /// Delete backup
  Future<Either<Failure, void>> deleteBackup(String backupId);

  // === DATA EXPORT ===
  
  /// Export all data
  Future<Either<Failure, ExportResult>> exportAllData({
    required DataExportFormat format,
    bool includeImages = false,
  });

  /// Export specific data types
  Future<Either<Failure, ExportResult>> exportData({
    required List<DataType> dataTypes,
    required DataExportFormat format,
    bool includeImages = false,
  });

  /// Get export history
  Future<Either<Failure, List<ExportInfo>>> getExportHistory();

  // === CACHE MANAGEMENT ===
  
  /// Get cache size information
  Future<Either<Failure, CacheInfo>> getCacheInfo();

  /// Clear all cache
  Future<Either<Failure, void>> clearAllCache();

  /// Clear specific cache type
  Future<Either<Failure, void>> clearCache(CacheType type);

  // === APP INFO & DIAGNOSTICS ===
  
  /// Get app version info
  Future<Either<Failure, AppVersionInfo>> getAppVersion();

  /// Get device info
  Future<Either<Failure, DeviceInfo>> getDeviceInfo();

  /// Get diagnostic information
  Future<Either<Failure, DiagnosticInfo>> getDiagnosticInfo();

  /// Send diagnostic report
  Future<Either<Failure, void>> sendDiagnosticReport({
    String? userComment,
    bool includeLogs = true,
  });

  // === SETTINGS VALIDATION ===
  
  /// Validate settings integrity
  Future<Either<Failure, SettingsValidationResult>> validateSettings();

  /// Repair corrupted settings
  Future<Either<Failure, SettingsEntity>> repairSettings();
}

/// Supported Language Entity
class SupportedLanguage {
  final String code;
  final String name;
  final String nativeName;
  final bool isSupported;

  const SupportedLanguage({
    required code,
    required name,
    required nativeName,
    isSupported = true,
  });
}

/// Biometric Info Entity
class BiometricInfo {
  final bool isAvailable;
  final bool isEnrolled;
  final List<BiometricType> availableTypes;

  const BiometricInfo({
    required isAvailable,
    required isEnrolled,
    required availableTypes,
  });
}

/// Biometric Types
enum BiometricType {
  fingerprint,
  faceID,
  iris,
  voice,
}

/// Backup Info Entity
class BackupInfo {
  final String id;
  final String name;
  final DateTime createdAt;
  final int sizeBytes;
  final bool includesImages;
  final BackupStorage storage;
  final BackupStatus status;

  const BackupInfo({
    required id,
    required name,
    required createdAt,
    required sizeBytes,
    required includesImages,
    required storage,
    required status,
  });
}

/// Backup Status
enum BackupStatus {
  creating,
  completed,
  failed,
  corrupted,
}

/// Export Result Entity
class ExportResult {
  final String filePath;
  final DataExportFormat format;
  final int sizeBytes;
  final DateTime createdAt;
  final List<DataType> includedTypes;

  const ExportResult({
    required filePath,
    required format,
    required sizeBytes,
    required createdAt,
    required includedTypes,
  });
}

/// Export Info Entity
class ExportInfo {
  final String id;
  final String fileName;
  final DataExportFormat format;
  final DateTime createdAt;
  final int sizeBytes;
  final ExportStatus status;

  const ExportInfo({
    required id,
    required fileName,
    required format,
    required createdAt,
    required sizeBytes,
    required status,
  });
}

/// Export Status
enum ExportStatus {
  inProgress,
  completed,
  failed,
  expired,
}

/// Data Types for Export
enum DataType {
  livestock,
  calculations,
  weather,
  news,
  settings,
  favorites,
}

/// Cache Info Entity
class CacheInfo {
  final Map<CacheType, int> cacheSizes;
  final int totalSizeBytes;
  final DateTime lastCleared;

  const CacheInfo({
    required cacheSizes,
    required totalSizeBytes,
    required lastCleared,
  });
}

/// Cache Types
enum CacheType {
  images,
  news,
  weather,
  calculations,
  all,
}

/// App Version Info Entity
class AppVersionInfo {
  final String version;
  final String buildNumber;
  final DateTime buildDate;
  final String gitCommit;
  final bool isDebug;

  const AppVersionInfo({
    required version,
    required buildNumber,
    required buildDate,
    required gitCommit,
    required isDebug,
  });
}

/// Device Info Entity
class DeviceInfo {
  final String platform;
  final String version;
  final String model;
  final String brand;
  final int totalMemory;
  final int availableMemory;
  final int totalStorage;
  final int availableStorage;

  const DeviceInfo({
    required platform,
    required version,
    required model,
    required brand,
    required totalMemory,
    required availableMemory,
    required totalStorage,
    required availableStorage,
  });
}

/// Diagnostic Info Entity
class DiagnosticInfo {
  final AppVersionInfo appVersion;
  final DeviceInfo deviceInfo;
  final Map<String, dynamic> systemMetrics;
  final List<String> errorLogs;
  final DateTime generatedAt;

  const DiagnosticInfo({
    required appVersion,
    required deviceInfo,
    required systemMetrics,
    required errorLogs,
    required generatedAt,
  });
}

/// Settings Validation Result Entity
class SettingsValidationResult {
  final bool isValid;
  final List<SettingsValidationError> errors;
  final List<SettingsValidationWarning> warnings;

  const SettingsValidationResult({
    required isValid,
    required errors,
    required warnings,
  });
}

/// Settings Validation Error
class SettingsValidationError {
  final String field;
  final String message;
  final SettingsErrorSeverity severity;

  const SettingsValidationError({
    required field,
    required message,
    required severity,
  });
}

/// Settings Validation Warning
class SettingsValidationWarning {
  final String field;
  final String message;

  const SettingsValidationWarning({
    required field,
    required message,
  });
}

/// Settings Error Severity
enum SettingsErrorSeverity {
  low,
  medium,
  high,
  critical,
}