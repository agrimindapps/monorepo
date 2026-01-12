import '../../domain/entities/tetris_settings.dart';

/// Model para serialização do TetrisSettings
class TetrisSettingsModel extends TetrisSettings {
  const TetrisSettingsModel({
    super.soundEnabled,
    super.musicEnabled,
    super.ghostPieceEnabled,
    super.theme,
    super.soundVolume,
    super.musicVolume,
  });

  /// Cria model a partir de entity
  factory TetrisSettingsModel.fromEntity(TetrisSettings entity) {
    return TetrisSettingsModel(
      soundEnabled: entity.soundEnabled,
      musicEnabled: entity.musicEnabled,
      ghostPieceEnabled: entity.ghostPieceEnabled,
      theme: entity.theme,
      soundVolume: entity.soundVolume,
      musicVolume: entity.musicVolume,
    );
  }

  /// Cria model a partir de JSON
  factory TetrisSettingsModel.fromJson(Map<String, dynamic> json) {
    return TetrisSettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      ghostPieceEnabled: json['ghostPieceEnabled'] as bool? ?? true,
      theme: TetrisTheme.values.firstWhere(
        (e) => e.name == (json['theme'] as String?),
        orElse: () => TetrisTheme.classic,
      ),
      soundVolume: (json['soundVolume'] as num?)?.toDouble() ?? 0.7,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.5,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'ghostPieceEnabled': ghostPieceEnabled,
      'theme': theme.name,
      'soundVolume': soundVolume,
      'musicVolume': musicVolume,
    };
  }

  /// Converte para entity
  TetrisSettings toEntity() {
    return TetrisSettings(
      soundEnabled: soundEnabled,
      musicEnabled: musicEnabled,
      ghostPieceEnabled: ghostPieceEnabled,
      theme: theme,
      soundVolume: soundVolume,
      musicVolume: musicVolume,
    );
  }
}
