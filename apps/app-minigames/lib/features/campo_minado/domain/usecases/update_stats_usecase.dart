import 'package:core/core.dart';
import '../entities/game_stats.dart';
import '../entities/game_state.dart';
import '../repositories/campo_minado_repository.dart';

/// Use case for updating statistics after a game
class UpdateStatsUseCase {
  final CampoMinadoRepository _repository;

  const UpdateStatsUseCase(this._repository);

  Future<Either<Failure, GameStats>> call({
    required GameState gameState,
    required bool won,
  }) async {
    if (!gameState.isGameOver) {
      return const Left(ValidationFailure('Jogo ainda não terminou'));
    }

    // Load current stats
    final statsResult = await _repository.loadStats(gameState.difficulty);

    return await statsResult.fold(
      (failure) => Left(failure),
      (currentStats) async {
        final updatedStats = _calculateUpdatedStats(
          currentStats: currentStats,
          won: won,
          timeSeconds: gameState.timeSeconds,
        );

        // Save updated stats
        final saveResult = await _repository.saveStats(updatedStats);

        return saveResult.fold(
          (failure) => Left(failure),
          (_) => Right(updatedStats),
        );
      },
    );
  }

  GameStats _calculateUpdatedStats({
    required GameStats currentStats,
    required bool won,
    required int timeSeconds,
  }) {
    int newTotalGames = currentStats.totalGames + 1;
    int newTotalWins = currentStats.totalWins + (won ? 1 : 0);
    int newCurrentStreak = won ? currentStats.currentStreak + 1 : 0;
    int newBestStreak = currentStats.bestStreak;
    int newBestTime = currentStats.bestTime;

    if (newCurrentStreak > newBestStreak) {
      newBestStreak = newCurrentStreak;
    }

    // Update best time only if won and faster than current best (or first win)
    if (won) {
      if (newBestTime == 0 || timeSeconds < newBestTime) {
        newBestTime = timeSeconds;
      }
    }

    return currentStats.copyWith(
      totalGames: newTotalGames,
      totalWins: newTotalWins,
      currentStreak: newCurrentStreak,
      bestStreak: newBestStreak,
      bestTime: newBestTime,
    );
  }
}
