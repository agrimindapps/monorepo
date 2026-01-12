import '../entities/space_invaders_stats.dart';
import '../repositories/i_space_invaders_stats_repository.dart';

class GetStatsUseCase {
  final ISpaceInvadersStatsRepository _repository;

  GetStatsUseCase(this._repository);

  Future<SpaceInvadersStats> call() async {
    return _repository.getStats();
  }
}
