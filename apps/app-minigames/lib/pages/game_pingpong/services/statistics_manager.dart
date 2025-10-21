// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/models/game_state.dart';
import 'package:app_minigames/models/paddle.dart';

/// Gerenciador de estatísticas do jogo Ping Pong
///
/// Coleta, processa e fornece estatísticas detalhadas sobre o desempenho
/// do jogador e dados de jogo para análise e melhoria da experiência.


/// Gerenciador central de estatísticas e métricas
class StatisticsManager extends ChangeNotifier {
  /// Instância singleton
  static StatisticsManager? _instance;
  static StatisticsManager get instance => _instance ??= StatisticsManager._();

  StatisticsManager._();

  /// Estatísticas da sessão atual
  SessionStats _currentSession = SessionStats();

  /// Estatísticas históricas
  HistoricalStats _historicalStats = HistoricalStats();

  /// Timer para coleta de estatísticas em tempo real
  Timer? _statsTimer;

  /// Estado do jogo para monitoramento
  PingPongGameState? _gameState;

  /// Getters
  SessionStats get currentSession => _currentSession;
  HistoricalStats get historicalStats => _historicalStats;
  bool get isTracking => _statsTimer?.isActive ?? false;

  /// Inicializa o gerenciador de estatísticas
  Future<void> initialize() async {
    await _loadHistoricalStats();
    _startNewSession();

    debugPrint('StatisticsManager inicializado');
    notifyListeners();
  }

  /// Inicia uma nova sessão de estatísticas
  void _startNewSession() {
    _currentSession = SessionStats();
    _currentSession.sessionStartTime = DateTime.now();

    debugPrint('Nova sessão de estatísticas iniciada');
  }

  /// Conecta com o estado do jogo para monitoramento automático
  void attachToGame(PingPongGameState gameState) {
    _gameState = gameState;
    _gameState?.addListener(_onGameStateChanged);

    debugPrint('StatisticsManager conectado ao estado do jogo');
  }

  /// Desconecta do estado do jogo
  void detachFromGame() {
    _gameState?.removeListener(_onGameStateChanged);
    _gameState = null;

    debugPrint('StatisticsManager desconectado do estado do jogo');
  }

  /// Inicia o tracking de uma partida
  void startGameTracking(GameMode mode, Difficulty difficulty) {
    final gameStats = GameStats(
      gameMode: mode,
      difficulty: difficulty,
      startTime: DateTime.now(),
    );

    _currentSession.currentGame = gameStats;
    _startRealTimeTracking();

    notifyListeners();
  }

  /// Para o tracking da partida atual
  void stopGameTracking() {
    _stopRealTimeTracking();

    if (_currentSession.currentGame != null) {
      _currentSession.currentGame!.endTime = DateTime.now();
      _currentSession.completedGames.add(_currentSession.currentGame!);
      _currentSession.currentGame = null;
    }

    notifyListeners();
  }

  /// Inicia tracking em tempo real
  void _startRealTimeTracking() {
    _statsTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) => _collectRealTimeStats(),
    );
  }

  /// Para tracking em tempo real
  void _stopRealTimeTracking() {
    _statsTimer?.cancel();
    _statsTimer = null;
  }

  /// Coleta estatísticas em tempo real
  void _collectRealTimeStats() {
    if (_gameState == null || _currentSession.currentGame == null) return;

    final game = _currentSession.currentGame!;
    final gameState = _gameState!;

    // Atualiza duração do jogo
    game.duration = DateTime.now().difference(game.startTime);

    // Atualiza estatísticas da bola
    game.ballStats.currentSpeed = gameState.ball.currentSpeed;
    if (gameState.ball.currentSpeed > game.ballStats.maxSpeed) {
      game.ballStats.maxSpeed = gameState.ball.currentSpeed;
    }

    // Atualiza posições para calcular distância percorrida
    final ballDistance = _calculateDistance(
      game.ballStats.lastPosition.dx,
      game.ballStats.lastPosition.dy,
      gameState.ball.x,
      gameState.ball.y,
    );

    game.ballStats.totalDistance += ballDistance;
    game.ballStats.lastPosition = Offset(gameState.ball.x, gameState.ball.y);

    // Atualiza estatísticas das raquetes
    _updatePaddleStats(game.playerStats, gameState.playerPaddle);
    _updatePaddleStats(game.aiStats, gameState.aiPaddle);

    // Atualiza score
    game.playerScore = gameState.playerScore;
    game.aiScore = gameState.aiScore;

    notifyListeners();
  }

  /// Calcula distância entre dois pontos
  double _calculateDistance(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return (dx * dx + dy * dy) / 2; // Simplified for performance
  }

  /// Atualiza estatísticas de uma raquete
  void _updatePaddleStats(PaddleStats paddleStats, paddle) {
    paddleStats.currentSpeed = paddle.velocity.abs();
    if (paddle.velocity.abs() > paddleStats.maxSpeed) {
      paddleStats.maxSpeed = paddle.velocity.abs();
    }

    final distance = (paddle.y - paddleStats.lastPosition).abs();
    paddleStats.totalDistance += distance;
    paddleStats.lastPosition = paddle.y;
  }

  /// Responde a mudanças no estado do jogo
  void _onGameStateChanged() {
    if (_gameState == null) return;

    // Detecta início de jogo
    if (_gameState!.isPlaying && _currentSession.currentGame == null) {
      startGameTracking(_gameState!.gameMode, _gameState!.difficulty);
    }

    // Detecta fim de jogo
    if (_gameState!.isGameOver && _currentSession.currentGame != null) {
      _recordGameEnd();
    }
  }

  /// Registra fim de jogo
  void _recordGameEnd() {
    if (_currentSession.currentGame == null || _gameState == null) return;

    final game = _currentSession.currentGame!;
    game.endTime = DateTime.now();
    game.playerWon = _gameState!.playerWon;
    game.totalHits = _gameState!.totalHits;
    game.maxRally = _gameState!.maxRally;

    // Adiciona ao histórico
    _currentSession.completedGames.add(game);
    _currentSession.currentGame = null;

    // Atualiza estatísticas históricas
    _updateHistoricalStats(game);

    stopGameTracking();

    debugPrint('Jogo registrado: ${game.playerWon ? "Vitória" : "Derrota"}');
  }

  /// Atualiza estatísticas históricas
  void _updateHistoricalStats(GameStats game) {
    _historicalStats.totalGamesPlayed++;

    if (game.playerWon) {
      _historicalStats.totalWins++;
    } else {
      _historicalStats.totalLosses++;
    }

    _historicalStats.totalPlayTime += game.duration;
    _historicalStats.totalHits += game.totalHits;

    if (game.maxRally > _historicalStats.bestRally) {
      _historicalStats.bestRally = game.maxRally;
    }

    if (game.ballStats.maxSpeed > _historicalStats.maxBallSpeed) {
      _historicalStats.maxBallSpeed = game.ballStats.maxSpeed;
    }

    // Atualiza streak
    if (game.playerWon) {
      _historicalStats.currentWinStreak++;
      if (_historicalStats.currentWinStreak > _historicalStats.bestWinStreak) {
        _historicalStats.bestWinStreak = _historicalStats.currentWinStreak;
      }
      _historicalStats.currentLossStreak = 0;
    } else {
      _historicalStats.currentLossStreak++;
      _historicalStats.currentWinStreak = 0;
    }

    // Atualiza por dificuldade
    final difficultyStats = _historicalStats
        .statsByDifficulty[game.difficulty] ??= DifficultyStats();
    difficultyStats.gamesPlayed++;
    if (game.playerWon) difficultyStats.wins++;

    // Atualiza por modo de jogo
    final modeStats =
        _historicalStats.statsByGameMode[game.gameMode] ??= GameModeStats();
    modeStats.gamesPlayed++;
    if (game.playerWon) modeStats.wins++;

    // Salva automaticamente
    _saveHistoricalStats();
  }

  /// Registra hit de raquete
  void recordPaddleHit(PaddleType paddleType, double impact) {
    if (_currentSession.currentGame == null) return;

    final game = _currentSession.currentGame!;

    if (paddleType == PaddleType.player) {
      game.playerStats.totalHits++;
      game.playerStats.totalImpact += impact;
      game.playerStats.impactHistory.add(impact);

      // Limita histórico de impacto
      if (game.playerStats.impactHistory.length > 100) {
        game.playerStats.impactHistory.removeAt(0);
      }
    } else {
      game.aiStats.totalHits++;
      game.aiStats.totalImpact += impact;
    }

    notifyListeners();
  }

  /// Registra erro do jogador
  void recordPlayerError(ErrorType errorType) {
    if (_currentSession.currentGame == null) return;

    final game = _currentSession.currentGame!;
    game.playerErrors[errorType] = (game.playerErrors[errorType] ?? 0) + 1;

    notifyListeners();
  }

  /// Obtém estatísticas da sessão atual
  Map<String, dynamic> getCurrentSessionStats() {
    return {
      'duration': _currentSession.sessionDuration.inMinutes,
      'gamesPlayed': _currentSession.completedGames.length,
      'wins': _currentSession.completedGames.where((g) => g.playerWon).length,
      'losses':
          _currentSession.completedGames.where((g) => !g.playerWon).length,
      'winRate': _currentSession.winRate,
      'averageGameDuration': _currentSession.averageGameDuration.inSeconds,
      'totalHits': _currentSession.totalHits,
      'currentGame': _currentSession.currentGame?.toMap(),
    };
  }

  /// Obtém estatísticas históricas
  Map<String, dynamic> getHistoricalStats() {
    return {
      'totalGames': _historicalStats.totalGamesPlayed,
      'totalWins': _historicalStats.totalWins,
      'totalLosses': _historicalStats.totalLosses,
      'winRate': _historicalStats.winRate,
      'totalPlayTime': _historicalStats.totalPlayTime.inHours,
      'bestWinStreak': _historicalStats.bestWinStreak,
      'currentWinStreak': _historicalStats.currentWinStreak,
      'bestRally': _historicalStats.bestRally,
      'maxBallSpeed': _historicalStats.maxBallSpeed.toStringAsFixed(2),
      'statsByDifficulty': _historicalStats.statsByDifficulty.map(
        (key, value) => MapEntry(key.toString(), value.toMap()),
      ),
      'statsByGameMode': _historicalStats.statsByGameMode.map(
        (key, value) => MapEntry(key.toString(), value.toMap()),
      ),
    };
  }

  /// Obtém insights de performance
  List<PerformanceInsight> getPerformanceInsights() {
    final insights = <PerformanceInsight>[];

    // Análise de win rate
    if (_historicalStats.totalGamesPlayed >= 10) {
      if (_historicalStats.winRate >= 0.7) {
        insights.add(PerformanceInsight(
          type: InsightType.positive,
          title: 'Excelente Performance!',
          description:
              'Você tem uma taxa de vitória de ${(_historicalStats.winRate * 100).toStringAsFixed(1)}%',
        ));
      } else if (_historicalStats.winRate <= 0.3) {
        insights.add(PerformanceInsight(
          type: InsightType.improvement,
          title: 'Área de Melhoria',
          description: 'Tente praticar mais para melhorar sua taxa de vitória',
        ));
      }
    }

    // Análise de streak
    if (_historicalStats.currentWinStreak >= 5) {
      insights.add(PerformanceInsight(
        type: InsightType.achievement,
        title: 'Em Chamas! 🔥',
        description:
            'Você está em uma sequência de ${_historicalStats.currentWinStreak} vitórias!',
      ));
    }

    // Análise de tempo de jogo
    if (_historicalStats.totalPlayTime.inHours >= 5) {
      insights.add(PerformanceInsight(
        type: InsightType.milestone,
        title: 'Jogador Dedicado',
        description:
            'Você já jogou por ${_historicalStats.totalPlayTime.inHours} horas!',
      ));
    }

    return insights;
  }

  /// Carrega estatísticas históricas
  Future<void> _loadHistoricalStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('pingpong_historical_stats');

      if (statsJson != null) {
        final data = json.decode(statsJson) as Map<String, dynamic>;
        _historicalStats = HistoricalStats.fromMap(data);
      }
    } catch (e) {
      debugPrint('Erro ao carregar estatísticas históricas: $e');
    }
  }

  /// Salva estatísticas históricas
  Future<void> _saveHistoricalStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = json.encode(_historicalStats.toMap());
      await prefs.setString('pingpong_historical_stats', statsJson);
    } catch (e) {
      debugPrint('Erro ao salvar estatísticas históricas: $e');
    }
  }

  /// Reseta todas as estatísticas
  Future<void> resetAllStats() async {
    _historicalStats = HistoricalStats();
    _startNewSession();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pingpong_historical_stats');

    notifyListeners();
  }

  @override
  void dispose() {
    _stopRealTimeTracking();
    detachFromGame();
    super.dispose();
  }
}

/// Estatísticas da sessão atual
class SessionStats {
  DateTime sessionStartTime = DateTime.now();
  List<GameStats> completedGames = [];
  GameStats? currentGame;

  Duration get sessionDuration => DateTime.now().difference(sessionStartTime);

  double get winRate {
    if (completedGames.isEmpty) return 0.0;
    final wins = completedGames.where((g) => g.playerWon).length;
    return wins / completedGames.length;
  }

  Duration get averageGameDuration {
    if (completedGames.isEmpty) return Duration.zero;
    final total = completedGames.fold<Duration>(
      Duration.zero,
      (sum, game) => sum + game.duration,
    );
    return Duration(
        milliseconds: total.inMilliseconds ~/ completedGames.length);
  }

  int get totalHits =>
      completedGames.fold(0, (sum, game) => sum + game.totalHits);
}

/// Estatísticas históricas
class HistoricalStats {
  int totalGamesPlayed = 0;
  int totalWins = 0;
  int totalLosses = 0;
  Duration totalPlayTime = Duration.zero;
  int totalHits = 0;
  int bestRally = 0;
  double maxBallSpeed = 0.0;
  int bestWinStreak = 0;
  int currentWinStreak = 0;
  int currentLossStreak = 0;

  Map<Difficulty, DifficultyStats> statsByDifficulty = {};
  Map<GameMode, GameModeStats> statsByGameMode = {};

  HistoricalStats();

  double get winRate =>
      totalGamesPlayed > 0 ? totalWins / totalGamesPlayed : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalWins': totalWins,
      'totalLosses': totalLosses,
      'totalPlayTime': totalPlayTime.inMilliseconds,
      'totalHits': totalHits,
      'bestRally': bestRally,
      'maxBallSpeed': maxBallSpeed,
      'bestWinStreak': bestWinStreak,
      'currentWinStreak': currentWinStreak,
      'currentLossStreak': currentLossStreak,
      'statsByDifficulty': statsByDifficulty.map(
        (key, value) => MapEntry(key.index, value.toMap()),
      ),
      'statsByGameMode': statsByGameMode.map(
        (key, value) => MapEntry(key.index, value.toMap()),
      ),
    };
  }

  factory HistoricalStats.fromMap(Map<String, dynamic> map) {
    final stats = HistoricalStats();
    stats.totalGamesPlayed = map['totalGamesPlayed'] ?? 0;
    stats.totalWins = map['totalWins'] ?? 0;
    stats.totalLosses = map['totalLosses'] ?? 0;
    stats.totalPlayTime = Duration(milliseconds: map['totalPlayTime'] ?? 0);
    stats.totalHits = map['totalHits'] ?? 0;
    stats.bestRally = map['bestRally'] ?? 0;
    stats.maxBallSpeed = map['maxBallSpeed']?.toDouble() ?? 0.0;
    stats.bestWinStreak = map['bestWinStreak'] ?? 0;
    stats.currentWinStreak = map['currentWinStreak'] ?? 0;
    stats.currentLossStreak = map['currentLossStreak'] ?? 0;

    if (map['statsByDifficulty'] != null) {
      final diffStats = map['statsByDifficulty'] as Map<String, dynamic>;
      for (final entry in diffStats.entries) {
        final difficulty = Difficulty.values[int.parse(entry.key)];
        stats.statsByDifficulty[difficulty] =
            DifficultyStats.fromMap(entry.value);
      }
    }

    if (map['statsByGameMode'] != null) {
      final modeStats = map['statsByGameMode'] as Map<String, dynamic>;
      for (final entry in modeStats.entries) {
        final mode = GameMode.values[int.parse(entry.key)];
        stats.statsByGameMode[mode] = GameModeStats.fromMap(entry.value);
      }
    }

    return stats;
  }
}

/// Estatísticas de um jogo específico
class GameStats {
  final GameMode gameMode;
  final Difficulty difficulty;
  final DateTime startTime;
  DateTime? endTime;

  Duration duration = Duration.zero;
  bool playerWon = false;
  int playerScore = 0;
  int aiScore = 0;
  int totalHits = 0;
  int maxRally = 0;

  BallStats ballStats = BallStats();
  PaddleStats playerStats = PaddleStats();
  PaddleStats aiStats = PaddleStats();

  Map<ErrorType, int> playerErrors = {};

  GameStats({
    required this.gameMode,
    required this.difficulty,
    required this.startTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'gameMode': gameMode.index,
      'difficulty': difficulty.index,
      'duration': duration.inMilliseconds,
      'playerWon': playerWon,
      'playerScore': playerScore,
      'aiScore': aiScore,
      'totalHits': totalHits,
      'maxRally': maxRally,
      'ballStats': ballStats.toMap(),
      'playerStats': playerStats.toMap(),
      'aiStats': aiStats.toMap(),
    };
  }
}

/// Estatísticas da bola
class BallStats {
  double currentSpeed = 0.0;
  double maxSpeed = 0.0;
  double totalDistance = 0.0;
  Offset lastPosition = Offset.zero;

  Map<String, dynamic> toMap() {
    return {
      'maxSpeed': maxSpeed,
      'totalDistance': totalDistance,
    };
  }
}

/// Estatísticas de uma raquete
class PaddleStats {
  double currentSpeed = 0.0;
  double maxSpeed = 0.0;
  double totalDistance = 0.0;
  double lastPosition = 0.0;
  int totalHits = 0;
  double totalImpact = 0.0;
  List<double> impactHistory = [];

  double get averageImpact => totalHits > 0 ? totalImpact / totalHits : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'maxSpeed': maxSpeed,
      'totalDistance': totalDistance,
      'totalHits': totalHits,
      'averageImpact': averageImpact,
    };
  }
}

/// Estatísticas por dificuldade
class DifficultyStats {
  int gamesPlayed = 0;
  int wins = 0;

  DifficultyStats();

  double get winRate => gamesPlayed > 0 ? wins / gamesPlayed : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'gamesPlayed': gamesPlayed,
      'wins': wins,
      'winRate': winRate,
    };
  }

  factory DifficultyStats.fromMap(Map<String, dynamic> map) {
    final stats = DifficultyStats();
    stats.gamesPlayed = map['gamesPlayed'] ?? 0;
    stats.wins = map['wins'] ?? 0;
    return stats;
  }
}

/// Estatísticas por modo de jogo
class GameModeStats {
  int gamesPlayed = 0;
  int wins = 0;

  GameModeStats();

  double get winRate => gamesPlayed > 0 ? wins / gamesPlayed : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'gamesPlayed': gamesPlayed,
      'wins': wins,
      'winRate': winRate,
    };
  }

  factory GameModeStats.fromMap(Map<String, dynamic> map) {
    final stats = GameModeStats();
    stats.gamesPlayed = map['gamesPlayed'] ?? 0;
    stats.wins = map['wins'] ?? 0;
    return stats;
  }
}

/// Insights de performance
class PerformanceInsight {
  final InsightType type;
  final String title;
  final String description;

  PerformanceInsight({
    required this.type,
    required this.title,
    required this.description,
  });
}

/// Tipos de insight
enum InsightType {
  positive,
  improvement,
  achievement,
  milestone,
}

/// Tipos de erro do jogador
enum ErrorType {
  missedBall,
  outOfBounds,
  weakHit,
  slowReaction,
}
