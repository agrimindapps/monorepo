import '../entities/reversi_entities.dart';

class ReversiStats {
  final int totalGames;
  final int blackWins;
  final int whiteWins;
  final int draws;
  final int bestScoreDifference;
  final int totalMoves;
  final Duration totalPlayTime;
  final DateTime? lastPlayed;

  const ReversiStats({
    this.totalGames = 0,
    this.blackWins = 0,
    this.whiteWins = 0,
    this.draws = 0,
    this.bestScoreDifference = 0,
    this.totalMoves = 0,
    this.totalPlayTime = Duration.zero,
    this.lastPlayed,
  });

  double get blackWinRate {
    if (totalGames == 0) return 0;
    return blackWins / totalGames;
  }

  double get whiteWinRate {
    if (totalGames == 0) return 0;
    return whiteWins / totalGames;
  }

  double get drawRate {
    if (totalGames == 0) return 0;
    return draws / totalGames;
  }

  double get averageMovesPerGame {
    if (totalGames == 0) return 0;
    return totalMoves / totalGames;
  }

  String get formattedTotalPlayTime {
    final hours = totalPlayTime.inHours;
    final minutes = totalPlayTime.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  ReversiStats copyWith({
    int? totalGames,
    int? blackWins,
    int? whiteWins,
    int? draws,
    int? bestScoreDifference,
    int? totalMoves,
    Duration? totalPlayTime,
    DateTime? lastPlayed,
  }) {
    return ReversiStats(
      totalGames: totalGames ?? this.totalGames,
      blackWins: blackWins ?? this.blackWins,
      whiteWins: whiteWins ?? this.whiteWins,
      draws: draws ?? this.draws,
      bestScoreDifference: bestScoreDifference ?? this.bestScoreDifference,
      totalMoves: totalMoves ?? this.totalMoves,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }
}
