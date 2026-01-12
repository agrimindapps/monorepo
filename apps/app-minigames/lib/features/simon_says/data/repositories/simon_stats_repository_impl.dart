import '../../domain/entities/simon_stats.dart';
import '../../domain/repositories/i_simon_stats_repository.dart';
import '../datasources/local/simon_local_datasource.dart';
import '../models/simon_stats_model.dart';

class SimonStatsRepositoryImpl implements ISimonStatsRepository {
  final SimonLocalDatasource _localDatasource;

  SimonStatsRepositoryImpl(this._localDatasource);

  @override
  Future<SimonStats> getStats() async {
    return _localDatasource.getStats();
  }

  @override
  Future<void> updateStats(SimonStats stats) async {
    final model = SimonStatsModel.fromEntity(stats);
    await _localDatasource.updateStats(model);
  }

  @override
  Future<void> resetStats() async {
    await _localDatasource.resetStats();
  }
}
