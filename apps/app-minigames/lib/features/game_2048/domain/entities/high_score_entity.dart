import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Represents high score data
class HighScoreEntity extends Equatable {
  final int score;
  final int moves;
  final Duration duration;
  final BoardSize boardSize;
  final DateTime achievedAt;

  const HighScoreEntity({
    required this.score,
    required this.moves,
    required this.duration,
    required this.boardSize,
    required this.achievedAt,
  });

  /// Creates an empty high score
  factory HighScoreEntity.empty(BoardSize boardSize) {
    return HighScoreEntity(
      score: 0,
      moves: 0,
      duration: Duration.zero,
      boardSize: boardSize,
      achievedAt: DateTime.now(),
    );
  }

  /// Checks if this is a new high score
  bool isBetterThan(HighScoreEntity other) {
    // Higher score is better
    if (score != other.score) {
      return score > other.score;
    }

    // If scores are equal, fewer moves is better
    if (moves != other.moves) {
      return moves < other.moves;
    }

    // If moves are equal, shorter duration is better
    return duration < other.duration;
  }

  /// Creates a copy with optional new values
  HighScoreEntity copyWith({
    int? score,
    int? moves,
    Duration? duration,
    BoardSize? boardSize,
    DateTime? achievedAt,
  }) {
    return HighScoreEntity(
      score: score ?? this.score,
      moves: moves ?? this.moves,
      duration: duration ?? this.duration,
      boardSize: boardSize ?? this.boardSize,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  List<Object?> get props => [score, moves, duration, boardSize, achievedAt];

  @override
  String toString() =>
      'HighScore(score: $score, moves: $moves, duration: $duration)';
}
