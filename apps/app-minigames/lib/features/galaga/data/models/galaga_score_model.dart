import '../../domain/entities/galaga_score.dart';

class GalagaScoreModel extends GalagaScore {
  const GalagaScoreModel({
    required super.score,
    required super.wave,
    required super.enemiesDestroyed,
    required super.timestamp,
  });

  factory GalagaScoreModel.fromEntity(GalagaScore entity) {
    return GalagaScoreModel(
      score: entity.score,
      wave: entity.wave,
      enemiesDestroyed: entity.enemiesDestroyed,
      timestamp: entity.timestamp,
    );
  }

  factory GalagaScoreModel.fromJson(Map<String, dynamic> json) {
    return GalagaScoreModel(
      score: json['score'] as int,
      wave: json['wave'] as int,
      enemiesDestroyed: json['enemiesDestroyed'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'wave': wave,
      'enemiesDestroyed': enemiesDestroyed,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
