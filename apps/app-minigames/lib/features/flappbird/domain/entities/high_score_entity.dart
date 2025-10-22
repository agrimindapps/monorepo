// Package imports:
import 'package:equatable/equatable.dart';

/// Entity representing the high score for Flappy Bird
class HighScoreEntity extends Equatable {
  final int score;
  final DateTime? achievedAt;

  const HighScoreEntity({
    required this.score,
    this.achievedAt,
  });

  /// Empty high score (0 points)
  factory HighScoreEntity.empty() {
    return const HighScoreEntity(score: 0);
  }

  /// Create a copy with modified fields
  HighScoreEntity copyWith({
    int? score,
    DateTime? achievedAt,
  }) {
    return HighScoreEntity(
      score: score ?? this.score,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  List<Object?> get props => [score, achievedAt];
}
