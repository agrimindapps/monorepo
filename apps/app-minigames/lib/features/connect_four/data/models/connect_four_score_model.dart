import '../../domain/entities/connect_four_score.dart';

class ConnectFourScoreModel extends ConnectFourScore {
  const ConnectFourScoreModel({
    required super.winner,
    required super.movesCount,
    required super.gameDuration,
    required super.timestamp,
  });

  factory ConnectFourScoreModel.fromEntity(ConnectFourScore entity) {
    return ConnectFourScoreModel(
      winner: entity.winner,
      movesCount: entity.movesCount,
      gameDuration: entity.gameDuration,
      timestamp: entity.timestamp,
    );
  }

  factory ConnectFourScoreModel.fromJson(Map<String, dynamic> json) {
    return ConnectFourScoreModel(
      winner: json['winner'] as String,
      movesCount: json['movesCount'] as int,
      gameDuration: Duration(microseconds: json['gameDurationMicros'] as int),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'winner': winner,
      'movesCount': movesCount,
      'gameDurationMicros': gameDuration.inMicroseconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
