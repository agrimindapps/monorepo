import 'dart:convert';

// Domain imports:
import '../../domain/entities/snake_statistics.dart';

/// Model for SnakeStatistics (extends entity, adds JSON serialization)
class SnakeStatisticsModel extends SnakeStatistics {
  const SnakeStatisticsModel({
    super.totalGamesPlayed,
    super.totalFoodEaten,
    super.totalPowerUpsCollected,
    super.totalSecondsPlayed,
    super.longestSnake,
    super.highestScore,
    super.totalDeaths,
    super.powerUpsByType,
    super.deathsByType,
    super.gamesWonHard,
    super.gamesWonMedium,
    super.gamesWonEasy,
    super.currentWinStreak,
    super.bestWinStreak,
    super.lastPlayedAt,
  });

  /// Create from JSON
  factory SnakeStatisticsModel.fromJson(Map<String, dynamic> json) {
    return SnakeStatisticsModel(
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
      totalFoodEaten: json['totalFoodEaten'] as int? ?? 0,
      totalPowerUpsCollected: json['totalPowerUpsCollected'] as int? ?? 0,
      totalSecondsPlayed: json['totalSecondsPlayed'] as int? ?? 0,
      longestSnake: json['longestSnake'] as int? ?? 0,
      highestScore: json['highestScore'] as int? ?? 0,
      totalDeaths: json['totalDeaths'] as int? ?? 0,
      powerUpsByType: _parseStringIntMap(json['powerUpsByType']),
      deathsByType: _parseStringIntMap(json['deathsByType']),
      gamesWonHard: json['gamesWonHard'] as int? ?? 0,
      gamesWonMedium: json['gamesWonMedium'] as int? ?? 0,
      gamesWonEasy: json['gamesWonEasy'] as int? ?? 0,
      currentWinStreak: json['currentWinStreak'] as int? ?? 0,
      bestWinStreak: json['bestWinStreak'] as int? ?? 0,
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.tryParse(json['lastPlayedAt'] as String)
          : null,
    );
  }

  /// Parse map from JSON
  static Map<String, int> _parseStringIntMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) {
      return value.map((k, v) => MapEntry(k, (v as int?) ?? 0));
    }
    return {};
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalFoodEaten': totalFoodEaten,
      'totalPowerUpsCollected': totalPowerUpsCollected,
      'totalSecondsPlayed': totalSecondsPlayed,
      'longestSnake': longestSnake,
      'highestScore': highestScore,
      'totalDeaths': totalDeaths,
      'powerUpsByType': powerUpsByType,
      'deathsByType': deathsByType,
      'gamesWonHard': gamesWonHard,
      'gamesWonMedium': gamesWonMedium,
      'gamesWonEasy': gamesWonEasy,
      'currentWinStreak': currentWinStreak,
      'bestWinStreak': bestWinStreak,
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
    };
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory SnakeStatisticsModel.fromJsonString(String jsonString) {
    return SnakeStatisticsModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  /// Create from entity
  factory SnakeStatisticsModel.fromEntity(SnakeStatistics entity) {
    return SnakeStatisticsModel(
      totalGamesPlayed: entity.totalGamesPlayed,
      totalFoodEaten: entity.totalFoodEaten,
      totalPowerUpsCollected: entity.totalPowerUpsCollected,
      totalSecondsPlayed: entity.totalSecondsPlayed,
      longestSnake: entity.longestSnake,
      highestScore: entity.highestScore,
      totalDeaths: entity.totalDeaths,
      powerUpsByType: entity.powerUpsByType,
      deathsByType: entity.deathsByType,
      gamesWonHard: entity.gamesWonHard,
      gamesWonMedium: entity.gamesWonMedium,
      gamesWonEasy: entity.gamesWonEasy,
      currentWinStreak: entity.currentWinStreak,
      bestWinStreak: entity.bestWinStreak,
      lastPlayedAt: entity.lastPlayedAt,
    );
  }

  /// Empty statistics
  factory SnakeStatisticsModel.empty() => const SnakeStatisticsModel();
}
