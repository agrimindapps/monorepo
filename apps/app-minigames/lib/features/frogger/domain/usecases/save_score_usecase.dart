import '../entities/frogger_score.dart';
import '../repositories/i_frogger_score_repository.dart';
import '../repositories/i_frogger_stats_repository.dart';

class SaveScoreUseCase {
  final IFroggerScoreRepository scoreRepository;
  final IFroggerStatsRepository statsRepository;

  SaveScoreUseCase(this.scoreRepository, this.statsRepository);

  Future<void> call(FroggerScore score) async {
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
      highestLevel: score.level > currentStats.highestLevel
          ? score.level
          : currentStats.highestLevel,
    );

    await statsRepository.updateStats(updatedStats);
  }
}
