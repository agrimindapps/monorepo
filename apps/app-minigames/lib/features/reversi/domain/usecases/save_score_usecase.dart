import '../entities/reversi_score.dart';
import '../repositories/i_reversi_score_repository.dart';
import '../repositories/i_reversi_stats_repository.dart';

class SaveScoreUseCase {
  final IReversiScoreRepository _scoreRepository;
  final IReversiStatsRepository _statsRepository;

  SaveScoreUseCase(this._scoreRepository, this._statsRepository);

  Future<void> call(ReversiScore score) async {
    await _scoreRepository.saveScore(score);

    final currentStats = await _statsRepository.getStats();
    final updatedStats = currentStats.copyWith(
      totalGames: currentStats.totalGames + 1,
      blackWins:
          currentStats.blackWins +
          (score.blackCount > score.whiteCount ? 1 : 0),
      whiteWins:
          currentStats.whiteWins +
          (score.whiteCount > score.blackCount ? 1 : 0),
      draws:
          currentStats.draws + (score.blackCount == score.whiteCount ? 1 : 0),
      bestScoreDifference:
          score.scoreDifference > currentStats.bestScoreDifference
          ? score.scoreDifference
          : currentStats.bestScoreDifference,
      totalMoves: currentStats.totalMoves + score.moves,
      totalPlayTime: currentStats.totalPlayTime + score.duration,
      lastPlayed: score.completedAt,
    );

    await _statsRepository.updateStats(updatedStats);
  }
}
