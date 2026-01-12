import '../entities/arkanoid_score.dart';
import '../repositories/i_arkanoid_score_repository.dart';
import '../repositories/i_arkanoid_stats_repository.dart';

class SaveScoreUseCase {
  final IArkanoidScoreRepository _scoreRepository;
  final IArkanoidStatsRepository _statsRepository;

  SaveScoreUseCase(this._scoreRepository, this._statsRepository);

  Future<void> call(ArkanoidScore score) async {
    await _scoreRepository.saveScore(score);

    final currentStats = await _statsRepository.getStats();
    final updatedStats = currentStats.copyWith(
      totalGames: currentStats.totalGames + 1,
      highestScore: score.score > currentStats.highestScore
          ? score.score
          : currentStats.highestScore,
      totalBricksDestroyed:
          currentStats.totalBricksDestroyed + score.bricksDestroyed,
      highestLevel: score.level > currentStats.highestLevel
          ? score.level
          : currentStats.highestLevel,
      totalPlayTime: currentStats.totalPlayTime + score.duration,
      lastPlayed: score.completedAt,
    );

    await _statsRepository.updateStats(updatedStats);
  }
}
