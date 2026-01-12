import '../entities/frogger_stats.dart';
import '../repositories/i_frogger_stats_repository.dart';

class GetStatsUseCase {
  final IFroggerStatsRepository repository;

  GetStatsUseCase(this.repository);

  Future<FroggerStats> call() async {
    return await repository.getStats();
  }
}
