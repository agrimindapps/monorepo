import '../entities/tetris_stats.dart';

/// Interface do repositório de estatísticas do Tetris
abstract class ITetrisStatsRepository {
  /// Obtém as estatísticas atuais
  Future<TetrisStats> getStats();
  
  /// Salva/atualiza as estatísticas
  Future<void> saveStats(TetrisStats stats);
  
  /// Reseta as estatísticas
  Future<void> resetStats();
}
