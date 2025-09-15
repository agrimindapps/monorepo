import 'dart:async';
import 'package:core/core.dart';
import '../../features/analytics/analytics_service.dart';
import 'sync_orchestrator.dart';
import 'sync_rate_limiter.dart';

/// Serviço para gerenciar sincronização manual com rate limiting
/// Integra com o SyncOrchestrator existente e controla acesso do usuário
class ManualSyncService {
  final SyncOrchestrator _syncOrchestrator;
  final SyncRateLimiter _rateLimiter;
  final ReceitaAgroAnalyticsService _analytics;

  // Stream controllers para UI
  final _statusController = StreamController<ManualSyncStatus>.broadcast();
  final _progressController = StreamController<ManualSyncProgress>.broadcast();

  ManualSyncStatus _currentStatus = ManualSyncStatus.idle();

  ManualSyncService({
    required SyncOrchestrator syncOrchestrator,
    required SyncRateLimiter rateLimiter,
    required ReceitaAgroAnalyticsService analytics,
  })  : _syncOrchestrator = syncOrchestrator,
        _rateLimiter = rateLimiter,
        _analytics = analytics;

  /// Stream do status da sincronização manual
  Stream<ManualSyncStatus> get statusStream => _statusController.stream;

  /// Stream do progresso da sincronização manual
  Stream<ManualSyncProgress> get progressStream => _progressController.stream;

  /// Status atual da sincronização manual
  ManualSyncStatus get currentStatus => _currentStatus;

  /// Estado atual do rate limiter
  SyncRateLimitState get rateLimitState => _rateLimiter.getCurrentState();

  /// Stream do estado do rate limiter
  Stream<SyncRateLimitState> get rateLimitStream => _rateLimiter.stateStream;

  /// Inicializa o serviço de sincronização manual
  Future<void> initialize() async {
    await _rateLimiter.initialize();

    // Escuta mudanças no orquestrador
    _syncOrchestrator.statusStream.listen(_handleOrchestratorStatusChange);
    _syncOrchestrator.eventStream.listen(_handleOrchestratorEvent);

    _analytics.trackEvent('manual_sync_service_initialized');
  }

  /// Executa sincronização manual respeitando rate limiting
  Future<ManualSyncResult> performManualSync({bool force = false}) async {
    try {
      // Verificar rate limiting
      if (!force && !_rateLimiter.canSync()) {
        final remainingCooldown = _rateLimiter.getRemainingCooldown();
        _analytics.trackEvent('manual_sync_rate_limited', parameters: {
          'remaining_seconds': remainingCooldown?.inSeconds.toString() ?? '0',
        });

        return ManualSyncResult.rateLimited(
          'Aguarde ${_rateLimiter.getCurrentState().cooldownText} para sincronizar novamente',
          remainingCooldown,
        );
      }

      // Verificar se já está sincronizando
      if (_currentStatus.isInProgress) {
        return ManualSyncResult.alreadyInProgress(
          'Sincronização já em andamento',
        );
      }

      // Iniciar sincronização
      _updateStatus(ManualSyncStatus.starting());
      _emitProgress(ManualSyncProgress(
        phase: 'Iniciando sincronização...',
        progress: 0.1,
        itemsProcessed: 0,
        totalItems: null,
      ));

      _analytics.trackEvent('manual_sync_started', parameters: {
        'force': force.toString(),
      });

      // Registrar tentativa de sync para rate limiting
      await _rateLimiter.recordSyncAttempt();

      // Executar sincronização através do orquestrador
      final syncResult = await _syncOrchestrator.performFullSync();

      if (syncResult.success) {
        _updateStatus(ManualSyncStatus.completed(DateTime.now()));
        _analytics.trackEvent('manual_sync_completed', parameters: {
          'operations_sent': syncResult.operationsSent.toString(),
          'operations_received': syncResult.operationsReceived.toString(),
          'conflicts': syncResult.conflicts.length.toString(),
        });

        return ManualSyncResult.success(
          'Sincronização concluída com sucesso',
          syncResult as SyncResult<BaseSyncEntity>,
        );
      } else {
        _updateStatus(
            ManualSyncStatus.error(syncResult.message ?? 'Erro desconhecido'));
        _analytics.trackEvent('manual_sync_failed', parameters: {
          'error': syncResult.message ?? 'unknown',
        });

        return ManualSyncResult.error(
          syncResult.message ?? 'Falha na sincronização',
        );
      }
    } catch (e) {
      _updateStatus(ManualSyncStatus.error(e.toString()));
      _analytics.trackError(
        'manual_sync_exception',
        e.toString(),
        metadata: {'force': force.toString()},
      );

      return ManualSyncResult.error('Erro inesperado: $e');
    }
  }

  /// Obtém estatísticas de sincronização para exibição na UI
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final orchestratorStatus = _syncOrchestrator.currentStatus;
      final rateLimitState = _rateLimiter.getCurrentState();

      // Obter estatísticas dos repositórios
      final Map<String, int> favoritosStats = await _getFavoritosStats();
      final Map<String, int> comentariosStats = await _getComentariosStats();

      return {
        'last_sync_time': rateLimitState.lastSyncTime?.toIso8601String(),
        'last_sync_text': rateLimitState.lastSyncText,
        'can_sync_now': rateLimitState.canSync,
        'cooldown_remaining': rateLimitState.cooldownText,
        'orchestrator_status': orchestratorStatus.state.name,
        'favoritos_count': favoritosStats['total'] ?? 0,
        'comentarios_count': comentariosStats['active'] ?? 0,
        'sync_service_ready':
            orchestratorStatus.state == SyncOrchestratorState.ready,
      };
    } catch (e) {
      _analytics.trackError('sync_stats_error', e.toString());
      return {
        'error': e.toString(),
        'favoritos_count': 0,
        'comentarios_count': 0,
        'sync_service_ready': false,
      };
    }
  }

  /// Obtém estatísticas de favoritos
  Future<Map<String, int>> _getFavoritosStats() async {
    try {
      // Tentar acessar repositório de favoritos através do DI
      // Por enquanto, retorna dados mock
      return {
        'total': 0,
        'defensivos': 0,
        'pragas': 0,
        'culturas': 0,
        'diagnosticos': 0,
      };
    } catch (e) {
      return {'total': 0};
    }
  }

  /// Obtém estatísticas de comentários
  Future<Map<String, int>> _getComentariosStats() async {
    try {
      // Tentar acessar repositório de comentários através do DI
      // Por enquanto, retorna dados mock
      return {
        'total': 0,
        'active': 0,
        'deleted': 0,
      };
    } catch (e) {
      return {'total': 0, 'active': 0};
    }
  }

  /// Lida com mudanças de status do orquestrador
  void _handleOrchestratorStatusChange(SyncOrchestratorStatus status) {
    switch (status.state) {
      case SyncOrchestratorState.syncing:
        if (_currentStatus.type != ManualSyncStatusType.inProgress) {
          _updateStatus(ManualSyncStatus.inProgress());
        }
        _emitProgress(const ManualSyncProgress(
          phase: 'Sincronizando...',
          progress: 0.5,
          itemsProcessed: 0,
          totalItems: null,
        ));
        break;

      case SyncOrchestratorState.error:
        _updateStatus(
            ManualSyncStatus.error(status.message ?? 'Erro na sincronização'));
        break;

      case SyncOrchestratorState.ready:
        if (_currentStatus.isInProgress) {
          _updateStatus(ManualSyncStatus.completed(DateTime.now()));
        }
        break;

      default:
        // Outros estados não requerem ação específica
        break;
    }
  }

  /// Lida com eventos do orquestrador
  void _handleOrchestratorEvent(SyncOrchestratorEvent event) {
    switch (event.type) {
      case SyncOrchestratorEventType.syncCompleted:
        _emitProgress(ManualSyncProgress(
          phase: 'Sincronização concluída',
          progress: 1.0,
          itemsProcessed: 100,
          totalItems: 100,
        ));
        break;

      case SyncOrchestratorEventType.syncFailed:
        _emitProgress(ManualSyncProgress(
          phase: 'Falha na sincronização',
          progress: 0.0,
          itemsProcessed: 0,
          totalItems: null,
          error: event.error,
        ));
        break;

      default:
        break;
    }
  }

  /// Atualiza status e notifica listeners
  void _updateStatus(ManualSyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  /// Emite progresso da sincronização
  void _emitProgress(ManualSyncProgress progress) {
    _progressController.add(progress);
  }

  /// Limpa dados de sincronização manual
  Future<void> clearSyncData() async {
    await _rateLimiter.clear();
    _updateStatus(ManualSyncStatus.idle());
    _analytics.trackEvent('manual_sync_data_cleared');
  }

  /// Dispose dos recursos
  void dispose() {
    _rateLimiter.dispose();
    _statusController.close();
    _progressController.close();
  }
}

// ===== SUPPORTING CLASSES =====

enum ManualSyncStatusType { idle, starting, inProgress, completed, error }

class ManualSyncStatus {
  final ManualSyncStatusType type;
  final String? message;
  final DateTime? timestamp;

  const ManualSyncStatus._({
    required this.type,
    this.message,
    this.timestamp,
  });

  factory ManualSyncStatus.idle() => ManualSyncStatus._(
        type: ManualSyncStatusType.idle,
        timestamp: DateTime.now(),
      );

  factory ManualSyncStatus.starting() => ManualSyncStatus._(
        type: ManualSyncStatusType.starting,
        message: 'Iniciando sincronização...',
        timestamp: DateTime.now(),
      );

  factory ManualSyncStatus.inProgress() => ManualSyncStatus._(
        type: ManualSyncStatusType.inProgress,
        message: 'Sincronização em andamento',
        timestamp: DateTime.now(),
      );

  factory ManualSyncStatus.completed(DateTime completedAt) =>
      ManualSyncStatus._(
        type: ManualSyncStatusType.completed,
        message: 'Sincronização concluída',
        timestamp: completedAt,
      );

  factory ManualSyncStatus.error(String error) => ManualSyncStatus._(
        type: ManualSyncStatusType.error,
        message: error,
        timestamp: DateTime.now(),
      );

  bool get isInProgress =>
      type == ManualSyncStatusType.starting ||
      type == ManualSyncStatusType.inProgress;
  bool get isCompleted => type == ManualSyncStatusType.completed;
  bool get isError => type == ManualSyncStatusType.error;
  bool get isIdle => type == ManualSyncStatusType.idle;
}

class ManualSyncProgress {
  final String phase;
  final double progress; // 0.0 to 1.0
  final int itemsProcessed;
  final int? totalItems;
  final String? error;

  const ManualSyncProgress({
    required this.phase,
    required this.progress,
    required this.itemsProcessed,
    this.totalItems,
    this.error,
  });

  bool get hasError => error != null;
  bool get isComplete => progress >= 1.0;

  String get progressText {
    if (totalItems != null && totalItems! > 0) {
      return '$itemsProcessed de $totalItems itens';
    }
    return '${(progress * 100).toInt()}%';
  }
}

class ManualSyncResult {
  final bool isSuccess;
  final String message;
  final SyncResult? syncResult;
  final Duration? retryAfter;
  final ManualSyncResultType type;

  const ManualSyncResult._({
    required this.isSuccess,
    required this.message,
    required this.type,
    this.syncResult,
    this.retryAfter,
  });

  factory ManualSyncResult.success(String message, SyncResult syncResult) {
    return ManualSyncResult._(
      isSuccess: true,
      message: message,
      type: ManualSyncResultType.success,
      syncResult: syncResult,
    );
  }

  factory ManualSyncResult.error(String message) {
    return ManualSyncResult._(
      isSuccess: false,
      message: message,
      type: ManualSyncResultType.error,
    );
  }

  factory ManualSyncResult.rateLimited(String message, Duration? retryAfter) {
    return ManualSyncResult._(
      isSuccess: false,
      message: message,
      type: ManualSyncResultType.rateLimited,
      retryAfter: retryAfter,
    );
  }

  factory ManualSyncResult.alreadyInProgress(String message) {
    return ManualSyncResult._(
      isSuccess: false,
      message: message,
      type: ManualSyncResultType.alreadyInProgress,
    );
  }
}

enum ManualSyncResultType { success, error, rateLimited, alreadyInProgress }
