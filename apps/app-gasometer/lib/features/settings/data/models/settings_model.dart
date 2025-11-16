import '../../domain/entities/settings_entity.dart';

/// Data model for settings with serialization support
///
/// Maps between domain entity and persistence layer
class SettingsModel {
  final bool isDarkTheme;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final String language;
  final String distanceUnit;
  final String volumeUnit;
  final String currency;
  final int maintenanceReminderDays;
  final bool autoBackupEnabled;
  final bool analyticsEnabled;

  const SettingsModel({
    required this.isDarkTheme,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.language,
    required this.distanceUnit,
    required this.volumeUnit,
    required this.currency,
    required this.maintenanceReminderDays,
    required this.autoBackupEnabled,
    required this.analyticsEnabled,
  });

  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      isDarkTheme: entity.isDarkTheme,
      notificationsEnabled: entity.notificationsEnabled,
      soundEnabled: entity.soundEnabled,
      language: entity.language,
      distanceUnit: entity.distanceUnit,
      volumeUnit: entity.volumeUnit,
      currency: entity.currency,
      maintenanceReminderDays: entity.maintenanceReminderDays,
      autoBackupEnabled: entity.autoBackupEnabled,
      analyticsEnabled: entity.analyticsEnabled,
    );
  }

  SettingsEntity toEntity() {
    return SettingsEntity(
      isDarkTheme: isDarkTheme,
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
      language: language,
      distanceUnit: distanceUnit,
      volumeUnit: volumeUnit,
      currency: currency,
      maintenanceReminderDays: maintenanceReminderDays,
      autoBackupEnabled: autoBackupEnabled,
      analyticsEnabled: analyticsEnabled,
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      isDarkTheme: json['isDarkTheme'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      language: json['language'] as String? ?? 'pt-BR',
      distanceUnit: json['distanceUnit'] as String? ?? 'km',
      volumeUnit: json['volumeUnit'] as String? ?? 'liters',
      currency: json['currency'] as String? ?? 'BRL',
      maintenanceReminderDays: json['maintenanceReminderDays'] as int? ?? 7,
      autoBackupEnabled: json['autoBackupEnabled'] as bool? ?? true,
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkTheme': isDarkTheme,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'language': language,
      'distanceUnit': distanceUnit,
      'volumeUnit': volumeUnit,
      'currency': currency,
      'maintenanceReminderDays': maintenanceReminderDays,
      'autoBackupEnabled': autoBackupEnabled,
      'analyticsEnabled': analyticsEnabled,
    };
  }
}
