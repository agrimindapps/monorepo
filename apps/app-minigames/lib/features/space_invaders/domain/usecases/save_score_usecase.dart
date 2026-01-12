import '../entities/space_invaders_score.dart';
import '../entities/space_invaders_stats.dart';
import '../repositories/i_space_invaders_score_repository.dart';
import '../repositories/i_space_invaders_stats_repository.dart';

class SaveScoreUseCase {
  final ISpaceInvadersScoreRepository _scoreRepository;
  final ISpaceInvadersStatsRepository _statsRepository;

  SaveScoreUseCase(this._scoreRepository, this._statsRepository);

  Future<void> call(SpaceInvadersScore score) async {
    await _scoreRepository.saveScore(score);

    final currentStats = await _statsRepository.getStats();
    final updatedStats = currentStats.copyWith(
      totalGames: currentStats.totalGames + 1,
      highestScore: score.score > currentStats.highestScore ? score.score : currentStats.highestScore,
      totalInvadersKilled: currentStats.totalInvadersKilled + score.invadersKilled,
      highestWave: score.wave > currentStats.highestWave ? score.wave : currentStats.highestWave,
      totalPlayTime: currentStats.totalPlayTime + score.duration,
      lastPlayed: score.completedAt,
    );

    await _statsRepository.updateStats(updatedStats);
  }
}
