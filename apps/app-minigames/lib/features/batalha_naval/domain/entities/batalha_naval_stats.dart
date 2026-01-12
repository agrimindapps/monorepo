class BatalhaNavalStats {
  final int totalGames;
  final int humanWins;
  final int computerWins;
  final int totalShipsDestroyed;
  final int totalShotsFired;
  final Duration totalPlayTime;

  const BatalhaNavalStats({
    this.totalGames = 0,
    this.humanWins = 0,
    this.computerWins = 0,
    this.totalShipsDestroyed = 0,
    this.totalShotsFired = 0,
    this.totalPlayTime = Duration.zero,
  });

  BatalhaNavalStats copyWith({
    int? totalGames,
    int? humanWins,
    int? computerWins,
    int? totalShipsDestroyed,
    int? totalShotsFired,
    Duration? totalPlayTime,
  }) {
    return BatalhaNavalStats(
      totalGames: totalGames ?? this.totalGames,
      humanWins: humanWins ?? this.humanWins,
      computerWins: computerWins ?? this.computerWins,
      totalShipsDestroyed: totalShipsDestroyed ?? this.totalShipsDestroyed,
      totalShotsFired: totalShotsFired ?? this.totalShotsFired,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
    );
  }

  double get winRate => totalGames > 0 ? humanWins / totalGames : 0;
  double get averageAccuracy =>
      totalShotsFired > 0 ? (totalShipsDestroyed * 5) / totalShotsFired : 0;
}
