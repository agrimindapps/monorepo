import '../../domain/entities/simon_settings.dart';

class SimonSettingsModel extends SimonSettings {
  const SimonSettingsModel({
    super.soundEnabled,
    super.musicEnabled,
    super.soundVolume,
    super.musicVolume,
    super.difficulty,
    super.colorblindMode,
    super.colorCount,
  });

  factory SimonSettingsModel.fromEntity(SimonSettings entity) {
    return SimonSettingsModel(
      soundEnabled: entity.soundEnabled,
      musicEnabled: entity.musicEnabled,
      soundVolume: entity.soundVolume,
      musicVolume: entity.musicVolume,
      difficulty: entity.difficulty,
      colorblindMode: entity.colorblindMode,
      colorCount: entity.colorCount,
    );
  }

  factory SimonSettingsModel.fromJson(Map<String, dynamic> json) {
    return SimonSettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      soundVolume: (json['soundVolume'] as num?)?.toDouble() ?? 0.7,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.5,
      difficulty: SimonDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] as String? ?? 'normal'),
        orElse: () => SimonDifficulty.normal,
      ),
      colorblindMode: json['colorblindMode'] as bool? ?? false,
      colorCount: json['colorCount'] as int? ?? 4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'soundVolume': soundVolume,
      'musicVolume': musicVolume,
      'difficulty': difficulty.name,
      'colorblindMode': colorblindMode,
      'colorCount': colorCount,
    };
  }
}
