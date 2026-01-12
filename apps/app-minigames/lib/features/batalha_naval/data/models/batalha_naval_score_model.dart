import '../../domain/entities/batalha_naval_score.dart';

class BatalhaNavalScoreModel extends BatalhaNavalScore {
  BatalhaNavalScoreModel({
    required super.winner,
    required super.shipsDestroyed,
    required super.shotsFired,
    required super.gameDuration,
    required super.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'winner': winner,
      'shipsDestroyed': shipsDestroyed,
      'shotsFired': shotsFired,
      'gameDuration': gameDuration.inSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory BatalhaNavalScoreModel.fromJson(Map<String, dynamic> json) {
    return BatalhaNavalScoreModel(
      winner: json['winner'] as String,
      shipsDestroyed: json['shipsDestroyed'] as int,
      shotsFired: json['shotsFired'] as int,
      gameDuration: Duration(seconds: json['gameDuration'] as int),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  factory BatalhaNavalScoreModel.fromEntity(BatalhaNavalScore entity) {
    return BatalhaNavalScoreModel(
      winner: entity.winner,
      shipsDestroyed: entity.shipsDestroyed,
      shotsFired: entity.shotsFired,
      gameDuration: entity.gameDuration,
      timestamp: entity.timestamp,
    );
  }
}
