import '../entities/tetris_score.dart';
import '../repositories/i_tetris_score_repository.dart';
import '../repositories/i_tetris_stats_repository.dart';

/// Use case para salvar um score e atualizar estatísticas
class SaveScoreUseCase {
  final ITetrisScoreRepository _scoreRepository;
  final ITetrisStatsRepository _statsRepository;

  SaveScoreUseCase(this._scoreRepository, this._statsRepository);

  /// Executa o use case: salva score e atualiza stats
  Future<void> call(TetrisScore score, {int tetrisCount = 0}) async {
    // Salva o score
    await _scoreRepository.saveScore(score);

    // Atualiza estatísticas
    final currentStats = await _statsRepository.getStats();
    
    final updatedStats = currentStats.copyWith(
      totalGames: currentStats.totalGames + 1,
      totalScore: currentStats.totalScore + score.score,
      totalLines: currentStats.totalLines + score.lines,
      highestScore: score.score > currentStats.highestScore 
          ? score.score 
          : currentStats.highestScore,
      highestLines: score.lines > currentStats.highestLines
          ? score.lines
          : currentStats.highestLines,
      highestLevel: score.level > currentStats.highestLevel
          ? score.level
          : currentStats.highestLevel,
      totalPlayTime: Duration(
        milliseconds: currentStats.totalPlayTime.inMilliseconds + 
                      score.duration.inMilliseconds,
      ),
      lastPlayedAt: score.completedAt,
      tetrisCount: currentStats.tetrisCount + tetrisCount,
    );

    await _statsRepository.saveStats(updatedStats);
  }
}
