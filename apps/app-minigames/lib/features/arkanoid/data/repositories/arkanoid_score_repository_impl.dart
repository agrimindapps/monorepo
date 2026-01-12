import '../../domain/entities/arkanoid_score.dart';
import '../../domain/repositories/i_arkanoid_score_repository.dart';
import '../datasources/local/arkanoid_local_datasource.dart';
import '../models/arkanoid_score_model.dart';

class ArkanoidScoreRepositoryImpl implements IArkanoidScoreRepository {
  final ArkanoidLocalDatasource _localDatasource;

  ArkanoidScoreRepositoryImpl(this._localDatasource);

  @override
  Future<void> saveScore(ArkanoidScore score) async {
    final model = ArkanoidScoreModel.fromEntity(score);
    await _localDatasource.saveScore(model);
  }

  @override
  Future<List<ArkanoidScore>> getAllScores() async {
    return _localDatasource.getScores();
  }

  @override
  Future<List<ArkanoidScore>> getTopScores({int limit = 10}) async {
    return _localDatasource.getTopScores(limit: limit);
  }

  @override
  Future<void> deleteScore(String id) async {
    await _localDatasource.deleteScore(id);
  }

  @override
  Future<void> deleteAllScores() async {
    await _localDatasource.deleteAllScores();
  }
}
