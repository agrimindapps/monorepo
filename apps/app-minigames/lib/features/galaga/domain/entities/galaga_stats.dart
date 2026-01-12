class GalagaStats {
  final int totalGames;
  final int totalScore;
  final int highestScore;
  final int totalEnemiesDestroyed;
  final int highestWave;

  const GalagaStats({
    this.totalGames = 0,
    this.totalScore = 0,
    this.highestScore = 0,
    this.totalEnemiesDestroyed = 0,
    this.highestWave = 0,
  });

  GalagaStats copyWith({
    int? totalGames,
    int? totalScore,
    int? highestScore,
    int? totalEnemiesDestroyed,
    int? highestWave,
  }) {
    return GalagaStats(
      totalGames: totalGames ?? this.totalGames,
      totalScore: totalScore ?? this.totalScore,
      highestScore: highestScore ?? this.highestScore,
      totalEnemiesDestroyed: totalEnemiesDestroyed ?? this.totalEnemiesDestroyed,
      highestWave: highestWave ?? this.highestWave,
    );
  }

  double get averageScore => totalGames > 0 ? totalScore / totalGames : 0;
}
