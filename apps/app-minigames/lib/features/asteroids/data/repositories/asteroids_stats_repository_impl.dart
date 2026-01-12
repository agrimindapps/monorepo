import '../../domain/entities/asteroids_stats.dart';
import '../../domain/repositories/i_asteroids_stats_repository.dart';
import '../datasources/local/asteroids_local_datasource.dart';
import '../models/asteroids_stats_model.dart';

class AsteroidsStatsRepositoryImpl implements IAsteroidsStatsRepository {
  final AsteroidsLocalDatasource _datasource;

  AsteroidsStatsRepositoryImpl(this._datasource);

  @override
  Future<AsteroidsStats> getStats() async {
    return await _datasource.getStats();
  }

  @override
  Future<void> updateStats(AsteroidsStats stats) async {
    final model = AsteroidsStatsModel.fromEntity(stats);
    await _datasource.saveStats(model);
  }

  @override
  Future<void> resetStats() async {
    await _datasource.clearStats();
  }
}
