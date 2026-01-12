import '../entities/simon_stats.dart';
import '../repositories/i_simon_stats_repository.dart';

class GetStatsUseCase {
  final ISimonStatsRepository _repository;

  GetStatsUseCase(this._repository);

  Future<SimonStats> call() async {
    return _repository.getStats();
  }
}
