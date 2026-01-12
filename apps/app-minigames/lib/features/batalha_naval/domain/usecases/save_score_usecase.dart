import '../entities/batalha_naval_score.dart';
import '../repositories/i_batalha_naval_score_repository.dart';
import '../repositories/i_batalha_naval_stats_repository.dart';

class SaveScoreUseCase {
  final IBatalhaNavalScoreRepository scoreRepository;
  final IBatalhaNavalStatsRepository statsRepository;

  SaveScoreUseCase(this.scoreRepository, this.statsRepository);

  Future<void> call(BatalhaNavalScore score) async {
    await scoreRepository.saveScore(score);

    final currentStats = await statsRepository.getStats();
    final updatedStats = currentStats.copyWith(
      totalGames: currentStats.totalGames + 1,
      humanWins: currentStats.humanWins + (score.winner == 'Humano' ? 1 : 0),
      computerWins:
          currentStats.computerWins + (score.winner == 'Computador' ? 1 : 0),
      totalShipsDestroyed:
          currentStats.totalShipsDestroyed + score.shipsDestroyed,
      totalShotsFired: currentStats.totalShotsFired + score.shotsFired,
      totalPlayTime: currentStats.totalPlayTime + score.gameDuration,
    );

    await statsRepository.updateStats(updatedStats);
  }
}
