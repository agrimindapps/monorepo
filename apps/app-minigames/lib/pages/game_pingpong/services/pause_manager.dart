// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/models/game_state.dart';

/// Gerenciador avançado de pausa para o jogo Ping Pong
///
/// Controla estados de pausa, duração do jogo, e sincronização
/// entre diferentes sistemas durante pausas e retomadas.


/// Gerenciador de sistema de pausa
class PauseManager extends ChangeNotifier {
  /// Estado do jogo
  PingPongGameState? _gameState;

  /// Controle de tempo
  DateTime? _gameStartTime;
  DateTime? _lastPauseTime;
  Duration _totalPausedTime = Duration.zero;
  Duration _currentSessionTime = Duration.zero;

  /// Estado de pausa
  bool _isPaused = false;
  PauseReason _pauseReason = PauseReason.manual;

  /// Stack de pausas para pausas aninhadas
  final List<PauseContext> _pauseStack = [];

  /// Timer para atualização de duração
  Timer? _durationTimer;

  /// Callbacks para eventos de pausa
  final List<VoidCallback> _onPauseCallbacks = [];
  final List<VoidCallback> _onResumeCallbacks = [];

  /// Getters
  bool get isPaused => _isPaused;
  PauseReason get pauseReason => _pauseReason;
  Duration get totalGameTime => _currentSessionTime;
  Duration get totalPausedTime => _totalPausedTime;
  Duration get activePlayTime => _currentSessionTime - _totalPausedTime;
  bool get hasActivePauses => _pauseStack.isNotEmpty;

  /// Inicializa o gerenciador
  void initialize(PingPongGameState gameState) {
    _gameState = gameState;
    _gameState?.addListener(_onGameStateChanged);

    debugPrint('PauseManager inicializado');
  }

  /// Inicia tracking de uma nova sessão de jogo
  void startGameSession() {
    _gameStartTime = DateTime.now();
    _lastPauseTime = null;
    _totalPausedTime = Duration.zero;
    _currentSessionTime = Duration.zero;
    _isPaused = false;
    _pauseStack.clear();

    _startDurationTimer();

    debugPrint('Nova sessão de jogo iniciada');
    notifyListeners();
  }

  /// Para a sessão atual
  void stopGameSession() {
    _stopDurationTimer();

    if (_isPaused) {
      _forcedResume();
    }

    _gameStartTime = null;
    _lastPauseTime = null;
    _pauseStack.clear();

    debugPrint('Sessão de jogo finalizada');
    notifyListeners();
  }

  /// Pausa o jogo com razão específica
  void pauseGame(PauseReason reason, {String? contextInfo}) {
    if (_gameState == null || _gameState!.currentState != GameState.playing) {
      debugPrint('Tentativa de pausar jogo em estado inválido');
      return;
    }

    final pauseContext = PauseContext(
      reason: reason,
      timestamp: DateTime.now(),
      contextInfo: contextInfo,
    );

    _pauseStack.add(pauseContext);

    if (!_isPaused) {
      _executePause(reason);
    }

    debugPrint('Jogo pausado: ${reason.name} - ${contextInfo ?? ""}');
  }

  /// Retoma o jogo removendo uma pausa específica
  void resumeGame(PauseReason reason) {
    if (!_isPaused) {
      debugPrint('Tentativa de retomar jogo que não está pausado');
      return;
    }

    // Remove a pausa da stack
    _pauseStack.removeWhere((context) => context.reason == reason);

    // Se não há mais pausas, retoma o jogo
    if (_pauseStack.isEmpty) {
      _executeResume();
    } else {
      // Atualiza a razão da pausa para a mais recente na stack
      _pauseReason = _pauseStack.last.reason;
      notifyListeners();
    }

    debugPrint(
        'Pausa removida: ${reason.name}. Pausas restantes: ${_pauseStack.length}');
  }

  /// Toggle de pausa manual
  void togglePause() {
    if (_isPaused && _pauseReason == PauseReason.manual) {
      resumeGame(PauseReason.manual);
    } else if (!_isPaused) {
      pauseGame(PauseReason.manual);
    }
  }

  /// Pausa forçada (remove todas as pausas e pausa)
  void forcedPause(PauseReason reason, {String? contextInfo}) {
    _pauseStack.clear();
    pauseGame(reason, contextInfo: contextInfo);
  }

  /// Retomada forçada (remove todas as pausas)
  void forcedResume() {
    if (!_isPaused) return;

    _pauseStack.clear();
    _executeResume();

    debugPrint('Retomada forçada executada');
  }

  /// Executa a pausa efetivamente
  void _executePause(PauseReason reason) {
    _isPaused = true;
    _pauseReason = reason;
    _lastPauseTime = DateTime.now();

    // Para o timer do jogo
    if (_gameState != null) {
      _gameState!.setGameState(GameState.paused);
    }

    // Notifica callbacks
    for (final callback in _onPauseCallbacks) {
      callback();
    }

    notifyListeners();
  }

  /// Executa a retomada efetivamente
  void _executeResume() {
    if (!_isPaused || _lastPauseTime == null) return;

    // Calcula tempo pausado
    final pauseDuration = DateTime.now().difference(_lastPauseTime!);
    _totalPausedTime += pauseDuration;

    _isPaused = false;
    _lastPauseTime = null;

    // Retoma o timer do jogo
    if (_gameState != null) {
      _gameState!.setGameState(GameState.playing);
    }

    // Notifica callbacks
    for (final callback in _onResumeCallbacks) {
      callback();
    }

    notifyListeners();
  }

  /// Retomada forçada sem verificações
  void _forcedResume() {
    _isPaused = false;
    _lastPauseTime = null;
    _pauseStack.clear();
    notifyListeners();
  }

  /// Inicia timer de duração
  void _startDurationTimer() {
    _stopDurationTimer();

    _durationTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) => _updateDuration(),
    );
  }

  /// Para timer de duração
  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  /// Atualiza duração do jogo
  void _updateDuration() {
    if (_gameStartTime == null) return;

    _currentSessionTime = DateTime.now().difference(_gameStartTime!);

    // Se estiver pausado, o tempo atual de pausa não é adicionado ao total
    // até que o jogo seja retomado

    notifyListeners();
  }

  /// Responde a mudanças no estado do jogo
  void _onGameStateChanged() {
    if (_gameState == null) return;

    final gameState = _gameState!.currentState;

    // Auto-pausa em certas situações
    if (gameState == GameState.gameOver && _isPaused) {
      forcedResume();
    }
  }

  /// Adiciona callback para evento de pausa
  void addPauseCallback(VoidCallback callback) {
    _onPauseCallbacks.add(callback);
  }

  /// Remove callback de pausa
  void removePauseCallback(VoidCallback callback) {
    _onPauseCallbacks.remove(callback);
  }

  /// Adiciona callback para evento de retomada
  void addResumeCallback(VoidCallback callback) {
    _onResumeCallbacks.add(callback);
  }

  /// Remove callback de retomada
  void removeResumeCallback(VoidCallback callback) {
    _onResumeCallbacks.remove(callback);
  }

  /// Pausa automática quando app perde foco
  void onAppLifecycleChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        if (!_isPaused && _gameState?.isPlaying == true) {
          pauseGame(PauseReason.appInactive, contextInfo: 'App perdeu foco');
        }
        break;
      case AppLifecycleState.resumed:
        // Não retoma automaticamente, deixa o usuário decidir
        break;
      case AppLifecycleState.detached:
        forcedPause(PauseReason.appInactive, contextInfo: 'App foi fechado');
        break;
      case AppLifecycleState.hidden:
        // Não faz nada
        break;
    }
  }

  /// Obtém informações detalhadas sobre pausas
  Map<String, dynamic> getPauseInfo() {
    return {
      'isPaused': _isPaused,
      'pauseReason': _pauseReason.name,
      'activePauses': _pauseStack.length,
      'totalGameTime': _currentSessionTime.inSeconds,
      'totalPausedTime': _totalPausedTime.inSeconds,
      'activePlayTime': activePlayTime.inSeconds,
      'pauseStack': _pauseStack
          .map((p) => {
                'reason': p.reason.name,
                'timestamp': p.timestamp.toIso8601String(),
                'contextInfo': p.contextInfo,
              })
          .toList(),
    };
  }

  /// Obtém estatísticas de pausa
  PauseStatistics getStatistics() {
    return PauseStatistics(
      totalGameTime: _currentSessionTime,
      totalPausedTime: _totalPausedTime,
      activePlayTime: activePlayTime,
      pauseCount: _pauseStack.length,
      currentPauseReason: _isPaused ? _pauseReason : null,
    );
  }

  @override
  void dispose() {
    _stopDurationTimer();
    _gameState?.removeListener(_onGameStateChanged);
    _onPauseCallbacks.clear();
    _onResumeCallbacks.clear();
    _pauseStack.clear();
    super.dispose();
  }
}

/// Contexto de uma pausa
class PauseContext {
  final PauseReason reason;
  final DateTime timestamp;
  final String? contextInfo;

  PauseContext({
    required this.reason,
    required this.timestamp,
    this.contextInfo,
  });
}

/// Razões para pausa
enum PauseReason {
  manual, // Pausa manual do usuário
  appInactive, // App perdeu foco
  incomingCall, // Chamada telefônica
  lowBattery, // Bateria baixa
  notification, // Notificação importante
  error, // Erro no jogo
  networkIssue, // Problema de rede (para modos online)
  systemOverlay, // Overlay do sistema
}

/// Estatísticas de pausa
class PauseStatistics {
  final Duration totalGameTime;
  final Duration totalPausedTime;
  final Duration activePlayTime;
  final int pauseCount;
  final PauseReason? currentPauseReason;

  PauseStatistics({
    required this.totalGameTime,
    required this.totalPausedTime,
    required this.activePlayTime,
    required this.pauseCount,
    this.currentPauseReason,
  });

  /// Porcentagem do tempo que foi gasto pausado
  double get pausePercentage {
    if (totalGameTime.inMilliseconds == 0) return 0.0;
    return (totalPausedTime.inMilliseconds / totalGameTime.inMilliseconds) *
        100;
  }

  /// Porcentagem do tempo jogando ativamente
  double get activePercentage => 100.0 - pausePercentage;

  Map<String, dynamic> toMap() {
    return {
      'totalGameTime': totalGameTime.inSeconds,
      'totalPausedTime': totalPausedTime.inSeconds,
      'activePlayTime': activePlayTime.inSeconds,
      'pauseCount': pauseCount,
      'pausePercentage': pausePercentage,
      'activePercentage': activePercentage,
      'currentPauseReason': currentPauseReason?.name,
    };
  }
}

/// Extensão para nomes das razões de pausa
extension PauseReasonExtension on PauseReason {
  String get name {
    switch (this) {
      case PauseReason.manual:
        return 'Manual';
      case PauseReason.appInactive:
        return 'App Inativo';
      case PauseReason.incomingCall:
        return 'Chamada';
      case PauseReason.lowBattery:
        return 'Bateria Baixa';
      case PauseReason.notification:
        return 'Notificação';
      case PauseReason.error:
        return 'Erro';
      case PauseReason.networkIssue:
        return 'Problema de Rede';
      case PauseReason.systemOverlay:
        return 'Overlay do Sistema';
    }
  }

  String get description {
    switch (this) {
      case PauseReason.manual:
        return 'Jogo pausado pelo jogador';
      case PauseReason.appInactive:
        return 'Aplicativo perdeu o foco';
      case PauseReason.incomingCall:
        return 'Chamada telefônica recebida';
      case PauseReason.lowBattery:
        return 'Nível de bateria baixo';
      case PauseReason.notification:
        return 'Notificação importante recebida';
      case PauseReason.error:
        return 'Erro no jogo detectado';
      case PauseReason.networkIssue:
        return 'Problema de conectividade';
      case PauseReason.systemOverlay:
        return 'Overlay do sistema ativo';
    }
  }

  IconData get icon {
    switch (this) {
      case PauseReason.manual:
        return Icons.pause;
      case PauseReason.appInactive:
        return Icons.phone_android;
      case PauseReason.incomingCall:
        return Icons.phone;
      case PauseReason.lowBattery:
        return Icons.battery_alert;
      case PauseReason.notification:
        return Icons.notifications;
      case PauseReason.error:
        return Icons.error;
      case PauseReason.networkIssue:
        return Icons.wifi_off;
      case PauseReason.systemOverlay:
        return Icons.layers;
    }
  }
}
