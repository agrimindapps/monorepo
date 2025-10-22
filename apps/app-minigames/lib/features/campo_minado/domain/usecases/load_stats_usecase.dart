import 'package:core/core.dart';
import '../entities/game_stats.dart';
import '../entities/enums.dart';
import '../repositories/campo_minado_repository.dart';

/// Use case for loading game statistics
class LoadStatsUseCase {
  final CampoMinadoRepository _repository;

  const LoadStatsUseCase(this._repository);

  Future<Either<Failure, GameStats>> call({
    required Difficulty difficulty,
  }) async {
    return await _repository.loadStats(difficulty);
  }
}
