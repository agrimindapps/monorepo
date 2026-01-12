import '../entities/damas_stats.dart';
import '../repositories/i_damas_stats_repository.dart';

class GetStatsUseCase {
  final IDamasStatsRepository repository;

  GetStatsUseCase(this.repository);

  Future<DamasStats> call() async {
    return repository.getStats();
  }
}
