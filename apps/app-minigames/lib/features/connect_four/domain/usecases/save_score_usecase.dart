import '../entities/connect_four_score.dart';
import '../repositories/i_connect_four_score_repository.dart';
import '../repositories/i_connect_four_stats_repository.dart';

class SaveScoreUseCase {
  final IConnectFourScoreRepository scoreRepository;
  final IConnectFourStatsRepository statsRepository;

  SaveScoreUseCase(this.scoreRepository, this.statsRepository);

  Future<void> call(ConnectFourScore score) async {
    await scoreRepository.saveScore(score);

    final currentStats = await statsRepository.getStats();
    final updatedStats = currentStats.copyWith(
      totalGames: currentStats.totalGames + 1,
      player1Wins:
          currentStats.player1Wins + (score.winner == 'Player 1' ? 1 : 0),
      player2Wins:
          currentStats.player2Wins + (score.winner == 'Player 2' ? 1 : 0),
      draws: currentStats.draws + (score.winner == 'Draw' ? 1 : 0),
      totalMoves: currentStats.totalMoves + score.movesCount,
      totalPlayTime: currentStats.totalPlayTime + score.gameDuration,
    );

    await statsRepository.updateStats(updatedStats);
  }
}
