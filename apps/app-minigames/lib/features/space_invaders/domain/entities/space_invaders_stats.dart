class SpaceInvadersStats {
  final int totalGames;
  final int highestScore;
  final int totalInvadersKilled;
  final int highestWave;
  final Duration totalPlayTime;
  final DateTime? lastPlayed;

  const SpaceInvadersStats({
    this.totalGames = 0,
    this.highestScore = 0,
    this.totalInvadersKilled = 0,
    this.highestWave = 0,
    this.totalPlayTime = Duration.zero,
    this.lastPlayed,
  });

  double get averageScore {
    if (totalGames == 0) return 0;
    return highestScore / totalGames;
  }

  double get averageInvadersPerGame {
    if (totalGames == 0) return 0;
    return totalInvadersKilled / totalGames;
  }

  String get formattedTotalPlayTime {
    final hours = totalPlayTime.inHours;
    final minutes = totalPlayTime.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  SpaceInvadersStats copyWith({
    int? totalGames,
    int? highestScore,
    int? totalInvadersKilled,
    int? highestWave,
    Duration? totalPlayTime,
    DateTime? lastPlayed,
  }) {
    return SpaceInvadersStats(
      totalGames: totalGames ?? this.totalGames,
      highestScore: highestScore ?? this.highestScore,
      totalInvadersKilled: totalInvadersKilled ?? this.totalInvadersKilled,
      highestWave: highestWave ?? this.highestWave,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }
}
