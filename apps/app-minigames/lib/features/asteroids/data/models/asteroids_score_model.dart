import '../../domain/entities/asteroids_score.dart';

class AsteroidsScoreModel extends AsteroidsScore {
  const AsteroidsScoreModel({
    required super.score,
    required super.wave,
    required super.asteroidsDestroyed,
    required super.timestamp,
  });

  factory AsteroidsScoreModel.fromEntity(AsteroidsScore entity) {
    return AsteroidsScoreModel(
      score: entity.score,
      wave: entity.wave,
      asteroidsDestroyed: entity.asteroidsDestroyed,
      timestamp: entity.timestamp,
    );
  }

  factory AsteroidsScoreModel.fromJson(Map<String, dynamic> json) {
    return AsteroidsScoreModel(
      score: json['score'] as int,
      wave: json['wave'] as int,
      asteroidsDestroyed: json['asteroidsDestroyed'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'wave': wave,
      'asteroidsDestroyed': asteroidsDestroyed,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
