import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/tictactoe_repository.dart';

/// Use case for resetting game statistics to zero
class ResetStatsUseCase {
  final TicTacToeRepository repository;

  ResetStatsUseCase(this.repository);

  /// Resets game statistics to zero
  /// Returns [void] on success or [Failure] on error
  Future<Either<Failure, void>> call() async {
    return await repository.resetStats();
  }
}
