import '../../domain/entities/space_invaders_settings.dart';

class SpaceInvadersSettingsModel extends SpaceInvadersSettings {
  const SpaceInvadersSettingsModel({
    super.soundEnabled,
    super.musicEnabled,
    super.soundVolume,
    super.musicVolume,
    super.difficulty,
    super.showFPS,
  });

  factory SpaceInvadersSettingsModel.fromEntity(SpaceInvadersSettings entity) {
    return SpaceInvadersSettingsModel(
      soundEnabled: entity.soundEnabled,
      musicEnabled: entity.musicEnabled,
      soundVolume: entity.soundVolume,
      musicVolume: entity.musicVolume,
      difficulty: entity.difficulty,
      showFPS: entity.showFPS,
    );
  }

  factory SpaceInvadersSettingsModel.fromJson(Map<String, dynamic> json) {
    return SpaceInvadersSettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      soundVolume: (json['soundVolume'] as num?)?.toDouble() ?? 0.7,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.5,
      difficulty: SpaceInvadersDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] as String? ?? 'normal'),
        orElse: () => SpaceInvadersDifficulty.normal,
      ),
      showFPS: json['showFPS'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'soundVolume': soundVolume,
      'musicVolume': musicVolume,
      'difficulty': difficulty.name,
      'showFPS': showFPS,
    };
  }
}
