import '../../domain/entities/high_score_entity.dart';
import '../../domain/entities/enums.dart';

class HighScoreModel extends HighScoreEntity {
  const HighScoreModel({
    required super.score,
    required super.difficulty,
    required super.date,
    required super.gameDuration,
    required super.totalHits,
  });

  factory HighScoreModel.fromEntity(HighScoreEntity entity) {
    return HighScoreModel(
      score: entity.score,
      difficulty: entity.difficulty,
      date: entity.date,
      gameDuration: entity.gameDuration,
      totalHits: entity.totalHits,
    );
  }

  factory HighScoreModel.fromJson(Map<String, dynamic> json) {
    return HighScoreModel(
      score: json['score'] as int,
      difficulty: GameDifficulty.values[json['difficulty'] as int],
      date: DateTime.parse(json['date'] as String),
      gameDuration: Duration(seconds: json['gameDurationSeconds'] as int),
      totalHits: json['totalHits'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'difficulty': difficulty.index,
      'date': date.toIso8601String(),
      'gameDurationSeconds': gameDuration.inSeconds,
      'totalHits': totalHits,
    };
  }

  @override
  HighScoreModel copyWith({
    int? score,
    GameDifficulty? difficulty,
    DateTime? date,
    Duration? gameDuration,
    int? totalHits,
  }) {
    return HighScoreModel(
      score: score ?? this.score,
      difficulty: difficulty ?? this.difficulty,
      date: date ?? this.date,
      gameDuration: gameDuration ?? this.gameDuration,
      totalHits: totalHits ?? this.totalHits,
    );
  }
}
