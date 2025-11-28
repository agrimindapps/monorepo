import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Statistics for a specific difficulty level
class DifficultyStats extends Equatable {
  final Difficulty difficulty;
  final int totalGames;
  final int totalWins;
  final int bestTime; // in seconds, 0 means no best time yet
  final int currentStreak;
  final int bestStreak;

  const DifficultyStats({
    required this.difficulty,
    this.totalGames = 0,
    this.totalWins = 0,
    this.bestTime = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
  });

  factory DifficultyStats.empty(Difficulty difficulty) {
    return DifficultyStats(difficulty: difficulty);
  }

  double get winRate => totalGames > 0 ? totalWins / totalGames : 0.0;
  int get winRatePercent => (winRate * 100).round();

  DifficultyStats copyWith({
    Difficulty? difficulty,
    int? totalGames,
    int? totalWins,
    int? bestTime,
    int? currentStreak,
    int? bestStreak,
  }) {
    return DifficultyStats(
      difficulty: difficulty ?? this.difficulty,
      totalGames: totalGames ?? this.totalGames,
      totalWins: totalWins ?? this.totalWins,
      bestTime: bestTime ?? this.bestTime,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }

  @override
  List<Object?> get props => [
        difficulty,
        totalGames,
        totalWins,
        bestTime,
        currentStreak,
        bestStreak,
      ];
}

/// Expanded statistics for Campo Minado achievements
class CampoMinadoStatistics extends Equatable {
  // Per difficulty stats
  final DifficultyStats beginnerStats;
  final DifficultyStats intermediateStats;
  final DifficultyStats expertStats;

  // Global stats
  final int totalGamesPlayed;
  final int totalWins;
  final int totalCellsRevealed;
  final int totalFlagsPlaced;
  final int totalChordClicks;
  final int perfectGames; // Games won without wrong flags
  final int totalSecondsPlayed;
  final int currentGlobalStreak;
  final int bestGlobalStreak;
  final int largestFirstClickReveal; // Largest area revealed on first click
  final DateTime? lastPlayedAt;

  const CampoMinadoStatistics({
    required this.beginnerStats,
    required this.intermediateStats,
    required this.expertStats,
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
    this.totalCellsRevealed = 0,
    this.totalFlagsPlaced = 0,
    this.totalChordClicks = 0,
    this.perfectGames = 0,
    this.totalSecondsPlayed = 0,
    this.currentGlobalStreak = 0,
    this.bestGlobalStreak = 0,
    this.largestFirstClickReveal = 0,
    this.lastPlayedAt,
  });

  factory CampoMinadoStatistics.empty() {
    return CampoMinadoStatistics(
      beginnerStats: DifficultyStats.empty(Difficulty.beginner),
      intermediateStats: DifficultyStats.empty(Difficulty.intermediate),
      expertStats: DifficultyStats.empty(Difficulty.expert),
    );
  }

  // Computed properties
  double get globalWinRate =>
      totalGamesPlayed > 0 ? totalWins / totalGamesPlayed : 0.0;
  int get globalWinRatePercent => (globalWinRate * 100).round();

  int get beginnerWins => beginnerStats.totalWins;
  int get intermediateWins => intermediateStats.totalWins;
  int get expertWins => expertStats.totalWins;

  int get beginnerBestTime => beginnerStats.bestTime;
  int get intermediateBestTime => intermediateStats.bestTime;
  int get expertBestTime => expertStats.bestTime;

  /// Count of unique difficulties won
  int get difficultiesWon {
    int count = 0;
    if (beginnerWins > 0) count++;
    if (intermediateWins > 0) count++;
    if (expertWins > 0) count++;
    return count;
  }

  /// Get stats for a specific difficulty
  DifficultyStats getStatsForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return beginnerStats;
      case Difficulty.intermediate:
        return intermediateStats;
      case Difficulty.expert:
        return expertStats;
      case Difficulty.custom:
        return DifficultyStats.empty(Difficulty.custom);
    }
  }

  CampoMinadoStatistics copyWith({
    DifficultyStats? beginnerStats,
    DifficultyStats? intermediateStats,
    DifficultyStats? expertStats,
    int? totalGamesPlayed,
    int? totalWins,
    int? totalCellsRevealed,
    int? totalFlagsPlaced,
    int? totalChordClicks,
    int? perfectGames,
    int? totalSecondsPlayed,
    int? currentGlobalStreak,
    int? bestGlobalStreak,
    int? largestFirstClickReveal,
    DateTime? lastPlayedAt,
  }) {
    return CampoMinadoStatistics(
      beginnerStats: beginnerStats ?? this.beginnerStats,
      intermediateStats: intermediateStats ?? this.intermediateStats,
      expertStats: expertStats ?? this.expertStats,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalWins: totalWins ?? this.totalWins,
      totalCellsRevealed: totalCellsRevealed ?? this.totalCellsRevealed,
      totalFlagsPlaced: totalFlagsPlaced ?? this.totalFlagsPlaced,
      totalChordClicks: totalChordClicks ?? this.totalChordClicks,
      perfectGames: perfectGames ?? this.perfectGames,
      totalSecondsPlayed: totalSecondsPlayed ?? this.totalSecondsPlayed,
      currentGlobalStreak: currentGlobalStreak ?? this.currentGlobalStreak,
      bestGlobalStreak: bestGlobalStreak ?? this.bestGlobalStreak,
      largestFirstClickReveal:
          largestFirstClickReveal ?? this.largestFirstClickReveal,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  @override
  List<Object?> get props => [
        beginnerStats,
        intermediateStats,
        expertStats,
        totalGamesPlayed,
        totalWins,
        totalCellsRevealed,
        totalFlagsPlaced,
        totalChordClicks,
        perfectGames,
        totalSecondsPlayed,
        currentGlobalStreak,
        bestGlobalStreak,
        largestFirstClickReveal,
        lastPlayedAt,
      ];
}

/// Statistics tracked during a single game session
class GameSessionStats extends Equatable {
  final int cellsRevealedThisGame;
  final int flagsPlacedThisGame;
  final int wrongFlagsThisGame;
  final int chordClicksThisGame;
  final int firstClickRevealCount;
  final bool hadFirstClick;

  const GameSessionStats({
    this.cellsRevealedThisGame = 0,
    this.flagsPlacedThisGame = 0,
    this.wrongFlagsThisGame = 0,
    this.chordClicksThisGame = 0,
    this.firstClickRevealCount = 0,
    this.hadFirstClick = false,
  });

  factory GameSessionStats.empty() => const GameSessionStats();

  bool get isPerfectGame => wrongFlagsThisGame == 0;

  GameSessionStats copyWith({
    int? cellsRevealedThisGame,
    int? flagsPlacedThisGame,
    int? wrongFlagsThisGame,
    int? chordClicksThisGame,
    int? firstClickRevealCount,
    bool? hadFirstClick,
  }) {
    return GameSessionStats(
      cellsRevealedThisGame:
          cellsRevealedThisGame ?? this.cellsRevealedThisGame,
      flagsPlacedThisGame: flagsPlacedThisGame ?? this.flagsPlacedThisGame,
      wrongFlagsThisGame: wrongFlagsThisGame ?? this.wrongFlagsThisGame,
      chordClicksThisGame: chordClicksThisGame ?? this.chordClicksThisGame,
      firstClickRevealCount:
          firstClickRevealCount ?? this.firstClickRevealCount,
      hadFirstClick: hadFirstClick ?? this.hadFirstClick,
    );
  }

  @override
  List<Object?> get props => [
        cellsRevealedThisGame,
        flagsPlacedThisGame,
        wrongFlagsThisGame,
        chordClicksThisGame,
        firstClickRevealCount,
        hadFirstClick,
      ];
}
