/// Domain entity for application settings
///
/// Pure domain object without external dependencies
class SettingsEntity {
  const SettingsEntity({
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

  factory SettingsEntity.defaults() => const SettingsEntity(
        isDarkTheme: false,
        notificationsEnabled: true,
        soundEnabled: true,
        language: 'pt-BR',
        distanceUnit: 'km',
        volumeUnit: 'liters',
        currency: 'BRL',
        maintenanceReminderDays: 7,
        autoBackupEnabled: true,
        analyticsEnabled: true,
      );

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

  SettingsEntity copyWith({
    bool? isDarkTheme,
    bool? notificationsEnabled,
    bool? soundEnabled,
    String? language,
    String? distanceUnit,
    String? volumeUnit,
    String? currency,
    int? maintenanceReminderDays,
    bool? autoBackupEnabled,
    bool? analyticsEnabled,
  }) {
    return SettingsEntity(
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      language: language ?? this.language,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      volumeUnit: volumeUnit ?? this.volumeUnit,
      currency: currency ?? this.currency,
      maintenanceReminderDays:
          maintenanceReminderDays ?? this.maintenanceReminderDays,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }
}
