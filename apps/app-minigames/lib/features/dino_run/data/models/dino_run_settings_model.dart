import '../../domain/entities/dino_run_settings.dart';

class DinoRunSettingsModel extends DinoRunSettings {
  const DinoRunSettingsModel({
    super.soundEnabled,
    super.musicEnabled,
    super.difficulty,
  });

  factory DinoRunSettingsModel.fromEntity(DinoRunSettings entity) {
    return DinoRunSettingsModel(
      soundEnabled: entity.soundEnabled,
      musicEnabled: entity.musicEnabled,
      difficulty: entity.difficulty,
    );
  }

  factory DinoRunSettingsModel.fromJson(Map<String, dynamic> json) {
    return DinoRunSettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      difficulty: DinoRunDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] as String? ?? 'normal'),
        orElse: () => DinoRunDifficulty.normal,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'difficulty': difficulty.name,
    };
  }
}
