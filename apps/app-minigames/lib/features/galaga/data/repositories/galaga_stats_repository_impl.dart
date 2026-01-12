import '../../domain/entities/galaga_stats.dart';
import '../../domain/repositories/i_galaga_stats_repository.dart';
import '../datasources/local/galaga_local_datasource.dart';
import '../models/galaga_stats_model.dart';

class GalagaStatsRepositoryImpl implements IGalagaStatsRepository {
  final GalagaLocalDatasource _datasource;

  GalagaStatsRepositoryImpl(this._datasource);

  @override
  Future<GalagaStats> getStats() async {
    return await _datasource.getStats();
  }

  @override
  Future<void> updateStats(GalagaStats stats) async {
    final model = GalagaStatsModel.fromEntity(stats);
    await _datasource.saveStats(model);
  }

  @override
  Future<void> resetStats() async {
    await _datasource.clearStats();
  }
}
