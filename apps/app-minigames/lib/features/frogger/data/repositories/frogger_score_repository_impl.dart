import '../../domain/entities/frogger_score.dart';
import '../../domain/repositories/i_frogger_score_repository.dart';
import '../datasources/local/frogger_local_datasource.dart';
import '../models/frogger_score_model.dart';

class FroggerScoreRepositoryImpl implements IFroggerScoreRepository {
  final FroggerLocalDatasource _datasource;

  FroggerScoreRepositoryImpl(this._datasource);

  @override
  Future<List<FroggerScore>> getScores() async {
    return await _datasource.getScores();
  }

  @override
  Future<void> saveScore(FroggerScore score) async {
    final model = FroggerScoreModel.fromEntity(score);
    await _datasource.saveScore(model);
  }

  @override
  Future<void> deleteScore(FroggerScore score) async {
    final model = FroggerScoreModel.fromEntity(score);
    await _datasource.deleteScore(model);
  }

  @override
  Future<void> clearAllScores() async {
    await _datasource.clearAllScores();
  }
}
