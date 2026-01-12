import '../../domain/entities/arkanoid_settings.dart';

class ArkanoidSettingsModel extends ArkanoidSettings {
  const ArkanoidSettingsModel({
    super.soundEnabled,
    super.musicEnabled,
    super.soundVolume,
    super.musicVolume,
    super.difficulty,
  });

  factory ArkanoidSettingsModel.fromEntity(ArkanoidSettings entity) {
    return ArkanoidSettingsModel(
      soundEnabled: entity.soundEnabled,
      musicEnabled: entity.musicEnabled,
      soundVolume: entity.soundVolume,
      musicVolume: entity.musicVolume,
      difficulty: entity.difficulty,
    );
  }

  factory ArkanoidSettingsModel.fromJson(Map<String, dynamic> json) {
    return ArkanoidSettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      soundVolume: (json['soundVolume'] as num?)?.toDouble() ?? 0.7,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.5,
      difficulty: ArkanoidDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] as String? ?? 'normal'),
        orElse: () => ArkanoidDifficulty.normal,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'soundVolume': soundVolume,
      'musicVolume': musicVolume,
      'difficulty': difficulty.name,
    };
  }
}

