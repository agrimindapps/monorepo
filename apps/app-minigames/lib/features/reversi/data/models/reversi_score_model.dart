import '../../domain/entities/reversi_entities.dart';
import '../../domain/entities/reversi_score.dart';

class ReversiScoreModel extends ReversiScore {
  const ReversiScoreModel({
    required super.id,
    required super.winner,
    required super.blackCount,
    required super.whiteCount,
    required super.moves,
    required super.duration,
    required super.completedAt,
    super.playerName,
  });

  factory ReversiScoreModel.fromEntity(ReversiScore entity) {
    return ReversiScoreModel(
      id: entity.id,
      winner: entity.winner,
      blackCount: entity.blackCount,
      whiteCount: entity.whiteCount,
      moves: entity.moves,
      duration: entity.duration,
      completedAt: entity.completedAt,
      playerName: entity.playerName,
    );
  }

  factory ReversiScoreModel.fromJson(Map<String, dynamic> json) {
    return ReversiScoreModel(
      id: json['id'] as String,
      winner: ReversiPlayer.values.firstWhere(
        (e) => e.name == json['winner'],
      ),
      blackCount: json['blackCount'] as int,
      whiteCount: json['whiteCount'] as int,
      moves: json['moves'] as int,
      duration: Duration(microseconds: json['durationMicros'] as int),
      completedAt: DateTime.parse(json['completedAt'] as String),
      playerName: json['playerName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'winner': winner.name,
      'blackCount': blackCount,
      'whiteCount': whiteCount,
      'moves': moves,
      'durationMicros': duration.inMicroseconds,
      'completedAt': completedAt.toIso8601String(),
      'playerName': playerName,
    };
  }
}
