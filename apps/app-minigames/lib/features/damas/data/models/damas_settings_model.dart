import '../../domain/entities/damas_settings.dart';

class DamasSettingsModel extends DamasSettings {
  const DamasSettingsModel({
    super.soundEnabled,
    super.musicEnabled,
    super.playAgainstAI,
    super.difficulty,
  });

  factory DamasSettingsModel.fromEntity(DamasSettings entity) {
    return DamasSettingsModel(
      soundEnabled: entity.soundEnabled,
      musicEnabled: entity.musicEnabled,
      playAgainstAI: entity.playAgainstAI,
      difficulty: entity.difficulty,
    );
  }

  factory DamasSettingsModel.fromJson(Map<String, dynamic> json) {
    return DamasSettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      playAgainstAI: json['playAgainstAI'] as bool? ?? false,
      difficulty: DamasDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] as String? ?? 'normal'),
        orElse: () => DamasDifficulty.normal,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'playAgainstAI': playAgainstAI,
      'difficulty': difficulty.name,
    };
  }
}
