import '../../domain/entities/connect_four_stats.dart';

class ConnectFourStatsModel extends ConnectFourStats {
  const ConnectFourStatsModel({
    super.totalGames,
    super.player1Wins,
    super.player2Wins,
    super.draws,
    super.totalMoves,
    super.totalPlayTime,
  });

  factory ConnectFourStatsModel.fromEntity(ConnectFourStats entity) {
    return ConnectFourStatsModel(
      totalGames: entity.totalGames,
      player1Wins: entity.player1Wins,
      player2Wins: entity.player2Wins,
      draws: entity.draws,
      totalMoves: entity.totalMoves,
      totalPlayTime: entity.totalPlayTime,
    );
  }

  factory ConnectFourStatsModel.fromJson(Map<String, dynamic> json) {
    return ConnectFourStatsModel(
      totalGames: json['totalGames'] as int? ?? 0,
      player1Wins: json['player1Wins'] as int? ?? 0,
      player2Wins: json['player2Wins'] as int? ?? 0,
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
      'player1Wins': player1Wins,
      'player2Wins': player2Wins,
      'draws': draws,
      'totalMoves': totalMoves,
      'totalPlayTimeMicros': totalPlayTime.inMicroseconds,
    };
  }
}
