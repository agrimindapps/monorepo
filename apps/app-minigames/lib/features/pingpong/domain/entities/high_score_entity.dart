import 'package:equatable/equatable.dart';
import 'enums.dart';

class HighScoreEntity extends Equatable {
  final int score;
  final GameDifficulty difficulty;
  final DateTime date;
  final Duration gameDuration;
  final int totalHits;

  const HighScoreEntity({
    required this.score,
    required this.difficulty,
    required this.date,
    required this.gameDuration,
    required this.totalHits,
  });

  factory HighScoreEntity.empty() => HighScoreEntity(
        score: 0,
        difficulty: GameDifficulty.medium,
        date: DateTime.now(),
        gameDuration: Duration.zero,
        totalHits: 0,
      );

  bool isBetterThan(HighScoreEntity other) => score > other.score;

  HighScoreEntity copyWith({
    int? score,
    GameDifficulty? difficulty,
    DateTime? date,
    Duration? gameDuration,
    int? totalHits,
  }) {
    return HighScoreEntity(
      score: score ?? this.score,
      difficulty: difficulty ?? this.difficulty,
      date: date ?? this.date,
      gameDuration: gameDuration ?? this.gameDuration,
      totalHits: totalHits ?? this.totalHits,
    );
  }

  @override
  List<Object?> get props => [score, difficulty, date, gameDuration, totalHits];

  @override
  String toString() =>
      'HighScoreEntity(score: $score, difficulty: ${difficulty.label}, date: $date)';
}
