class ConnectFourStats {
  final int totalGames;
  final int player1Wins;
  final int player2Wins;
  final int draws;
  final int totalMoves;
  final Duration totalPlayTime;

  const ConnectFourStats({
    this.totalGames = 0,
    this.player1Wins = 0,
    this.player2Wins = 0,
    this.draws = 0,
    this.totalMoves = 0,
    this.totalPlayTime = Duration.zero,
  });

  ConnectFourStats copyWith({
    int? totalGames,
    int? player1Wins,
    int? player2Wins,
    int? draws,
    int? totalMoves,
    Duration? totalPlayTime,
  }) {
    return ConnectFourStats(
      totalGames: totalGames ?? this.totalGames,
      player1Wins: player1Wins ?? this.player1Wins,
      player2Wins: player2Wins ?? this.player2Wins,
      draws: draws ?? this.draws,
      totalMoves: totalMoves ?? this.totalMoves,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
    );
  }

  double get player1WinRate => totalGames > 0 ? player1Wins / totalGames : 0;
  double get player2WinRate => totalGames > 0 ? player2Wins / totalGames : 0;
  double get drawRate => totalGames > 0 ? draws / totalGames : 0;
  double get averageMoves => totalGames > 0 ? totalMoves / totalGames : 0;
}
