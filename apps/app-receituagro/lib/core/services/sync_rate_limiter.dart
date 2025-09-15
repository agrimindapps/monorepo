import 'dart:async';
import 'package:core/core.dart';

/// Serviço de Rate Limiting para sincronização manual
/// Implementa controle de 1 sincronização por minuto para evitar sobrecarga
class SyncRateLimiter {
  static const Duration _rateLimitDuration = Duration(minutes: 1);
  static const String _lastSyncKey = 'last_manual_sync_timestamp';
  
  final HiveStorageService _storage;
  DateTime? _lastSyncTime;
  Timer? _cooldownTimer;
  
  // Stream controller para notificar mudanças no estado
  final _stateController = StreamController<SyncRateLimitState>.broadcast();
  
  SyncRateLimiter(this._storage);
  
  /// Stream do estado atual do rate limiter
  Stream<SyncRateLimitState> get stateStream => _stateController.stream;
  
  /// Inicializa o rate limiter carregando o último timestamp
  Future<void> initialize() async {
    try {
      final timestampResult = await _storage.get<int>(
        key: _lastSyncKey,
        box: 'sync_settings',
      );
      
      timestampResult.fold(
        (failure) => _lastSyncTime = null,
        (timestamp) {
          if (timestamp != null) {
            _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            _startCooldownTimerIfNeeded();
          }
        },
      );
    } catch (e) {
      _lastSyncTime = null;
    }
  }
  
  /// Verifica se é possível executar uma sincronização manual
  bool canSync() {
    if (_lastSyncTime == null) return true;
    
    final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
    return timeSinceLastSync >= _rateLimitDuration;
  }
  
  /// Retorna o tempo restante para a próxima sincronização permitida
  Duration? getRemainingCooldown() {
    if (_lastSyncTime == null) return null;
    
    final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
    if (timeSinceLastSync >= _rateLimitDuration) return null;
    
    return _rateLimitDuration - timeSinceLastSync;
  }
  
  /// Registra uma sincronização manual executada
  Future<void> recordSyncAttempt() async {
    final now = DateTime.now();
    _lastSyncTime = now;
    
    // Persiste o timestamp
    await _storage.save(
      key: _lastSyncKey,
      data: now.millisecondsSinceEpoch,
      box: 'sync_settings',
    );
    
    // Inicia timer de cooldown
    _startCooldownTimer();
    
    // Emite novo estado
    _emitCurrentState();
  }
  
  /// Inicia timer de cooldown se necessário
  void _startCooldownTimerIfNeeded() {
    final remainingCooldown = getRemainingCooldown();
    if (remainingCooldown != null) {
      _startCooldownTimer();
    }
  }
  
  /// Inicia timer de cooldown
  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    
    final remainingCooldown = getRemainingCooldown();
    if (remainingCooldown == null) {
      _emitCurrentState();
      return;
    }
    
    _cooldownTimer = Timer(remainingCooldown, () {
      _emitCurrentState();
    });
    
    _emitCurrentState();
  }
  
  /// Emite o estado atual do rate limiter
  void _emitCurrentState() {
    final canSyncNow = canSync();
    final remainingCooldown = getRemainingCooldown();
    
    _stateController.add(SyncRateLimitState(
      canSync: canSyncNow,
      lastSyncTime: _lastSyncTime,
      remainingCooldown: remainingCooldown,
    ));
  }
  
  /// Obtém o estado atual do rate limiter
  SyncRateLimitState getCurrentState() {
    return SyncRateLimitState(
      canSync: canSync(),
      lastSyncTime: _lastSyncTime,
      remainingCooldown: getRemainingCooldown(),
    );
  }
  
  /// Limpa os dados de rate limiting
  Future<void> clear() async {
    _lastSyncTime = null;
    _cooldownTimer?.cancel();
    
    await _storage.remove(
      key: _lastSyncKey,
      box: 'sync_settings',
    );
    
    _emitCurrentState();
  }
  
  /// Dispose dos recursos
  void dispose() {
    _cooldownTimer?.cancel();
    _stateController.close();
  }
}

/// Estado atual do rate limiter
class SyncRateLimitState {
  final bool canSync;
  final DateTime? lastSyncTime;
  final Duration? remainingCooldown;
  
  const SyncRateLimitState({
    required this.canSync,
    this.lastSyncTime,
    this.remainingCooldown,
  });
  
  /// Texto amigável do countdown restante
  String? get cooldownText {
    if (remainingCooldown == null) return null;
    
    final seconds = remainingCooldown!.inSeconds;
    if (seconds <= 0) return null;
    
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }
  
  /// Texto do status da última sincronização
  String? get lastSyncText {
    if (lastSyncTime == null) return 'Nunca sincronizado';
    
    final now = DateTime.now();
    final difference = now.difference(lastSyncTime!);
    
    if (difference.inMinutes < 1) {
      return 'Agora há pouco';
    } else if (difference.inHours < 1) {
      return 'Há ${difference.inMinutes} minutos';
    } else if (difference.inDays < 1) {
      return 'Há ${difference.inHours} horas';
    } else {
      return 'Há ${difference.inDays} dias';
    }
  }
}