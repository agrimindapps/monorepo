class AsteroidsStats {
  final int totalGames;
  final int totalScore;
  final int highestScore;
  final int totalAsteroidsDestroyed;
  final int highestWave;

  const AsteroidsStats({
    this.totalGames = 0,
    this.totalScore = 0,
    this.highestScore = 0,
    this.totalAsteroidsDestroyed = 0,
    this.highestWave = 0,
  });

  AsteroidsStats copyWith({
    int? totalGames,
    int? totalScore,
    int? highestScore,
    int? totalAsteroidsDestroyed,
    int? highestWave,
  }) {
    return AsteroidsStats(
      totalGames: totalGames ?? this.totalGames,
      totalScore: totalScore ?? this.totalScore,
      highestScore: highestScore ?? this.highestScore,
      totalAsteroidsDestroyed: totalAsteroidsDestroyed ?? this.totalAsteroidsDestroyed,
      highestWave: highestWave ?? this.highestWave,
    );
  }

  double get averageScore => totalGames > 0 ? totalScore / totalGames : 0;
}
