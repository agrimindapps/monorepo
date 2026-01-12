import '../../domain/entities/connect_four_score.dart';

class ConnectFourScoreModel extends ConnectFourScore {
  const ConnectFourScoreModel({
    required super.score,
    required super.level,
    required super.crossingsCompleted,
    required super.timestamp,
  });

  factory ConnectFourScoreModel.fromEntity(ConnectFourScore entity) {
    return ConnectFourScoreModel(
      score: entity.score,
      level: entity.level,
      crossingsCompleted: entity.crossingsCompleted,
      timestamp: entity.timestamp,
    );
  }

  factory ConnectFourScoreModel.fromJson(Map<String, dynamic> json) {
    return ConnectFourScoreModel(
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
