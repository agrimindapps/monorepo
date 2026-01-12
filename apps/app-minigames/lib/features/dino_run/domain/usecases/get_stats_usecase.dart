import '../entities/dino_run_stats.dart';
import '../repositories/i_dino_run_stats_repository.dart';

class GetStatsUseCase {
  final IDinoRunStatsRepository repository;

  GetStatsUseCase(this.repository);

  Future<DinoRunStats> call() async {
    return await repository.getStats();
  }
}
