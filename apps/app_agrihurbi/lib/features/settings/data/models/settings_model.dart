import 'package:hive/hive.dart';
import 'package:app_agrihurbi/features/settings/domain/entities/settings_entity.dart';

part 'settings_model.g.dart';

/// Settings Model with Hive Serialization
@HiveType(typeId: 23)
class SettingsModel extends SettingsEntity {
  @HiveField(0)
  final String userId;
  
  @HiveField(1)
  final AppThemeModel theme;
  
  @HiveField(2)
  final String language;
  
  @HiveField(3)
  final NotificationSettingsModel notifications;
  
  @HiveField(4)
  final DataSettingsModel dataSettings;
  
  @HiveField(5)
  final PrivacySettingsModel privacy;
  
  @HiveField(6)
  final DisplaySettingsModel display;
  
  @HiveField(7)
  final SecuritySettingsModel security;
  
  @HiveField(8)
  final BackupSettingsModel backup;
  
  @HiveField(9)
  final DateTime lastUpdated;

  const SettingsModel({
    required this.userId,
    this.theme = AppThemeModel.system,
    this.language = 'pt_BR',
    this.notifications = const NotificationSettingsModel(),
    this.dataSettings = const DataSettingsModel(),
    this.privacy = const PrivacySettingsModel(),
    this.display = const DisplaySettingsModel(),
    this.security = const SecuritySettingsModel(),
    this.backup = const BackupSettingsModel(),
    required this.lastUpdated,
  }) : super(
          userId: userId,
          theme: theme,
          language: language,
          notifications: notifications,
          dataSettings: dataSettings,
          privacy: privacy,
          display: display,
          security: security,
          backup: backup,
          lastUpdated: lastUpdated,
        );

  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      userId: entity.userId,
      theme: AppThemeModel.fromEntity(entity.theme),
      language: entity.language,
      notifications: NotificationSettingsModel.fromEntity(entity.notifications),
      dataSettings: DataSettingsModel.fromEntity(entity.dataSettings),
      privacy: PrivacySettingsModel.fromEntity(entity.privacy),
      display: DisplaySettingsModel.fromEntity(entity.display),
      security: SecuritySettingsModel.fromEntity(entity.security),
      backup: BackupSettingsModel.fromEntity(entity.backup),
      lastUpdated: entity.lastUpdated,
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      userId: json['userId'] ?? '',
      theme: AppThemeModel.fromString(json['theme'] ?? 'system'),
      language: json['language'] ?? 'pt_BR',
      notifications: NotificationSettingsModel.fromJson(json['notifications'] ?? {}),
      dataSettings: DataSettingsModel.fromJson(json['dataSettings'] ?? {}),
      privacy: PrivacySettingsModel.fromJson(json['privacy'] ?? {}),
      display: DisplaySettingsModel.fromJson(json['display'] ?? {}),
      security: SecuritySettingsModel.fromJson(json['security'] ?? {}),
      backup: BackupSettingsModel.fromJson(json['backup'] ?? {}),
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'theme': theme.name,
      'language': language,
      'notifications': notifications.toJson(),
      'dataSettings': dataSettings.toJson(),
      'privacy': privacy.toJson(),
      'display': display.toJson(),
      'security': security.toJson(),
      'backup': backup.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

@HiveType(typeId: 24)
enum AppThemeModel {
  @HiveField(0) light,
  @HiveField(1) dark,
  @HiveField(2) system;

  AppTheme toEntity() {
    switch (this) {
      case AppThemeModel.light: return AppTheme.light;
      case AppThemeModel.dark: return AppTheme.dark;
      case AppThemeModel.system: return AppTheme.system;
    }
  }

  static AppThemeModel fromEntity(AppTheme theme) {
    switch (theme) {
      case AppTheme.light: return AppThemeModel.light;
      case AppTheme.dark: return AppThemeModel.dark;
      case AppTheme.system: return AppThemeModel.system;
    }
  }

  static AppThemeModel fromString(String theme) {
    switch (theme.toLowerCase()) {
      case 'light': return AppThemeModel.light;
      case 'dark': return AppThemeModel.dark;
      case 'system': return AppThemeModel.system;
      default: return AppThemeModel.system;
    }
  }
}

@HiveType(typeId: 25)
class NotificationSettingsModel extends NotificationSettings {
  @HiveField(0) final bool pushNotifications;
  @HiveField(1) final bool newsNotifications;
  @HiveField(2) final bool marketAlerts;
  @HiveField(3) final bool weatherAlerts;
  @HiveField(4) final bool animalReminders;
  @HiveField(5) final bool calculatorReminders;
  @HiveField(6) final String quietHoursStart;
  @HiveField(7) final String quietHoursEnd;

  const NotificationSettingsModel({
    this.pushNotifications = true,
    this.newsNotifications = true,
    this.marketAlerts = true,
    this.weatherAlerts = true,
    this.animalReminders = true,
    this.calculatorReminders = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
  }) : super(
          pushNotifications: pushNotifications,
          newsNotifications: newsNotifications,
          marketAlerts: marketAlerts,
          weatherAlerts: weatherAlerts,
          animalReminders: animalReminders,
          calculatorReminders: calculatorReminders,
          quietHoursStart: quietHoursStart,
          quietHoursEnd: quietHoursEnd,
        );

  factory NotificationSettingsModel.fromEntity(NotificationSettings entity) {
    return NotificationSettingsModel(
      pushNotifications: entity.pushNotifications,
      newsNotifications: entity.newsNotifications,
      marketAlerts: entity.marketAlerts,
      weatherAlerts: entity.weatherAlerts,
      animalReminders: entity.animalReminders,
      calculatorReminders: entity.calculatorReminders,
      quietHoursStart: entity.quietHoursStart,
      quietHoursEnd: entity.quietHoursEnd,
    );
  }

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      pushNotifications: json['pushNotifications'] ?? true,
      newsNotifications: json['newsNotifications'] ?? true,
      marketAlerts: json['marketAlerts'] ?? true,
      weatherAlerts: json['weatherAlerts'] ?? true,
      animalReminders: json['animalReminders'] ?? true,
      calculatorReminders: json['calculatorReminders'] ?? false,
      quietHoursStart: json['quietHoursStart'] ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] ?? '07:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotifications': pushNotifications,
      'newsNotifications': newsNotifications,
      'marketAlerts': marketAlerts,
      'weatherAlerts': weatherAlerts,
      'animalReminders': animalReminders,
      'calculatorReminders': calculatorReminders,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }
}

// Similar pattern for other settings models...
@HiveType(typeId: 26)
class DataSettingsModel extends DataSettings {
  @HiveField(0) final bool autoSync;
  @HiveField(1) final bool wifiOnlySync;
  @HiveField(2) final bool cacheImages;
  @HiveField(3) final int cacheRetentionDays;
  @HiveField(4) final bool compressBackups;
  @HiveField(5) final DataExportFormatModel exportFormat;

  const DataSettingsModel({
    this.autoSync = true,
    this.wifiOnlySync = true,
    this.cacheImages = true,
    this.cacheRetentionDays = 30,
    this.compressBackups = true,
    this.exportFormat = DataExportFormatModel.json,
  }) : super(
          autoSync: autoSync,
          wifiOnlySync: wifiOnlySync,
          cacheImages: cacheImages,
          cacheRetentionDays: cacheRetentionDays,
          compressBackups: compressBackups,
          exportFormat: exportFormat,
        );

  factory DataSettingsModel.fromEntity(DataSettings entity) {
    return DataSettingsModel(
      autoSync: entity.autoSync,
      wifiOnlySync: entity.wifiOnlySync,
      cacheImages: entity.cacheImages,
      cacheRetentionDays: entity.cacheRetentionDays,
      compressBackups: entity.compressBackups,
      exportFormat: DataExportFormatModel.fromEntity(entity.exportFormat),
    );
  }

  factory DataSettingsModel.fromJson(Map<String, dynamic> json) {
    return DataSettingsModel(
      autoSync: json['autoSync'] ?? true,
      wifiOnlySync: json['wifiOnlySync'] ?? true,
      cacheImages: json['cacheImages'] ?? true,
      cacheRetentionDays: json['cacheRetentionDays'] ?? 30,
      compressBackups: json['compressBackups'] ?? true,
      exportFormat: DataExportFormatModel.fromString(json['exportFormat'] ?? 'json'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoSync': autoSync,
      'wifiOnlySync': wifiOnlySync,
      'cacheImages': cacheImages,
      'cacheRetentionDays': cacheRetentionDays,
      'compressBackups': compressBackups,
      'exportFormat': exportFormat.name,
    };
  }
}

@HiveType(typeId: 27)
enum DataExportFormatModel {
  @HiveField(0) json,
  @HiveField(1) csv,
  @HiveField(2) excel;

  DataExportFormat toEntity() {
    switch (this) {
      case DataExportFormatModel.json: return DataExportFormat.json;
      case DataExportFormatModel.csv: return DataExportFormat.csv;
      case DataExportFormatModel.excel: return DataExportFormat.excel;
    }
  }

  static DataExportFormatModel fromEntity(DataExportFormat format) {
    switch (format) {
      case DataExportFormat.json: return DataExportFormatModel.json;
      case DataExportFormat.csv: return DataExportFormatModel.csv;
      case DataExportFormat.excel: return DataExportFormatModel.excel;
    }
  }

  static DataExportFormatModel fromString(String format) {
    switch (format.toLowerCase()) {
      case 'json': return DataExportFormatModel.json;
      case 'csv': return DataExportFormatModel.csv;
      case 'excel': return DataExportFormatModel.excel;
      default: return DataExportFormatModel.json;
    }
  }
}

// Simplified versions of remaining models...
@HiveType(typeId: 28)
class PrivacySettingsModel extends PrivacySettings {
  @HiveField(0) final bool analyticsEnabled;
  @HiveField(1) final bool crashReportingEnabled;
  @HiveField(2) final bool shareUsageData;
  @HiveField(3) final bool personalizedAds;
  @HiveField(4) final bool locationTracking;

  const PrivacySettingsModel({
    this.analyticsEnabled = true,
    this.crashReportingEnabled = true,
    this.shareUsageData = false,
    this.personalizedAds = false,
    this.locationTracking = false,
  }) : super(
          analyticsEnabled: analyticsEnabled,
          crashReportingEnabled: crashReportingEnabled,
          shareUsageData: shareUsageData,
          personalizedAds: personalizedAds,
          locationTracking: locationTracking,
        );

  factory PrivacySettingsModel.fromEntity(PrivacySettings entity) => PrivacySettingsModel(
        analyticsEnabled: entity.analyticsEnabled,
        crashReportingEnabled: entity.crashReportingEnabled,
        shareUsageData: entity.shareUsageData,
        personalizedAds: entity.personalizedAds,
        locationTracking: entity.locationTracking,
      );

  factory PrivacySettingsModel.fromJson(Map<String, dynamic> json) => PrivacySettingsModel(
        analyticsEnabled: json['analyticsEnabled'] ?? true,
        crashReportingEnabled: json['crashReportingEnabled'] ?? true,
        shareUsageData: json['shareUsageData'] ?? false,
        personalizedAds: json['personalizedAds'] ?? false,
        locationTracking: json['locationTracking'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'analyticsEnabled': analyticsEnabled,
        'crashReportingEnabled': crashReportingEnabled,
        'shareUsageData': shareUsageData,
        'personalizedAds': personalizedAds,
        'locationTracking': locationTracking,
      };
}

@HiveType(typeId: 29)
class DisplaySettingsModel extends DisplaySettings {
  @HiveField(0) final double fontSize;
  @HiveField(1) final bool highContrast;
  @HiveField(2) final bool animations;
  @HiveField(3) final bool showTutorials;
  @HiveField(4) final String dateFormat;
  @HiveField(5) final String timeFormat;
  @HiveField(6) final String currency;
  @HiveField(7) final String unitSystem;

  const DisplaySettingsModel({
    this.fontSize = 1.0,
    this.highContrast = false,
    this.animations = true,
    this.showTutorials = true,
    this.dateFormat = 'dd/MM/yyyy',
    this.timeFormat = 'HH:mm',
    this.currency = 'BRL',
    this.unitSystem = 'metric',
  }) : super(
          fontSize: fontSize,
          highContrast: highContrast,
          animations: animations,
          showTutorials: showTutorials,
          dateFormat: dateFormat,
          timeFormat: timeFormat,
          currency: currency,
          unitSystem: unitSystem,
        );

  factory DisplaySettingsModel.fromEntity(DisplaySettings entity) => DisplaySettingsModel(
        fontSize: entity.fontSize,
        highContrast: entity.highContrast,
        animations: entity.animations,
        showTutorials: entity.showTutorials,
        dateFormat: entity.dateFormat,
        timeFormat: entity.timeFormat,
        currency: entity.currency,
        unitSystem: entity.unitSystem,
      );

  factory DisplaySettingsModel.fromJson(Map<String, dynamic> json) => DisplaySettingsModel(
        fontSize: (json['fontSize'] ?? 1.0).toDouble(),
        highContrast: json['highContrast'] ?? false,
        animations: json['animations'] ?? true,
        showTutorials: json['showTutorials'] ?? true,
        dateFormat: json['dateFormat'] ?? 'dd/MM/yyyy',
        timeFormat: json['timeFormat'] ?? 'HH:mm',
        currency: json['currency'] ?? 'BRL',
        unitSystem: json['unitSystem'] ?? 'metric',
      );

  Map<String, dynamic> toJson() => {
        'fontSize': fontSize,
        'highContrast': highContrast,
        'animations': animations,
        'showTutorials': showTutorials,
        'dateFormat': dateFormat,
        'timeFormat': timeFormat,
        'currency': currency,
        'unitSystem': unitSystem,
      };
}

@HiveType(typeId: 30)
class SecuritySettingsModel extends SecuritySettings {
  @HiveField(0) final bool biometricAuth;
  @HiveField(1) final bool requireAuthOnOpen;
  @HiveField(2) final int autoLockMinutes;
  @HiveField(3) final bool hideDataInRecents;
  @HiveField(4) final bool encryptBackups;

  const SecuritySettingsModel({
    this.biometricAuth = false,
    this.requireAuthOnOpen = false,
    this.autoLockMinutes = 5,
    this.hideDataInRecents = false,
    this.encryptBackups = true,
  }) : super(
          biometricAuth: biometricAuth,
          requireAuthOnOpen: requireAuthOnOpen,
          autoLockMinutes: autoLockMinutes,
          hideDataInRecents: hideDataInRecents,
          encryptBackups: encryptBackups,
        );

  factory SecuritySettingsModel.fromEntity(SecuritySettings entity) => SecuritySettingsModel(
        biometricAuth: entity.biometricAuth,
        requireAuthOnOpen: entity.requireAuthOnOpen,
        autoLockMinutes: entity.autoLockMinutes,
        hideDataInRecents: entity.hideDataInRecents,
        encryptBackups: entity.encryptBackups,
      );

  factory SecuritySettingsModel.fromJson(Map<String, dynamic> json) => SecuritySettingsModel(
        biometricAuth: json['biometricAuth'] ?? false,
        requireAuthOnOpen: json['requireAuthOnOpen'] ?? false,
        autoLockMinutes: json['autoLockMinutes'] ?? 5,
        hideDataInRecents: json['hideDataInRecents'] ?? false,
        encryptBackups: json['encryptBackups'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'biometricAuth': biometricAuth,
        'requireAuthOnOpen': requireAuthOnOpen,
        'autoLockMinutes': autoLockMinutes,
        'hideDataInRecents': hideDataInRecents,
        'encryptBackups': encryptBackups,
      };
}

@HiveType(typeId: 31)
class BackupSettingsModel extends BackupSettings {
  @HiveField(0) final bool autoBackup;
  @HiveField(1) final BackupFrequencyModel frequency;
  @HiveField(2) final bool includeImages;
  @HiveField(3) final String? lastBackupDate;
  @HiveField(4) final BackupStorageModel storage;

  const BackupSettingsModel({
    this.autoBackup = true,
    this.frequency = BackupFrequencyModel.weekly,
    this.includeImages = false,
    this.lastBackupDate,
    this.storage = BackupStorageModel.cloud,
  }) : super(
          autoBackup: autoBackup,
          frequency: frequency,
          includeImages: includeImages,
          lastBackupDate: lastBackupDate,
          storage: storage,
        );

  factory BackupSettingsModel.fromEntity(BackupSettings entity) => BackupSettingsModel(
        autoBackup: entity.autoBackup,
        frequency: BackupFrequencyModel.fromEntity(entity.frequency),
        includeImages: entity.includeImages,
        lastBackupDate: entity.lastBackupDate,
        storage: BackupStorageModel.fromEntity(entity.storage),
      );

  factory BackupSettingsModel.fromJson(Map<String, dynamic> json) => BackupSettingsModel(
        autoBackup: json['autoBackup'] ?? true,
        frequency: BackupFrequencyModel.fromString(json['frequency'] ?? 'weekly'),
        includeImages: json['includeImages'] ?? false,
        lastBackupDate: json['lastBackupDate'],
        storage: BackupStorageModel.fromString(json['storage'] ?? 'cloud'),
      );

  Map<String, dynamic> toJson() => {
        'autoBackup': autoBackup,
        'frequency': frequency.name,
        'includeImages': includeImages,
        'lastBackupDate': lastBackupDate,
        'storage': storage.name,
      };
}

@HiveType(typeId: 32)
enum BackupFrequencyModel {
  @HiveField(0) daily,
  @HiveField(1) weekly,
  @HiveField(2) monthly;

  BackupFrequency toEntity() {
    switch (this) {
      case BackupFrequencyModel.daily: return BackupFrequency.daily;
      case BackupFrequencyModel.weekly: return BackupFrequency.weekly;
      case BackupFrequencyModel.monthly: return BackupFrequency.monthly;
    }
  }

  static BackupFrequencyModel fromEntity(BackupFrequency frequency) {
    switch (frequency) {
      case BackupFrequency.daily: return BackupFrequencyModel.daily;
      case BackupFrequency.weekly: return BackupFrequencyModel.weekly;
      case BackupFrequency.monthly: return BackupFrequencyModel.monthly;
    }
  }

  static BackupFrequencyModel fromString(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily': return BackupFrequencyModel.daily;
      case 'weekly': return BackupFrequencyModel.weekly;
      case 'monthly': return BackupFrequencyModel.monthly;
      default: return BackupFrequencyModel.weekly;
    }
  }
}

@HiveType(typeId: 33)
enum BackupStorageModel {
  @HiveField(0) local,
  @HiveField(1) cloud;

  BackupStorage toEntity() {
    switch (this) {
      case BackupStorageModel.local: return BackupStorage.local;
      case BackupStorageModel.cloud: return BackupStorage.cloud;
    }
  }

  static BackupStorageModel fromEntity(BackupStorage storage) {
    switch (storage) {
      case BackupStorage.local: return BackupStorageModel.local;
      case BackupStorage.cloud: return BackupStorageModel.cloud;
    }
  }

  static BackupStorageModel fromString(String storage) {
    switch (storage.toLowerCase()) {
      case 'local': return BackupStorageModel.local;
      case 'cloud': return BackupStorageModel.cloud;
      default: return BackupStorageModel.cloud;
    }
  }
}