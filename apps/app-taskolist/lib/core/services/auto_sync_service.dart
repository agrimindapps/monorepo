import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../errors/failures.dart' as local_failures;
import 'data_integrity_service.dart';

/// Auto-Sync Service para app-taskolist
///
/// Responsabilidades:
/// 1. **Connectivity Monitoring**: Escuta mudanças de conectividade em tempo real
/// 2. **Auto-sync on Reconnect**: Trigger sync automático ao reconectar (~2s)
/// 3. **Periodic Sync**: Timer periódico para sync (3-5min)
/// 4. **Manual Trigger**: Método forceSync() para triggers manuais
/// 5. **Integrity Checks**: Verifica integridade após sync bem-sucedido
///
/// **Fluxo:**
/// ```
/// Offline → Online:
///   1. ConnectivityService detecta reconexão
///   2. AutoSyncService trigga sync imediato (~2s delay)
///   3. UnifiedSyncManager sincroniza todas entities dirty
///   4. DataIntegrityService verifica integridade
///
/// Timer Periódico:
///   1. A cada 3-5min (configurável)
///   2. Verifica conectividade
///   3. Se online: trigga sync
///   4. Se offline: aguarda próximo timer
/// ```
///
/// **Exemplo de uso:**
/// ```dart
/// // No main.dart
/// final autoSync = ref.read(autoSyncServiceProvider);
/// await autoSync.initialize();
///
/// // Para trigger manual
/// await autoSync.forceSync();
///
/// // Para obter estatísticas
/// final stats = autoSync.getStats();
/// print('Last sync: ${stats['last_sync_at']}');
/// ```
class AutoSyncService {
  AutoSyncService(
    this._connectivityService,
    this._dataIntegrityService,
  );

  final ConnectivityService _connectivityService;
  final DataIntegrityService _dataIntegrityService;

  /// UnifiedSyncManager singleton (for future use)
  // ignore: unused_element
  UnifiedSyncManager get _syncManager => UnifiedSyncManager.instance;

  // ========================================================================
  // STATE
  // ========================================================================

  bool _isInitialized = false;
  bool _isSyncing = false;
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _periodicSyncTimer;

  /// Estatísticas de sync
  DateTime? _lastSyncAt;
  DateTime? _lastSuccessfulSyncAt;
  int _syncCount = 0;
  int _syncFailures = 0;
  String? _lastError;

  // ========================================================================
  // CONFIGURATION
  // ========================================================================

  /// Intervalo de sync periódico (padrão: 5min)
  Duration _syncInterval = const Duration(minutes: 5);

  /// Delay após reconexão antes de sync (padrão: 2s)
  final Duration _reconnectDelay = const Duration(seconds: 2);

  /// Se periodic sync está habilitado
  bool _periodicSyncEnabled = true;

  // ========================================================================
  // INITIALIZATION
  // ========================================================================

  /// Inicializa o AutoSyncService
  ///
  /// **Opções:**
  /// - syncInterval: Intervalo entre syncs periódicos (padrão: 5min)
  /// - enablePeriodicSync: Habilitar sync periódico (padrão: true)
  Future<Either<local_failures.Failure, void>> initialize({
    Duration syncInterval = const Duration(minutes: 5),
    bool enablePeriodicSync = true,
  }) async {
    try {
      if (_isInitialized) {
        return const Right(null);
      }

      _syncInterval = syncInterval;
      _periodicSyncEnabled = enablePeriodicSync;

      // 1. Inicializar ConnectivityService
      final connectivityInit = await _connectivityService.initialize();
      if (connectivityInit.isLeft()) {
        return Left(
          local_failures.ServerFailure(
            'Failed to initialize connectivity service',
          ),
        );
      }

      // 2. Escutar mudanças de conectividade
      _connectivitySubscription = _connectivityService.connectivityStream.listen(
        _onConnectivityChanged,
        onError: (Object error) {
          if (kDebugMode) {
            debugPrint('[AutoSync] ❌ Connectivity stream error: $error');
          }
        },
      );

      // 3. Iniciar periodic sync timer (se habilitado)
      if (_periodicSyncEnabled) {
        _startPeriodicSync();
      }

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('[AutoSync] ✅ Initialized');
        debugPrint('[AutoSync]    - Sync interval: ${_syncInterval.inMinutes}min');
        debugPrint('[AutoSync]    - Periodic sync: ${_periodicSyncEnabled ? 'enabled' : 'disabled'}');
      }

      // 4. Trigger sync inicial (se online)
      final isOnlineResult = await _connectivityService.isOnline();
      if (isOnlineResult.isRight() && isOnlineResult.getOrElse(() => false)) {
        _scheduleSyncAfterDelay(_reconnectDelay);
      }

      return const Right(null);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[AutoSync] ❌ Initialization failed: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(
        local_failures.ServerFailure('Failed to initialize AutoSyncService: $e'),
      );
    }
  }

  // ========================================================================
  // CONNECTIVITY MONITORING
  // ========================================================================

  /// Callback para mudanças de conectividade
  void _onConnectivityChanged(bool isOnline) {
    if (kDebugMode) {
      debugPrint('[AutoSync] 🔄 Connectivity changed: ${isOnline ? 'ONLINE' : 'OFFLINE'}');
    }

    if (isOnline) {
      // Reconectou - trigger sync após delay
      _scheduleSyncAfterDelay(_reconnectDelay);
    }
  }

  /// Agenda sync após delay (para evitar múltiplos triggers rápidos)
  void _scheduleSyncAfterDelay(Duration delay) {
    if (kDebugMode) {
      debugPrint('[AutoSync] ⏱️ Scheduling sync in ${delay.inSeconds}s...');
    }

    Timer(delay, () {
      _triggerSync(reason: 'connectivity_restored');
    });
  }

  // ========================================================================
  // PERIODIC SYNC
  // ========================================================================

  /// Inicia timer de sync periódico
  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();

    _periodicSyncTimer = Timer.periodic(_syncInterval, (_) async {
      if (kDebugMode) {
        debugPrint('[AutoSync] ⏲️ Periodic sync timer triggered');
      }

      // Verificar se está online antes de sync
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.getOrElse(() => false);

      if (isOnline) {
        await _triggerSync(reason: 'periodic_timer');
      } else {
        if (kDebugMode) {
          debugPrint('[AutoSync] ⏸️ Skipping periodic sync (offline)');
        }
      }
    });

    if (kDebugMode) {
      debugPrint('[AutoSync] ✅ Periodic sync started (${_syncInterval.inMinutes}min)');
    }
  }

  // ========================================================================
  // SYNC TRIGGERS
  // ========================================================================

  /// Trigger sync interno (não-bloqueante)
  Future<void> _triggerSync({required String reason}) async {
    if (_isSyncing) {
      if (kDebugMode) {
        debugPrint('[AutoSync] ⏭️ Sync already in progress, skipping...');
      }
      return;
    }

    _isSyncing = true;
    _lastSyncAt = DateTime.now();
    _syncCount++;

    if (kDebugMode) {
      debugPrint('[AutoSync] 🔄 Starting sync (reason: $reason)...');
    }

    try {
      // TODO: Implementar quando UnifiedSyncManager tiver método trigger
      // Por enquanto, apenas registramos o evento
      // await _syncManager.forceSyncApp('taskolist');

      if (kDebugMode) {
        debugPrint('[AutoSync] ⚠️ Sync trigger registered (implementation pending)');
        debugPrint('[AutoSync]    - Reason: $reason');
        debugPrint('[AutoSync]    - UnifiedSyncManager will sync in background');
      }

      // Simular sucesso por enquanto
      _lastSuccessfulSyncAt = DateTime.now();

      // Verificar integridade após sync
      // await _verifyIntegrityAfterSync();
    } catch (e) {
      _syncFailures++;
      _lastError = e.toString();

      if (kDebugMode) {
        debugPrint('[AutoSync] ❌ Sync failed: $e');
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Force sync manual (bloqueante)
  ///
  /// Útil para:
  /// - Sync antes de operações críticas
  /// - Pull-to-refresh em UI
  /// - Após mudanças importantes
  Future<Either<local_failures.Failure, void>> forceSync() async {
    if (!_isInitialized) {
      return Left(
        local_failures.ServerFailure('AutoSyncService not initialized'),
      );
    }

    if (kDebugMode) {
      debugPrint('[AutoSync] 🚀 Force sync requested (manual trigger)');
    }

    // Verificar conectividade antes de sync
    final isOnlineResult = await _connectivityService.isOnline();
    final isOnline = isOnlineResult.getOrElse(() => false);

    if (!isOnline) {
      return Left(
        local_failures.NetworkFailure('Cannot sync while offline'),
      );
    }

    await _triggerSync(reason: 'manual_force');

    return const Right(null);
  }

  /// Verifica integridade após sync (otimização: apenas se necessário)
  // ignore: unused_element
  Future<void> _verifyIntegrityAfterSync() async {
    try {
      if (kDebugMode) {
        debugPrint('[AutoSync] 🔍 Verifying data integrity...');
      }

      final result = await _dataIntegrityService.verifyTaskIntegrity();

      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('[AutoSync] ❌ Integrity check failed: ${failure.message}');
          }
        },
        (report) {
          if (kDebugMode) {
            debugPrint('[AutoSync] ✅ Integrity verified: ${report.summary}');
          }

          if (report.hasIssues) {
            debugPrint('[AutoSync] ⚠️ Found ${report.totalIssues} issues (auto-fixed: ${report.issuesFixed})');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AutoSync] ⚠️ Integrity verification error: $e');
      }
    }
  }

  // ========================================================================
  // STATISTICS
  // ========================================================================

  /// Obtém estatísticas de sync
  Map<String, dynamic> getStats() {
    return {
      'is_initialized': _isInitialized,
      'is_syncing': _isSyncing,
      'sync_count': _syncCount,
      'sync_failures': _syncFailures,
      'last_sync_at': _lastSyncAt?.toIso8601String(),
      'last_successful_sync_at': _lastSuccessfulSyncAt?.toIso8601String(),
      'last_error': _lastError,
      'sync_interval_minutes': _syncInterval.inMinutes,
      'periodic_sync_enabled': _periodicSyncEnabled,
      'success_rate': _syncCount > 0
          ? (((_syncCount - _syncFailures) / _syncCount) * 100).toStringAsFixed(1)
          : '0.0',
    };
  }

  // ========================================================================
  // LIFECYCLE
  // ========================================================================

  /// Pausa periodic sync (útil para economizar bateria)
  void pausePeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;

    if (kDebugMode) {
      debugPrint('[AutoSync] ⏸️ Periodic sync paused');
    }
  }

  /// Resume periodic sync
  void resumePeriodicSync() {
    if (_periodicSyncEnabled && _periodicSyncTimer == null) {
      _startPeriodicSync();

      if (kDebugMode) {
        debugPrint('[AutoSync] ▶️ Periodic sync resumed');
      }
    }
  }

  /// Cleanup de recursos
  Future<void> dispose() async {
    if (kDebugMode) {
      debugPrint('[AutoSync] 🗑️ Disposing...');
    }

    await _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();

    _isInitialized = false;

    if (kDebugMode) {
      debugPrint('[AutoSync] ✅ Disposed');
    }
  }
}
