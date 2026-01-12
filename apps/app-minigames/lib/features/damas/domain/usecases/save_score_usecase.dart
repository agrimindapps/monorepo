import '../entities/damas_score.dart';
import '../repositories/i_damas_score_repository.dart';
import '../repositories/i_damas_stats_repository.dart';

class SaveScoreUseCase {
  final IDamasScoreRepository scoreRepository;
  final IDamasStatsRepository statsRepository;

  SaveScoreUseCase(this.scoreRepository, this.statsRepository);

  Future<void> call(DamasScore score) async {
    await scoreRepository.saveScore(score);

    final currentStats = await statsRepository.getStats();
    final updatedStats = currentStats.copyWith(
      totalGames: currentStats.totalGames + 1,
      redWins: currentStats.redWins + (score.winner == 'Red' ? 1 : 0),
      blackWins: currentStats.blackWins + (score.winner == 'Black' ? 1 : 0),
      draws: currentStats.draws + (score.winner == 'Draw' ? 1 : 0),
      totalMoves: currentStats.totalMoves + score.movesCount,
      totalPlayTime: currentStats.totalPlayTime + score.gameDuration,
    );

    await statsRepository.updateStats(updatedStats);
  }
}
