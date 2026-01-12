import '../entities/galaga_score.dart';
import '../repositories/i_galaga_score_repository.dart';
import '../repositories/i_galaga_stats_repository.dart';

class SaveScoreUseCase {
  final IGalagaScoreRepository scoreRepository;
  final IGalagaStatsRepository statsRepository;

  SaveScoreUseCase(this.scoreRepository, this.statsRepository);

  Future<void> call(GalagaScore score) async {
    await scoreRepository.saveScore(score);

    final currentStats = await statsRepository.getStats();
    final updatedStats = currentStats.copyWith(
      totalGames: currentStats.totalGames + 1,
      totalScore: currentStats.totalScore + score.score,
      highestScore: score.score > currentStats.highestScore
          ? score.score
          : currentStats.highestScore,
      totalEnemiesDestroyed:
          currentStats.totalEnemiesDestroyed + score.enemiesDestroyed,
      highestWave: score.wave > currentStats.highestWave
          ? score.wave
          : currentStats.highestWave,
    );

    await statsRepository.updateStats(updatedStats);
  }
}
