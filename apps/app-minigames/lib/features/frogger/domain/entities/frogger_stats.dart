class FroggerStats {
  final int totalGames;
  final int totalScore;
  final int highestScore;
  final int totalCrossingsCompleted;
  final int highestWave;

  const FroggerStats({
    this.totalGames = 0,
    this.totalScore = 0,
    this.highestScore = 0,
    this.totalCrossingsCompleted = 0,
    this.highestWave = 0,
  });

  FroggerStats copyWith({
    int? totalGames,
    int? totalScore,
    int? highestScore,
    int? totalCrossingsCompleted,
    int? highestWave,
  }) {
    return FroggerStats(
      totalGames: totalGames ?? this.totalGames,
      totalScore: totalScore ?? this.totalScore,
      highestScore: highestScore ?? this.highestScore,
      totalCrossingsCompleted: totalCrossingsCompleted ?? this.totalCrossingsCompleted,
      highestWave: highestWave ?? this.highestWave,
    );
  }

  double get averageScore => totalGames > 0 ? totalScore / totalGames : 0;
}
