class SimonStats {
  final int totalGames;
  final int highestScore;
  final int longestSequence;
  final Duration totalPlayTime;
  final int perfectRounds;
  final DateTime? lastPlayed;

  const SimonStats({
    this.totalGames = 0,
    this.highestScore = 0,
    this.longestSequence = 0,
    this.totalPlayTime = Duration.zero,
    this.perfectRounds = 0,
    this.lastPlayed,
  });

  double get averageScore {
    if (totalGames == 0) return 0;
    return highestScore / totalGames;
  }

  String get formattedTotalPlayTime {
    final hours = totalPlayTime.inHours;
    final minutes = totalPlayTime.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  SimonStats copyWith({
    int? totalGames,
    int? highestScore,
    int? longestSequence,
    Duration? totalPlayTime,
    int? perfectRounds,
    DateTime? lastPlayed,
  }) {
    return SimonStats(
      totalGames: totalGames ?? this.totalGames,
      highestScore: highestScore ?? this.highestScore,
      longestSequence: longestSequence ?? this.longestSequence,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      perfectRounds: perfectRounds ?? this.perfectRounds,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }
}
