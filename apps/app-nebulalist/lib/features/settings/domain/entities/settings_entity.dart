import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  final String themeMode;
  final String language;
  final bool notificationsEnabled;
  final bool soundEffectsEnabled;
  final String defaultView;
  final bool autoSyncEnabled;
  final bool showCompletedTasks;

  const SettingsEntity({
    required this.themeMode,
    required this.language,
    required this.notificationsEnabled,
    required this.soundEffectsEnabled,
    required this.defaultView,
    required this.autoSyncEnabled,
    required this.showCompletedTasks,
  });

  factory SettingsEntity.defaultSettings() {
    return const SettingsEntity(
      themeMode: 'system',
      language: 'pt',
      notificationsEnabled: true,
      soundEffectsEnabled: true,
      defaultView: 'list',
      autoSyncEnabled: true,
      showCompletedTasks: false,
    );
  }

  SettingsEntity copyWith({
    String? themeMode,
    String? language,
    bool? notificationsEnabled,
    bool? soundEffectsEnabled,
    String? defaultView,
    bool? autoSyncEnabled,
    bool? showCompletedTasks,
  }) {
    return SettingsEntity(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      defaultView: defaultView ?? this.defaultView,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      showCompletedTasks: showCompletedTasks ?? this.showCompletedTasks,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        language,
        notificationsEnabled,
        soundEffectsEnabled,
        defaultView,
        autoSyncEnabled,
        showCompletedTasks,
      ];
}
