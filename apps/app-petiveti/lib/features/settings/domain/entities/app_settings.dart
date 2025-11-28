import 'package:core/core.dart';

/// Entity representing application settings
class AppSettings extends Equatable {
  const AppSettings({
    required this.id,
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.language = 'pt_BR',
    this.soundsEnabled = true,
    this.vibrationEnabled = true,
    this.reminderHoursBefore = 24,
    this.autoSync = true,
    this.lastSyncAt,
  });

  final String id;
  final bool darkMode;
  final bool notificationsEnabled;
  final String language;
  final bool soundsEnabled;
  final bool vibrationEnabled;
  final int reminderHoursBefore;
  final bool autoSync;
  final DateTime? lastSyncAt;

  /// Default settings factory
  factory AppSettings.defaults() => const AppSettings(id: 'default');

  AppSettings copyWith({
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
    return AppSettings(
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

  @override
  List<Object?> get props => [
        id,
        darkMode,
        notificationsEnabled,
        language,
        soundsEnabled,
        vibrationEnabled,
        reminderHoursBefore,
        autoSync,
        lastSyncAt,
      ];
}
