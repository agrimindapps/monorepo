import '../../domain/entities/damas_stats.dart';
import '../../domain/repositories/i_damas_stats_repository.dart';
import '../datasources/local/damas_local_datasource.dart';
import '../models/damas_stats_model.dart';

class DamasStatsRepositoryImpl implements IDamasStatsRepository {
  final DamasLocalDatasource localDatasource;

  DamasStatsRepositoryImpl(this.localDatasource);

  @override
  Future<DamasStats> getStats() async {
    return localDatasource.getStats();
  }

  @override
  Future<void> updateStats(DamasStats stats) async {
    await localDatasource.updateStats(DamasStatsModel.fromEntity(stats));
  }

  @override
  Future<void> resetStats() async {
    // Optional
  }
}
