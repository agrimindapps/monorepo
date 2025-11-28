import 'dart:convert';
import '../../domain/entities/campo_minado_statistics.dart';
import '../../domain/entities/enums.dart';

/// Data model for difficulty statistics with JSON serialization
class DifficultyStatsModel extends DifficultyStats {
  const DifficultyStatsModel({
    required super.difficulty,
    super.totalGames,
    super.totalWins,
    super.bestTime,
    super.currentStreak,
    super.bestStreak,
  });

  factory DifficultyStatsModel.fromEntity(DifficultyStats entity) {
    return DifficultyStatsModel(
      difficulty: entity.difficulty,
      totalGames: entity.totalGames,
      totalWins: entity.totalWins,
      bestTime: entity.bestTime,
      currentStreak: entity.currentStreak,
      bestStreak: entity.bestStreak,
    );
  }

  factory DifficultyStatsModel.fromJson(Map<String, dynamic> json) {
    return DifficultyStatsModel(
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.beginner,
      ),
      totalGames: json['totalGames'] as int? ?? 0,
      totalWins: json['totalWins'] as int? ?? 0,
      bestTime: json['bestTime'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty.name,
      'totalGames': totalGames,
      'totalWins': totalWins,
      'bestTime': bestTime,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
    };
  }

  factory DifficultyStatsModel.empty(Difficulty difficulty) {
    return DifficultyStatsModel(difficulty: difficulty);
  }
}

/// Data model for expanded Campo Minado statistics with JSON serialization
class CampoMinadoStatisticsModel extends CampoMinadoStatistics {
  const CampoMinadoStatisticsModel({
    required DifficultyStatsModel beginnerStats,
    required DifficultyStatsModel intermediateStats,
    required DifficultyStatsModel expertStats,
    super.totalGamesPlayed,
    super.totalWins,
    super.totalCellsRevealed,
    super.totalFlagsPlaced,
    super.totalChordClicks,
    super.perfectGames,
    super.totalSecondsPlayed,
    super.currentGlobalStreak,
    super.bestGlobalStreak,
    super.largestFirstClickReveal,
    super.lastPlayedAt,
  }) : super(
          beginnerStats: beginnerStats,
          intermediateStats: intermediateStats,
          expertStats: expertStats,
        );

  factory CampoMinadoStatisticsModel.fromEntity(CampoMinadoStatistics entity) {
    return CampoMinadoStatisticsModel(
      beginnerStats: DifficultyStatsModel.fromEntity(entity.beginnerStats),
      intermediateStats:
          DifficultyStatsModel.fromEntity(entity.intermediateStats),
      expertStats: DifficultyStatsModel.fromEntity(entity.expertStats),
      totalGamesPlayed: entity.totalGamesPlayed,
      totalWins: entity.totalWins,
      totalCellsRevealed: entity.totalCellsRevealed,
      totalFlagsPlaced: entity.totalFlagsPlaced,
      totalChordClicks: entity.totalChordClicks,
      perfectGames: entity.perfectGames,
      totalSecondsPlayed: entity.totalSecondsPlayed,
      currentGlobalStreak: entity.currentGlobalStreak,
      bestGlobalStreak: entity.bestGlobalStreak,
      largestFirstClickReveal: entity.largestFirstClickReveal,
      lastPlayedAt: entity.lastPlayedAt,
    );
  }

  factory CampoMinadoStatisticsModel.fromJson(Map<String, dynamic> json) {
    return CampoMinadoStatisticsModel(
      beginnerStats: json['beginnerStats'] != null
          ? DifficultyStatsModel.fromJson(
              json['beginnerStats'] as Map<String, dynamic>)
          : DifficultyStatsModel.empty(Difficulty.beginner),
      intermediateStats: json['intermediateStats'] != null
          ? DifficultyStatsModel.fromJson(
              json['intermediateStats'] as Map<String, dynamic>)
          : DifficultyStatsModel.empty(Difficulty.intermediate),
      expertStats: json['expertStats'] != null
          ? DifficultyStatsModel.fromJson(
              json['expertStats'] as Map<String, dynamic>)
          : DifficultyStatsModel.empty(Difficulty.expert),
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
      totalWins: json['totalWins'] as int? ?? 0,
      totalCellsRevealed: json['totalCellsRevealed'] as int? ?? 0,
      totalFlagsPlaced: json['totalFlagsPlaced'] as int? ?? 0,
      totalChordClicks: json['totalChordClicks'] as int? ?? 0,
      perfectGames: json['perfectGames'] as int? ?? 0,
      totalSecondsPlayed: json['totalSecondsPlayed'] as int? ?? 0,
      currentGlobalStreak: json['currentGlobalStreak'] as int? ?? 0,
      bestGlobalStreak: json['bestGlobalStreak'] as int? ?? 0,
      largestFirstClickReveal: json['largestFirstClickReveal'] as int? ?? 0,
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastPlayedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'beginnerStats':
          DifficultyStatsModel.fromEntity(beginnerStats).toJson(),
      'intermediateStats':
          DifficultyStatsModel.fromEntity(intermediateStats).toJson(),
      'expertStats': DifficultyStatsModel.fromEntity(expertStats).toJson(),
      'totalGamesPlayed': totalGamesPlayed,
      'totalWins': totalWins,
      'totalCellsRevealed': totalCellsRevealed,
      'totalFlagsPlaced': totalFlagsPlaced,
      'totalChordClicks': totalChordClicks,
      'perfectGames': perfectGames,
      'totalSecondsPlayed': totalSecondsPlayed,
      'currentGlobalStreak': currentGlobalStreak,
      'bestGlobalStreak': bestGlobalStreak,
      'largestFirstClickReveal': largestFirstClickReveal,
      'lastPlayedAt': lastPlayedAt?.millisecondsSinceEpoch,
    };
  }

  factory CampoMinadoStatisticsModel.empty() {
    return CampoMinadoStatisticsModel(
      beginnerStats: DifficultyStatsModel.empty(Difficulty.beginner),
      intermediateStats: DifficultyStatsModel.empty(Difficulty.intermediate),
      expertStats: DifficultyStatsModel.empty(Difficulty.expert),
    );
  }

  /// Create from JSON string
  factory CampoMinadoStatisticsModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return CampoMinadoStatisticsModel.fromJson(json);
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }
}

/// Data model for game session statistics
class GameSessionStatsModel extends GameSessionStats {
  const GameSessionStatsModel({
    super.cellsRevealedThisGame,
    super.flagsPlacedThisGame,
    super.wrongFlagsThisGame,
    super.chordClicksThisGame,
    super.firstClickRevealCount,
    super.hadFirstClick,
  });

  factory GameSessionStatsModel.fromEntity(GameSessionStats entity) {
    return GameSessionStatsModel(
      cellsRevealedThisGame: entity.cellsRevealedThisGame,
      flagsPlacedThisGame: entity.flagsPlacedThisGame,
      wrongFlagsThisGame: entity.wrongFlagsThisGame,
      chordClicksThisGame: entity.chordClicksThisGame,
      firstClickRevealCount: entity.firstClickRevealCount,
      hadFirstClick: entity.hadFirstClick,
    );
  }

  factory GameSessionStatsModel.fromJson(Map<String, dynamic> json) {
    return GameSessionStatsModel(
      cellsRevealedThisGame: json['cellsRevealedThisGame'] as int? ?? 0,
      flagsPlacedThisGame: json['flagsPlacedThisGame'] as int? ?? 0,
      wrongFlagsThisGame: json['wrongFlagsThisGame'] as int? ?? 0,
      chordClicksThisGame: json['chordClicksThisGame'] as int? ?? 0,
      firstClickRevealCount: json['firstClickRevealCount'] as int? ?? 0,
      hadFirstClick: json['hadFirstClick'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cellsRevealedThisGame': cellsRevealedThisGame,
      'flagsPlacedThisGame': flagsPlacedThisGame,
      'wrongFlagsThisGame': wrongFlagsThisGame,
      'chordClicksThisGame': chordClicksThisGame,
      'firstClickRevealCount': firstClickRevealCount,
      'hadFirstClick': hadFirstClick,
    };
  }

  factory GameSessionStatsModel.empty() => const GameSessionStatsModel();
}
