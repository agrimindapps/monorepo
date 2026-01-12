import '../entities/asteroids_score.dart';
import '../repositories/i_asteroids_score_repository.dart';
import '../repositories/i_asteroids_stats_repository.dart';

class SaveScoreUseCase {
  final IAsteroidsScoreRepository scoreRepository;
  final IAsteroidsStatsRepository statsRepository;

  SaveScoreUseCase(this.scoreRepository, this.statsRepository);

  Future<void> call(AsteroidsScore score) async {
    await scoreRepository.saveScore(score);

    final currentStats = await statsRepository.getStats();
    final updatedStats = currentStats.copyWith(
      totalGames: currentStats.totalGames + 1,
      totalScore: currentStats.totalScore + score.score,
      highestScore: score.score > currentStats.highestScore
          ? score.score
          : currentStats.highestScore,
      totalAsteroidsDestroyed:
          currentStats.totalAsteroidsDestroyed + score.asteroidsDestroyed,
      highestWave: score.wave > currentStats.highestWave
          ? score.wave
          : currentStats.highestWave,
    );

    await statsRepository.updateStats(updatedStats);
  }
}
