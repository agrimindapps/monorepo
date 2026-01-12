import '../entities/tetris_score.dart';
import '../repositories/i_tetris_score_repository.dart';

/// Use case para obter high scores
class GetHighScoresUseCase {
  final ITetrisScoreRepository _repository;

  GetHighScoresUseCase(this._repository);

  /// Obtém top N scores
  Future<List<TetrisScore>> call({int limit = 10}) async {
    return _repository.getTopScores(limit);
  }

  /// Obtém todos os scores
  Future<List<TetrisScore>> getAll() async {
    return _repository.getAllScores();
  }

  /// Obtém scores de hoje
  Future<List<TetrisScore>> getToday() async {
    return _repository.getTodayScores();
  }

  /// Obtém scores desta semana
  Future<List<TetrisScore>> getWeek() async {
    return _repository.getWeekScores();
  }
}
