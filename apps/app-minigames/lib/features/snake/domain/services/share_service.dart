/// Service for sharing game scores
class ShareService {
  /// Generate share text for game results
  String generateShareText({
    required int score,
    required int snakeLength,
    required String gameMode,
    required String difficulty,
    required int xpGained,
    required int playerLevel,
    required String levelTitle,
    bool isNewHighScore = false,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('🐍 NEON SNAKE 🐍');
    buffer.writeln('');
    
    if (isNewHighScore) {
      buffer.writeln('🏆 NOVO RECORDE! 🏆');
      buffer.writeln('');
    }
    
    buffer.writeln('📊 Score: $score pontos');
    buffer.writeln('📏 Tamanho: $snakeLength');
    buffer.writeln('🎮 Modo: $gameMode');
    buffer.writeln('⚡ Dificuldade: $difficulty');
    buffer.writeln('');
    buffer.writeln('✨ XP Ganho: +$xpGained');
    buffer.writeln('🎯 Level $playerLevel - $levelTitle');
    buffer.writeln('');
    buffer.writeln('Consegue me superar? 🎮');
    buffer.writeln('#NeonSnake #MiniGames');
    
    return buffer.toString();
  }

  /// Generate share text for statistics
  String generateStatsShareText({
    required int totalGames,
    required int highestScore,
    required int longestSnake,
    required int totalMinutesPlayed,
    required int playerLevel,
    required String levelTitle,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('🐍 NEON SNAKE - ESTATÍSTICAS 🐍');
    buffer.writeln('');
    buffer.writeln('🎮 Partidas: $totalGames');
    buffer.writeln('🏆 Maior Score: $highestScore');
    buffer.writeln('📏 Maior Cobra: $longestSnake');
    buffer.writeln('⏱️ Tempo Jogado: ${_formatMinutes(totalMinutesPlayed)}');
    buffer.writeln('');
    buffer.writeln('🎯 Level $playerLevel - $levelTitle');
    buffer.writeln('');
    buffer.writeln('#NeonSnake #MiniGames');
    
    return buffer.toString();
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m';
    }
    return '${minutes}m';
  }
}
