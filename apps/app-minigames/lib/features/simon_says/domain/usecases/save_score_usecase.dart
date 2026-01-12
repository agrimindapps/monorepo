import '../entities/simon_score.dart';
import '../repositories/i_simon_score_repository.dart';
import '../repositories/i_simon_stats_repository.dart';

class SaveScoreUseCase {
  final ISimonScoreRepository _scoreRepository;
  final ISimonStatsRepository _statsRepository;

  SaveScoreUseCase(this._scoreRepository, this._statsRepository);

  Future<void> call(SimonScore score) async {
    await _scoreRepository.saveScore(score);

    final currentStats = await _statsRepository.getStats();
    final updatedStats = currentStats.copyWith(
      totalGames: currentStats.totalGames + 1,
      highestScore: score.score > currentStats.highestScore
          ? score.score
          : currentStats.highestScore,
      longestSequence: score.longestSequence > currentStats.longestSequence
          ? score.longestSequence
          : currentStats.longestSequence,
      perfectRounds: currentStats.perfectRounds + score.perfectRounds,
      totalPlayTime: currentStats.totalPlayTime + score.duration,
      lastPlayed: score.completedAt,
    );

    await _statsRepository.updateStats(updatedStats);
  }
}
