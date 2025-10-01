import 'dart:async';

/// Rate limiter para operações de sincronização
/// Previne sync excessivo e implementa backoff exponencial
class SyncThrottler {
  /// Mapa de último sync por service ID
  final Map<String, DateTime> _lastSync = {};

  /// Mapa de contagem de failures para backoff exponencial
  final Map<String, int> _failureCount = {};

  /// Mapa de timers de debounce ativos
  final Map<String, Timer> _debounceTimers = {};

  /// Intervalo mínimo entre syncs
  final Duration minInterval;

  /// Intervalo máximo de backoff (padrão: 1 hora)
  final Duration maxBackoffInterval;

  /// Fator de multiplicação para backoff exponencial (padrão: 2x)
  final double backoffMultiplier;

  /// Duração do debounce (padrão: 2 segundos)
  final Duration debounceDuration;

  SyncThrottler({
    this.minInterval = const Duration(minutes: 5),
    this.maxBackoffInterval = const Duration(hours: 1),
    this.backoffMultiplier = 2.0,
    this.debounceDuration = const Duration(seconds: 2),
  });

  /// Verifica se pode sincronizar agora
  /// Considera min interval e backoff por failures
  bool canSync(String serviceId) {
    final lastSync = _lastSync[serviceId];
    if (lastSync == null) return true;

    final effectiveInterval = _calculateEffectiveInterval(serviceId);
    final timeSinceLastSync = DateTime.now().difference(lastSync);

    return timeSinceLastSync >= effectiveInterval;
  }

  /// Calcula intervalo efetivo considerando backoff por failures
  Duration _calculateEffectiveInterval(String serviceId) {
    final failures = _failureCount[serviceId] ?? 0;
    if (failures == 0) return minInterval;

    // Backoff exponencial: minInterval * (multiplier ^ failures)
    final backoffFactor = backoffMultiplier * failures;
    final backoffInterval = Duration(
      milliseconds: (minInterval.inMilliseconds * backoffFactor).round(),
    );

    // Limitar ao máximo configurado
    return backoffInterval > maxBackoffInterval
        ? maxBackoffInterval
        : backoffInterval;
  }

  /// Registra sync bem-sucedido
  /// Reset failure count e atualiza timestamp
  void recordSuccess(String serviceId) {
    _lastSync[serviceId] = DateTime.now();
    _failureCount[serviceId] = 0; // Reset failures on success
  }

  /// Registra sync com falha
  /// Incrementa failure count para backoff
  void recordFailure(String serviceId) {
    _lastSync[serviceId] = DateTime.now();
    _failureCount[serviceId] = (_failureCount[serviceId] ?? 0) + 1;
  }

  /// Tempo restante até próximo sync permitido
  Duration? timeUntilNextSync(String serviceId) {
    if (canSync(serviceId)) return Duration.zero;

    final lastSync = _lastSync[serviceId];
    if (lastSync == null) return Duration.zero;

    final effectiveInterval = _calculateEffectiveInterval(serviceId);
    final timeSinceLastSync = DateTime.now().difference(lastSync);

    return effectiveInterval - timeSinceLastSync;
  }

  /// Debounce para múltiplas requisições de sync
  /// Agrupa sync requests em burst evitando sync excessivo
  Future<void> debounce(
    String serviceId,
    Future<void> Function() syncOperation,
  ) async {
    // Cancelar timer anterior se existir
    _debounceTimers[serviceId]?.cancel();

    // Criar novo completer para aguardar debounce
    final completer = Completer<void>();

    // Configurar novo timer
    _debounceTimers[serviceId] = Timer(debounceDuration, () async {
      _debounceTimers.remove(serviceId);

      try {
        await syncOperation();
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  /// Obtém estatísticas de throttling
  SyncThrottlingStats getStats(String serviceId) {
    return SyncThrottlingStats(
      serviceId: serviceId,
      lastSync: _lastSync[serviceId],
      failureCount: _failureCount[serviceId] ?? 0,
      effectiveInterval: _calculateEffectiveInterval(serviceId),
      canSyncNow: canSync(serviceId),
      timeUntilNextSync: timeUntilNextSync(serviceId),
    );
  }

  /// Limpa dados de throttling para um service
  void clear(String serviceId) {
    _lastSync.remove(serviceId);
    _failureCount.remove(serviceId);
    _debounceTimers[serviceId]?.cancel();
    _debounceTimers.remove(serviceId);
  }

  /// Limpa todos os dados de throttling
  void clearAll() {
    _lastSync.clear();
    _failureCount.clear();

    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }

  /// Dispose resources
  void dispose() {
    clearAll();
  }
}

/// Estatísticas de throttling para um service
class SyncThrottlingStats {
  final String serviceId;
  final DateTime? lastSync;
  final int failureCount;
  final Duration effectiveInterval;
  final bool canSyncNow;
  final Duration? timeUntilNextSync;

  SyncThrottlingStats({
    required this.serviceId,
    required this.lastSync,
    required this.failureCount,
    required this.effectiveInterval,
    required this.canSyncNow,
    required this.timeUntilNextSync,
  });

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'last_sync': lastSync?.toIso8601String(),
      'failure_count': failureCount,
      'effective_interval_seconds': effectiveInterval.inSeconds,
      'can_sync_now': canSyncNow,
      'time_until_next_sync_seconds': timeUntilNextSync?.inSeconds,
    };
  }

  @override
  String toString() {
    return 'SyncThrottlingStats(serviceId: $serviceId, '
        'lastSync: $lastSync, '
        'failureCount: $failureCount, '
        'effectiveInterval: ${effectiveInterval.inMinutes}min, '
        'canSyncNow: $canSyncNow, '
        'timeUntilNextSync: ${timeUntilNextSync?.inMinutes}min)';
  }
}
