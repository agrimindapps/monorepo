import '../../domain/entities/galaga_score.dart';
import '../../domain/repositories/i_galaga_score_repository.dart';
import '../datasources/local/galaga_local_datasource.dart';
import '../models/galaga_score_model.dart';

class GalagaScoreRepositoryImpl implements IGalagaScoreRepository {
  final GalagaLocalDatasource _datasource;

  GalagaScoreRepositoryImpl(this._datasource);

  @override
  Future<List<GalagaScore>> getScores() async {
    return await _datasource.getScores();
  }

  @override
  Future<void> saveScore(GalagaScore score) async {
    final model = GalagaScoreModel.fromEntity(score);
    await _datasource.saveScore(model);
  }

  @override
  Future<void> deleteScore(GalagaScore score) async {
    final model = GalagaScoreModel.fromEntity(score);
    await _datasource.deleteScore(model);
  }

  @override
  Future<void> clearAllScores() async {
    await _datasource.clearAllScores();
  }
}
