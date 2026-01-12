import '../entities/asteroids_stats.dart';
import '../repositories/i_asteroids_stats_repository.dart';

class GetStatsUseCase {
  final IAsteroidsStatsRepository repository;

  GetStatsUseCase(this.repository);

  Future<AsteroidsStats> call() async {
    return await repository.getStats();
  }
}
