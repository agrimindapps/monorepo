import '../../domain/entities/settings_entity.dart';

class SettingsModel extends SettingsEntity {
  const SettingsModel({
    required super.themeMode,
    required super.language,
    required super.notificationsEnabled,
    required super.soundEffectsEnabled,
    required super.defaultView,
    required super.autoSyncEnabled,
    required super.showCompletedTasks,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      themeMode: json['themeMode'] as String? ?? 'system',
      language: json['language'] as String? ?? 'pt',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEffectsEnabled: json['soundEffectsEnabled'] as bool? ?? true,
      defaultView: json['defaultView'] as String? ?? 'list',
      autoSyncEnabled: json['autoSyncEnabled'] as bool? ?? true,
      showCompletedTasks: json['showCompletedTasks'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'soundEffectsEnabled': soundEffectsEnabled,
      'defaultView': defaultView,
      'autoSyncEnabled': autoSyncEnabled,
      'showCompletedTasks': showCompletedTasks,
    };
  }

  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      themeMode: entity.themeMode,
      language: entity.language,
      notificationsEnabled: entity.notificationsEnabled,
      soundEffectsEnabled: entity.soundEffectsEnabled,
      defaultView: entity.defaultView,
      autoSyncEnabled: entity.autoSyncEnabled,
      showCompletedTasks: entity.showCompletedTasks,
    );
  }
}
