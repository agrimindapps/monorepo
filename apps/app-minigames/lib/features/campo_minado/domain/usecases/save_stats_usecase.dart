import 'package:core/core.dart';
import '../entities/game_stats.dart';
import '../repositories/campo_minado_repository.dart';

/// Use case for saving game statistics
class SaveStatsUseCase {
  final CampoMinadoRepository _repository;

  const SaveStatsUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required GameStats stats,
  }) async {
    // Validation
    if (stats.totalGames < 0) {
      return const Left(ValidationFailure('Total de jogos não pode ser negativo'));
    }

    if (stats.totalWins < 0) {
      return const Left(ValidationFailure('Total de vitórias não pode ser negativo'));
    }

    if (stats.totalWins > stats.totalGames) {
      return const Left(
        ValidationFailure('Total de vitórias não pode ser maior que total de jogos'),
      );
    }

    if (stats.bestTime < 0) {
      return const Left(ValidationFailure('Melhor tempo não pode ser negativo'));
    }

    return await _repository.saveStats(stats);
  }
}
