import '../entities/tetris_stats.dart';
import '../repositories/i_tetris_stats_repository.dart';

/// Use case para obter estatísticas
class GetStatsUseCase {
  final ITetrisStatsRepository _repository;

  GetStatsUseCase(this._repository);

  /// Obtém as estatísticas atuais
  Future<TetrisStats> call() async {
    return _repository.getStats();
  }
}
