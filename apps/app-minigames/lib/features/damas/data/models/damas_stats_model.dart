import '../../domain/entities/damas_stats.dart';

class DamasStatsModel extends DamasStats {
  const DamasStatsModel({
    super.totalGames,
    super.redWins,
    super.blackWins,
    super.draws,
    super.totalMoves,
    super.totalPlayTime,
  });

  factory DamasStatsModel.fromEntity(DamasStats entity) {
    return DamasStatsModel(
      totalGames: entity.totalGames,
      redWins: entity.redWins,
      blackWins: entity.blackWins,
      draws: entity.draws,
      totalMoves: entity.totalMoves,
      totalPlayTime: entity.totalPlayTime,
    );
  }

  factory DamasStatsModel.fromJson(Map<String, dynamic> json) {
    return DamasStatsModel(
      totalGames: json['totalGames'] as int? ?? 0,
      redWins: json['redWins'] as int? ?? 0,
      blackWins: json['blackWins'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
      totalMoves: json['totalMoves'] as int? ?? 0,
      totalPlayTime: Duration(
        microseconds: json['totalPlayTimeMicros'] as int? ?? 0,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGames': totalGames,
      'redWins': redWins,
      'blackWins': blackWins,
      'draws': draws,
      'totalMoves': totalMoves,
      'totalPlayTimeMicros': totalPlayTime.inMicroseconds,
    };
  }
}
