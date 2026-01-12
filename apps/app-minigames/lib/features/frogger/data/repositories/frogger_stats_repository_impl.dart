import '../../domain/entities/frogger_stats.dart';
import '../../domain/repositories/i_frogger_stats_repository.dart';
import '../datasources/local/frogger_local_datasource.dart';
import '../models/frogger_stats_model.dart';

class FroggerStatsRepositoryImpl implements IFroggerStatsRepository {
  final FroggerLocalDatasource _datasource;

  FroggerStatsRepositoryImpl(this._datasource);

  @override
  Future<FroggerStats> getStats() async {
    return await _datasource.getStats();
  }

  @override
  Future<void> updateStats(FroggerStats stats) async {
    final model = FroggerStatsModel.fromEntity(stats);
    await _datasource.saveStats(model);
  }

  @override
  Future<void> resetStats() async {
    await _datasource.clearStats();
  }
}
