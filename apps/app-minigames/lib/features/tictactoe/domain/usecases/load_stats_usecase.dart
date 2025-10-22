import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_stats.dart';
import '../repositories/tictactoe_repository.dart';

/// Use case for loading game statistics from storage
@injectable
class LoadStatsUseCase {
  final TicTacToeRepository repository;

  LoadStatsUseCase(this.repository);

  /// Loads game statistics from storage
  /// Returns [GameStats] on success or [Failure] on error
  Future<Either<Failure, GameStats>> call() async {
    return await repository.getStats();
  }
}
