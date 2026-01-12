import '../../domain/entities/connect_four_settings.dart';

class ConnectFourSettingsModel extends ConnectFourSettings {
  const ConnectFourSettingsModel({
    super.soundEnabled,
    super.musicEnabled,
    super.difficulty,
  });

  factory ConnectFourSettingsModel.fromEntity(ConnectFourSettings entity) {
    return ConnectFourSettingsModel(
      soundEnabled: entity.soundEnabled,
      musicEnabled: entity.musicEnabled,
      difficulty: entity.difficulty,
    );
  }

  factory ConnectFourSettingsModel.fromJson(Map<String, dynamic> json) {
    return ConnectFourSettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      difficulty: ConnectFourDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] as String? ?? 'normal'),
        orElse: () => ConnectFourDifficulty.normal,
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
