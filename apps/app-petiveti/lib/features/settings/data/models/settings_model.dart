import '../../domain/entities/app_settings.dart';

/// Data model for AppSettings with JSON serialization
class SettingsModel extends AppSettings {
  const SettingsModel({
    required super.id,
    super.darkMode,
    super.notificationsEnabled,
    super.language,
    super.soundsEnabled,
    super.vibrationEnabled,
    super.reminderHoursBefore,
    super.autoSync,
    super.lastSyncAt,
  });

  /// Create from AppSettings entity
  factory SettingsModel.fromEntity(AppSettings entity) {
    return SettingsModel(
      id: entity.id,
      darkMode: entity.darkMode,
      notificationsEnabled: entity.notificationsEnabled,
      language: entity.language,
      soundsEnabled: entity.soundsEnabled,
      vibrationEnabled: entity.vibrationEnabled,
      reminderHoursBefore: entity.reminderHoursBefore,
      autoSync: entity.autoSync,
      lastSyncAt: entity.lastSyncAt,
    );
  }

  /// Create from JSON map
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      id: json['id'] as String? ?? 'default',
      darkMode: json['dark_mode'] as bool? ?? false,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      language: json['language'] as String? ?? 'pt_BR',
      soundsEnabled: json['sounds_enabled'] as bool? ?? true,
      vibrationEnabled: json['vibration_enabled'] as bool? ?? true,
      reminderHoursBefore: json['reminder_hours_before'] as int? ?? 24,
      autoSync: json['auto_sync'] as bool? ?? true,
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.tryParse(json['last_sync_at'] as String)
          : null,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dark_mode': darkMode,
      'notifications_enabled': notificationsEnabled,
      'language': language,
      'sounds_enabled': soundsEnabled,
      'vibration_enabled': vibrationEnabled,
      'reminder_hours_before': reminderHoursBefore,
      'auto_sync': autoSync,
      'last_sync_at': lastSyncAt?.toIso8601String(),
    };
  }

  /// Convert to entity
  AppSettings toEntity() {
    return AppSettings(
      id: id,
      darkMode: darkMode,
      notificationsEnabled: notificationsEnabled,
      language: language,
      soundsEnabled: soundsEnabled,
      vibrationEnabled: vibrationEnabled,
      reminderHoursBefore: reminderHoursBefore,
      autoSync: autoSync,
      lastSyncAt: lastSyncAt,
    );
  }

  @override
  SettingsModel copyWith({
    String? id,
    bool? darkMode,
    bool? notificationsEnabled,
    String? language,
    bool? soundsEnabled,
    bool? vibrationEnabled,
    int? reminderHoursBefore,
    bool? autoSync,
    DateTime? lastSyncAt,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      reminderHoursBefore: reminderHoursBefore ?? this.reminderHoursBefore,
      autoSync: autoSync ?? this.autoSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}
