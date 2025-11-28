import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Statistics for a specific Sudoku difficulty level
class SudokuDifficultyStats extends Equatable {
  final GameDifficulty difficulty;
  final int puzzlesCompleted;
  final int puzzlesStarted;
  final int bestTimeSeconds;
  final int totalMistakes;
  final int perfectGames; // Games without mistakes
  final int noHintGames; // Games without hints
  final int currentStreak;
  final int bestStreak;

  const SudokuDifficultyStats({
    required this.difficulty,
    this.puzzlesCompleted = 0,
    this.puzzlesStarted = 0,
    this.bestTimeSeconds = 0,
    this.totalMistakes = 0,
    this.perfectGames = 0,
    this.noHintGames = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
  });

  factory SudokuDifficultyStats.empty(GameDifficulty difficulty) {
    return SudokuDifficultyStats(difficulty: difficulty);
  }

  double get completionRate =>
      puzzlesStarted > 0 ? puzzlesCompleted / puzzlesStarted : 0.0;
  int get completionRatePercent => (completionRate * 100).round();

  SudokuDifficultyStats copyWith({
    GameDifficulty? difficulty,
    int? puzzlesCompleted,
    int? puzzlesStarted,
    int? bestTimeSeconds,
    int? totalMistakes,
    int? perfectGames,
    int? noHintGames,
    int? currentStreak,
    int? bestStreak,
  }) {
    return SudokuDifficultyStats(
      difficulty: difficulty ?? this.difficulty,
      puzzlesCompleted: puzzlesCompleted ?? this.puzzlesCompleted,
      puzzlesStarted: puzzlesStarted ?? this.puzzlesStarted,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
      totalMistakes: totalMistakes ?? this.totalMistakes,
      perfectGames: perfectGames ?? this.perfectGames,
      noHintGames: noHintGames ?? this.noHintGames,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }

  @override
  List<Object?> get props => [
        difficulty,
        puzzlesCompleted,
        puzzlesStarted,
        bestTimeSeconds,
        totalMistakes,
        perfectGames,
        noHintGames,
        currentStreak,
        bestStreak,
      ];
}

/// Expanded statistics for Sudoku achievements
class SudokuStatistics extends Equatable {
  // Per difficulty stats
  final SudokuDifficultyStats easyStats;
  final SudokuDifficultyStats mediumStats;
  final SudokuDifficultyStats hardStats;

  // Global stats
  final int totalPuzzlesStarted;
  final int totalPuzzlesCompleted;
  final int totalCellsFilled;
  final int totalCorrectPlacements;
  final int totalMistakes;
  final int totalHintsUsed;
  final int totalNotesPlaced;
  final int totalSecondsPlayed;
  final int perfectGames; // Without mistakes
  final int noHintGames; // Without hints
  final int perfectNoHintGames; // Without mistakes AND without hints
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastPlayedAt;

  const SudokuStatistics({
    required this.easyStats,
    required this.mediumStats,
    required this.hardStats,
    this.totalPuzzlesStarted = 0,
    this.totalPuzzlesCompleted = 0,
    this.totalCellsFilled = 0,
    this.totalCorrectPlacements = 0,
    this.totalMistakes = 0,
    this.totalHintsUsed = 0,
    this.totalNotesPlaced = 0,
    this.totalSecondsPlayed = 0,
    this.perfectGames = 0,
    this.noHintGames = 0,
    this.perfectNoHintGames = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastPlayedAt,
  });

  factory SudokuStatistics.empty() {
    return SudokuStatistics(
      easyStats: SudokuDifficultyStats.empty(GameDifficulty.easy),
      mediumStats: SudokuDifficultyStats.empty(GameDifficulty.medium),
      hardStats: SudokuDifficultyStats.empty(GameDifficulty.hard),
    );
  }

  // Computed properties
  double get globalCompletionRate =>
      totalPuzzlesStarted > 0 ? totalPuzzlesCompleted / totalPuzzlesStarted : 0.0;
  int get globalCompletionRatePercent => (globalCompletionRate * 100).round();

  int get easyCompleted => easyStats.puzzlesCompleted;
  int get mediumCompleted => mediumStats.puzzlesCompleted;
  int get hardCompleted => hardStats.puzzlesCompleted;

  int get easyBestTime => easyStats.bestTimeSeconds;
  int get mediumBestTime => mediumStats.bestTimeSeconds;
  int get hardBestTime => hardStats.bestTimeSeconds;

  /// Count of unique difficulties completed
  int get difficultiesCompleted {
    int count = 0;
    if (easyCompleted > 0) count++;
    if (mediumCompleted > 0) count++;
    if (hardCompleted > 0) count++;
    return count;
  }

  /// Get stats for a specific difficulty
  SudokuDifficultyStats getStatsForDifficulty(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return easyStats;
      case GameDifficulty.medium:
        return mediumStats;
      case GameDifficulty.hard:
        return hardStats;
    }
  }

  SudokuStatistics copyWith({
    SudokuDifficultyStats? easyStats,
    SudokuDifficultyStats? mediumStats,
    SudokuDifficultyStats? hardStats,
    int? totalPuzzlesStarted,
    int? totalPuzzlesCompleted,
    int? totalCellsFilled,
    int? totalCorrectPlacements,
    int? totalMistakes,
    int? totalHintsUsed,
    int? totalNotesPlaced,
    int? totalSecondsPlayed,
    int? perfectGames,
    int? noHintGames,
    int? perfectNoHintGames,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastPlayedAt,
  }) {
    return SudokuStatistics(
      easyStats: easyStats ?? this.easyStats,
      mediumStats: mediumStats ?? this.mediumStats,
      hardStats: hardStats ?? this.hardStats,
      totalPuzzlesStarted: totalPuzzlesStarted ?? this.totalPuzzlesStarted,
      totalPuzzlesCompleted: totalPuzzlesCompleted ?? this.totalPuzzlesCompleted,
      totalCellsFilled: totalCellsFilled ?? this.totalCellsFilled,
      totalCorrectPlacements: totalCorrectPlacements ?? this.totalCorrectPlacements,
      totalMistakes: totalMistakes ?? this.totalMistakes,
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      totalNotesPlaced: totalNotesPlaced ?? this.totalNotesPlaced,
      totalSecondsPlayed: totalSecondsPlayed ?? this.totalSecondsPlayed,
      perfectGames: perfectGames ?? this.perfectGames,
      noHintGames: noHintGames ?? this.noHintGames,
      perfectNoHintGames: perfectNoHintGames ?? this.perfectNoHintGames,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  @override
  List<Object?> get props => [
        easyStats,
        mediumStats,
        hardStats,
        totalPuzzlesStarted,
        totalPuzzlesCompleted,
        totalCellsFilled,
        totalCorrectPlacements,
        totalMistakes,
        totalHintsUsed,
        totalNotesPlaced,
        totalSecondsPlayed,
        perfectGames,
        noHintGames,
        perfectNoHintGames,
        currentStreak,
        bestStreak,
        lastPlayedAt,
      ];
}

/// Statistics tracked during a single Sudoku game session
class SudokuSessionStats extends Equatable {
  final int cellsFilledThisGame;
  final int mistakesThisGame;
  final int hintsUsedThisGame;
  final int notesPlacedThisGame;
  final bool usedNotesMode;

  const SudokuSessionStats({
    this.cellsFilledThisGame = 0,
    this.mistakesThisGame = 0,
    this.hintsUsedThisGame = 0,
    this.notesPlacedThisGame = 0,
    this.usedNotesMode = false,
  });

  factory SudokuSessionStats.empty() => const SudokuSessionStats();

  bool get isPerfectGame => mistakesThisGame == 0;
  bool get isNoHintGame => hintsUsedThisGame == 0;
  bool get isPerfectNoHintGame => isPerfectGame && isNoHintGame;

  SudokuSessionStats copyWith({
    int? cellsFilledThisGame,
    int? mistakesThisGame,
    int? hintsUsedThisGame,
    int? notesPlacedThisGame,
    bool? usedNotesMode,
  }) {
    return SudokuSessionStats(
      cellsFilledThisGame: cellsFilledThisGame ?? this.cellsFilledThisGame,
      mistakesThisGame: mistakesThisGame ?? this.mistakesThisGame,
      hintsUsedThisGame: hintsUsedThisGame ?? this.hintsUsedThisGame,
      notesPlacedThisGame: notesPlacedThisGame ?? this.notesPlacedThisGame,
      usedNotesMode: usedNotesMode ?? this.usedNotesMode,
    );
  }

  @override
  List<Object?> get props => [
        cellsFilledThisGame,
        mistakesThisGame,
        hintsUsedThisGame,
        notesPlacedThisGame,
        usedNotesMode,
      ];
}
