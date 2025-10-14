import 'dart:async';

import 'package:flutter/foundation.dart';

/// Serviço de throttling para sincronização
///
/// Responsabilidades:
/// - Auto-sync periódico com intervalo configurável
/// - Timer management
/// - Rate limiting
/// - Debouncing de sync operations
class SyncThrottleService {
  Timer? _syncTimer;
  Duration _syncInterval;
  DateTime? _lastSyncTime;

  SyncThrottleService({
    Duration syncInterval = const Duration(minutes: 5),
  }) : _syncInterval = syncInterval;

  /// Inicia auto-sync periódico
  ///
  /// [onSync]: Callback executado a cada intervalo
  void startAutoSync(VoidCallback onSync) {
    stopAutoSync();

    if (_syncInterval.inSeconds > 0) {
      _syncTimer = Timer.periodic(_syncInterval, (timer) {
        _lastSyncTime = DateTime.now();
        onSync();
      });
    }
  }

  /// Para auto-sync
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Verifica se deve fazer throttle (rate limiting)
  ///
  /// Retorna true se deve BLOQUEAR a operação
  bool shouldThrottle({Duration minimumInterval = const Duration(seconds: 5)}) {
    if (_lastSyncTime == null) return false;

    final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
    return timeSinceLastSync < minimumInterval;
  }

  /// Atualiza o intervalo de sync
  void updateInterval(Duration newInterval) {
    if (_syncInterval == newInterval) return;

    _syncInterval = newInterval;

    // Restart timer if running
    if (_syncTimer != null && _syncTimer!.isActive) {
      stopAutoSync();
      // Note: Would need to store callback to properly restart
      // For now, requires manual restart via startAutoSync()
    }
  }

  /// Obtém tempo desde última sincronização
  Duration? get timeSinceLastSync {
    if (_lastSyncTime == null) return null;
    return DateTime.now().difference(_lastSyncTime!);
  }

  /// Marca que uma sincronização ocorreu
  void markSynced() {
    _lastSyncTime = DateTime.now();
  }

  /// Verifica se está rodando
  bool get isActive => _syncTimer != null && _syncTimer!.isActive;

  /// Cleanup
  void dispose() {
    stopAutoSync();
  }
}
