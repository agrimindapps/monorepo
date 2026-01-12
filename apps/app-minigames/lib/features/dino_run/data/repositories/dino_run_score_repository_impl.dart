import '../../domain/entities/dino_run_score.dart';
import '../../domain/repositories/i_dino_run_score_repository.dart';
import '../datasources/local/dino_run_local_datasource.dart';
import '../models/dino_run_score_model.dart';

class DinoRunScoreRepositoryImpl implements IDinoRunScoreRepository {
  final DinoRunLocalDatasource _datasource;

  DinoRunScoreRepositoryImpl(this._datasource);

  @override
  Future<List<DinoRunScore>> getScores() async {
    return await _datasource.getScores();
  }

  @override
  Future<void> saveScore(DinoRunScore score) async {
    final model = DinoRunScoreModel.fromEntity(score);
    await _datasource.saveScore(model);
  }

  @override
  Future<void> deleteScore(DinoRunScore score) async {
    final model = DinoRunScoreModel.fromEntity(score);
    await _datasource.deleteScore(model);
  }

  @override
  Future<void> clearAllScores() async {
    await _datasource.clearAllScores();
  }
}
