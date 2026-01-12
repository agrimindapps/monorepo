import '../../domain/entities/dino_run_stats.dart';
import '../../domain/repositories/i_dino_run_stats_repository.dart';
import '../datasources/local/dino_run_local_datasource.dart';
import '../models/dino_run_stats_model.dart';

class DinoRunStatsRepositoryImpl implements IDinoRunStatsRepository {
  final DinoRunLocalDatasource _datasource;

  DinoRunStatsRepositoryImpl(this._datasource);

  @override
  Future<DinoRunStats> getStats() async {
    return await _datasource.getStats();
  }

  @override
  Future<void> updateStats(DinoRunStats stats) async {
    final model = DinoRunStatsModel.fromEntity(stats);
    await _datasource.saveStats(model);
  }

  @override
  Future<void> resetStats() async {
    await _datasource.clearStats();
  }
}
