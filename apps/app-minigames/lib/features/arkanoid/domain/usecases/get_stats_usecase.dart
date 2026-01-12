import '../entities/arkanoid_stats.dart';
import '../repositories/i_arkanoid_stats_repository.dart';

class GetStatsUseCase {
  final IArkanoidStatsRepository _repository;

  GetStatsUseCase(this._repository);

  Future<ArkanoidStats> call() async {
    return _repository.getStats();
  }
}
