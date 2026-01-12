import '../entities/dino_run_score.dart';
import '../entities/dino_run_stats.dart';
import '../repositories/i_dino_run_score_repository.dart';
import '../repositories/i_dino_run_stats_repository.dart';

class SaveScoreUseCase {
  final IDinoRunScoreRepository scoreRepository;
  final IDinoRunStatsRepository statsRepository;

  SaveScoreUseCase(this.scoreRepository, this.statsRepository);

  Future<void> call(DinoRunScore score) async {
    await scoreRepository.saveScore(score);

    final currentStats = await statsRepository.getStats();
    final updatedStats = currentStats.copyWith(
      totalGames: currentStats.totalGames + 1,
      totalScore: currentStats.totalScore + score.score,
      highestScore: score.score > currentStats.highestScore
          ? score.score
          : currentStats.highestScore,
      totalObstaclesJumped:
          currentStats.totalObstaclesJumped + score.obstaclesJumped,
      highestDistance:
          score.distance > currentStats.highestDistance ? score.distance : currentStats.highestDistance,
    );

    await statsRepository.updateStats(updatedStats);
  }
}
