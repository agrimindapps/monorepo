import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_stats.dart';
import '../repositories/tictactoe_repository.dart';

/// Use case for saving game statistics to storage
class SaveStatsUseCase {
  final TicTacToeRepository repository;

  SaveStatsUseCase(this.repository);

  /// Saves game statistics to storage
  ///
  /// Validates:
  /// - Stats values are non-negative
  ///
  /// Returns [void] on success or [Failure] on error
  Future<Either<Failure, void>> call(GameStats stats) async {
    // Validation: Stats must have non-negative values
    if (stats.xWins < 0 || stats.oWins < 0 || stats.draws < 0) {
      return const Left(
        ValidationFailure('Stats cannot have negative values'),
      );
    }

    return await repository.saveStats(stats);
  }
}
