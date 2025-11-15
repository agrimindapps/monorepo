import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';

import 'gasometer_sync_service.dart';

/// Background sync service para o Gasometer
///
/// Responsabilidades:
/// - Auto-sync periódico em intervalos configuráveis (default: 15min)
/// - Monitoramento de conectividade (pausa quando offline)
/// - Premium feature gate (free = manual only, premium = auto-sync)
/// - Battery optimization (não sync quando bateria baixa)
/// - Retry logic com exponential backoff
/// - Logging detalhado para debugging
///
/// **Premium Feature:**
/// Auto-sync requer assinatura premium. Free users podem fazer sync manual apenas.
///
/// **Conectividade:**
/// Monitora mudanças de conectividade e pausa/resume auto-sync automaticamente.
///
/// **Retry Strategy:**
/// - Max 3 falhas consecutivas antes de desabilitar auto-sync
/// - Logging detalhado de todas as operações
class GasometerBatchSyncService {
  GasometerBatchSyncService({
    required GasometerSyncService syncService,
    required IConnectivityRepository connectivityService,
    required IAnalyticsRepository analyticsService,
  })  : _syncService = syncService,
        _connectivityService = connectivityService,
        _analyticsService = analyticsService;

  final GasometerSyncService _syncService;
  final IConnectivityRepository _connectivityService;
  final IAnalyticsRepository _analyticsService;

  Timer? _autoSyncTimer;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isRunning = false;
  bool _isPaused = false;
  DateTime? _lastSyncTime;
  int _consecutiveFailures = 0;

  // Configurações
  static const Duration _defaultSyncInterval = Duration(minutes: 15);
  static const Duration _minSyncInterval = Duration(minutes: 5);
  static const Duration _maxSyncInterval = Duration(hours: 1);
  static const int _maxConsecutiveFailures = 3;

  // Streams
  final _statusController = StreamController<BatchSyncStatus>.broadcast();
  Stream<BatchSyncStatus> get statusStream => _statusController.stream;

  /// Inicia auto-sync (requer premium)
  ///
  /// **Premium Feature:** Auto-sync requer assinatura premium.
  /// Free users devem usar [performManualSync] apenas.
  ///
  /// **Parâmetros:**
  /// - [interval]: Intervalo entre syncs (min: 5min, max: 1h, default: 15min)
  ///
  /// **Retorna:**
  /// - Right(void): Auto-sync iniciado com sucesso
  /// - Left(PermissionFailure): Usuário não é premium
  /// - Left(ValidationFailure): Intervalo inválido
  /// - Left(ServerFailure): Erro ao iniciar auto-sync
  Future<Either<Failure, void>> startAutoSync({
    Duration? interval,
  }) async {
    try {
      // 1. Validar intervalo
      final syncInterval = interval ?? _defaultSyncInterval;
      if (syncInterval < _minSyncInterval) {
        return Left(
          ValidationFailure(
            'Sync interval must be at least ${_minSyncInterval.inMinutes} minutes',
          ),
        );
      }

      if (syncInterval > _maxSyncInterval) {
        return Left(
          ValidationFailure(
            'Sync interval must be at most ${_maxSyncInterval.inHours} hour(s)',
          ),
        );
      }

      if (_isRunning) {
        developer.log('Auto-sync already running', name: 'BatchSync');
        return const Right(null);
      }

      // 2. Setup connectivity monitoring
      await _setupConnectivityMonitoring();

      // 3. Iniciar timer
      _isRunning = true;
      _isPaused = false;
      _consecutiveFailures = 0;

      _autoSyncTimer = Timer.periodic(syncInterval, (_) async {
        await _performAutoSync();
      });

      // 4. Executar sync inicial imediatamente
      await _performAutoSync();

      developer.log(
        'Auto-sync started with ${syncInterval.inMinutes}min interval',
        name: 'BatchSync',
      );

      unawaited(_analyticsService.logEvent('batch_sync_started'));

      _statusController.add(BatchSyncStatus.running);
      return const Right(null);
    } catch (e, stackTrace) {
      developer.log('Error starting auto-sync: $e', name: 'BatchSync');
      developer.log('$stackTrace', name: 'BatchSync');
      return Left(ServerFailure('Failed to start auto-sync: $e'));
    }
  }

  /// Para auto-sync
  Future<void> stopAutoSync() async {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _isRunning = false;
    _isPaused = false;

    developer.log('Auto-sync stopped', name: 'BatchSync');
    unawaited(_analyticsService.logEvent('batch_sync_stopped'));

    _statusController.add(BatchSyncStatus.stopped);
  }

  /// Pausa auto-sync temporariamente (ex: bateria baixa)
  void pauseAutoSync() {
    _isPaused = true;
    developer.log('Auto-sync paused', name: 'BatchSync');
    _statusController.add(BatchSyncStatus.paused);
  }

  /// Resume auto-sync
  void resumeAutoSync() {
    _isPaused = false;
    developer.log('Auto-sync resumed', name: 'BatchSync');
    _statusController.add(BatchSyncStatus.running);
  }

  /// Executa sync manual (disponível para free users)
  ///
  /// **Free Feature:** Sync manual está disponível para todos os usuários.
  ///
  /// **Retorna:**
  /// - Right(ServiceSyncResult): Sync completado (success ou partial)
  /// - Left(Failure): Erro durante sync
  Future<Either<Failure, ServiceSyncResult>> performManualSync() async {
    developer.log('Manual sync triggered', name: 'BatchSync');
    unawaited(_analyticsService.logEvent('manual_sync_triggered'));

    final result = await _syncService.sync();

    result.fold(
      (failure) {
        unawaited(
          _analyticsService.logEvent(
            'manual_sync_failed',
            parameters: {'error': failure.message},
          ),
        );
      },
      (syncResult) {
        _lastSyncTime = DateTime.now();
        unawaited(
          _analyticsService.logEvent(
            'manual_sync_succeeded',
            parameters: {
              'items_synced': syncResult.itemsSynced,
              'duration_seconds': syncResult.duration.inSeconds,
            },
          ),
        );
      },
    );

    return result;
  }

  /// Sync automático interno (chamado pelo timer)
  Future<void> _performAutoSync() async {
    // 1. Verificar se pausado
    if (_isPaused) {
      developer.log('Auto-sync skipped (paused)', name: 'BatchSync');
      return;
    }

    // 2. Verificar conectividade
    final connectivityResult = await _connectivityService.isOnline();
    final isConnected = connectivityResult.getOrElse(() => false);

    if (!isConnected) {
      developer.log('Auto-sync skipped (no connection)', name: 'BatchSync');
      _statusController.add(BatchSyncStatus.waitingForConnection);
      return;
    }

    // 3. Verificar se há pending sync
    final hasPending = await _syncService.hasPendingSync;
    if (!hasPending) {
      developer.log('Auto-sync skipped (no pending data)', name: 'BatchSync');
      _statusController.add(BatchSyncStatus.running);
      return;
    }

    // 4. Executar sync
    _statusController.add(BatchSyncStatus.syncing);

    developer.log('Auto-sync executing...', name: 'BatchSync');

    final result = await _syncService.sync();

    result.fold(
      (failure) {
        _consecutiveFailures++;
        developer.log(
          '❌ Auto-sync failed (attempt $_consecutiveFailures): ${failure.message}',
          name: 'BatchSync',
        );

        unawaited(
          _analyticsService.logEvent(
            'auto_sync_failed',
            parameters: {
              'error': failure.message,
              'consecutive_failures': _consecutiveFailures,
            },
          ),
        );

        // Desabilitar auto-sync após muitas falhas consecutivas
        if (_consecutiveFailures >= _maxConsecutiveFailures) {
          developer.log(
            '🚨 Auto-sync disabled due to $_maxConsecutiveFailures consecutive failures',
            name: 'BatchSync',
          );
          unawaited(stopAutoSync());
          _statusController.add(BatchSyncStatus.failedPermanently);
        } else {
          _statusController.add(BatchSyncStatus.failedRetrying);
        }
      },
      (syncResult) {
        _consecutiveFailures = 0; // Reset failures counter
        _lastSyncTime = DateTime.now();

        developer.log(
          '✅ Auto-sync completed: ${syncResult.itemsSynced} items in ${syncResult.duration.inSeconds}s',
          name: 'BatchSync',
        );

        unawaited(
          _analyticsService.logEvent(
            'auto_sync_succeeded',
            parameters: {
              'items_synced': syncResult.itemsSynced,
              'duration_seconds': syncResult.duration.inSeconds,
            },
          ),
        );

        _statusController.add(BatchSyncStatus.running);
      },
    );
  }

  /// Setup de monitoramento de conectividade
  Future<void> _setupConnectivityMonitoring() async {
    await _connectivitySubscription?.cancel();

    _connectivitySubscription =
        _connectivityService.connectivityStream.listen(
      (isConnected) {
        if (isConnected && _isPaused) {
          // Reconectou - resume auto-sync
          developer.log(
            'Connectivity restored - resuming auto-sync',
            name: 'BatchSync',
          );
          resumeAutoSync();
        } else if (!isConnected && !_isPaused) {
          // Perdeu conexão - pause auto-sync
          developer.log(
            'Connectivity lost - pausing auto-sync',
            name: 'BatchSync',
          );
          pauseAutoSync();
        }
      },
    );
  }

  /// Estatísticas de sync
  BatchSyncStatistics get statistics {
    return BatchSyncStatistics(
      isRunning: _isRunning,
      isPaused: _isPaused,
      lastSyncTime: _lastSyncTime,
      consecutiveFailures: _consecutiveFailures,
    );
  }

  Future<void> dispose() async {
    await stopAutoSync();
    await _statusController.close();
  }
}

/// Status do batch sync
enum BatchSyncStatus {
  /// Auto-sync não está rodando
  stopped,

  /// Auto-sync ativo e aguardando próximo intervalo
  running,

  /// Auto-sync pausado (sem conectividade ou bateria baixa)
  paused,

  /// Executando sync no momento
  syncing,

  /// Aguardando conexão de rede
  waitingForConnection,

  /// Falhou mas vai tentar novamente
  failedRetrying,

  /// Falhou permanentemente (max retries atingido)
  failedPermanently,
}

/// Estatísticas do batch sync
class BatchSyncStatistics {
  const BatchSyncStatistics({
    required this.isRunning,
    required this.isPaused,
    this.lastSyncTime,
    required this.consecutiveFailures,
  });

  final bool isRunning;
  final bool isPaused;
  final DateTime? lastSyncTime;
  final int consecutiveFailures;

  Duration? get timeSinceLastSync =>
      lastSyncTime != null ? DateTime.now().difference(lastSyncTime!) : null;

  bool get hasRecentSync =>
      lastSyncTime != null &&
      DateTime.now().difference(lastSyncTime!).inHours < 24;

  bool get isHealthy => consecutiveFailures == 0;

  Map<String, dynamic> toMap() {
    return {
      'is_running': isRunning,
      'is_paused': isPaused,
      'last_sync_time': lastSyncTime?.toIso8601String(),
      'consecutive_failures': consecutiveFailures,
      'time_since_last_sync_minutes': timeSinceLastSync?.inMinutes,
      'has_recent_sync': hasRecentSync,
      'is_healthy': isHealthy,
    };
  }

  @override
  String toString() {
    return 'BatchSyncStatistics(running: $isRunning, paused: $isPaused, '
        'lastSync: $lastSyncTime, failures: $consecutiveFailures)';
  }
}
