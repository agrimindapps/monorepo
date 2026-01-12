import '../../domain/entities/frogger_score.dart';

class FroggerScoreModel extends FroggerScore {
  const FroggerScoreModel({
    required super.score,
    required super.level,
    required super.crossingsCompleted,
    required super.timestamp,
  });

  factory FroggerScoreModel.fromEntity(FroggerScore entity) {
    return FroggerScoreModel(
      score: entity.score,
      level: entity.level,
      crossingsCompleted: entity.crossingsCompleted,
      timestamp: entity.timestamp,
    );
  }

  factory FroggerScoreModel.fromJson(Map<String, dynamic> json) {
    return FroggerScoreModel(
      score: json['score'] as int,
      level: json['level'] as int,
      crossingsCompleted: json['crossingsCompleted'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'level': level,
      'crossingsCompleted': crossingsCompleted,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
