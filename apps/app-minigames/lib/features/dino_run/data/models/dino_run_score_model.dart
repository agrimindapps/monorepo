import '../../domain/entities/dino_run_score.dart';

class DinoRunScoreModel extends DinoRunScore {
  const DinoRunScoreModel({
    required super.score,
    required super.distance,
    required super.obstaclesJumped,
    required super.timestamp,
  });

  factory DinoRunScoreModel.fromEntity(DinoRunScore entity) {
    return DinoRunScoreModel(
      score: entity.score,
      distance: entity.distance,
      obstaclesJumped: entity.obstaclesJumped,
      timestamp: entity.timestamp,
    );
  }

  factory DinoRunScoreModel.fromJson(Map<String, dynamic> json) {
    return DinoRunScoreModel(
      score: json['score'] as int,
      distance: json['distance'] as int,
      obstaclesJumped: json['obstaclesJumped'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'distance': distance,
      'obstaclesJumped': obstaclesJumped,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
