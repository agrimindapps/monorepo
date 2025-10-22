import 'package:equatable/equatable.dart';

import 'enums.dart';

/// High score data for Soletrando game
class HighScoreEntity extends Equatable {
  final int score;
  final int wordsCompleted;
  final GameDifficulty difficulty;
  final DateTime achievedAt;

  const HighScoreEntity({
    required this.score,
    required this.wordsCompleted,
    required this.difficulty,
    required this.achievedAt,
  });

  /// Create empty high score
  factory HighScoreEntity.empty({GameDifficulty? difficulty}) {
    return HighScoreEntity(
      score: 0,
      wordsCompleted: 0,
      difficulty: difficulty ?? GameDifficulty.medium,
      achievedAt: DateTime.now(),
    );
  }

  /// Check if this is a valid score (greater than zero)
  bool get isValid => score > 0;

  /// Check if this is better than another score
  bool isBetterThan(HighScoreEntity other) {
    if (difficulty != other.difficulty) return false;
    if (score != other.score) return score > other.score;
    return wordsCompleted > other.wordsCompleted;
  }

  /// Copy with new values
  HighScoreEntity copyWith({
    int? score,
    int? wordsCompleted,
    GameDifficulty? difficulty,
    DateTime? achievedAt,
  }) {
    return HighScoreEntity(
      score: score ?? this.score,
      wordsCompleted: wordsCompleted ?? this.wordsCompleted,
      difficulty: difficulty ?? this.difficulty,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  List<Object?> get props => [score, wordsCompleted, difficulty, achievedAt];

  @override
  String toString() => 'HighScoreEntity(score: $score, words: $wordsCompleted, '
      'difficulty: ${difficulty.label}, date: $achievedAt)';
}

/// Collection of high scores by difficulty
class HighScoresCollection extends Equatable {
  final HighScoreEntity easy;
  final HighScoreEntity medium;
  final HighScoreEntity hard;

  const HighScoresCollection({
    required this.easy,
    required this.medium,
    required this.hard,
  });

  /// Create empty collection
  factory HighScoresCollection.empty() {
    return HighScoresCollection(
      easy: HighScoreEntity.empty(difficulty: GameDifficulty.easy),
      medium: HighScoreEntity.empty(difficulty: GameDifficulty.medium),
      hard: HighScoreEntity.empty(difficulty: GameDifficulty.hard),
    );
  }

  /// Get high score for specific difficulty
  HighScoreEntity getForDifficulty(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return easy;
      case GameDifficulty.medium:
        return medium;
      case GameDifficulty.hard:
        return hard;
    }
  }

  /// Update high score for specific difficulty
  HighScoresCollection updateForDifficulty(
    GameDifficulty difficulty,
    HighScoreEntity newScore,
  ) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return copyWith(easy: newScore);
      case GameDifficulty.medium:
        return copyWith(medium: newScore);
      case GameDifficulty.hard:
        return copyWith(hard: newScore);
    }
  }

  /// Copy with new values
  HighScoresCollection copyWith({
    HighScoreEntity? easy,
    HighScoreEntity? medium,
    HighScoreEntity? hard,
  }) {
    return HighScoresCollection(
      easy: easy ?? this.easy,
      medium: medium ?? this.medium,
      hard: hard ?? this.hard,
    );
  }

  @override
  List<Object?> get props => [easy, medium, hard];
}
