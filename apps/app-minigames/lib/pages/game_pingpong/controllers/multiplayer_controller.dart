// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';
import '../controllers/feedback_controller.dart';
import 'package:app_minigames/models/game_state.dart';

/// Controlador de modo multijogador local para o jogo Ping Pong
///
/// Gerencia partidas com dois jogadores humanos na mesma tela,
/// incluindo controles separados, pontuação e coordenação de entrada.


/// Controlador para modo multijogador local
class MultiplayerController extends ChangeNotifier {
  /// Estado do jogo
  PingPongGameState? _gameState;

  /// Controladores de entrada para cada jogador
  final Map<PlayerId, PlayerInputController> _playerControllers = {};

  /// Controlador de feedback
  FeedbackController? _feedbackController;

  /// Configurações de jogadores
  final Map<PlayerId, PlayerConfig> _playerConfigs = {};

  /// Estatísticas da sessão multijogador
  final MultiplayerStats _stats = MultiplayerStats();

  /// Estado atual do modo multijogador
  MultiplayerState _currentState = MultiplayerState.setup;

  /// Configurações do modo multijogador
  MultiplayerConfig _config = MultiplayerConfig();

  /// Getters
  MultiplayerState get currentState => _currentState;
  MultiplayerConfig get config => _config;
  MultiplayerStats get stats => _stats;
  Map<PlayerId, PlayerConfig> get playerConfigs =>
      Map.unmodifiable(_playerConfigs);

  /// Inicializa o controlador multijogador
  Future<void> initialize(
    PingPongGameState gameState,
    FeedbackController feedbackController,
  ) async {
    _gameState = gameState;
    _feedbackController = feedbackController;

    // Configura jogadores padrão
    await _setupDefaultPlayers();

    // Configura estado do jogo para multijogador
    _gameState!.setGameMode(GameMode.multiPlayerLocal);

    _currentState = MultiplayerState.ready;
    notifyListeners();

    debugPrint('MultiplayerController inicializado');
  }

  /// Configura jogadores padrão
  Future<void> _setupDefaultPlayers() async {
    // Jogador 1 (esquerda)
    _playerConfigs[PlayerId.player1] = PlayerConfig(
      id: PlayerId.player1,
      name: 'Jogador 1',
      color: Colors.green,
      paddleSide: PaddleSide.left,
      preferredControls: ControlScheme.arrows,
    );

    // Jogador 2 (direita)
    _playerConfigs[PlayerId.player2] = PlayerConfig(
      id: PlayerId.player2,
      name: 'Jogador 2',
      color: Colors.red,
      paddleSide: PaddleSide.right,
      preferredControls: ControlScheme.wasd,
    );

    // Cria controladores de entrada
    for (final config in _playerConfigs.values) {
      _playerControllers[config.id] = PlayerInputController(config);
    }
  }

  /// Inicia uma partida multijogador
  void startMatch() {
    if (_gameState == null || _currentState != MultiplayerState.ready) return;

    // Reseta estatísticas
    _stats.reset();

    // Inicia jogo
    _gameState!.startGame();
    _currentState = MultiplayerState.playing;

    // Registra início da partida
    _stats.recordMatchStart();

    notifyListeners();
  }

  /// Para a partida atual
  void stopMatch() {
    if (_gameState == null) return;

    _gameState!.stopGame();
    _currentState = MultiplayerState.ready;

    // Registra fim da partida
    _stats.recordMatchEnd();

    notifyListeners();
  }

  /// Pausa/despausa a partida
  void togglePause() {
    if (_gameState == null || _currentState != MultiplayerState.playing) return;

    _gameState!.togglePause();

    if (_gameState!.isPaused) {
      _stats.recordPauseStart();
    } else {
      _stats.recordPauseEnd();
    }

    notifyListeners();
  }

  /// Processa entrada de movimento do jogador
  void handlePlayerMovement(PlayerId playerId, double deltaY) {
    if (_gameState == null || !_gameState!.isPlaying) return;

    final config = _playerConfigs[playerId];
    if (config == null) return;

    // Move a raquete apropriada
    if (config.paddleSide == PaddleSide.left) {
      _gameState!.movePlayerPaddle(deltaY);
      _stats.recordPlayerAction(playerId, PlayerAction.paddleMove);
    } else {
      // Para o jogador 2, move a raquete da "IA" (que agora é controlada pelo jogador)
      _gameState!.updateAIPaddle(_gameState!.aiPaddle.y + deltaY);
      _stats.recordPlayerAction(playerId, PlayerAction.paddleMove);
    }

    // Feedback para movimento
    _provideFeedbackForMovement(playerId, deltaY);
  }

  /// Processa entrada de teclado
  void handleKeyboardInput(KeyEvent event) {
    if (_gameState == null || !_gameState!.isPlaying) return;

    for (final controller in _playerControllers.values) {
      controller.processKeyboardInput(event, this);
    }
  }

  /// Processa entrada de toque
  void handleTouchInput(
      PlayerId playerId, Offset position, TouchAction action) {
    if (_gameState == null || !_gameState!.isPlaying) return;

    final controller = _playerControllers[playerId];
    if (controller == null) return;

    controller.processTouchInput(position, action, this);
    _stats.recordPlayerAction(playerId, PlayerAction.touch);
  }

  /// Registra hit de raquete
  void registerPaddleHit(PlayerId playerId, double impact) {
    _stats.recordPlayerAction(playerId, PlayerAction.paddleHit);
    _stats.recordImpact(playerId, impact);

    // Feedback específico para o jogador
    _provideFeedbackForHit(playerId, impact);
  }

  /// Registra pontuação
  void registerScore(PlayerId playerId) {
    _stats.recordPlayerAction(playerId, PlayerAction.score);
    _stats.recordScore(playerId);

    // Feedback para pontuação
    _provideFeedbackForScore(playerId);

    // Verifica fim de partida
    _checkMatchEnd();
  }

  /// Verifica se a partida terminou
  void _checkMatchEnd() {
    if (_gameState == null) return;

    const maxScore = GameConfig.maxScore;
    final player1Score = _getPlayerScore(PlayerId.player1);
    final player2Score = _getPlayerScore(PlayerId.player2);

    if (player1Score >= maxScore || player2Score >= maxScore) {
      final winner =
          player1Score > player2Score ? PlayerId.player1 : PlayerId.player2;
      _handleMatchEnd(winner);
    }
  }

  /// Lida com fim de partida
  void _handleMatchEnd(PlayerId winner) {
    _currentState = MultiplayerState.finished;
    _stats.recordMatchWinner(winner);

    // Feedback para fim de partida
    _provideFeedbackForMatchEnd(winner);

    notifyListeners();
  }

  /// Obtém pontuação de um jogador
  int _getPlayerScore(PlayerId playerId) {
    if (_gameState == null) return 0;

    final config = _playerConfigs[playerId];
    if (config == null) return 0;

    return config.paddleSide == PaddleSide.left
        ? _gameState!.playerScore
        : _gameState!.aiScore;
  }

  /// Fornece feedback para movimento
  void _provideFeedbackForMovement(PlayerId playerId, double deltaY) {
    // Feedback tátil leve apenas para movimentos grandes
    if (deltaY.abs() > 10.0) {
      _feedbackController?.onButtonPress('player_move_${playerId.name}');
    }
  }

  /// Fornece feedback para hit
  void _provideFeedbackForHit(PlayerId playerId, double impact) {
    final config = _playerConfigs[playerId];
    if (config == null) return;

    // Feedback diferenciado por jogador
    _feedbackController?.onButtonPress('player_hit_${playerId.name}');
  }

  /// Fornece feedback para pontuação
  void _provideFeedbackForScore(PlayerId playerId) {
    _feedbackController?.onButtonPress('player_score_${playerId.name}');
  }

  /// Fornece feedback para fim de partida
  void _provideFeedbackForMatchEnd(PlayerId winner) {
    _feedbackController?.onButtonPress('match_end_${winner.name}');
  }

  /// Configura um jogador
  void configurePlayer(PlayerId playerId, PlayerConfig config) {
    _playerConfigs[playerId] = config;

    // Atualiza controlador de entrada
    _playerControllers[playerId] = PlayerInputController(config);

    notifyListeners();
  }

  /// Alterna posições dos jogadores
  void swapPlayerPositions() {
    final player1Config = _playerConfigs[PlayerId.player1];
    final player2Config = _playerConfigs[PlayerId.player2];

    if (player1Config != null && player2Config != null) {
      // Troca lados das raquetes
      _playerConfigs[PlayerId.player1] = player1Config.copyWith(
        paddleSide: player2Config.paddleSide,
      );
      _playerConfigs[PlayerId.player2] = player2Config.copyWith(
        paddleSide: player1Config.paddleSide,
      );

      // Recria controladores
      _playerControllers[PlayerId.player1] =
          PlayerInputController(_playerConfigs[PlayerId.player1]!);
      _playerControllers[PlayerId.player2] =
          PlayerInputController(_playerConfigs[PlayerId.player2]!);

      notifyListeners();
    }
  }

  /// Obtém configurações do modo multijogador
  void setMultiplayerConfig(MultiplayerConfig config) {
    _config = config;
    notifyListeners();
  }

  /// Obtém estatísticas de um jogador específico
  PlayerStats? getPlayerStats(PlayerId playerId) {
    return _stats.getPlayerStats(playerId);
  }

  /// Obtém relatório completo da sessão
  Map<String, dynamic> getSessionReport() {
    return {
      'currentState': _currentState.toString(),
      'config': _config.toMap(),
      'players': _playerConfigs
          .map((key, value) => MapEntry(key.toString(), value.toMap())),
      'stats': _stats.toMap(),
      'matchDuration': _stats.currentMatchDuration?.inSeconds ?? 0,
    };
  }

  /// Salva configurações
  Map<String, dynamic> saveSettings() {
    return {
      'config': _config.toMap(),
      'playerConfigs': _playerConfigs
          .map((key, value) => MapEntry(key.toString(), value.toMap())),
    };
  }

  /// Carrega configurações
  void loadSettings(Map<String, dynamic> settings) {
    if (settings.containsKey('config')) {
      _config = MultiplayerConfig.fromMap(settings['config']);
    }

    if (settings.containsKey('playerConfigs')) {
      final configs = settings['playerConfigs'] as Map<String, dynamic>;
      for (final entry in configs.entries) {
        final playerId =
            PlayerId.values.firstWhere((p) => p.toString() == entry.key);
        _playerConfigs[playerId] = PlayerConfig.fromMap(entry.value);
        _playerControllers[playerId] =
            PlayerInputController(_playerConfigs[playerId]!);
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _playerControllers.clear();
    _playerConfigs.clear();
    super.dispose();
  }
}

/// Controlador de entrada para um jogador específico
class PlayerInputController {
  final PlayerConfig config;

  /// Última posição de toque
  Offset? _lastTouchPosition;

  /// Teclas atualmente pressionadas
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  PlayerInputController(this.config);

  /// Processa entrada de teclado
  void processKeyboardInput(KeyEvent event, MultiplayerController controller) {
    final key = event.logicalKey;

    if (event is KeyDownEvent) {
      _pressedKeys.add(key);
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(key);
    }

    // Processa movimento baseado no esquema de controle
    double movement = 0.0;

    switch (config.preferredControls) {
      case ControlScheme.arrows:
        if (_pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
          movement -= 8.0;
        }
        if (_pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
          movement += 8.0;
        }
        break;

      case ControlScheme.wasd:
        if (_pressedKeys.contains(LogicalKeyboardKey.keyW)) {
          movement -= 8.0;
        }
        if (_pressedKeys.contains(LogicalKeyboardKey.keyS)) {
          movement += 8.0;
        }
        break;

      case ControlScheme.ijkl:
        if (_pressedKeys.contains(LogicalKeyboardKey.keyI)) {
          movement -= 8.0;
        }
        if (_pressedKeys.contains(LogicalKeyboardKey.keyK)) {
          movement += 8.0;
        }
        break;

      case ControlScheme.numpad:
        if (_pressedKeys.contains(LogicalKeyboardKey.numpad8)) {
          movement -= 8.0;
        }
        if (_pressedKeys.contains(LogicalKeyboardKey.numpad2)) {
          movement += 8.0;
        }
        break;
    }

    if (movement != 0) {
      controller.handlePlayerMovement(config.id, movement);
    }
  }

  /// Processa entrada de toque
  void processTouchInput(
      Offset position, TouchAction action, MultiplayerController controller) {
    switch (action) {
      case TouchAction.start:
        _lastTouchPosition = position;
        break;

      case TouchAction.move:
        if (_lastTouchPosition != null) {
          final deltaY = position.dy - _lastTouchPosition!.dy;
          controller.handlePlayerMovement(config.id, deltaY);
          _lastTouchPosition = position;
        }
        break;

      case TouchAction.end:
        _lastTouchPosition = null;
        break;
    }
  }
}

/// Estatísticas do modo multijogador
class MultiplayerStats {
  final Map<PlayerId, PlayerStats> _playerStats = {};
  DateTime? _matchStartTime;
  DateTime? _currentPauseStart;
  Duration _totalPauseTime = Duration.zero;

  MultiplayerStats() {
    for (final playerId in PlayerId.values) {
      _playerStats[playerId] = PlayerStats();
    }
  }

  void reset() {
    for (final stats in _playerStats.values) {
      stats.reset();
    }
    _matchStartTime = null;
    _currentPauseStart = null;
    _totalPauseTime = Duration.zero;
  }

  void recordMatchStart() {
    _matchStartTime = DateTime.now();
  }

  void recordMatchEnd() {
    // Fim de partida registrado
  }

  void recordPauseStart() {
    _currentPauseStart = DateTime.now();
  }

  void recordPauseEnd() {
    if (_currentPauseStart != null) {
      _totalPauseTime += DateTime.now().difference(_currentPauseStart!);
      _currentPauseStart = null;
    }
  }

  void recordPlayerAction(PlayerId playerId, PlayerAction action) {
    _playerStats[playerId]?.recordAction(action);
  }

  void recordImpact(PlayerId playerId, double impact) {
    _playerStats[playerId]?.recordImpact(impact);
  }

  void recordScore(PlayerId playerId) {
    _playerStats[playerId]?.recordScore();
  }

  void recordMatchWinner(PlayerId winner) {
    _playerStats[winner]?.recordWin();
    for (final playerId in PlayerId.values) {
      if (playerId != winner) {
        _playerStats[playerId]?.recordLoss();
      }
    }
  }

  PlayerStats? getPlayerStats(PlayerId playerId) {
    return _playerStats[playerId];
  }

  Duration? get currentMatchDuration {
    if (_matchStartTime == null) return null;

    var duration = DateTime.now().difference(_matchStartTime!);
    duration -= _totalPauseTime;

    if (_currentPauseStart != null) {
      duration -= DateTime.now().difference(_currentPauseStart!);
    }

    return duration;
  }

  Map<String, dynamic> toMap() {
    return {
      'playerStats': _playerStats
          .map((key, value) => MapEntry(key.toString(), value.toMap())),
      'matchDuration': currentMatchDuration?.inSeconds ?? 0,
      'totalPauseTime': _totalPauseTime.inSeconds,
    };
  }
}

/// Estatísticas de um jogador
class PlayerStats {
  int _totalActions = 0;
  int _paddleHits = 0;
  int _scores = 0;
  int _wins = 0;
  int _losses = 0;
  double _totalImpact = 0.0;
  final List<double> _impactHistory = [];

  void reset() {
    _totalActions = 0;
    _paddleHits = 0;
    _scores = 0;
    _wins = 0;
    _losses = 0;
    _totalImpact = 0.0;
    _impactHistory.clear();
  }

  void recordAction(PlayerAction action) {
    _totalActions++;
    if (action == PlayerAction.paddleHit) {
      _paddleHits++;
    }
  }

  void recordImpact(double impact) {
    _totalImpact += impact;
    _impactHistory.add(impact);
    if (_impactHistory.length > 100) {
      _impactHistory.removeAt(0);
    }
  }

  void recordScore() {
    _scores++;
  }

  void recordWin() {
    _wins++;
  }

  void recordLoss() {
    _losses++;
  }

  double get averageImpact =>
      _paddleHits > 0 ? _totalImpact / _paddleHits : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'totalActions': _totalActions,
      'paddleHits': _paddleHits,
      'scores': _scores,
      'wins': _wins,
      'losses': _losses,
      'averageImpact': averageImpact,
    };
  }
}

/// Enums e classes de configuração
enum PlayerId { player1, player2 }

enum PaddleSide { left, right }

enum ControlScheme { arrows, wasd, ijkl, numpad }

enum TouchAction { start, move, end }

enum PlayerAction { paddleMove, paddleHit, score, touch }

enum MultiplayerState { setup, ready, playing, paused, finished }

/// Configuração de um jogador
class PlayerConfig {
  final PlayerId id;
  final String name;
  final Color color;
  final PaddleSide paddleSide;
  final ControlScheme preferredControls;

  PlayerConfig({
    required this.id,
    required this.name,
    required this.color,
    required this.paddleSide,
    required this.preferredControls,
  });

  PlayerConfig copyWith({
    PlayerId? id,
    String? name,
    Color? color,
    PaddleSide? paddleSide,
    ControlScheme? preferredControls,
  }) {
    return PlayerConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      paddleSide: paddleSide ?? this.paddleSide,
      preferredControls: preferredControls ?? this.preferredControls,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id.index,
      'name': name,
      'color': color.value,
      'paddleSide': paddleSide.index,
      'preferredControls': preferredControls.index,
    };
  }

  factory PlayerConfig.fromMap(Map<String, dynamic> map) {
    return PlayerConfig(
      id: PlayerId.values[map['id']],
      name: map['name'],
      color: Color(map['color']),
      paddleSide: PaddleSide.values[map['paddleSide']],
      preferredControls: ControlScheme.values[map['preferredControls']],
    );
  }
}

/// Configuração do modo multijogador
class MultiplayerConfig {
  final bool enableTouchControls;
  final bool enableKeyboardControls;
  final bool showPlayerColors;
  final bool separateScoreAreas;
  final double touchSensitivity;

  MultiplayerConfig({
    this.enableTouchControls = true,
    this.enableKeyboardControls = true,
    this.showPlayerColors = true,
    this.separateScoreAreas = true,
    this.touchSensitivity = 1.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'enableTouchControls': enableTouchControls,
      'enableKeyboardControls': enableKeyboardControls,
      'showPlayerColors': showPlayerColors,
      'separateScoreAreas': separateScoreAreas,
      'touchSensitivity': touchSensitivity,
    };
  }

  factory MultiplayerConfig.fromMap(Map<String, dynamic> map) {
    return MultiplayerConfig(
      enableTouchControls: map['enableTouchControls'] ?? true,
      enableKeyboardControls: map['enableKeyboardControls'] ?? true,
      showPlayerColors: map['showPlayerColors'] ?? true,
      separateScoreAreas: map['separateScoreAreas'] ?? true,
      touchSensitivity: map['touchSensitivity']?.toDouble() ?? 1.0,
    );
  }
}
