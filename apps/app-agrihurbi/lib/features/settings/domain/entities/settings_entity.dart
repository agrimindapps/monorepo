import 'package:core/core.dart';

/// Settings Entity for App Configuration Management
/// 
/// Represents all user preferences and app configuration options
class SettingsEntity extends Equatable {
  final String userId;
  final AppTheme theme;
  final String language;
  final NotificationSettings notifications;
  final DataSettings dataSettings;
  final PrivacySettings privacy;
  final DisplaySettings display;
  final SecuritySettings security;
  final BackupSettings backup;
  final DateTime lastUpdated;

  const SettingsEntity({
    required this.userId,
    this.theme = AppTheme.system,
    this.language = 'pt_BR',
    this.notifications = const NotificationSettings(),
    this.dataSettings = const DataSettings(),
    this.privacy = const PrivacySettings(),
    this.display = const DisplaySettings(),
    this.security = const SecuritySettings(),
    this.backup = const BackupSettings(),
    required this.lastUpdated,
  });

  SettingsEntity copyWith({
    String? userId,
    AppTheme? theme,
    String? language,
    NotificationSettings? notifications,
    DataSettings? dataSettings,
    PrivacySettings? privacy,
    DisplaySettings? display,
    SecuritySettings? security,
    BackupSettings? backup,
    DateTime? lastUpdated,
  }) {
    return SettingsEntity(
      userId: userId ?? this.userId,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
      dataSettings: dataSettings ?? this.dataSettings,
      privacy: privacy ?? this.privacy,
      display: display ?? this.display,
      security: security ?? this.security,
      backup: backup ?? this.backup,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        theme,
        language,
        notifications,
        dataSettings,
        privacy,
        display,
        security,
        backup,
        lastUpdated,
      ];
}

/// App Theme Options
enum AppTheme {
  light('Claro'),
  dark('Escuro'),
  system('Sistema');

  const AppTheme(this.displayName);
  final String displayName;
}

/// Notification Settings
class NotificationSettings extends Equatable {
  final bool pushNotifications;
  final bool newsNotifications;
  final bool marketAlerts;
  final bool weatherAlerts;
  final bool animalReminders;
  final bool calculatorReminders;
  final String quietHoursStart;
  final String quietHoursEnd;

  const NotificationSettings({
    this.pushNotifications = true,
    this.newsNotifications = true,
    this.marketAlerts = true,
    this.weatherAlerts = true,
    this.animalReminders = true,
    this.calculatorReminders = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
  });

  NotificationSettings copyWith({
    bool? pushNotifications,
    bool? newsNotifications,
    bool? marketAlerts,
    bool? weatherAlerts,
    bool? animalReminders,
    bool? calculatorReminders,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      newsNotifications: newsNotifications ?? this.newsNotifications,
      marketAlerts: marketAlerts ?? this.marketAlerts,
      weatherAlerts: weatherAlerts ?? this.weatherAlerts,
      animalReminders: animalReminders ?? this.animalReminders,
      calculatorReminders: calculatorReminders ?? this.calculatorReminders,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  @override
  List<Object?> get props => [
        pushNotifications,
        newsNotifications,
        marketAlerts,
        weatherAlerts,
        animalReminders,
        calculatorReminders,
        quietHoursStart,
        quietHoursEnd,
      ];
}

/// Data Settings
class DataSettings extends Equatable {
  final bool autoSync;
  final bool wifiOnlySync;
  final bool cacheImages;
  final int cacheRetentionDays;
  final bool compressBackups;
  final DataExportFormat exportFormat;

  const DataSettings({
    this.autoSync = true,
    this.wifiOnlySync = true,
    this.cacheImages = true,
    this.cacheRetentionDays = 30,
    this.compressBackups = true,
    this.exportFormat = DataExportFormat.json,
  });

  DataSettings copyWith({
    bool? autoSync,
    bool? wifiOnlySync,
    bool? cacheImages,
    int? cacheRetentionDays,
    bool? compressBackups,
    DataExportFormat? exportFormat,
  }) {
    return DataSettings(
      autoSync: autoSync ?? this.autoSync,
      wifiOnlySync: wifiOnlySync ?? this.wifiOnlySync,
      cacheImages: cacheImages ?? this.cacheImages,
      cacheRetentionDays: cacheRetentionDays ?? this.cacheRetentionDays,
      compressBackups: compressBackups ?? this.compressBackups,
      exportFormat: exportFormat ?? this.exportFormat,
    );
  }

  @override
  List<Object?> get props => [
        autoSync,
        wifiOnlySync,
        cacheImages,
        cacheRetentionDays,
        compressBackups,
        exportFormat,
      ];
}

/// Privacy Settings
class PrivacySettings extends Equatable {
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool shareUsageData;
  final bool personalizedAds;
  final bool locationTracking;

  const PrivacySettings({
    this.analyticsEnabled = true,
    this.crashReportingEnabled = true,
    this.shareUsageData = false,
    this.personalizedAds = false,
    this.locationTracking = false,
  });

  PrivacySettings copyWith({
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? shareUsageData,
    bool? personalizedAds,
    bool? locationTracking,
  }) {
    return PrivacySettings(
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
      shareUsageData: shareUsageData ?? this.shareUsageData,
      personalizedAds: personalizedAds ?? this.personalizedAds,
      locationTracking: locationTracking ?? this.locationTracking,
    );
  }

  @override
  List<Object?> get props => [
        analyticsEnabled,
        crashReportingEnabled,
        shareUsageData,
        personalizedAds,
        locationTracking,
      ];
}

/// Display Settings
class DisplaySettings extends Equatable {
  final double fontSize;
  final bool highContrast;
  final bool animations;
  final bool showTutorials;
  final String dateFormat;
  final String timeFormat;
  final String currency;
  final String unitSystem;

  const DisplaySettings({
    this.fontSize = 1.0,
    this.highContrast = false,
    this.animations = true,
    this.showTutorials = true,
    this.dateFormat = 'dd/MM/yyyy',
    this.timeFormat = 'HH:mm',
    this.currency = 'BRL',
    this.unitSystem = 'metric',
  });

  DisplaySettings copyWith({
    double? fontSize,
    bool? highContrast,
    bool? animations,
    bool? showTutorials,
    String? dateFormat,
    String? timeFormat,
    String? currency,
    String? unitSystem,
  }) {
    return DisplaySettings(
      fontSize: fontSize ?? this.fontSize,
      highContrast: highContrast ?? this.highContrast,
      animations: animations ?? this.animations,
      showTutorials: showTutorials ?? this.showTutorials,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      currency: currency ?? this.currency,
      unitSystem: unitSystem ?? this.unitSystem,
    );
  }

  @override
  List<Object?> get props => [
        fontSize,
        highContrast,
        animations,
        showTutorials,
        dateFormat,
        timeFormat,
        currency,
        unitSystem,
      ];
}

/// Security Settings
class SecuritySettings extends Equatable {
  final bool biometricAuth;
  final bool requireAuthOnOpen;
  final int autoLockMinutes;
  final bool hideDataInRecents;
  final bool encryptBackups;

  const SecuritySettings({
    this.biometricAuth = false,
    this.requireAuthOnOpen = false,
    this.autoLockMinutes = 5,
    this.hideDataInRecents = false,
    this.encryptBackups = true,
  });

  SecuritySettings copyWith({
    bool? biometricAuth,
    bool? requireAuthOnOpen,
    int? autoLockMinutes,
    bool? hideDataInRecents,
    bool? encryptBackups,
  }) {
    return SecuritySettings(
      biometricAuth: biometricAuth ?? this.biometricAuth,
      requireAuthOnOpen: requireAuthOnOpen ?? this.requireAuthOnOpen,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      hideDataInRecents: hideDataInRecents ?? this.hideDataInRecents,
      encryptBackups: encryptBackups ?? this.encryptBackups,
    );
  }

  @override
  List<Object?> get props => [
        biometricAuth,
        requireAuthOnOpen,
        autoLockMinutes,
        hideDataInRecents,
        encryptBackups,
      ];
}

/// Backup Settings
class BackupSettings extends Equatable {
  final bool autoBackup;
  final BackupFrequency frequency;
  final bool includeImages;
  final String? lastBackupDate;
  final BackupStorage storage;

  const BackupSettings({
    this.autoBackup = true,
    this.frequency = BackupFrequency.weekly,
    this.includeImages = false,
    this.lastBackupDate,
    this.storage = BackupStorage.cloud,
  });

  BackupSettings copyWith({
    bool? autoBackup,
    BackupFrequency? frequency,
    bool? includeImages,
    String? lastBackupDate,
    BackupStorage? storage,
  }) {
    return BackupSettings(
      autoBackup: autoBackup ?? this.autoBackup,
      frequency: frequency ?? this.frequency,
      includeImages: includeImages ?? this.includeImages,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      storage: storage ?? this.storage,
    );
  }

  @override
  List<Object?> get props => [
        autoBackup,
        frequency,
        includeImages,
        lastBackupDate,
        storage,
      ];
}

/// Data Export Formats
enum DataExportFormat {
  json('JSON'),
  csv('CSV'),
  excel('Excel');

  const DataExportFormat(this.displayName);
  final String displayName;
}

/// Backup Frequency
enum BackupFrequency {
  daily('Diário'),
  weekly('Semanal'),
  monthly('Mensal');

  const BackupFrequency(this.displayName);
  final String displayName;
}

/// Backup Storage Options
enum BackupStorage {
  local('Local'),
  cloud('Nuvem');

  const BackupStorage(this.displayName);
  final String displayName;
}