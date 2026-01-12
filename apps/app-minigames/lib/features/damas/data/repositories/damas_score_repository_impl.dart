import '../../domain/entities/damas_score.dart';
import '../../domain/repositories/i_damas_score_repository.dart';
import '../datasources/local/damas_local_datasource.dart';
import '../models/damas_score_model.dart';

class DamasScoreRepositoryImpl implements IDamasScoreRepository {
  final DamasLocalDatasource localDatasource;

  DamasScoreRepositoryImpl(this.localDatasource);

  @override
  Future<List<DamasScore>> getScores() async {
    return localDatasource.getScores();
  }

  @override
  Future<void> saveScore(DamasScore score) async {
    await localDatasource.saveScore(DamasScoreModel.fromEntity(score));
  }

  @override
  Future<void> deleteScore(DamasScore score) async {
    await localDatasource.deleteScore(score.id);
  }

  @override
  Future<void> clearAllScores() async {
    // Optional: add to datasource if needed
  }
}
