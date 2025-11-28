import 'dart:convert';
import '../../domain/entities/sudoku_statistics.dart';
import '../../domain/entities/enums.dart';

/// Data model for Sudoku difficulty statistics with JSON serialization
class SudokuDifficultyStatsModel extends SudokuDifficultyStats {
  const SudokuDifficultyStatsModel({
    required super.difficulty,
    super.puzzlesCompleted,
    super.puzzlesStarted,
    super.bestTimeSeconds,
    super.totalMistakes,
    super.perfectGames,
    super.noHintGames,
    super.currentStreak,
    super.bestStreak,
  });

  factory SudokuDifficultyStatsModel.fromEntity(SudokuDifficultyStats entity) {
    return SudokuDifficultyStatsModel(
      difficulty: entity.difficulty,
      puzzlesCompleted: entity.puzzlesCompleted,
      puzzlesStarted: entity.puzzlesStarted,
      bestTimeSeconds: entity.bestTimeSeconds,
      totalMistakes: entity.totalMistakes,
      perfectGames: entity.perfectGames,
      noHintGames: entity.noHintGames,
      currentStreak: entity.currentStreak,
      bestStreak: entity.bestStreak,
    );
  }

  factory SudokuDifficultyStatsModel.fromJson(Map<String, dynamic> json) {
    return SudokuDifficultyStatsModel(
      difficulty: GameDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => GameDifficulty.easy,
      ),
      puzzlesCompleted: json['puzzlesCompleted'] as int? ?? 0,
      puzzlesStarted: json['puzzlesStarted'] as int? ?? 0,
      bestTimeSeconds: json['bestTimeSeconds'] as int? ?? 0,
      totalMistakes: json['totalMistakes'] as int? ?? 0,
      perfectGames: json['perfectGames'] as int? ?? 0,
      noHintGames: json['noHintGames'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty.name,
      'puzzlesCompleted': puzzlesCompleted,
      'puzzlesStarted': puzzlesStarted,
      'bestTimeSeconds': bestTimeSeconds,
      'totalMistakes': totalMistakes,
      'perfectGames': perfectGames,
      'noHintGames': noHintGames,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
    };
  }

  factory SudokuDifficultyStatsModel.empty(GameDifficulty difficulty) {
    return SudokuDifficultyStatsModel(difficulty: difficulty);
  }
}

/// Data model for expanded Sudoku statistics with JSON serialization
class SudokuStatisticsModel extends SudokuStatistics {
  const SudokuStatisticsModel({
    required SudokuDifficultyStatsModel easyStats,
    required SudokuDifficultyStatsModel mediumStats,
    required SudokuDifficultyStatsModel hardStats,
    super.totalPuzzlesStarted,
    super.totalPuzzlesCompleted,
    super.totalCellsFilled,
    super.totalCorrectPlacements,
    super.totalMistakes,
    super.totalHintsUsed,
    super.totalNotesPlaced,
    super.totalSecondsPlayed,
    super.perfectGames,
    super.noHintGames,
    super.perfectNoHintGames,
    super.currentStreak,
    super.bestStreak,
    super.lastPlayedAt,
  }) : super(
          easyStats: easyStats,
          mediumStats: mediumStats,
          hardStats: hardStats,
        );

  factory SudokuStatisticsModel.fromEntity(SudokuStatistics entity) {
    return SudokuStatisticsModel(
      easyStats: SudokuDifficultyStatsModel.fromEntity(entity.easyStats),
      mediumStats: SudokuDifficultyStatsModel.fromEntity(entity.mediumStats),
      hardStats: SudokuDifficultyStatsModel.fromEntity(entity.hardStats),
      totalPuzzlesStarted: entity.totalPuzzlesStarted,
      totalPuzzlesCompleted: entity.totalPuzzlesCompleted,
      totalCellsFilled: entity.totalCellsFilled,
      totalCorrectPlacements: entity.totalCorrectPlacements,
      totalMistakes: entity.totalMistakes,
      totalHintsUsed: entity.totalHintsUsed,
      totalNotesPlaced: entity.totalNotesPlaced,
      totalSecondsPlayed: entity.totalSecondsPlayed,
      perfectGames: entity.perfectGames,
      noHintGames: entity.noHintGames,
      perfectNoHintGames: entity.perfectNoHintGames,
      currentStreak: entity.currentStreak,
      bestStreak: entity.bestStreak,
      lastPlayedAt: entity.lastPlayedAt,
    );
  }

  factory SudokuStatisticsModel.fromJson(Map<String, dynamic> json) {
    return SudokuStatisticsModel(
      easyStats: json['easyStats'] != null
          ? SudokuDifficultyStatsModel.fromJson(
              json['easyStats'] as Map<String, dynamic>)
          : SudokuDifficultyStatsModel.empty(GameDifficulty.easy),
      mediumStats: json['mediumStats'] != null
          ? SudokuDifficultyStatsModel.fromJson(
              json['mediumStats'] as Map<String, dynamic>)
          : SudokuDifficultyStatsModel.empty(GameDifficulty.medium),
      hardStats: json['hardStats'] != null
          ? SudokuDifficultyStatsModel.fromJson(
              json['hardStats'] as Map<String, dynamic>)
          : SudokuDifficultyStatsModel.empty(GameDifficulty.hard),
      totalPuzzlesStarted: json['totalPuzzlesStarted'] as int? ?? 0,
      totalPuzzlesCompleted: json['totalPuzzlesCompleted'] as int? ?? 0,
      totalCellsFilled: json['totalCellsFilled'] as int? ?? 0,
      totalCorrectPlacements: json['totalCorrectPlacements'] as int? ?? 0,
      totalMistakes: json['totalMistakes'] as int? ?? 0,
      totalHintsUsed: json['totalHintsUsed'] as int? ?? 0,
      totalNotesPlaced: json['totalNotesPlaced'] as int? ?? 0,
      totalSecondsPlayed: json['totalSecondsPlayed'] as int? ?? 0,
      perfectGames: json['perfectGames'] as int? ?? 0,
      noHintGames: json['noHintGames'] as int? ?? 0,
      perfectNoHintGames: json['perfectNoHintGames'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastPlayedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'easyStats': SudokuDifficultyStatsModel.fromEntity(easyStats).toJson(),
      'mediumStats':
          SudokuDifficultyStatsModel.fromEntity(mediumStats).toJson(),
      'hardStats': SudokuDifficultyStatsModel.fromEntity(hardStats).toJson(),
      'totalPuzzlesStarted': totalPuzzlesStarted,
      'totalPuzzlesCompleted': totalPuzzlesCompleted,
      'totalCellsFilled': totalCellsFilled,
      'totalCorrectPlacements': totalCorrectPlacements,
      'totalMistakes': totalMistakes,
      'totalHintsUsed': totalHintsUsed,
      'totalNotesPlaced': totalNotesPlaced,
      'totalSecondsPlayed': totalSecondsPlayed,
      'perfectGames': perfectGames,
      'noHintGames': noHintGames,
      'perfectNoHintGames': perfectNoHintGames,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastPlayedAt': lastPlayedAt?.millisecondsSinceEpoch,
    };
  }

  factory SudokuStatisticsModel.empty() {
    return SudokuStatisticsModel(
      easyStats: SudokuDifficultyStatsModel.empty(GameDifficulty.easy),
      mediumStats: SudokuDifficultyStatsModel.empty(GameDifficulty.medium),
      hardStats: SudokuDifficultyStatsModel.empty(GameDifficulty.hard),
    );
  }

  /// Create from JSON string
  factory SudokuStatisticsModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return SudokuStatisticsModel.fromJson(json);
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }
}

/// Data model for Sudoku session statistics
class SudokuSessionStatsModel extends SudokuSessionStats {
  const SudokuSessionStatsModel({
    super.cellsFilledThisGame,
    super.mistakesThisGame,
    super.hintsUsedThisGame,
    super.notesPlacedThisGame,
    super.usedNotesMode,
  });

  factory SudokuSessionStatsModel.fromEntity(SudokuSessionStats entity) {
    return SudokuSessionStatsModel(
      cellsFilledThisGame: entity.cellsFilledThisGame,
      mistakesThisGame: entity.mistakesThisGame,
      hintsUsedThisGame: entity.hintsUsedThisGame,
      notesPlacedThisGame: entity.notesPlacedThisGame,
      usedNotesMode: entity.usedNotesMode,
    );
  }

  factory SudokuSessionStatsModel.fromJson(Map<String, dynamic> json) {
    return SudokuSessionStatsModel(
      cellsFilledThisGame: json['cellsFilledThisGame'] as int? ?? 0,
      mistakesThisGame: json['mistakesThisGame'] as int? ?? 0,
      hintsUsedThisGame: json['hintsUsedThisGame'] as int? ?? 0,
      notesPlacedThisGame: json['notesPlacedThisGame'] as int? ?? 0,
      usedNotesMode: json['usedNotesMode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cellsFilledThisGame': cellsFilledThisGame,
      'mistakesThisGame': mistakesThisGame,
      'hintsUsedThisGame': hintsUsedThisGame,
      'notesPlacedThisGame': notesPlacedThisGame,
      'usedNotesMode': usedNotesMode,
    };
  }

  factory SudokuSessionStatsModel.empty() => const SudokuSessionStatsModel();
}
