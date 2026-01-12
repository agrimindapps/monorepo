import '../../domain/entities/reversi_stats.dart';

class ReversiStatsModel extends ReversiStats {
  const ReversiStatsModel({
    super.totalGames,
    super.blackWins,
    super.whiteWins,
    super.draws,
    super.bestScoreDifference,
    super.totalMoves,
    super.totalPlayTime,
    super.lastPlayed,
  });

  factory ReversiStatsModel.fromEntity(ReversiStats entity) {
    return ReversiStatsModel(
      totalGames: entity.totalGames,
      blackWins: entity.blackWins,
      whiteWins: entity.whiteWins,
      draws: entity.draws,
      bestScoreDifference: entity.bestScoreDifference,
      totalMoves: entity.totalMoves,
      totalPlayTime: entity.totalPlayTime,
      lastPlayed: entity.lastPlayed,
    );
  }

  factory ReversiStatsModel.fromJson(Map<String, dynamic> json) {
    return ReversiStatsModel(
      totalGames: json['totalGames'] as int? ?? 0,
      blackWins: json['blackWins'] as int? ?? 0,
      whiteWins: json['whiteWins'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
      bestScoreDifference: json['bestScoreDifference'] as int? ?? 0,
      totalMoves: json['totalMoves'] as int? ?? 0,
      totalPlayTime: Duration(
        microseconds: json['totalPlayTimeMicros'] as int? ?? 0,
      ),
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.parse(json['lastPlayed'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGames': totalGames,
      'blackWins': blackWins,
      'whiteWins': whiteWins,
      'draws': draws,
      'bestScoreDifference': bestScoreDifference,
      'totalMoves': totalMoves,
      'totalPlayTimeMicros': totalPlayTime.inMicroseconds,
      'lastPlayed': lastPlayed?.toIso8601String(),
    };
  }
}
