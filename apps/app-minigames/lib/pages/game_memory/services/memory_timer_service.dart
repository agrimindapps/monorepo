/// Serviço otimizado de gerenciamento de timers para o jogo da memória
/// 
/// Implementa controle seguro de timers com prevenção de vazamentos de memória,
/// observabilidade e mecanismos de retry/fallback.
library;

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

/// Tipos de timer utilizados no jogo
enum MemoryTimerType {
  gameTimer,     // Timer principal do jogo
  matchTimer,    // Timer para verificação de match
  pauseTimer,    // Timer durante pausa
  animationTimer, // Timer para animações
}

/// Informações de um timer ativo
class TimerInfo {
  final MemoryTimerType type;
  final DateTime startTime;
  final Duration interval;
  final String? description;
  
  TimerInfo({
    required this.type,
    required this.startTime,
    required this.interval,
    this.description,
  });
  
  Duration get elapsedTime => DateTime.now().difference(startTime);
  
  @override
  String toString() {
    return 'TimerInfo(type: $type, elapsed: ${elapsedTime.inSeconds}s, interval: ${interval.inMilliseconds}ms)';
  }
}

/// Serviço de gerenciamento de timers
class MemoryTimerService {
  /// Mapa de timers ativos
  final Map<MemoryTimerType, Timer> _activeTimers = {};
  
  /// Mapa de informações dos timers
  final Map<MemoryTimerType, TimerInfo> _timerInfos = {};
  
  /// Controle de estado
  bool _isDisposed = false;
  bool _isPaused = false;
  
  /// Callbacks para auditoria e debug
  final List<Function(MemoryTimerType, String)> _auditCallbacks = [];
  
  /// Timer de auditoria para detectar vazamentos
  Timer? _auditTimer;
  
  /// Construtor
  MemoryTimerService() {
    _startAuditTimer();
  }
  
  /// Inicia timer de auditoria
  void _startAuditTimer() {
    _auditTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) => _performAudit(),
    );
  }
  
  /// Adiciona callback de auditoria
  void addAuditCallback(Function(MemoryTimerType, String) callback) {
    _auditCallbacks.add(callback);
  }
  
  /// Remove callback de auditoria
  void removeAuditCallback(Function(MemoryTimerType, String) callback) {
    _auditCallbacks.remove(callback);
  }
  
  /// Notifica callbacks de auditoria
  void _notifyAudit(MemoryTimerType type, String message) {
    for (final callback in _auditCallbacks) {
      try {
        callback(type, message);
      } catch (e) {
        debugPrint('Erro em callback de auditoria: $e');
      }
    }
  }
  
  /// Inicia timer do jogo
  void startGameTimer({
    required VoidCallback onTick,
    Duration interval = const Duration(seconds: 1),
  }) {
    if (_isDisposed) {
      debugPrint('MemoryTimerService foi disposed - não é possível criar timer');
      return;
    }
    
    _cancelTimer(MemoryTimerType.gameTimer);
    
    try {
      final timer = Timer.periodic(interval, (timer) {
        if (_isDisposed || _isPaused) return;
        
        try {
          onTick();
        } catch (e) {
          debugPrint('Erro no callback do game timer: $e');
          _cancelTimer(MemoryTimerType.gameTimer);
        }
      });
      
      _activeTimers[MemoryTimerType.gameTimer] = timer;
      _timerInfos[MemoryTimerType.gameTimer] = TimerInfo(
        type: MemoryTimerType.gameTimer,
        startTime: DateTime.now(),
        interval: interval,
        description: 'Timer principal do jogo',
      );
      
      _notifyAudit(MemoryTimerType.gameTimer, 'Timer iniciado');
      debugPrint('Game timer iniciado');
    } catch (e) {
      debugPrint('Erro ao iniciar game timer: $e');
    }
  }
  
  /// Para timer do jogo
  void stopGameTimer() {
    _cancelTimer(MemoryTimerType.gameTimer);
    _notifyAudit(MemoryTimerType.gameTimer, 'Timer parado');
    debugPrint('Game timer parado');
  }
  
  /// Pausa timer do jogo
  void pauseGameTimer() {
    _isPaused = true;
    _notifyAudit(MemoryTimerType.gameTimer, 'Timer pausado');
    debugPrint('Game timer pausado');
  }
  
  /// Retoma timer do jogo
  void resumeGameTimer() {
    _isPaused = false;
    _notifyAudit(MemoryTimerType.gameTimer, 'Timer retomado');
    debugPrint('Game timer retomado');
  }
  
  /// Cria timer para verificação de match
  void createMatchTimer({
    required VoidCallback onComplete,
    required Duration delay,
    int maxRetries = 3,
  }) {
    if (_isDisposed) return;
    
    _cancelTimer(MemoryTimerType.matchTimer);
    
    _createTimerWithRetry(
      type: MemoryTimerType.matchTimer,
      delay: delay,
      callback: onComplete,
      maxRetries: maxRetries,
      description: 'Timer de verificação de match',
    );
  }
  
  /// Cria timer com mecanismo de retry
  void _createTimerWithRetry({
    required MemoryTimerType type,
    required Duration delay,
    required VoidCallback callback,
    required int maxRetries,
    String? description,
    int currentAttempt = 1,
  }) {
    try {
      final timer = Timer(delay, () {
        if (_isDisposed) return;
        
        try {
          callback();
          _notifyAudit(type, 'Timer executado com sucesso');
        } catch (e) {
          debugPrint('Erro na execução do timer $type: $e');
          
          // Retry se ainda há tentativas
          if (currentAttempt < maxRetries) {
            debugPrint('Tentando novamente timer $type (tentativa ${currentAttempt + 1}/$maxRetries)');
            _createTimerWithRetry(
              type: type,
              delay: delay,
              callback: callback,
              maxRetries: maxRetries,
              description: description,
              currentAttempt: currentAttempt + 1,
            );
          } else {
            _notifyAudit(type, 'Timer falhou após $maxRetries tentativas');
          }
        } finally {
          _activeTimers.remove(type);
          _timerInfos.remove(type);
        }
      });
      
      _activeTimers[type] = timer;
      _timerInfos[type] = TimerInfo(
        type: type,
        startTime: DateTime.now(),
        interval: delay,
        description: description,
      );
      
      _notifyAudit(type, 'Timer criado (tentativa $currentAttempt)');
    } catch (e) {
      debugPrint('Erro ao criar timer $type: $e');
      _notifyAudit(type, 'Erro ao criar timer: $e');
    }
  }
  
  /// Cria timer para animações
  void createAnimationTimer({
    required VoidCallback onTick,
    required Duration interval,
    Duration? timeout,
  }) {
    if (_isDisposed) return;
    
    _cancelTimer(MemoryTimerType.animationTimer);
    
    DateTime startTime = DateTime.now();
    
    final timer = Timer.periodic(interval, (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      
      // Verifica timeout
      if (timeout != null && DateTime.now().difference(startTime) > timeout) {
        _cancelTimer(MemoryTimerType.animationTimer);
        _notifyAudit(MemoryTimerType.animationTimer, 'Timer de animação expirou por timeout');
        return;
      }
      
      try {
        onTick();
      } catch (e) {
        debugPrint('Erro no timer de animação: $e');
        _cancelTimer(MemoryTimerType.animationTimer);
      }
    });
    
    _activeTimers[MemoryTimerType.animationTimer] = timer;
    _timerInfos[MemoryTimerType.animationTimer] = TimerInfo(
      type: MemoryTimerType.animationTimer,
      startTime: startTime,
      interval: interval,
      description: 'Timer de animação',
    );
    
    _notifyAudit(MemoryTimerType.animationTimer, 'Timer de animação criado');
  }
  
  /// Cancela timer específico
  void _cancelTimer(MemoryTimerType type) {
    final timer = _activeTimers[type];
    if (timer != null) {
      timer.cancel();
      _activeTimers.remove(type);
      _timerInfos.remove(type);
      debugPrint('Timer $type cancelado');
    }
  }
  
  /// Cancela timer específico (método público)
  void cancelTimer(MemoryTimerType type) {
    _cancelTimer(type);
    _notifyAudit(type, 'Timer cancelado manualmente');
  }
  
  /// Cancela timers relacionados ao jogo
  void cancelGameRelatedTimers() {
    final gameTimers = [
      MemoryTimerType.gameTimer,
      MemoryTimerType.matchTimer,
    ];
    
    for (final type in gameTimers) {
      _cancelTimer(type);
    }
    
    debugPrint('Timers relacionados ao jogo cancelados');
  }
  
  /// Cancela todos os timers
  void cancelAllTimers() {
    final types = List<MemoryTimerType>.from(_activeTimers.keys);
    
    for (final type in types) {
      _cancelTimer(type);
    }
    
    debugPrint('Todos os timers cancelados');
    _notifyAudit(MemoryTimerType.gameTimer, 'Todos os timers cancelados');
  }
  
  /// Verifica se um timer está ativo
  bool isTimerActive(MemoryTimerType type) {
    return _activeTimers.containsKey(type) && _activeTimers[type]!.isActive;
  }
  
  /// Obtém contagem de timers ativos
  int get activeTimerCount => _activeTimers.length;
  
  /// Obtém lista de timers ativos
  List<MemoryTimerType> get activeTimerTypes => _activeTimers.keys.toList();
  
  /// Obtém informações de um timer
  TimerInfo? getTimerInfo(MemoryTimerType type) => _timerInfos[type];
  
  /// Obtém todas as informações de timers
  Map<MemoryTimerType, TimerInfo> get allTimerInfos => Map.unmodifiable(_timerInfos);
  
  /// Realiza auditoria dos timers
  void _performAudit() {
    if (_isDisposed) return;
    
    final now = DateTime.now();
    final staleTimers = <MemoryTimerType>[];
    
    for (final entry in _timerInfos.entries) {
      final type = entry.key;
      final info = entry.value;
      
      // Verifica timers que estão rodando há muito tempo
      if (info.elapsedTime.inMinutes > 30) {
        debugPrint('Timer $type está ativo há ${info.elapsedTime.inMinutes} minutos');
        _notifyAudit(type, 'Timer de longa duração detectado');
      }
      
      // Verifica timers órfãos (sem timer ativo correspondente)
      if (!_activeTimers.containsKey(type)) {
        staleTimers.add(type);
      }
    }
    
    // Remove informações de timers órfãos
    for (final type in staleTimers) {
      _timerInfos.remove(type);
      _notifyAudit(type, 'Informação de timer órfão removida');
    }
    
    debugPrint('Auditoria concluída. Timers ativos: $activeTimerCount');
  }
  
  /// Força auditoria imediata
  void forceAudit() {
    _performAudit();
  }
  
  /// Obtém estatísticas de uso
  Map<String, dynamic> getUsageStatistics() {
    return {
      'activeTimers': activeTimerCount,
      'timerTypes': activeTimerTypes.map((t) => t.name).toList(),
      'isDisposed': _isDisposed,
      'isPaused': _isPaused,
      'longestRunningTimer': _getLongestRunningTimer(),
    };
  }
  
  /// Obtém o timer que está rodando há mais tempo
  String? _getLongestRunningTimer() {
    if (_timerInfos.isEmpty) return null;
    
    final sorted = _timerInfos.entries.toList()
      ..sort((a, b) => a.value.startTime.compareTo(b.value.startTime));
    
    final oldest = sorted.first;
    return '${oldest.key.name} (${oldest.value.elapsedTime.inSeconds}s)';
  }
  
  /// Dispose do serviço
  void dispose() {
    if (_isDisposed) return;
    
    debugPrint('Fazendo dispose do MemoryTimerService');
    
    // Cancela timer de auditoria
    _auditTimer?.cancel();
    _auditTimer = null;
    
    // Cancela todos os timers ativos
    cancelAllTimers();
    
    // Limpa callbacks
    _auditCallbacks.clear();
    
    _isDisposed = true;
    debugPrint('MemoryTimerService disposed');
  }
}
