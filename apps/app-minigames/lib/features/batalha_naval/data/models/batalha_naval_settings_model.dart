import '../../domain/entities/batalha_naval_settings.dart';

class BatalhaNavalSettingsModel extends BatalhaNavalSettings {
  BatalhaNavalSettingsModel({
    super.soundEnabled,
    super.musicEnabled,
    super.difficulty,
  });

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'difficulty': difficulty.index,
    };
  }

  factory BatalhaNavalSettingsModel.fromJson(Map<String, dynamic> json) {
    return BatalhaNavalSettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      difficulty:
          BatalhaNavalDifficulty.values[json['difficulty'] as int? ?? 1],
    );
  }

  factory BatalhaNavalSettingsModel.fromEntity(BatalhaNavalSettings entity) {
    return BatalhaNavalSettingsModel(
      soundEnabled: entity.soundEnabled,
      musicEnabled: entity.musicEnabled,
      difficulty: entity.difficulty,
    );
  }
}
