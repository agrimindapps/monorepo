import '../../domain/entities/space_invaders_stats.dart';
import '../../domain/repositories/i_space_invaders_stats_repository.dart';
import '../datasources/local/space_invaders_local_datasource.dart';
import '../models/space_invaders_stats_model.dart';

class SpaceInvadersStatsRepositoryImpl implements ISpaceInvadersStatsRepository {
  final SpaceInvadersLocalDatasource _localDatasource;

  SpaceInvadersStatsRepositoryImpl(this._localDatasource);

  @override
  Future<SpaceInvadersStats> getStats() async {
    return _localDatasource.getStats();
  }

  @override
  Future<void> updateStats(SpaceInvadersStats stats) async {
    final model = SpaceInvadersStatsModel.fromEntity(stats);
    await _localDatasource.updateStats(model);
  }

  @override
  Future<void> resetStats() async {
    await _localDatasource.resetStats();
  }
}
