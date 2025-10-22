import 'package:equatable/equatable.dart';
import 'enums.dart';

class HighScoreEntity extends Equatable {
  final int bestTime; // in seconds
  final int fewestMistakes;
  final int gamesCompleted;
  final GameDifficulty difficulty;
  final DateTime? lastPlayedAt;

  const HighScoreEntity({
    required this.bestTime,
    required this.fewestMistakes,
    required this.gamesCompleted,
    required this.difficulty,
    this.lastPlayedAt,
  });

  /// Factory for initial state
  factory HighScoreEntity.initial(GameDifficulty difficulty) {
    return HighScoreEntity(
      bestTime: 0,
      fewestMistakes: 0,
      gamesCompleted: 0,
      difficulty: difficulty,
      lastPlayedAt: null,
    );
  }

  /// Format time as MM:SS
  String get formattedBestTime {
    if (bestTime == 0) return '--:--';
    final minutes = bestTime ~/ 60;
    final seconds = bestTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if this is a new record
  bool isNewRecord(int timeInSeconds, int mistakes) {
    if (gamesCompleted == 0) return true; // First game
    if (mistakes < fewestMistakes) return true;
    if (mistakes == fewestMistakes && timeInSeconds < bestTime) return true;
    return false;
  }

  /// Update with new game result
  HighScoreEntity updateWithGame({
    required int timeInSeconds,
    required int mistakes,
  }) {
    final isNewBestTime =
        (bestTime == 0 || timeInSeconds < bestTime) && mistakes == 0;
    final isNewFewestMistakes =
        fewestMistakes == 0 || mistakes < fewestMistakes;

    return copyWith(
      bestTime: isNewBestTime ? timeInSeconds : bestTime,
      fewestMistakes: isNewFewestMistakes ? mistakes : fewestMistakes,
      gamesCompleted: gamesCompleted + 1,
      lastPlayedAt: DateTime.now(),
    );
  }

  HighScoreEntity copyWith({
    int? bestTime,
    int? fewestMistakes,
    int? gamesCompleted,
    GameDifficulty? difficulty,
    DateTime? lastPlayedAt,
  }) {
    return HighScoreEntity(
      bestTime: bestTime ?? this.bestTime,
      fewestMistakes: fewestMistakes ?? this.fewestMistakes,
      gamesCompleted: gamesCompleted ?? this.gamesCompleted,
      difficulty: difficulty ?? this.difficulty,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  @override
  List<Object?> get props => [
        bestTime,
        fewestMistakes,
        gamesCompleted,
        difficulty,
        lastPlayedAt,
      ];

  @override
  String toString() =>
      'HighScore(bestTime: $formattedBestTime, mistakes: $fewestMistakes, games: $gamesCompleted)';
}
