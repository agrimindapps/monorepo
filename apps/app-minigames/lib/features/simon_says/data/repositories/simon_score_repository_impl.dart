import '../../domain/entities/simon_score.dart';
import '../../domain/repositories/i_simon_score_repository.dart';
import '../datasources/local/simon_local_datasource.dart';
import '../models/simon_score_model.dart';

class SimonScoreRepositoryImpl implements ISimonScoreRepository {
  final SimonLocalDatasource _localDatasource;

  SimonScoreRepositoryImpl(this._localDatasource);

  @override
  Future<void> saveScore(SimonScore score) async {
    final model = SimonScoreModel.fromEntity(score);
    await _localDatasource.saveScore(model);
  }

  @override
  Future<List<SimonScore>> getAllScores() async {
    return _localDatasource.getScores();
  }

  @override
  Future<List<SimonScore>> getTopScores({int limit = 10}) async {
    return _localDatasource.getTopScores(limit: limit);
  }

  @override
  Future<List<SimonScore>> getTodayScores() async {
    return _localDatasource.getTodayScores();
  }

  @override
  Future<List<SimonScore>> getWeekScores() async {
    return _localDatasource.getWeekScores();
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
