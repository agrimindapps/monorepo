import '../../domain/entities/batalha_naval_stats.dart';
import '../../domain/repositories/i_batalha_naval_stats_repository.dart';
import '../datasources/local/batalha_naval_local_datasource.dart';
import '../models/batalha_naval_stats_model.dart';

class BatalhaNavalStatsRepositoryImpl implements IBatalhaNavalStatsRepository {
  final BatalhaNavalLocalDatasource localDatasource;

  BatalhaNavalStatsRepositoryImpl(this.localDatasource);

  @override
  Future<BatalhaNavalStats> getStats() async {
    return await localDatasource.getStats();
  }

  @override
  Future<void> updateStats(BatalhaNavalStats stats) async {
    await localDatasource.updateStats(BatalhaNavalStatsModel.fromEntity(stats));
  }

  @override
  Future<void> resetStats() async {
    await localDatasource.resetStats();
  }
}
