import '../../domain/entities/space_invaders_score.dart';

class SpaceInvadersScoreModel extends SpaceInvadersScore {
  const SpaceInvadersScoreModel({
    required super.id,
    required super.score,
    required super.wave,
    required super.invadersKilled,
    required super.duration,
    required super.completedAt,
    super.playerName,
  });

  factory SpaceInvadersScoreModel.fromEntity(SpaceInvadersScore entity) {
    return SpaceInvadersScoreModel(
      id: entity.id,
      score: entity.score,
      wave: entity.wave,
      invadersKilled: entity.invadersKilled,
      duration: entity.duration,
      completedAt: entity.completedAt,
      playerName: entity.playerName,
    );
  }

  factory SpaceInvadersScoreModel.fromJson(Map<String, dynamic> json) {
    return SpaceInvadersScoreModel(
      id: json['id'] as String,
      score: json['score'] as int,
      wave: json['wave'] as int,
      invadersKilled: json['invadersKilled'] as int,
      duration: Duration(microseconds: json['durationMicros'] as int),
      completedAt: DateTime.parse(json['completedAt'] as String),
      playerName: json['playerName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'wave': wave,
      'invadersKilled': invadersKilled,
      'durationMicros': duration.inMicroseconds,
      'completedAt': completedAt.toIso8601String(),
      'playerName': playerName,
    };
  }
}
