class DinoRunStats {
  final int totalGames;
  final int totalScore;
  final int highestScore;
  final int totalObstaclesJumped;
  final int highestDistance;

  const DinoRunStats({
    this.totalGames = 0,
    this.totalScore = 0,
    this.highestScore = 0,
    this.totalObstaclesJumped = 0,
    this.highestDistance = 0,
  });

  DinoRunStats copyWith({
    int? totalGames,
    int? totalScore,
    int? highestScore,
    int? totalObstaclesJumped,
    int? highestDistance,
  }) {
    return DinoRunStats(
      totalGames: totalGames ?? this.totalGames,
      totalScore: totalScore ?? this.totalScore,
      highestScore: highestScore ?? this.highestScore,
      totalObstaclesJumped: totalObstaclesJumped ?? this.totalObstaclesJumped,
      highestDistance: highestDistance ?? this.highestDistance,
    );
  }

  double get averageScore => totalGames > 0 ? totalScore / totalGames : 0;
}
