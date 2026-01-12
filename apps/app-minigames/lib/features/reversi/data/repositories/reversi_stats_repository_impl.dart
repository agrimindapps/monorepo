import '../../domain/entities/reversi_stats.dart';
import '../../domain/repositories/i_reversi_stats_repository.dart';
import '../datasources/local/reversi_local_datasource.dart';
import '../models/reversi_stats_model.dart';

class ReversiStatsRepositoryImpl implements IReversiStatsRepository {
  final ReversiLocalDatasource _localDatasource;

  ReversiStatsRepositoryImpl(this._localDatasource);

  @override
  Future<ReversiStats> getStats() async {
    return _localDatasource.getStats();
  }

  @override
  Future<void> updateStats(ReversiStats stats) async {
    final model = ReversiStatsModel.fromEntity(stats);
    await _localDatasource.updateStats(model);
  }

  @override
  Future<void> resetStats() async {
    await _localDatasource.resetStats();
  }
}
