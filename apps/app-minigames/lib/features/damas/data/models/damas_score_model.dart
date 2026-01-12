import '../../domain/entities/damas_score.dart';

class DamasScoreModel extends DamasScore {
  const DamasScoreModel({
    required super.id,
    required super.winner,
    required super.movesCount,
    required super.gameDuration,
    required super.timestamp,
  });

  factory DamasScoreModel.fromEntity(DamasScore entity) {
    return DamasScoreModel(
      id: entity.id,
      winner: entity.winner,
      movesCount: entity.movesCount,
      gameDuration: entity.gameDuration,
      timestamp: entity.timestamp,
    );
  }

  factory DamasScoreModel.fromJson(Map<String, dynamic> json) {
    return DamasScoreModel(
      id: json['id'] as String,
      winner: json['winner'] as String,
      movesCount: json['movesCount'] as int,
      gameDuration: Duration(microseconds: json['gameDurationMicros'] as int),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'winner': winner,
      'movesCount': movesCount,
      'gameDurationMicros': gameDuration.inMicroseconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
