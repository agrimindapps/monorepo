class DamasStats {
  final int totalGames;
  final int redWins;
  final int blackWins;
  final int draws;
  final int totalMoves;
  final Duration totalPlayTime;

  const DamasStats({
    this.totalGames = 0,
    this.redWins = 0,
    this.blackWins = 0,
    this.draws = 0,
    this.totalMoves = 0,
    this.totalPlayTime = Duration.zero,
  });

  DamasStats copyWith({
    int? totalGames,
    int? redWins,
    int? blackWins,
    int? draws,
    int? totalMoves,
    Duration? totalPlayTime,
  }) {
    return DamasStats(
      totalGames: totalGames ?? this.totalGames,
      redWins: redWins ?? this.redWins,
      blackWins: blackWins ?? this.blackWins,
      draws: draws ?? this.draws,
      totalMoves: totalMoves ?? this.totalMoves,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
    );
  }

  double get redWinRate => totalGames > 0 ? redWins / totalGames : 0;
  double get blackWinRate => totalGames > 0 ? blackWins / totalGames : 0;
  double get drawRate => totalGames > 0 ? draws / totalGames : 0;
  double get averageMoves => totalGames > 0 ? totalMoves / totalGames : 0;
}
