import '../../domain/entities/arkanoid_stats.dart';

class ArkanoidStatsModel extends ArkanoidStats {
  const ArkanoidStatsModel({
    super.totalGames,
    super.highestScore,
    super.totalBricksDestroyed,
    super.highestLevel,
    super.totalPlayTime,
    super.lastPlayed,
  });

  factory ArkanoidStatsModel.fromEntity(ArkanoidStats entity) {
    return ArkanoidStatsModel(
      totalGames: entity.totalGames,
      highestScore: entity.highestScore,
      totalBricksDestroyed: entity.totalBricksDestroyed,
      highestLevel: entity.highestLevel,
      totalPlayTime: entity.totalPlayTime,
      lastPlayed: entity.lastPlayed,
    );
  }

  factory ArkanoidStatsModel.fromJson(Map<String, dynamic> json) {
    return ArkanoidStatsModel(
      totalGames: json['totalGames'] as int? ?? 0,
      highestScore: json['highestScore'] as int? ?? 0,
      totalBricksDestroyed: json['totalBricksDestroyed'] as int? ?? 0,
      highestLevel: json['highestLevel'] as int? ?? 0,
      totalPlayTime: Duration(microseconds: json['totalPlayTimeMicros'] as int? ?? 0),
      lastPlayed: json['lastPlayed'] != null ? DateTime.parse(json['lastPlayed'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGames': totalGames,
      'highestScore': highestScore,
      'totalBricksDestroyed': totalBricksDestroyed,
      'highestLevel': highestLevel,
      'totalPlayTimeMicros': totalPlayTime.inMicroseconds,
      'lastPlayed': lastPlayed?.toIso8601String(),
    };
  }
}
