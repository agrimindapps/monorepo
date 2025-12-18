import 'dart:async';
import 'package:flutter/foundation.dart';
import 'nebulalist_sync_service.dart';

/// Serviço de sincronização automática em background
///
/// Executa sync periódico a cada X minutos quando app está ativo.
/// Gerencia Timer e permite start/stop manual.
///
/// **Uso:**
/// ```dart
/// final backgroundSync = BackgroundSyncService(
///   syncService: nebulalistSyncService,
///   intervalMinutes: 15,
/// );
///
/// // Iniciar auto-sync
/// backgroundSync.start();
///
/// // Parar quando não necessário
/// backgroundSync.stop();
/// ```
class BackgroundSyncService {
  final NebulalistSyncService _syncService;
  final int _intervalMinutes;

  Timer? _timer;
  bool _isRunning = false;
  bool _isSyncing = false;

  BackgroundSyncService({
    required NebulalistSyncService syncService,
    int intervalMinutes = 15,
  })  : _syncService = syncService,
        _intervalMinutes = intervalMinutes;

  /// Indica se auto-sync está ativo
  bool get isRunning => _isRunning;

  /// Indica se está fazendo sync no momento
  bool get isSyncing => _isSyncing;

  /// Inicia auto-sync periódico
  ///
  /// Se já estiver rodando, não faz nada.
  /// Executa primeiro sync imediatamente se [runImmediately] = true.
  void start({bool runImmediately = false}) {
    if (_isRunning) {
      debugPrint('BackgroundSyncService: Already running');
      return;
    }

    debugPrint(
      'BackgroundSyncService: Starting with interval of $_intervalMinutes minutes',
    );

    _isRunning = true;

    // Sync imediato se solicitado
    if (runImmediately) {
      _performSync();
    }

    // Inicia timer periódico
    _timer = Timer.periodic(
      Duration(minutes: _intervalMinutes),
      (_) => _performSync(),
    );
  }

  /// Para auto-sync
  void stop() {
    if (!_isRunning) {
      return;
    }

    debugPrint('BackgroundSyncService: Stopping');

    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  /// Executa sync manualmente (independente do timer)
  Future<void> syncNow() async {
    await _performSync();
  }

  /// Executa sync
  Future<void> _performSync() async {
    // Evita sync concorrente
    if (_isSyncing) {
      debugPrint('BackgroundSyncService: Sync already in progress, skipping');
      return;
    }

    // Verifica se service pode fazer sync
    if (!_syncService.canSync) {
      debugPrint('BackgroundSyncService: Service not ready for sync');
      return;
    }

    _isSyncing = true;

    try {
      debugPrint('BackgroundSyncService: Starting sync...');

      final result = await _syncService.sync();

      result.fold(
        (failure) {
          debugPrint('BackgroundSyncService: Sync failed - ${failure.message}');
        },
        (syncResult) {
          debugPrint(
            'BackgroundSyncService: Sync completed - '
            '${syncResult.itemsSynced} items synced, '
            '${syncResult.itemsFailed} failed',
          );
        },
      );
    } catch (e) {
      debugPrint('BackgroundSyncService: Sync error - $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Libera recursos
  void dispose() {
    stop();
  }
}
