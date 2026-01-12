import '../../domain/entities/tetris_stats.dart';
import '../../domain/repositories/i_tetris_stats_repository.dart';
import '../datasources/local/tetris_local_datasource.dart';
import '../models/tetris_stats_model.dart';

/// Implementação do repositório de estatísticas
class TetrisStatsRepositoryImpl implements ITetrisStatsRepository {
  final TetrisLocalDatasource _localDatasource;

  TetrisStatsRepositoryImpl(this._localDatasource);

  @override
  Future<TetrisStats> getStats() async {
    final model = await _localDatasource.getStats();
    return model.toEntity();
  }

  @override
  Future<void> saveStats(TetrisStats stats) async {
    final model = TetrisStatsModel.fromEntity(stats);
    await _localDatasource.saveStats(model);
  }

  @override
  Future<void> resetStats() async {
    await _localDatasource.resetStats();
  }
}
