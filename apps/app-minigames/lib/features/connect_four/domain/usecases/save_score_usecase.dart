import '../entities/connect_four_score.dart';
import '../entities/connect_four_stats.dart';
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
      totalScore: currentStats.totalScore + score.score,
      highestScore: score.score > currentStats.highestScore
          ? score.score
          : currentStats.highestScore,
      totalCrossingsCompleted:
          currentStats.totalCrossingsCompleted + score.crossingsCompleted,
      highestWave:
          score.level > currentStats.highestWave ? score.level : currentStats.highestWave,
    );

    await statsRepository.updateStats(updatedStats);
  }
}
