// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

/// Enum para estados do temporizador
enum TimerState {
  stopped,
  running,
  paused,
  expired,
}

/// Classe otimizada para gerenciamento de temporizadores do jogo
/// Implementa compensação de tempo e gerenciamento adequado de recursos
class TimerService extends ChangeNotifier {
  Timer? _timer;
  late DateTime _startTime;
  late DateTime _pauseTime;
  late int _initialDuration;
  int _remainingTime = 0;
  TimerState _state = TimerState.stopped;
  
  // Callbacks para eventos do timer
  VoidCallback? _onTick;
  VoidCallback? _onExpired;
  VoidCallback? _onHalfTime;
  VoidCallback? _onCriticalTime;
  
  // Configurações
  static const int _criticalThreshold = 10; // segundos para estado crítico
  bool _halfTimeTriggered = false;
  bool _criticalTimeTriggered = false;
  
  // Getters
  int get remainingTime => _remainingTime;
  TimerState get state => _state;
  bool get isRunning => _state == TimerState.running;
  bool get isPaused => _state == TimerState.paused;
  bool get isExpired => _state == TimerState.expired;
  bool get isCritical => _remainingTime <= _criticalThreshold && _remainingTime > 0;
  double get progress => _initialDuration > 0 ? (1.0 - _remainingTime / _initialDuration) : 0.0;
  
  /// Inicia o temporizador com a duração especificada em segundos
  void start({
    required int durationInSeconds,
    VoidCallback? onTick,
    VoidCallback? onExpired,
    VoidCallback? onHalfTime,
    VoidCallback? onCriticalTime,
  }) {
    // Cancela timer anterior se existir
    _timer?.cancel();
    
    // Configura callbacks
    _onTick = onTick;
    _onExpired = onExpired;
    _onHalfTime = onHalfTime;
    _onCriticalTime = onCriticalTime;
    
    // Inicializa variáveis
    _initialDuration = durationInSeconds;
    _remainingTime = durationInSeconds;
    _startTime = DateTime.now();
    _state = TimerState.running;
    _halfTimeTriggered = false;
    _criticalTimeTriggered = false;
    
    // Inicia o timer com compensação de tempo
    _startPeriodicTimer();
    
    notifyListeners();
  }
  
  /// Pausa o temporizador
  void pause() {
    if (_state != TimerState.running) return;
    
    _timer?.cancel();
    _pauseTime = DateTime.now();
    _state = TimerState.paused;
    
    notifyListeners();
  }
  
  /// Retoma o temporizador
  void resume() {
    if (_state != TimerState.paused) return;
    
    // Compensa o tempo perdido durante a pausa
    final pauseDuration = DateTime.now().difference(_pauseTime);
    _startTime = _startTime.add(pauseDuration);
    
    _state = TimerState.running;
    _startPeriodicTimer();
    
    notifyListeners();
  }
  
  /// Para o temporizador
  void stop() {
    _timer?.cancel();
    _state = TimerState.stopped;
    _remainingTime = 0;
    
    notifyListeners();
  }
  
  /// Adiciona tempo ao temporizador
  void addTime(int seconds) {
    if (_state == TimerState.running || _state == TimerState.paused) {
      _remainingTime += seconds;
      _initialDuration += seconds;
      notifyListeners();
    }
  }
  
  /// Remove tempo do temporizador
  void removeTime(int seconds) {
    if (_state == TimerState.running || _state == TimerState.paused) {
      _remainingTime = (_remainingTime - seconds).clamp(0, _initialDuration);
      if (_remainingTime == 0) {
        _expire();
      } else {
        notifyListeners();
      }
    }
  }
  
  /// Inicia o timer periódico com compensação
  void _startPeriodicTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateTime();
    });
  }
  
  /// Atualiza o tempo restante com compensação
  void _updateTime() {
    if (_state != TimerState.running) return;
    
    // Calcula o tempo decorrido desde o início
    final elapsed = DateTime.now().difference(_startTime).inSeconds;
    final newRemainingTime = (_initialDuration - elapsed).clamp(0, _initialDuration);
    
    // Só notifica listeners se houve mudança significativa (>= 1 segundo)
    if (newRemainingTime != _remainingTime) {
      _remainingTime = newRemainingTime;
      
      // Verifica eventos especiais
      _checkTimerEvents();
      
      // Executa callback de tick
      _onTick?.call();
      
      if (_remainingTime <= 0) {
        _expire();
      } else {
        notifyListeners();
      }
    }
  }
  
  /// Verifica e dispara eventos especiais do timer
  void _checkTimerEvents() {
    // Evento de metade do tempo
    if (!_halfTimeTriggered && _remainingTime <= _initialDuration / 2) {
      _halfTimeTriggered = true;
      _onHalfTime?.call();
    }
    
    // Evento de tempo crítico
    if (!_criticalTimeTriggered && _remainingTime <= _criticalThreshold) {
      _criticalTimeTriggered = true;
      _onCriticalTime?.call();
    }
  }
  
  /// Expira o temporizador
  void _expire() {
    _timer?.cancel();
    _remainingTime = 0;
    _state = TimerState.expired;
    
    _onExpired?.call();
    notifyListeners();
  }
  
  /// Retorna informações de debug do timer
  Map<String, dynamic> getDebugInfo() {
    return {
      'state': _state.toString(),
      'remainingTime': _remainingTime,
      'initialDuration': _initialDuration,
      'progress': progress,
      'isCritical': isCritical,
      'halfTimeTriggered': _halfTimeTriggered,
      'criticalTimeTriggered': _criticalTimeTriggered,
    };
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Widget helper para usar o TimerService com facilidade
class TimerServiceProvider extends ChangeNotifier {
  static TimerServiceProvider? _instance;
  
  static TimerServiceProvider get instance {
    _instance ??= TimerServiceProvider._();
    return _instance!;
  }
  
  TimerServiceProvider._();
  
  final Map<String, TimerService> _timers = {};
  
  /// Cria ou obtém um timer com ID específico
  TimerService getTimer(String id) {
    if (!_timers.containsKey(id)) {
      _timers[id] = TimerService();
    }
    return _timers[id]!;
  }
  
  /// Remove um timer específico
  void removeTimer(String id) {
    _timers[id]?.dispose();
    _timers.remove(id);
  }
  
  /// Remove todos os timers
  void removeAllTimers() {
    for (final timer in _timers.values) {
      timer.dispose();
    }
    _timers.clear();
  }
  
  @override
  void dispose() {
    removeAllTimers();
    super.dispose();
  }
}
