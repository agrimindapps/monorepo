import '../../domain/entities/enums.dart';
import '../../domain/entities/high_score_entity.dart';

/// Data model for high score with JSON serialization
class HighScoreModel extends HighScoreEntity {
  const HighScoreModel({
    required super.score,
    required super.wordsCompleted,
    required super.difficulty,
    required super.achievedAt,
  });

  /// Create from entity
  factory HighScoreModel.fromEntity(HighScoreEntity entity) {
    return HighScoreModel(
      score: entity.score,
      wordsCompleted: entity.wordsCompleted,
      difficulty: entity.difficulty,
      achievedAt: entity.achievedAt,
    );
  }

  /// Create from JSON
  factory HighScoreModel.fromJson(Map<String, dynamic> json) {
    return HighScoreModel(
      score: (json['score'] as num).toInt(),
      wordsCompleted: (json['wordsCompleted'] as num).toInt(),
      difficulty: GameDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => GameDifficulty.medium,
      ),
      achievedAt: DateTime.parse(json['achievedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'wordsCompleted': wordsCompleted,
      'difficulty': difficulty.name,
      'achievedAt': achievedAt.toIso8601String(),
    };
  }

  /// Create empty model
  factory HighScoreModel.empty({GameDifficulty? difficulty}) {
    return HighScoreModel(
      score: 0,
      wordsCompleted: 0,
      difficulty: difficulty ?? GameDifficulty.medium,
      achievedAt: DateTime.now(),
    );
  }
}

/// Model for high scores collection with JSON serialization
class HighScoresCollectionModel extends HighScoresCollection {
  const HighScoresCollectionModel({
    required super.easy,
    required super.medium,
    required super.hard,
  });

  /// Create from entity
  factory HighScoresCollectionModel.fromEntity(HighScoresCollection entity) {
    return HighScoresCollectionModel(
      easy: HighScoreModel.fromEntity(entity.easy),
      medium: HighScoreModel.fromEntity(entity.medium),
      hard: HighScoreModel.fromEntity(entity.hard),
    );
  }

  /// Create from JSON
  factory HighScoresCollectionModel.fromJson(Map<String, dynamic> json) {
    return HighScoresCollectionModel(
      easy: json.containsKey('easy')
          ? HighScoreModel.fromJson(json['easy'] as Map<String, dynamic>)
          : HighScoreModel.empty(difficulty: GameDifficulty.easy),
      medium: json.containsKey('medium')
          ? HighScoreModel.fromJson(json['medium'] as Map<String, dynamic>)
          : HighScoreModel.empty(difficulty: GameDifficulty.medium),
      hard: json.containsKey('hard')
          ? HighScoreModel.fromJson(json['hard'] as Map<String, dynamic>)
          : HighScoreModel.empty(difficulty: GameDifficulty.hard),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'easy': HighScoreModel.fromEntity(easy).toJson(),
      'medium': HighScoreModel.fromEntity(medium).toJson(),
      'hard': HighScoreModel.fromEntity(hard).toJson(),
    };
  }

  /// Create empty collection
  factory HighScoresCollectionModel.empty() {
    return HighScoresCollectionModel(
      easy: HighScoreModel.empty(difficulty: GameDifficulty.easy),
      medium: HighScoreModel.empty(difficulty: GameDifficulty.medium),
      hard: HighScoreModel.empty(difficulty: GameDifficulty.hard),
    );
  }
}
