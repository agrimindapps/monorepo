import '../../domain/entities/arkanoid_score.dart';

class ArkanoidScoreModel extends ArkanoidScore {
  const ArkanoidScoreModel({
    required super.id,
    required super.score,
    required super.level,
    required super.bricksDestroyed,
    required super.duration,
    required super.completedAt,
    super.playerName,
  });

  factory ArkanoidScoreModel.fromEntity(ArkanoidScore entity) {
    return ArkanoidScoreModel(
      id: entity.id,
      score: entity.score,
      level: entity.level,
      bricksDestroyed: entity.bricksDestroyed,
      duration: entity.duration,
      completedAt: entity.completedAt,
      playerName: entity.playerName,
    );
  }

  factory ArkanoidScoreModel.fromJson(Map<String, dynamic> json) {
    return ArkanoidScoreModel(
      id: json['id'] as String,
      score: json['score'] as int,
      level: json['level'] as int,
      bricksDestroyed: json['bricksDestroyed'] as int,
      duration: Duration(microseconds: json['durationMicros'] as int),
      completedAt: DateTime.parse(json['completedAt'] as String),
      playerName: json['playerName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'level': level,
      'bricksDestroyed': bricksDestroyed,
      'durationMicros': duration.inMicroseconds,
      'completedAt': completedAt.toIso8601String(),
      'playerName': playerName,
    };
  }
}
