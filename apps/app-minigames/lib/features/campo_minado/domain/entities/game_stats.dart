import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Immutable entity representing game statistics
class GameStats extends Equatable {
  final Difficulty difficulty;
  final int bestTime;
  final int totalGames;
  final int totalWins;
  final int currentStreak;
  final int bestStreak;

  const GameStats({
    required this.difficulty,
    required this.bestTime,
    required this.totalGames,
    required this.totalWins,
    required this.currentStreak,
    required this.bestStreak,
  });

  /// Factory constructor for empty stats
  factory GameStats.empty({Difficulty difficulty = Difficulty.beginner}) {
    return GameStats(
      difficulty: difficulty,
      bestTime: 0,
      totalGames: 0,
      totalWins: 0,
      currentStreak: 0,
      bestStreak: 0,
    );
  }

  /// Win rate as a percentage (0.0 to 1.0)
  double get winRate => totalGames > 0 ? totalWins / totalGames : 0.0;

  /// Win rate as percentage string
  String get winRatePercentage =>
      '${(winRate * 100).toStringAsFixed(1)}%';

  /// Formats best time as MM:SS
  String get formattedBestTime {
    if (bestTime == 0) return '--:--';
    final minutes = bestTime ~/ 60;
    final seconds = bestTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Creates a copy with updated fields
  GameStats copyWith({
    Difficulty? difficulty,
    int? bestTime,
    int? totalGames,
    int? totalWins,
    int? currentStreak,
    int? bestStreak,
  }) {
    return GameStats(
      difficulty: difficulty ?? this.difficulty,
      bestTime: bestTime ?? this.bestTime,
      totalGames: totalGames ?? this.totalGames,
      totalWins: totalWins ?? this.totalWins,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }

  @override
  List<Object?> get props => [
        difficulty,
        bestTime,
        totalGames,
        totalWins,
        currentStreak,
        bestStreak,
      ];

  @override
  String toString() {
    return 'GameStats(difficulty: $difficulty, wins: $totalWins/$totalGames, streak: $currentStreak, best: $bestStreak)';
  }
}
