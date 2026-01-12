import '../entities/galaga_stats.dart';
import '../repositories/i_galaga_stats_repository.dart';

class GetStatsUseCase {
  final IGalagaStatsRepository repository;

  GetStatsUseCase(this.repository);

  Future<GalagaStats> call() async {
    return await repository.getStats();
  }
}
