import '../../domain/entities/game_stats.dart';
import '../../domain/entities/enums.dart';

/// Data model for game statistics with JSON serialization
class GameStatsModel extends GameStats {
  const GameStatsModel({
    required super.difficulty,
    required super.bestTime,
    required super.totalGames,
    required super.totalWins,
    required super.currentStreak,
    required super.bestStreak,
  });

  /// Creates model from entity
  factory GameStatsModel.fromEntity(GameStats entity) {
    return GameStatsModel(
      difficulty: entity.difficulty,
      bestTime: entity.bestTime,
      totalGames: entity.totalGames,
      totalWins: entity.totalWins,
      currentStreak: entity.currentStreak,
      bestStreak: entity.bestStreak,
    );
  }

  /// Creates model from JSON
  factory GameStatsModel.fromJson(Map<String, dynamic> json) {
    return GameStatsModel(
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.beginner,
      ),
      bestTime: json['bestTime'] as int? ?? 0,
      totalGames: json['totalGames'] as int? ?? 0,
      totalWins: json['totalWins'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
    );
  }

  /// Converts model to JSON
  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty.name,
      'bestTime': bestTime,
      'totalGames': totalGames,
      'totalWins': totalWins,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
    };
  }

  /// Creates empty model
  factory GameStatsModel.empty({Difficulty difficulty = Difficulty.beginner}) {
    return GameStatsModel(
      difficulty: difficulty,
      bestTime: 0,
      totalGames: 0,
      totalWins: 0,
      currentStreak: 0,
      bestStreak: 0,
    );
  }
}
