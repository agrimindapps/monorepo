import '../../domain/entities/galaga_settings.dart';

class GalagaSettingsModel extends GalagaSettings {
  const GalagaSettingsModel({
    super.soundEnabled,
    super.musicEnabled,
    super.difficulty,
  });

  factory GalagaSettingsModel.fromEntity(GalagaSettings entity) {
    return GalagaSettingsModel(
      soundEnabled: entity.soundEnabled,
      musicEnabled: entity.musicEnabled,
      difficulty: entity.difficulty,
    );
  }

  factory GalagaSettingsModel.fromJson(Map<String, dynamic> json) {
    return GalagaSettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      difficulty: GalagaDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] as String? ?? 'normal'),
        orElse: () => GalagaDifficulty.normal,
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
