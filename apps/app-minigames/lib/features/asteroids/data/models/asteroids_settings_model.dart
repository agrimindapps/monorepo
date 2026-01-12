import '../../domain/entities/asteroids_settings.dart';

class AsteroidsSettingsModel extends AsteroidsSettings {
  const AsteroidsSettingsModel({
    super.soundEnabled,
    super.musicEnabled,
    super.difficulty,
  });

  factory AsteroidsSettingsModel.fromEntity(AsteroidsSettings entity) {
    return AsteroidsSettingsModel(
      soundEnabled: entity.soundEnabled,
      musicEnabled: entity.musicEnabled,
      difficulty: entity.difficulty,
    );
  }

  factory AsteroidsSettingsModel.fromJson(Map<String, dynamic> json) {
    return AsteroidsSettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      difficulty: AsteroidsDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] as String? ?? 'normal'),
        orElse: () => AsteroidsDifficulty.normal,
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
