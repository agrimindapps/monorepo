// Package imports:
import 'package:equatable/equatable.dart';

/// Entity representing player statistics for snake game
class SnakeStatistics extends Equatable {
  final int totalGamesPlayed;
  final int totalFoodEaten;
  final int totalPowerUpsCollected;
  final int totalSecondsPlayed;
  final int longestSnake;
  final int highestScore;
  final int totalDeaths;
  final Map<String, int> powerUpsByType;
  final Map<String, int> deathsByType;
  final int gamesWonHard;
  final int gamesWonMedium;
  final int gamesWonEasy;
  final int currentWinStreak;
  final int bestWinStreak;
  final DateTime? lastPlayedAt;

  const SnakeStatistics({
    this.totalGamesPlayed = 0,
    this.totalFoodEaten = 0,
    this.totalPowerUpsCollected = 0,
    this.totalSecondsPlayed = 0,
    this.longestSnake = 0,
    this.highestScore = 0,
    this.totalDeaths = 0,
    this.powerUpsByType = const {},
    this.deathsByType = const {},
    this.gamesWonHard = 0,
    this.gamesWonMedium = 0,
    this.gamesWonEasy = 0,
    this.currentWinStreak = 0,
    this.bestWinStreak = 0,
    this.lastPlayedAt,
  });

  /// Empty statistics
  factory SnakeStatistics.empty() => const SnakeStatistics();

  /// Computed getters
  double get averageScore =>
      totalGamesPlayed > 0 ? highestScore / totalGamesPlayed : 0;

  double get survivalRate =>
      totalGamesPlayed > 0 ? (totalGamesPlayed - totalDeaths) / totalGamesPlayed : 0;

  int get totalMinutesPlayed => totalSecondsPlayed ~/ 60;

  int get totalHoursPlayed => totalMinutesPlayed ~/ 60;

  double get averageGameDuration =>
      totalGamesPlayed > 0 ? totalSecondsPlayed / totalGamesPlayed : 0;

  double get averageSnakeLength =>
      totalGamesPlayed > 0 ? longestSnake / totalGamesPlayed : 0;

  int get totalGamesWon => gamesWonHard + gamesWonMedium + gamesWonEasy;

  double get winRate =>
      totalGamesPlayed > 0 ? totalGamesWon / totalGamesPlayed : 0;

  String get formattedPlayTime {
    if (totalHoursPlayed > 0) {
      return '${totalHoursPlayed}h ${totalMinutesPlayed % 60}m';
    }
    if (totalMinutesPlayed > 0) {
      return '${totalMinutesPlayed}m ${totalSecondsPlayed % 60}s';
    }
    return '${totalSecondsPlayed}s';
  }

  /// Create a copy with modified fields
  SnakeStatistics copyWith({
    int? totalGamesPlayed,
    int? totalFoodEaten,
    int? totalPowerUpsCollected,
    int? totalSecondsPlayed,
    int? longestSnake,
    int? highestScore,
    int? totalDeaths,
    Map<String, int>? powerUpsByType,
    Map<String, int>? deathsByType,
    int? gamesWonHard,
    int? gamesWonMedium,
    int? gamesWonEasy,
    int? currentWinStreak,
    int? bestWinStreak,
    DateTime? lastPlayedAt,
  }) {
    return SnakeStatistics(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalFoodEaten: totalFoodEaten ?? this.totalFoodEaten,
      totalPowerUpsCollected: totalPowerUpsCollected ?? this.totalPowerUpsCollected,
      totalSecondsPlayed: totalSecondsPlayed ?? this.totalSecondsPlayed,
      longestSnake: longestSnake ?? this.longestSnake,
      highestScore: highestScore ?? this.highestScore,
      totalDeaths: totalDeaths ?? this.totalDeaths,
      powerUpsByType: powerUpsByType ?? this.powerUpsByType,
      deathsByType: deathsByType ?? this.deathsByType,
      gamesWonHard: gamesWonHard ?? this.gamesWonHard,
      gamesWonMedium: gamesWonMedium ?? this.gamesWonMedium,
      gamesWonEasy: gamesWonEasy ?? this.gamesWonEasy,
      currentWinStreak: currentWinStreak ?? this.currentWinStreak,
      bestWinStreak: bestWinStreak ?? this.bestWinStreak,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  @override
  List<Object?> get props => [
        totalGamesPlayed,
        totalFoodEaten,
        totalPowerUpsCollected,
        totalSecondsPlayed,
        longestSnake,
        highestScore,
        totalDeaths,
        powerUpsByType,
        deathsByType,
        gamesWonHard,
        gamesWonMedium,
        gamesWonEasy,
        currentWinStreak,
        bestWinStreak,
        lastPlayedAt,
      ];
}
