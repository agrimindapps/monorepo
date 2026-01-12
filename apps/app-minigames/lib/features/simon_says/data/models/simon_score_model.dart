import '../../domain/entities/simon_score.dart';

class SimonScoreModel extends SimonScore {
  const SimonScoreModel({
    required super.id,
    required super.score,
    required super.longestSequence,
    super.perfectRounds,
    required super.duration,
    required super.completedAt,
    super.playerName,
  });

  factory SimonScoreModel.fromEntity(SimonScore entity) {
    return SimonScoreModel(
      id: entity.id,
      score: entity.score,
      longestSequence: entity.longestSequence,
      perfectRounds: entity.perfectRounds,
      duration: entity.duration,
      completedAt: entity.completedAt,
      playerName: entity.playerName,
    );
  }

  factory SimonScoreModel.fromJson(Map<String, dynamic> json) {
    return SimonScoreModel(
      id: json['id'] as String,
      score: json['score'] as int,
      longestSequence: json['longestSequence'] as int,
      perfectRounds: json['perfectRounds'] as int? ?? 0,
      duration: Duration(microseconds: json['durationMicros'] as int),
      completedAt: DateTime.parse(json['completedAt'] as String),
      playerName: json['playerName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'longestSequence': longestSequence,
      'perfectRounds': perfectRounds,
      'durationMicros': duration.inMicroseconds,
      'completedAt': completedAt.toIso8601String(),
      'playerName': playerName,
    };
  }
}
