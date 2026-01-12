class ArkanoidStats {
  final int totalGames;
  final int highestScore;
  final int totalBricksDestroyed;
  final int highestLevel;
  final Duration totalPlayTime;
  final DateTime? lastPlayed;

  const ArkanoidStats({
    this.totalGames = 0,
    this.highestScore = 0,
    this.totalBricksDestroyed = 0,
    this.highestLevel = 0,
    this.totalPlayTime = Duration.zero,
    this.lastPlayed,
  });

  double get averageScore {
    if (totalGames == 0) return 0;
    return highestScore / totalGames;
  }

  String get formattedTotalPlayTime {
    final hours = totalPlayTime.inHours;
    final minutes = totalPlayTime.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  ArkanoidStats copyWith({
    int? totalGames,
    int? highestScore,
    int? totalBricksDestroyed,
    int? highestLevel,
    Duration? totalPlayTime,
    DateTime? lastPlayed,
  }) {
    return ArkanoidStats(
      totalGames: totalGames ?? this.totalGames,
      highestScore: highestScore ?? this.highestScore,
      totalBricksDestroyed: totalBricksDestroyed ?? this.totalBricksDestroyed,
      highestLevel: highestLevel ?? this.highestLevel,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }
}
