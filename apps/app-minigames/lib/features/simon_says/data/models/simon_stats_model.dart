import '../../domain/entities/simon_stats.dart';

class SimonStatsModel extends SimonStats {
  const SimonStatsModel({
    super.totalGames,
    super.highestScore,
    super.longestSequence,
    super.totalPlayTime,
    super.perfectRounds,
    super.lastPlayed,
  });

  factory SimonStatsModel.fromEntity(SimonStats entity) {
    return SimonStatsModel(
      totalGames: entity.totalGames,
      highestScore: entity.highestScore,
      longestSequence: entity.longestSequence,
      totalPlayTime: entity.totalPlayTime,
      perfectRounds: entity.perfectRounds,
      lastPlayed: entity.lastPlayed,
    );
  }

  factory SimonStatsModel.fromJson(Map<String, dynamic> json) {
    return SimonStatsModel(
      totalGames: json['totalGames'] as int? ?? 0,
      highestScore: json['highestScore'] as int? ?? 0,
      longestSequence: json['longestSequence'] as int? ?? 0,
      totalPlayTime: Duration(
        microseconds: json['totalPlayTimeMicros'] as int? ?? 0,
      ),
      perfectRounds: json['perfectRounds'] as int? ?? 0,
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.parse(json['lastPlayed'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGames': totalGames,
      'highestScore': highestScore,
      'longestSequence': longestSequence,
      'totalPlayTimeMicros': totalPlayTime.inMicroseconds,
      'perfectRounds': perfectRounds,
      'lastPlayed': lastPlayed?.toIso8601String(),
    };
  }
}
