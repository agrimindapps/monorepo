import '../../domain/entities/asteroids_score.dart';
import '../../domain/repositories/i_asteroids_score_repository.dart';
import '../datasources/local/asteroids_local_datasource.dart';
import '../models/asteroids_score_model.dart';

class AsteroidsScoreRepositoryImpl implements IAsteroidsScoreRepository {
  final AsteroidsLocalDatasource _datasource;

  AsteroidsScoreRepositoryImpl(this._datasource);

  @override
  Future<List<AsteroidsScore>> getScores() async {
    return await _datasource.getScores();
  }

  @override
  Future<void> saveScore(AsteroidsScore score) async {
    final model = AsteroidsScoreModel.fromEntity(score);
    await _datasource.saveScore(model);
  }

  @override
  Future<void> deleteScore(AsteroidsScore score) async {
    final model = AsteroidsScoreModel.fromEntity(score);
    await _datasource.deleteScore(model);
  }

  @override
  Future<void> clearAllScores() async {
    await _datasource.clearAllScores();
  }
}
