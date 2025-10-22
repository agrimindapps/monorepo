import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Represents a single move in a game
class GameMove extends Equatable {
  final int row;
  final int col;
  final Player player;
  final DateTime timestamp;
  final Duration thinkingTime;

  const GameMove({
    required this.row,
    required this.col,
    required this.player,
    required this.timestamp,
    required this.thinkingTime,
  });

  @override
  List<Object> get props => [row, col, player, timestamp, thinkingTime];
}

/// Represents a complete game session with analytics data
class GameSession extends Equatable {
  final List<GameMove> moves;
  final GameResult result;
  final GameMode mode;
  final Difficulty difficulty;
  final DateTime startTime;
  final DateTime endTime;

  const GameSession({
    required this.moves,
    required this.result,
    required this.mode,
    required this.difficulty,
    required this.startTime,
    required this.endTime,
  });

  /// Total duration of the game
  Duration get totalDuration => endTime.difference(startTime);

  /// Average thinking time per move
  Duration get averageThinkingTime {
    if (moves.isEmpty) return Duration.zero;
    final total = moves.fold<Duration>(
      Duration.zero,
      (sum, move) => sum + move.thinkingTime,
    );
    return Duration(milliseconds: total.inMilliseconds ~/ moves.length);
  }

  @override
  List<Object> get props => [
        moves,
        result,
        mode,
        difficulty,
        startTime,
        endTime,
      ];
}

/// Analytics data for multiple game sessions
class GameAnalytics extends Equatable {
  final List<GameSession> sessions;

  const GameAnalytics({
    this.sessions = const [],
  });

  /// Win rate for X player (0.0 to 1.0)
  double get winRate {
    if (sessions.isEmpty) return 0.0;
    final wins = sessions.where((s) => s.result == GameResult.xWins).length;
    return wins / sessions.length;
  }

  /// Average game duration across all sessions
  Duration get averageGameDuration {
    if (sessions.isEmpty) return Duration.zero;
    final total = sessions.fold<Duration>(
      Duration.zero,
      (sum, session) => sum + session.totalDuration,
    );
    return Duration(milliseconds: total.inMilliseconds ~/ sessions.length);
  }

  /// Map of position preferences (e.g., "1-1" -> count)
  Map<String, int> get preferredPositions {
    final positions = <String, int>{};
    for (final session in sessions) {
      for (final move in session.moves) {
        if (move.player == Player.x) {
          final key = '${move.row}-${move.col}';
          positions[key] = (positions[key] ?? 0) + 1;
        }
      }
    }
    return positions;
  }

  /// Generates personalized game tips based on analytics
  List<String> getGameTips() {
    final tips = <String>[];

    if (sessions.isEmpty) {
      tips.add('Jogue mais partidas para receber dicas personalizadas!');
      return tips;
    }

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
        ? sessions.fold<Duration>(
            Duration.zero, (sum, s) => sum + s.averageThinkingTime)
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

  /// Adds a new session to analytics
  GameAnalytics addSession(GameSession session) {
    return GameAnalytics(
      sessions: [...sessions, session],
    );
  }

  @override
  List<Object> get props => [sessions];
}
