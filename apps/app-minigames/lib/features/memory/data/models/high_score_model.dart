import '../../domain/entities/enums.dart';
import '../../domain/entities/high_score_entity.dart';

class HighScoreModel extends HighScoreEntity {
  const HighScoreModel({
    required super.difficulty,
    required super.score,
    required super.moves,
    required super.time,
    required super.achievedAt,
  });

  factory HighScoreModel.fromEntity(HighScoreEntity entity) {
    return HighScoreModel(
      difficulty: entity.difficulty,
      score: entity.score,
      moves: entity.moves,
      time: entity.time,
      achievedAt: entity.achievedAt,
    );
  }

  factory HighScoreModel.fromJson(Map<String, dynamic> json) {
    return HighScoreModel(
      difficulty: GameDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => GameDifficulty.medium,
      ),
      score: json['score'] as int,
      moves: json['moves'] as int,
      time: Duration(seconds: json['timeInSeconds'] as int),
      achievedAt: DateTime.parse(json['achievedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty.name,
      'score': score,
      'moves': moves,
      'timeInSeconds': time.inSeconds,
      'achievedAt': achievedAt.toIso8601String(),
    };
  }

  HighScoreEntity toEntity() {
    return HighScoreEntity(
      difficulty: difficulty,
      score: score,
      moves: moves,
      time: time,
      achievedAt: achievedAt,
    );
  }

  // Note: achievedAt cannot be const because DateTime constructor is not const
  // Use factory method or lazy initialization instead
  static final HighScoreModel empty = HighScoreModel(
    difficulty: GameDifficulty.medium,
    score: 0,
    moves: 0,
    time: Duration.zero,
    achievedAt: DateTime(1970), // Unix epoch as default
  );
}
