import '../entities/tetris_score.dart';

/// Interface do repositório de scores do Tetris
abstract class ITetrisScoreRepository {
  /// Salva um novo score
  Future<void> saveScore(TetrisScore score);
  
  /// Obtém todos os scores salvos, ordenados por pontuação (maior primeiro)
  Future<List<TetrisScore>> getAllScores();
  
  /// Obtém os top N scores
  Future<List<TetrisScore>> getTopScores(int limit);
  
  /// Obtém scores de hoje
  Future<List<TetrisScore>> getTodayScores();
  
  /// Obtém scores desta semana
  Future<List<TetrisScore>> getWeekScores();
  
  /// Deleta um score específico
  Future<void> deleteScore(String id);
  
  /// Deleta todos os scores
  Future<void> deleteAllScores();
  
  /// Obtém o melhor score
  Future<TetrisScore?> getBestScore();
}
