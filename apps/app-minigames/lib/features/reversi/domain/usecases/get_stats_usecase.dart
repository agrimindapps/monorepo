import '../entities/reversi_stats.dart';
import '../repositories/i_reversi_stats_repository.dart';

class GetStatsUseCase {
  final IReversiStatsRepository _repository;

  GetStatsUseCase(this._repository);

  Future<ReversiStats> call() async {
    return _repository.getStats();
  }
}
