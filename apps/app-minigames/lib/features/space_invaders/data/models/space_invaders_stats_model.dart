import '../../domain/entities/space_invaders_stats.dart';

class SpaceInvadersStatsModel extends SpaceInvadersStats {
  const SpaceInvadersStatsModel({
    super.totalGames,
    super.highestScore,
    super.totalInvadersKilled,
    super.highestWave,
    super.totalPlayTime,
    super.lastPlayed,
  });

  factory SpaceInvadersStatsModel.fromEntity(SpaceInvadersStats entity) {
    return SpaceInvadersStatsModel(
      totalGames: entity.totalGames,
      highestScore: entity.highestScore,
      totalInvadersKilled: entity.totalInvadersKilled,
      highestWave: entity.highestWave,
      totalPlayTime: entity.totalPlayTime,
      lastPlayed: entity.lastPlayed,
    );
  }

  factory SpaceInvadersStatsModel.fromJson(Map<String, dynamic> json) {
    return SpaceInvadersStatsModel(
      totalGames: json['totalGames'] as int? ?? 0,
      highestScore: json['highestScore'] as int? ?? 0,
      totalInvadersKilled: json['totalInvadersKilled'] as int? ?? 0,
      highestWave: json['highestWave'] as int? ?? 0,
      totalPlayTime: Duration(microseconds: json['totalPlayTimeMicros'] as int? ?? 0),
      lastPlayed: json['lastPlayed'] != null ? DateTime.parse(json['lastPlayed'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGames': totalGames,
      'highestScore': highestScore,
      'totalInvadersKilled': totalInvadersKilled,
      'highestWave': highestWave,
      'totalPlayTimeMicros': totalPlayTime.inMicroseconds,
      'lastPlayed': lastPlayed?.toIso8601String(),
    };
  }
}
