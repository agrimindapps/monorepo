import '../../domain/entities/reversi_score.dart';
import '../../domain/repositories/i_reversi_score_repository.dart';
import '../datasources/local/reversi_local_datasource.dart';
import '../models/reversi_score_model.dart';

class ReversiScoreRepositoryImpl implements IReversiScoreRepository {
  final ReversiLocalDatasource _localDatasource;

  ReversiScoreRepositoryImpl(this._localDatasource);

  @override
  Future<void> saveScore(ReversiScore score) async {
    final model = ReversiScoreModel.fromEntity(score);
    await _localDatasource.saveScore(model);
  }

  @override
  Future<List<ReversiScore>> getAllScores() async {
    return _localDatasource.getScores();
  }

  @override
  Future<List<ReversiScore>> getTopScores({int limit = 10}) async {
    return _localDatasource.getTopScores(limit: limit);
  }

  @override
  Future<List<ReversiScore>> getTodayScores() async {
    return _localDatasource.getTodayScores();
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
