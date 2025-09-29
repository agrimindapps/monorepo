import 'package:equatable/equatable.dart';

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
    required userId,
    theme = AppTheme.system,
    language = 'pt_BR',
    notifications = const NotificationSettings(),
    dataSettings = const DataSettings(),
    privacy = const PrivacySettings(),
    display = const DisplaySettings(),
    security = const SecuritySettings(),
    backup = const BackupSettings(),
    required lastUpdated,
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
      userId: userId ?? userId,
      theme: theme ?? theme,
      language: language ?? language,
      notifications: notifications ?? notifications,
      dataSettings: dataSettings ?? dataSettings,
      privacy: privacy ?? privacy,
      display: display ?? display,
      security: security ?? security,
      backup: backup ?? backup,
      lastUpdated: lastUpdated ?? lastUpdated,
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

  const AppTheme(displayName);
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
    pushNotifications = true,
    newsNotifications = true,
    marketAlerts = true,
    weatherAlerts = true,
    animalReminders = true,
    calculatorReminders = false,
    quietHoursStart = '22:00',
    quietHoursEnd = '07:00',
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
      pushNotifications: pushNotifications ?? pushNotifications,
      newsNotifications: newsNotifications ?? newsNotifications,
      marketAlerts: marketAlerts ?? marketAlerts,
      weatherAlerts: weatherAlerts ?? weatherAlerts,
      animalReminders: animalReminders ?? animalReminders,
      calculatorReminders: calculatorReminders ?? calculatorReminders,
      quietHoursStart: quietHoursStart ?? quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? quietHoursEnd,
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
    autoSync = true,
    wifiOnlySync = true,
    cacheImages = true,
    cacheRetentionDays = 30,
    compressBackups = true,
    exportFormat = DataExportFormat.json,
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
      autoSync: autoSync ?? autoSync,
      wifiOnlySync: wifiOnlySync ?? wifiOnlySync,
      cacheImages: cacheImages ?? cacheImages,
      cacheRetentionDays: cacheRetentionDays ?? cacheRetentionDays,
      compressBackups: compressBackups ?? compressBackups,
      exportFormat: exportFormat ?? exportFormat,
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
    analyticsEnabled = true,
    crashReportingEnabled = true,
    shareUsageData = false,
    personalizedAds = false,
    locationTracking = false,
  });

  PrivacySettings copyWith({
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? shareUsageData,
    bool? personalizedAds,
    bool? locationTracking,
  }) {
    return PrivacySettings(
      analyticsEnabled: analyticsEnabled ?? analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled ?? crashReportingEnabled,
      shareUsageData: shareUsageData ?? shareUsageData,
      personalizedAds: personalizedAds ?? personalizedAds,
      locationTracking: locationTracking ?? locationTracking,
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
    fontSize = 1.0,
    highContrast = false,
    animations = true,
    showTutorials = true,
    dateFormat = 'dd/MM/yyyy',
    timeFormat = 'HH:mm',
    currency = 'BRL',
    unitSystem = 'metric',
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
      fontSize: fontSize ?? fontSize,
      highContrast: highContrast ?? highContrast,
      animations: animations ?? animations,
      showTutorials: showTutorials ?? showTutorials,
      dateFormat: dateFormat ?? dateFormat,
      timeFormat: timeFormat ?? timeFormat,
      currency: currency ?? currency,
      unitSystem: unitSystem ?? unitSystem,
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
    biometricAuth = false,
    requireAuthOnOpen = false,
    autoLockMinutes = 5,
    hideDataInRecents = false,
    encryptBackups = true,
  });

  SecuritySettings copyWith({
    bool? biometricAuth,
    bool? requireAuthOnOpen,
    int? autoLockMinutes,
    bool? hideDataInRecents,
    bool? encryptBackups,
  }) {
    return SecuritySettings(
      biometricAuth: biometricAuth ?? biometricAuth,
      requireAuthOnOpen: requireAuthOnOpen ?? requireAuthOnOpen,
      autoLockMinutes: autoLockMinutes ?? autoLockMinutes,
      hideDataInRecents: hideDataInRecents ?? hideDataInRecents,
      encryptBackups: encryptBackups ?? encryptBackups,
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
    autoBackup = true,
    frequency = BackupFrequency.weekly,
    includeImages = false,
    lastBackupDate,
    storage = BackupStorage.cloud,
  });

  BackupSettings copyWith({
    bool? autoBackup,
    BackupFrequency? frequency,
    bool? includeImages,
    String? lastBackupDate,
    BackupStorage? storage,
  }) {
    return BackupSettings(
      autoBackup: autoBackup ?? autoBackup,
      frequency: frequency ?? frequency,
      includeImages: includeImages ?? includeImages,
      lastBackupDate: lastBackupDate ?? lastBackupDate,
      storage: storage ?? storage,
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

  const DataExportFormat(displayName);
  final String displayName;
}

/// Backup Frequency
enum BackupFrequency {
  daily('Diário'),
  weekly('Semanal'),
  monthly('Mensal');

  const BackupFrequency(displayName);
  final String displayName;
}

/// Backup Storage Options
enum BackupStorage {
  local('Local'),
  cloud('Nuvem');

  const BackupStorage(displayName);
  final String displayName;
}