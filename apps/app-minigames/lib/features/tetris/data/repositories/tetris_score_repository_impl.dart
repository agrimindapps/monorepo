import '../../domain/entities/tetris_score.dart';
import '../../domain/repositories/i_tetris_score_repository.dart';
import '../datasources/local/tetris_local_datasource.dart';
import '../models/tetris_score_model.dart';

/// Implementação do repositório de scores
class TetrisScoreRepositoryImpl implements ITetrisScoreRepository {
  final TetrisLocalDatasource _localDatasource;

  TetrisScoreRepositoryImpl(this._localDatasource);

  @override
  Future<void> saveScore(TetrisScore score) async {
    final model = TetrisScoreModel.fromEntity(score);
    await _localDatasource.saveScore(model);
  }

  @override
  Future<List<TetrisScore>> getAllScores() async {
    final models = await _localDatasource.getAllScores();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TetrisScore>> getTopScores(int limit) async {
    final models = await _localDatasource.getTopScores(limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TetrisScore>> getTodayScores() async {
    final models = await _localDatasource.getTodayScores();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TetrisScore>> getWeekScores() async {
    final models = await _localDatasource.getWeekScores();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> deleteScore(String id) async {
    await _localDatasource.deleteScore(id);
  }

  @override
  Future<void> deleteAllScores() async {
    await _localDatasource.deleteAllScores();
  }

  @override
  Future<TetrisScore?> getBestScore() async {
    final model = await _localDatasource.getBestScore();
    return model?.toEntity();
  }
}
