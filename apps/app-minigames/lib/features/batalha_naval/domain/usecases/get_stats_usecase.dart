import '../entities/batalha_naval_stats.dart';
import '../repositories/i_batalha_naval_stats_repository.dart';

class GetStatsUseCase {
  final IBatalhaNavalStatsRepository repository;

  GetStatsUseCase(this.repository);

  Future<BatalhaNavalStats> call() {
    return repository.getStats();
  }
}
