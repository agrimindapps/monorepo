import '../../domain/entities/game_settings.dart';
import '../../domain/entities/enums.dart';

/// Data model for GameSettings with JSON serialization
/// Extends domain entity to add persistence capabilities
class GameSettingsModel extends GameSettings {
  const GameSettingsModel({
    required super.gameMode,
    required super.difficulty,
  });

  /// Creates model from domain entity
  factory GameSettingsModel.fromEntity(GameSettings entity) {
    return GameSettingsModel(
      gameMode: entity.gameMode,
      difficulty: entity.difficulty,
    );
  }

  /// Creates model from JSON map
  factory GameSettingsModel.fromJson(Map<String, dynamic> json) {
    return GameSettingsModel(
      gameMode: GameMode.values.firstWhere(
        (e) => e.name == json['gameMode'],
        orElse: () => GameMode.vsPlayer,
      ),
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => Difficulty.medium,
      ),
    );
  }

  /// Converts model to JSON map for persistence
  Map<String, dynamic> toJson() {
    return {
      'gameMode': gameMode.name,
      'difficulty': difficulty.name,
    };
  }
}
