import '../../domain/entities/frogger_settings.dart';

class FroggerSettingsModel extends FroggerSettings {
  const FroggerSettingsModel({
    super.soundEnabled,
    super.musicEnabled,
    super.difficulty,
  });

  factory FroggerSettingsModel.fromEntity(FroggerSettings entity) {
    return FroggerSettingsModel(
      soundEnabled: entity.soundEnabled,
      musicEnabled: entity.musicEnabled,
      difficulty: entity.difficulty,
    );
  }

  factory FroggerSettingsModel.fromJson(Map<String, dynamic> json) {
    return FroggerSettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      difficulty: FroggerDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] as String? ?? 'normal'),
        orElse: () => FroggerDifficulty.normal,
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
