import '../../domain/entities/game_stats.dart';

/// Data model for GameStats with JSON serialization
/// Extends domain entity to add persistence capabilities
class GameStatsModel extends GameStats {
  const GameStatsModel({
    required super.xWins,
    required super.oWins,
    required super.draws,
  });

  /// Creates model from domain entity
  factory GameStatsModel.fromEntity(GameStats entity) {
    return GameStatsModel(
      xWins: entity.xWins,
      oWins: entity.oWins,
      draws: entity.draws,
    );
  }

  /// Creates model from JSON map
  factory GameStatsModel.fromJson(Map<String, dynamic> json) {
    return GameStatsModel(
      xWins: json['xWins'] as int? ?? 0,
      oWins: json['oWins'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
    );
  }

  /// Converts model to JSON map for persistence
  Map<String, dynamic> toJson() {
    return {
      'xWins': xWins,
      'oWins': oWins,
      'draws': draws,
    };
  }
}
