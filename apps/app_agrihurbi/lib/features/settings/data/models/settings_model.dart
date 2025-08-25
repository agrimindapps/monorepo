import 'package:app_agrihurbi/features/settings/domain/entities/settings_entity.dart';
import 'package:hive/hive.dart';

part 'settings_model.g.dart';

/// Settings Model with Hive Serialization
@HiveType(typeId: 23)
class SettingsModel extends SettingsEntity {
  @HiveField(0)
  @override
  final String userId;
  
  @HiveField(1)
  @override
  final AppTheme theme;
  
  @HiveField(2)
  @override
  final String language;
  
  @HiveField(3)
  @override
  final NotificationSettingsModel notifications;
  
  @HiveField(4)
  @override
  final DataSettingsModel dataSettings;
  
  @HiveField(5)
  @override
  final PrivacySettingsModel privacy;
  
  @HiveField(6)
  @override
  final DisplaySettingsModel display;
  
  @HiveField(7)
  @override
  final SecuritySettingsModel security;
  
  @HiveField(8)
  @override
  final BackupSettingsModel backup;
  
  @HiveField(9)
  @override
  final DateTime lastUpdated;

  const SettingsModel({
    required this.userId,
    this.theme = AppTheme.system,
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
      theme: entity.theme,
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
      userId: json['userId']?.toString() ?? '',
      theme: _parseThemeFromString(json['theme']?.toString() ?? 'system'),
      language: json['language']?.toString() ?? 'pt_BR',
      notifications: NotificationSettingsModel.fromJson(
        (json['notifications'] as Map<String, dynamic>?) ?? <String, dynamic>{}
      ),
      dataSettings: DataSettingsModel.fromJson(
        (json['dataSettings'] as Map<String, dynamic>?) ?? <String, dynamic>{}
      ),
      privacy: PrivacySettingsModel.fromJson(
        (json['privacy'] as Map<String, dynamic>?) ?? <String, dynamic>{}
      ),
      display: DisplaySettingsModel.fromJson(
        (json['display'] as Map<String, dynamic>?) ?? <String, dynamic>{}
      ),
      security: SecuritySettingsModel.fromJson(
        (json['security'] as Map<String, dynamic>?) ?? <String, dynamic>{}
      ),
      backup: BackupSettingsModel.fromJson(
        (json['backup'] as Map<String, dynamic>?) ?? <String, dynamic>{}
      ),
      lastUpdated: DateTime.tryParse(json['lastUpdated']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'theme': theme.toString().split('.').last,
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

  static AppTheme _parseThemeFromString(String theme) {
    switch (theme.toLowerCase()) {
      case 'light':
        return AppTheme.light;
      case 'dark':
        return AppTheme.dark;
      case 'system':
        return AppTheme.system;
      default:
        return AppTheme.system;
    }
  }
}


@HiveType(typeId: 25)
class NotificationSettingsModel extends NotificationSettings {
  @HiveField(0)
  @override
  final bool pushNotifications;
  
  @HiveField(1)
  @override
  final bool newsNotifications;
  
  @HiveField(2)
  @override
  final bool marketAlerts;
  
  @HiveField(3)
  @override
  final bool weatherAlerts;
  
  @HiveField(4)
  @override
  final bool animalReminders;
  
  @HiveField(5)
  @override
  final bool calculatorReminders;
  
  @HiveField(6)
  @override
  final String quietHoursStart;
  
  @HiveField(7)
  @override
  final String quietHoursEnd;

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
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      newsNotifications: json['newsNotifications'] as bool? ?? true,
      marketAlerts: json['marketAlerts'] as bool? ?? true,
      weatherAlerts: json['weatherAlerts'] as bool? ?? true,
      animalReminders: json['animalReminders'] as bool? ?? true,
      calculatorReminders: json['calculatorReminders'] as bool? ?? false,
      quietHoursStart: json['quietHoursStart'] as String? ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] as String? ?? '07:00',
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
  @HiveField(0)
  @override
  final bool autoSync;
  
  @HiveField(1)
  @override
  final bool wifiOnlySync;
  
  @HiveField(2)
  @override
  final bool cacheImages;
  
  @HiveField(3)
  @override
  final int cacheRetentionDays;
  
  @HiveField(4)
  @override
  final bool compressBackups;
  
  @HiveField(5)
  @override
  final DataExportFormat exportFormat;

  const DataSettingsModel({
    this.autoSync = true,
    this.wifiOnlySync = true,
    this.cacheImages = true,
    this.cacheRetentionDays = 30,
    this.compressBackups = true,
    this.exportFormat = DataExportFormat.json,
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
      exportFormat: entity.exportFormat,
    );
  }

  factory DataSettingsModel.fromJson(Map<String, dynamic> json) {
    return DataSettingsModel(
      autoSync: json['autoSync'] as bool? ?? true,
      wifiOnlySync: json['wifiOnlySync'] as bool? ?? true,
      cacheImages: json['cacheImages'] as bool? ?? true,
      cacheRetentionDays: json['cacheRetentionDays'] as int? ?? 30,
      compressBackups: json['compressBackups'] as bool? ?? true,
      exportFormat: DataExportFormat.values.firstWhere(
        (e) => e.name == (json['exportFormat'] as String? ?? 'json'),
        orElse: () => DataExportFormat.json,
      ),
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


// Simplified versions of remaining models...
@HiveType(typeId: 28)
class PrivacySettingsModel extends PrivacySettings {
  @HiveField(0)
  @override
  final bool analyticsEnabled;
  
  @HiveField(1)
  @override
  final bool crashReportingEnabled;
  
  @HiveField(2)
  @override
  final bool shareUsageData;
  
  @HiveField(3)
  @override
  final bool personalizedAds;
  
  @HiveField(4)
  @override
  final bool locationTracking;

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
        analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
        crashReportingEnabled: json['crashReportingEnabled'] as bool? ?? true,
        shareUsageData: json['shareUsageData'] as bool? ?? false,
        personalizedAds: json['personalizedAds'] as bool? ?? false,
        locationTracking: json['locationTracking'] as bool? ?? false,
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
  const DisplaySettingsModel({
    super.fontSize = 1.0,
    super.highContrast = false,
    super.animations = true,
    super.showTutorials = true,
    super.dateFormat = 'dd/MM/yyyy',
    super.timeFormat = 'HH:mm',
    super.currency = 'BRL',
    super.unitSystem = 'metric',
  });

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
        fontSize: (json['fontSize'] as num? ?? 1.0).toDouble(),
        highContrast: json['highContrast'] as bool? ?? false,
        animations: json['animations'] as bool? ?? true,
        showTutorials: json['showTutorials'] as bool? ?? true,
        dateFormat: json['dateFormat'] as String? ?? 'dd/MM/yyyy',
        timeFormat: json['timeFormat'] as String? ?? 'HH:mm',
        currency: json['currency'] as String? ?? 'BRL',
        unitSystem: json['unitSystem'] as String? ?? 'metric',
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
  const SecuritySettingsModel({
    super.biometricAuth = false,
    super.requireAuthOnOpen = false,
    super.autoLockMinutes = 5,
    super.hideDataInRecents = false,
    super.encryptBackups = true,
  });

  factory SecuritySettingsModel.fromEntity(SecuritySettings entity) => SecuritySettingsModel(
        biometricAuth: entity.biometricAuth,
        requireAuthOnOpen: entity.requireAuthOnOpen,
        autoLockMinutes: entity.autoLockMinutes,
        hideDataInRecents: entity.hideDataInRecents,
        encryptBackups: entity.encryptBackups,
      );

  factory SecuritySettingsModel.fromJson(Map<String, dynamic> json) => SecuritySettingsModel(
        biometricAuth: json['biometricAuth'] as bool? ?? false,
        requireAuthOnOpen: json['requireAuthOnOpen'] as bool? ?? false,
        autoLockMinutes: json['autoLockMinutes'] as int? ?? 5,
        hideDataInRecents: json['hideDataInRecents'] as bool? ?? false,
        encryptBackups: json['encryptBackups'] as bool? ?? true,
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
  const BackupSettingsModel({
    super.autoBackup = true,
    super.frequency = BackupFrequency.weekly,
    super.includeImages = false,
    super.lastBackupDate,
    super.storage = BackupStorage.cloud,
  });

  factory BackupSettingsModel.fromEntity(BackupSettings entity) => BackupSettingsModel(
        autoBackup: entity.autoBackup,
        frequency: entity.frequency,
        includeImages: entity.includeImages,
        lastBackupDate: entity.lastBackupDate,
        storage: entity.storage,
      );

  factory BackupSettingsModel.fromJson(Map<String, dynamic> json) => BackupSettingsModel(
        autoBackup: json['autoBackup'] as bool? ?? true,
        frequency: BackupFrequency.values.firstWhere(
          (e) => e.name == (json['frequency'] as String? ?? 'weekly'),
          orElse: () => BackupFrequency.weekly,
        ),
        includeImages: json['includeImages'] as bool? ?? false,
        lastBackupDate: json['lastBackupDate'] as String?,
        storage: BackupStorage.values.firstWhere(
          (e) => e.name == (json['storage'] as String? ?? 'cloud'),
          orElse: () => BackupStorage.cloud,
        ),
      );

  Map<String, dynamic> toJson() => {
        'autoBackup': autoBackup,
        'frequency': frequency.name,
        'includeImages': includeImages,
        'lastBackupDate': lastBackupDate,
        'storage': storage.name,
      };
}
