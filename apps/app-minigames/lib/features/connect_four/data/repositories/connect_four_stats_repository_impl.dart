import '../../domain/entities/connect_four_stats.dart';
import '../../domain/repositories/i_connect_four_stats_repository.dart';
import '../datasources/local/connect_four_local_datasource.dart';
import '../models/connect_four_stats_model.dart';

class ConnectFourStatsRepositoryImpl implements IConnectFourStatsRepository {
  final ConnectFourLocalDatasource _datasource;

  ConnectFourStatsRepositoryImpl(this._datasource);

  @override
  Future<ConnectFourStats> getStats() async {
    return await _datasource.getStats();
  }

  @override
  Future<void> updateStats(ConnectFourStats stats) async {
    final model = ConnectFourStatsModel.fromEntity(stats);
    await _datasource.saveStats(model);
  }

  @override
  Future<void> resetStats() async {
    await _datasource.clearStats();
  }
}
