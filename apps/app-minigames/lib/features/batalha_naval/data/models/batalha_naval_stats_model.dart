import '../../domain/entities/batalha_naval_stats.dart';

class BatalhaNavalStatsModel extends BatalhaNavalStats {
  BatalhaNavalStatsModel({
    super.totalGames,
    super.humanWins,
    super.computerWins,
    super.totalShipsDestroyed,
    super.totalShotsFired,
    super.totalPlayTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalGames': totalGames,
      'humanWins': humanWins,
      'computerWins': computerWins,
      'totalShipsDestroyed': totalShipsDestroyed,
      'totalShotsFired': totalShotsFired,
      'totalPlayTime': totalPlayTime.inSeconds,
    };
  }

  factory BatalhaNavalStatsModel.fromJson(Map<String, dynamic> json) {
    return BatalhaNavalStatsModel(
      totalGames: json['totalGames'] as int? ?? 0,
      humanWins: json['humanWins'] as int? ?? 0,
      computerWins: json['computerWins'] as int? ?? 0,
      totalShipsDestroyed: json['totalShipsDestroyed'] as int? ?? 0,
      totalShotsFired: json['totalShotsFired'] as int? ?? 0,
      totalPlayTime: Duration(seconds: json['totalPlayTime'] as int? ?? 0),
    );
  }

  factory BatalhaNavalStatsModel.fromEntity(BatalhaNavalStats entity) {
    return BatalhaNavalStatsModel(
      totalGames: entity.totalGames,
      humanWins: entity.humanWins,
      computerWins: entity.computerWins,
      totalShipsDestroyed: entity.totalShipsDestroyed,
      totalShotsFired: entity.totalShotsFired,
      totalPlayTime: entity.totalPlayTime,
    );
  }
}
