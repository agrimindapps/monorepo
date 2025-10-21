// Project imports:
import 'package:app_minigames/constants/enums.dart';

class GameMove {
  final int row;
  final int col;
  final Player player;
  final DateTime timestamp;
  final Duration thinkingTime;
  
  GameMove({
    required this.row,
    required this.col,
    required this.player,
    required this.timestamp,
    required this.thinkingTime,
  });
  
  Map<String, dynamic> toJson() => {
    'row': row,
    'col': col,
    'player': player.name,
    'timestamp': timestamp.toIso8601String(),
    'thinkingTime': thinkingTime.inMilliseconds,
  };
}

class GameSession {
  final List<GameMove> moves;
  final GameResult result;
  final GameMode mode;
  final Difficulty difficulty;
  final DateTime startTime;
  final DateTime endTime;
  
  GameSession({
    required this.moves,
    required this.result,
    required this.mode,
    required this.difficulty,
    required this.startTime,
    required this.endTime,
  });
  
  Duration get totalDuration => endTime.difference(startTime);
  
  Duration get averageThinkingTime {
    if (moves.isEmpty) return Duration.zero;
    final total = moves.fold<Duration>(
      Duration.zero,
      (sum, move) => sum + move.thinkingTime,
    );
    return Duration(milliseconds: total.inMilliseconds ~/ moves.length);
  }
  
  Map<String, dynamic> toJson() => {
    'moves': moves.map((m) => m.toJson()).toList(),
    'result': result.name,
    'mode': mode.name,
    'difficulty': difficulty.name,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
  };
}

class GameAnalytics {
  final List<GameSession> sessions = [];
  
  // Análises
  double get winRate {
    if (sessions.isEmpty) return 0.0;
    final wins = sessions.where((s) => s.result == GameResult.xWins).length;
    return wins / sessions.length;
  }
  
  Duration get averageGameDuration {
    if (sessions.isEmpty) return Duration.zero;
    final total = sessions.fold<Duration>(
      Duration.zero,
      (sum, session) => sum + session.totalDuration,
    );
    return Duration(milliseconds: total.inMilliseconds ~/ sessions.length);
  }
  
  Map<String, int> get preferredPositions {
    final positions = <String, int>{};
    for (final session in sessions) {
      for (final move in session.moves) {
        if (move.player == Player.x) { // Jogadas do usuário
          final key = '${move.row}-${move.col}';
          positions[key] = (positions[key] ?? 0) + 1;
        }
      }
    }
    return positions;
  }
  
  List<String> getGameTips() {
    final tips = <String>[];
    
    if (sessions.isEmpty) {
      tips.add('Jogue mais partidas para receber dicas personalizadas!');
      return tips;
    }
    
    // Análise de padrões
    final positions = preferredPositions;
    final centerMoves = positions['1-1'] ?? 0;
    final cornerMoves = (positions['0-0'] ?? 0) + 
                       (positions['0-2'] ?? 0) + 
                       (positions['2-0'] ?? 0) + 
                       (positions['2-2'] ?? 0);
    
    if (centerMoves < cornerMoves) {
      tips.add('Dica: Tente jogar no centro mais frequentemente - é uma posição estratégica!');
    }
    
    final avgThinking = sessions.isNotEmpty 
      ? sessions.fold<Duration>(Duration.zero, (sum, s) => sum + s.averageThinkingTime)
      : Duration.zero;
    
    if (avgThinking.inSeconds > 10) {
      tips.add('Dica: Tente ser mais rápido nas decisões - confie nos seus instintos!');
    }
    
    if (winRate < 0.3) {
      tips.add('Dica: Foque em bloquear as jogadas do oponente além de buscar suas próprias vitórias.');
    }
    
    if (winRate > 0.7) {
      tips.add('Excelente! Você está dominando o jogo. Que tal tentar uma dificuldade maior?');
    }
    
    return tips;
  }
}
