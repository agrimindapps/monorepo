import '../../domain/entities/space_invaders_score.dart';
import '../../domain/repositories/i_space_invaders_score_repository.dart';
import '../datasources/local/space_invaders_local_datasource.dart';
import '../models/space_invaders_score_model.dart';

class SpaceInvadersScoreRepositoryImpl implements ISpaceInvadersScoreRepository {
  final SpaceInvadersLocalDatasource _localDatasource;

  SpaceInvadersScoreRepositoryImpl(this._localDatasource);

  @override
  Future<void> saveScore(SpaceInvadersScore score) async {
    final model = SpaceInvadersScoreModel.fromEntity(score);
    await _localDatasource.saveScore(model);
  }

  @override
  Future<List<SpaceInvadersScore>> getAllScores() async {
    return _localDatasource.getScores();
  }

  @override
  Future<List<SpaceInvadersScore>> getTopScores({int limit = 10}) async {
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
