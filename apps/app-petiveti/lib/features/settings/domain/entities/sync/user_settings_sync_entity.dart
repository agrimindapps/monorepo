import 'package:core/core.dart';

/// Entidade UserSettings para sincronização
/// Configurações do usuário com funcionalidades específicas:
/// - Single-device user preferences (usuário único)
/// - Offline-first para acessibilidade
/// - Emergency settings para situações críticas
class UserSettingsSyncEntity extends BaseSyncEntity {
  const UserSettingsSyncEntity({
    required super.id,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty = false,
    super.isDeleted = false,
    super.version = 1,
    super.userId,
    super.moduleName,
    this.language = 'pt-BR',
    this.theme = AppTheme.system,
    this.currency = 'BRL',
    this.weightUnit = WeightUnit.kg,
    this.temperatureUnit = TemperatureUnit.celsius,
    this.dateFormat = DateFormat.ddmmyyyy,
    this.timeFormat = TimeFormat.h24,
    this.enableNotifications = true,
    this.enableMedicationReminders = true,
    this.enableAppointmentReminders = true,
    this.enableWeightTrackingReminders = false,
    this.enableEmergencyAlerts = true,
    this.notificationSound = NotificationSound.defaultSound,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.medicationReminderAdvance = const Duration(minutes: 15),
    this.appointmentReminderAdvance = const Duration(hours: 2),
    this.allowEmergencyAccess = true,
    this.autoBackupEnabled = true,
    this.autoBackupFrequency = BackupFrequency.daily,
    this.includePhotosInBackup = false,
    this.onlyBackupOnWifi = true,
    this.maxLocalStorageDays = 365,
    this.enableDataExport = true,
    this.fontSize = FontSize.normal,
    this.enableHighContrast = false,
    this.enableVoiceOver = false,
    this.enableHapticFeedback = true,
    this.enableReducedMotion = false,
    this.colorBlindnessType,
    this.defaultAnimalViewMode = AnimalViewMode.list,
    this.showAgeInDays = false,
    this.enableWeightTrends = true,
    this.enableMedicationAdherence = true,
    this.enableVetReminders = true,
    this.autoCalculateNextVaccination = true,
    this.preferredVeterinarianId,
    this.defaultReminderLeadTime = const Duration(days: 1),
    this.developerMode = false,
    this.enableAnalytics = true,
    this.enableCrashReporting = true,
    this.enableBetaFeatures = false,
    this.maxSyncRetries = 3,
    this.syncTimeout = const Duration(minutes: 5),
    this.customCategories = const {},
    this.favoriteFeatures = const [],
    this.hiddenFeatures = const [],
    this.quickActionButtons = const [],
    this.dashboardWidgets = const [],
  });
  final String language;
  final AppTheme theme;
  final String currency;
  final WeightUnit weightUnit;
  final TemperatureUnit temperatureUnit;
  final DateFormat dateFormat;
  final TimeFormat timeFormat;
  final bool enableNotifications;
  final bool enableMedicationReminders;
  final bool enableAppointmentReminders;
  final bool enableWeightTrackingReminders;
  final bool enableEmergencyAlerts;
  final NotificationSound notificationSound;
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;
  final Duration medicationReminderAdvance;
  final Duration appointmentReminderAdvance;
  final bool allowEmergencyAccess;
  final bool sharePhotosByDefault = false; // Single user - always false
  final bool shareWeightDataByDefault = false; // Single user - always false
  final bool shareMedicalDataByDefault = false; // Single user - always false
  final bool hasEmergencyContacts = true; // Single user - simplified
  final bool autoBackupEnabled;
  final BackupFrequency autoBackupFrequency;
  final bool includePhotosInBackup;
  final bool onlyBackupOnWifi;
  final int maxLocalStorageDays;
  final bool enableDataExport;
  final FontSize fontSize;
  final bool enableHighContrast;
  final bool enableVoiceOver;
  final bool enableHapticFeedback;
  final bool enableReducedMotion;
  final ColorBlindnessType? colorBlindnessType;
  final AnimalViewMode defaultAnimalViewMode;
  final bool showAgeInDays;
  final bool enableWeightTrends;
  final bool enableMedicationAdherence;
  final bool enableVetReminders;
  final bool autoCalculateNextVaccination;
  final String? preferredVeterinarianId;
  final Duration defaultReminderLeadTime;
  final bool developerMode;
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final bool enableBetaFeatures;
  final int maxSyncRetries;
  final Duration syncTimeout;
  final Map<String, List<String>> customCategories;
  final List<String> favoriteFeatures;
  final List<String> hiddenFeatures;
  final List<String> quickActionButtons;
  final List<String> dashboardWidgets;

  /// Getters computados
  bool get hasQuietHours => quietHoursStart != null && quietHoursEnd != null;
  bool get isInQuietHours {
    if (!hasQuietHours) return false;
    final now = TimeOfDay.now();
    return _isTimeInRange(now, quietHoursStart!, quietHoursEnd!);
  }

  bool get isAccessibilityEnabled => enableHighContrast || enableVoiceOver || enableReducedMotion;
  bool get isPrivacyFocused => !sharePhotosByDefault && !shareWeightDataByDefault && !shareMedicalDataByDefault;

  /// Configurações de emergência críticas
  bool get hasEmergencySettings => allowEmergencyAccess && hasEmergencyContacts;
  Map<String, dynamic> get emergencySettings => {
    'allow_emergency_access': allowEmergencyAccess,
    'share_medical_data': shareMedicalDataByDefault,
    'enable_emergency_alerts': enableEmergencyAlerts,
  };

  @override
  Map<String, dynamic> toFirebaseMap() {
    final Map<String, dynamic> map = {
      ...baseFirebaseFields,
      'language': language,
      'theme': theme.toString().split('.').last,
      'currency': currency,
      'weight_unit': weightUnit.toString().split('.').last,
      'temperature_unit': temperatureUnit.toString().split('.').last,
      'date_format': dateFormat.toString().split('.').last,
      'time_format': timeFormat.toString().split('.').last,
      'enable_notifications': enableNotifications,
      'enable_medication_reminders': enableMedicationReminders,
      'enable_appointment_reminders': enableAppointmentReminders,
      'enable_weight_tracking_reminders': enableWeightTrackingReminders,
      'enable_emergency_alerts': enableEmergencyAlerts,
      'notification_sound': notificationSound.toString().split('.').last,
      'quiet_hours_start': quietHoursStart != null ? '${quietHoursStart!.hour}:${quietHoursStart!.minute}' : null,
      'quiet_hours_end': quietHoursEnd != null ? '${quietHoursEnd!.hour}:${quietHoursEnd!.minute}' : null,
      'medication_reminder_advance_minutes': medicationReminderAdvance.inMinutes,
      'appointment_reminder_advance_hours': appointmentReminderAdvance.inHours,
      'allow_emergency_access': allowEmergencyAccess,
      'auto_backup_enabled': autoBackupEnabled,
      'auto_backup_frequency': autoBackupFrequency.toString().split('.').last,
      'include_photos_in_backup': includePhotosInBackup,
      'only_backup_on_wifi': onlyBackupOnWifi,
      'max_local_storage_days': maxLocalStorageDays,
      'enable_data_export': enableDataExport,
      'font_size': fontSize.toString().split('.').last,
      'enable_high_contrast': enableHighContrast,
      'enable_voice_over': enableVoiceOver,
      'enable_haptic_feedback': enableHapticFeedback,
      'enable_reduced_motion': enableReducedMotion,
      'color_blindness_type': colorBlindnessType?.toString().split('.').last,
      'default_animal_view_mode': defaultAnimalViewMode.toString().split('.').last,
      'show_age_in_days': showAgeInDays,
      'enable_weight_trends': enableWeightTrends,
      'enable_medication_adherence': enableMedicationAdherence,
      'enable_vet_reminders': enableVetReminders,
      'auto_calculate_next_vaccination': autoCalculateNextVaccination,
      'preferred_veterinarian_id': preferredVeterinarianId,
      'default_reminder_lead_time_hours': defaultReminderLeadTime.inHours,
      'developer_mode': developerMode,
      'enable_analytics': enableAnalytics,
      'enable_crash_reporting': enableCrashReporting,
      'enable_beta_features': enableBetaFeatures,
      'max_sync_retries': maxSyncRetries,
      'sync_timeout_minutes': syncTimeout.inMinutes,
      'custom_categories': customCategories,
      'favorite_features': favoriteFeatures,
      'hidden_features': hiddenFeatures,
      'quick_action_buttons': quickActionButtons,
      'dashboard_widgets': dashboardWidgets,
      'has_quiet_hours': hasQuietHours,
      'has_emergency_contacts': hasEmergencyContacts,
      'is_accessibility_enabled': isAccessibilityEnabled,
      'is_privacy_focused': isPrivacyFocused,
      'has_emergency_settings': hasEmergencySettings,
      'emergency_settings': emergencySettings,
    };
    map.removeWhere((key, value) => value == null);
    return map;
  }

  static UserSettingsSyncEntity fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);

    return UserSettingsSyncEntity(
      id: baseFields['id'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: (baseFields['isDirty'] as bool?) ?? false,
      isDeleted: (baseFields['isDeleted'] as bool?) ?? false,
      version: (baseFields['version'] as int?) ?? 1,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      language: map['language'] as String? ?? 'pt-BR',
      theme: _parseAppTheme(map['theme'] as String?),
      currency: map['currency'] as String? ?? 'BRL',
      weightUnit: _parseWeightUnit(map['weight_unit'] as String?),
      temperatureUnit: _parseTemperatureUnit(map['temperature_unit'] as String?),
      dateFormat: _parseDateFormat(map['date_format'] as String?),
      timeFormat: _parseTimeFormat(map['time_format'] as String?),
      enableNotifications: map['enable_notifications'] as bool? ?? true,
      enableMedicationReminders: map['enable_medication_reminders'] as bool? ?? true,
      enableAppointmentReminders: map['enable_appointment_reminders'] as bool? ?? true,
      enableWeightTrackingReminders: map['enable_weight_tracking_reminders'] as bool? ?? false,
      enableEmergencyAlerts: map['enable_emergency_alerts'] as bool? ?? true,
      notificationSound: _parseNotificationSound(map['notification_sound'] as String?),
      quietHoursStart: _parseTimeOfDay(map['quiet_hours_start'] as String?),
      quietHoursEnd: _parseTimeOfDay(map['quiet_hours_end'] as String?),
      medicationReminderAdvance: Duration(minutes: map['medication_reminder_advance_minutes'] as int? ?? 15),
      appointmentReminderAdvance: Duration(hours: map['appointment_reminder_advance_hours'] as int? ?? 2),
      allowEmergencyAccess: map['allow_emergency_access'] as bool? ?? true,
      autoBackupEnabled: map['auto_backup_enabled'] as bool? ?? true,
      autoBackupFrequency: _parseBackupFrequency(map['auto_backup_frequency'] as String?),
      includePhotosInBackup: map['include_photos_in_backup'] as bool? ?? false,
      onlyBackupOnWifi: map['only_backup_on_wifi'] as bool? ?? true,
      maxLocalStorageDays: map['max_local_storage_days'] as int? ?? 365,
      enableDataExport: map['enable_data_export'] as bool? ?? true,
      fontSize: _parseFontSize(map['font_size'] as String?),
      enableHighContrast: map['enable_high_contrast'] as bool? ?? false,
      enableVoiceOver: map['enable_voice_over'] as bool? ?? false,
      enableHapticFeedback: map['enable_haptic_feedback'] as bool? ?? true,
      enableReducedMotion: map['enable_reduced_motion'] as bool? ?? false,
      colorBlindnessType: _parseColorBlindnessType(map['color_blindness_type'] as String?),
      defaultAnimalViewMode: _parseAnimalViewMode(map['default_animal_view_mode'] as String?),
      showAgeInDays: map['show_age_in_days'] as bool? ?? false,
      enableWeightTrends: map['enable_weight_trends'] as bool? ?? true,
      enableMedicationAdherence: map['enable_medication_adherence'] as bool? ?? true,
      enableVetReminders: map['enable_vet_reminders'] as bool? ?? true,
      autoCalculateNextVaccination: map['auto_calculate_next_vaccination'] as bool? ?? true,
      preferredVeterinarianId: map['preferred_veterinarian_id'] as String?,
      defaultReminderLeadTime: Duration(hours: map['default_reminder_lead_time_hours'] as int? ?? 24),
      developerMode: map['developer_mode'] as bool? ?? false,
      enableAnalytics: map['enable_analytics'] as bool? ?? true,
      enableCrashReporting: map['enable_crash_reporting'] as bool? ?? true,
      enableBetaFeatures: map['enable_beta_features'] as bool? ?? false,
      maxSyncRetries: map['max_sync_retries'] as int? ?? 3,
      syncTimeout: Duration(minutes: map['sync_timeout_minutes'] as int? ?? 5),
      customCategories: Map<String, List<String>>.from(
        (map['custom_categories'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as List<dynamic>).map((e) => e as String).toList()),
        ) ?? {},
      ),
      favoriteFeatures: (map['favorite_features'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [],
      hiddenFeatures: (map['hidden_features'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [],
      quickActionButtons: (map['quick_action_buttons'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [],
      dashboardWidgets: (map['dashboard_widgets'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [],
    );
  }
  static AppTheme _parseAppTheme(String? value) {
    if (value == null) return AppTheme.system;
    try {
      return AppTheme.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return AppTheme.system;
    }
  }

  static WeightUnit _parseWeightUnit(String? value) {
    if (value == null) return WeightUnit.kg;
    try {
      return WeightUnit.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return WeightUnit.kg;
    }
  }

  static TemperatureUnit _parseTemperatureUnit(String? value) {
    if (value == null) return TemperatureUnit.celsius;
    try {
      return TemperatureUnit.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return TemperatureUnit.celsius;
    }
  }

  static DateFormat _parseDateFormat(String? value) {
    if (value == null) return DateFormat.ddmmyyyy;
    try {
      return DateFormat.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return DateFormat.ddmmyyyy;
    }
  }

  static TimeFormat _parseTimeFormat(String? value) {
    if (value == null) return TimeFormat.h24;
    try {
      return TimeFormat.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return TimeFormat.h24;
    }
  }

  static NotificationSound _parseNotificationSound(String? value) {
    if (value == null) return NotificationSound.defaultSound;
    try {
      return NotificationSound.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return NotificationSound.defaultSound;
    }
  }

  static BackupFrequency _parseBackupFrequency(String? value) {
    if (value == null) return BackupFrequency.daily;
    try {
      return BackupFrequency.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return BackupFrequency.daily;
    }
  }

  static FontSize _parseFontSize(String? value) {
    if (value == null) return FontSize.normal;
    try {
      return FontSize.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return FontSize.normal;
    }
  }

  static ColorBlindnessType? _parseColorBlindnessType(String? value) {
    if (value == null) return null;
    try {
      return ColorBlindnessType.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return null;
    }
  }

  static AnimalViewMode _parseAnimalViewMode(String? value) {
    if (value == null) return AnimalViewMode.list;
    try {
      return AnimalViewMode.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return AnimalViewMode.list;
    }
  }

  static TimeOfDay? _parseTimeOfDay(String? value) {
    if (value == null) return null;
    try {
      final parts = value.split(':');
      if (parts.length == 2) {
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (e) {
    }
    return null;
  }

  bool _isTimeInRange(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  @override
  UserSettingsSyncEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    String? language,
    AppTheme? theme,
    String? currency,
    WeightUnit? weightUnit,
    TemperatureUnit? temperatureUnit,
    DateFormat? dateFormat,
    TimeFormat? timeFormat,
    bool? enableNotifications,
    bool? enableMedicationReminders,
    bool? enableAppointmentReminders,
    bool? enableWeightTrackingReminders,
    bool? enableEmergencyAlerts,
    NotificationSound? notificationSound,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    Duration? medicationReminderAdvance,
    Duration? appointmentReminderAdvance,
    bool? allowEmergencyAccess,
    bool? autoBackupEnabled,
    BackupFrequency? autoBackupFrequency,
    bool? includePhotosInBackup,
    bool? onlyBackupOnWifi,
    int? maxLocalStorageDays,
    bool? enableDataExport,
    FontSize? fontSize,
    bool? enableHighContrast,
    bool? enableVoiceOver,
    bool? enableHapticFeedback,
    bool? enableReducedMotion,
    ColorBlindnessType? colorBlindnessType,
    AnimalViewMode? defaultAnimalViewMode,
    bool? showAgeInDays,
    bool? enableWeightTrends,
    bool? enableMedicationAdherence,
    bool? enableVetReminders,
    bool? autoCalculateNextVaccination,
    String? preferredVeterinarianId,
    Duration? defaultReminderLeadTime,
    bool? developerMode,
    bool? enableAnalytics,
    bool? enableCrashReporting,
    bool? enableBetaFeatures,
    int? maxSyncRetries,
    Duration? syncTimeout,
    Map<String, List<String>>? customCategories,
    List<String>? favoriteFeatures,
    List<String>? hiddenFeatures,
    List<String>? quickActionButtons,
    List<String>? dashboardWidgets,
  }) {
    return UserSettingsSyncEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      currency: currency ?? this.currency,
      weightUnit: weightUnit ?? this.weightUnit,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableMedicationReminders: enableMedicationReminders ?? this.enableMedicationReminders,
      enableAppointmentReminders: enableAppointmentReminders ?? this.enableAppointmentReminders,
      enableWeightTrackingReminders: enableWeightTrackingReminders ?? this.enableWeightTrackingReminders,
      enableEmergencyAlerts: enableEmergencyAlerts ?? this.enableEmergencyAlerts,
      notificationSound: notificationSound ?? this.notificationSound,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      medicationReminderAdvance: medicationReminderAdvance ?? this.medicationReminderAdvance,
      appointmentReminderAdvance: appointmentReminderAdvance ?? this.appointmentReminderAdvance,
      allowEmergencyAccess: allowEmergencyAccess ?? this.allowEmergencyAccess,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      autoBackupFrequency: autoBackupFrequency ?? this.autoBackupFrequency,
      includePhotosInBackup: includePhotosInBackup ?? this.includePhotosInBackup,
      onlyBackupOnWifi: onlyBackupOnWifi ?? this.onlyBackupOnWifi,
      maxLocalStorageDays: maxLocalStorageDays ?? this.maxLocalStorageDays,
      enableDataExport: enableDataExport ?? this.enableDataExport,
      fontSize: fontSize ?? this.fontSize,
      enableHighContrast: enableHighContrast ?? this.enableHighContrast,
      enableVoiceOver: enableVoiceOver ?? this.enableVoiceOver,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableReducedMotion: enableReducedMotion ?? this.enableReducedMotion,
      colorBlindnessType: colorBlindnessType ?? this.colorBlindnessType,
      defaultAnimalViewMode: defaultAnimalViewMode ?? this.defaultAnimalViewMode,
      showAgeInDays: showAgeInDays ?? this.showAgeInDays,
      enableWeightTrends: enableWeightTrends ?? this.enableWeightTrends,
      enableMedicationAdherence: enableMedicationAdherence ?? this.enableMedicationAdherence,
      enableVetReminders: enableVetReminders ?? this.enableVetReminders,
      autoCalculateNextVaccination: autoCalculateNextVaccination ?? this.autoCalculateNextVaccination,
      preferredVeterinarianId: preferredVeterinarianId ?? this.preferredVeterinarianId,
      defaultReminderLeadTime: defaultReminderLeadTime ?? this.defaultReminderLeadTime,
      developerMode: developerMode ?? this.developerMode,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      enableBetaFeatures: enableBetaFeatures ?? this.enableBetaFeatures,
      maxSyncRetries: maxSyncRetries ?? this.maxSyncRetries,
      syncTimeout: syncTimeout ?? this.syncTimeout,
      customCategories: customCategories ?? this.customCategories,
      favoriteFeatures: favoriteFeatures ?? this.favoriteFeatures,
      hiddenFeatures: hiddenFeatures ?? this.hiddenFeatures,
      quickActionButtons: quickActionButtons ?? this.quickActionButtons,
      dashboardWidgets: dashboardWidgets ?? this.dashboardWidgets,
    );
  }

  @override
  UserSettingsSyncEntity markAsDirty() {
    return copyWith(
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  UserSettingsSyncEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  UserSettingsSyncEntity markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  UserSettingsSyncEntity incrementVersion() {
    return copyWith(
      version: version + 1,
      updatedAt: DateTime.now(),
    );
  }

  @override
  UserSettingsSyncEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  UserSettingsSyncEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }

  /// Métodos de conveniência


  /// Configura horário silencioso
  UserSettingsSyncEntity setQuietHours(TimeOfDay start, TimeOfDay end) {
    return copyWith(
      quietHoursStart: start,
      quietHoursEnd: end,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Ativa modo de emergência
  UserSettingsSyncEntity enableEmergencyMode() {
    return copyWith(
      allowEmergencyAccess: true,
      enableEmergencyAlerts: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    language,
    theme,
    currency,
    weightUnit,
    temperatureUnit,
    dateFormat,
    timeFormat,
    enableNotifications,
    enableMedicationReminders,
    enableAppointmentReminders,
    enableWeightTrackingReminders,
    enableEmergencyAlerts,
    notificationSound,
    quietHoursStart,
    quietHoursEnd,
    medicationReminderAdvance,
    appointmentReminderAdvance,
    allowEmergencyAccess,
    autoBackupEnabled,
    autoBackupFrequency,
    includePhotosInBackup,
    onlyBackupOnWifi,
    maxLocalStorageDays,
    enableDataExport,
    fontSize,
    enableHighContrast,
    enableVoiceOver,
    enableHapticFeedback,
    enableReducedMotion,
    colorBlindnessType,
    defaultAnimalViewMode,
    showAgeInDays,
    enableWeightTrends,
    enableMedicationAdherence,
    enableVetReminders,
    autoCalculateNextVaccination,
    preferredVeterinarianId,
    defaultReminderLeadTime,
    developerMode,
    enableAnalytics,
    enableCrashReporting,
    enableBetaFeatures,
    maxSyncRetries,
    syncTimeout,
    customCategories,
    favoriteFeatures,
    hiddenFeatures,
    quickActionButtons,
    dashboardWidgets,
  ];
}

enum AppTheme { light, dark, system }
enum WeightUnit { kg, lb }
enum TemperatureUnit { celsius, fahrenheit }
enum DateFormat { ddmmyyyy, mmddyyyy, yyyymmdd }
enum TimeFormat { h12, h24 }
enum NotificationSound { defaultSound, none, custom }
enum BackupFrequency { daily, weekly, monthly, never }
enum FontSize { small, normal, large, extraLarge }
enum ColorBlindnessType { protanopia, deuteranopia, tritanopia }
enum AnimalViewMode { list, grid, cards }

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  static TimeOfDay now() {
    final now = DateTime.now();
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeOfDay && hour == other.hour && minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}