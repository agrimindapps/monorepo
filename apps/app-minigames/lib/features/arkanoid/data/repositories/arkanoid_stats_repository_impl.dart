import '../../domain/entities/arkanoid_stats.dart';
import '../../domain/repositories/i_arkanoid_stats_repository.dart';
import '../datasources/local/arkanoid_local_datasource.dart';
import '../models/arkanoid_stats_model.dart';

class ArkanoidStatsRepositoryImpl implements IArkanoidStatsRepository {
  final ArkanoidLocalDatasource _localDatasource;

  ArkanoidStatsRepositoryImpl(this._localDatasource);

  @override
  Future<ArkanoidStats> getStats() async {
    return _localDatasource.getStats();
  }

  @override
  Future<void> updateStats(ArkanoidStats stats) async {
    final model = ArkanoidStatsModel.fromEntity(stats);
    await _localDatasource.updateStats(model);
  }

  @override
  Future<void> resetStats() async {
    await _localDatasource.resetStats();
  }
}
