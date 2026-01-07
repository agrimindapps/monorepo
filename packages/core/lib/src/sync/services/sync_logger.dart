import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Logger estruturado para operações de sincronização
/// Baseado no padrão do app-gasometer LoggingService
class SyncLogger {
  final String appName;
  final bool enableDebugLogs;

  SyncLogger({required this.appName, this.enableDebugLogs = kDebugMode});

  /// Log de início de sincronização
  void logSyncStart({required String entity, Map<String, dynamic>? metadata}) {
    _log(
      level: LogLevel.info,
      category: SyncLogCategory.sync,
      message: 'Starting sync for $entity',
      metadata: {
        'app': appName,
        'entity': entity,
        'operation': 'sync_start',
        ...?metadata,
      },
    );
  }

  /// Log de sucesso de sincronização
  void logSyncSuccess({
    required String entity,
    required Duration duration,
    required int itemsSynced,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      level: LogLevel.info,
      category: SyncLogCategory.sync,
      message: 'Sync completed successfully for $entity',
      metadata: {
        'app': appName,
        'entity': entity,
        'operation': 'sync_success',
        'duration_ms': duration.inMilliseconds,
        'items_synced': itemsSynced,
        ...?metadata,
      },
    );
  }

  /// Log de falha de sincronização
  void logSyncFailure({
    required String entity,
    required String error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      level: LogLevel.error,
      category: SyncLogCategory.sync,
      message: 'Sync failed for $entity: $error',
      metadata: {
        'app': appName,
        'entity': entity,
        'operation': 'sync_failure',
        'error': error,
        'stack_trace': stackTrace?.toString(),
        ...?metadata,
      },
    );
  }

  /// Log de retry de sincronização
  void logSyncRetry({
    required String entity,
    required int attempt,
    required int maxAttempts,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      level: LogLevel.warning,
      category: SyncLogCategory.sync,
      message: 'Retrying sync for $entity (attempt $attempt/$maxAttempts)',
      metadata: {
        'app': appName,
        'entity': entity,
        'operation': 'sync_retry',
        'attempt': attempt,
        'max_attempts': maxAttempts,
        ...?metadata,
      },
    );
  }

  /// Log de tamanho da fila de sync
  void logQueueSize({
    required int pendingOperations,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      level: LogLevel.info,
      category: SyncLogCategory.sync,
      message: 'Sync queue has $pendingOperations pending operations',
      metadata: {
        'app': appName,
        'operation': 'queue_status',
        'pending_operations': pendingOperations,
        ...?metadata,
      },
    );
  }

  /// Log de mudança de conectividade
  void logConnectivityChange({
    required bool isConnected,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      level: LogLevel.info,
      category: SyncLogCategory.network,
      message: 'Connectivity changed: ${isConnected ? 'Online' : 'Offline'}',
      metadata: {
        'app': appName,
        'operation': 'connectivity_change',
        'is_connected': isConnected,
        ...?metadata,
      },
    );
  }

  /// Log de auto-recovery
  void logAutoRecovery({
    required String entity,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      level: LogLevel.info,
      category: SyncLogCategory.sync,
      message: 'Auto-recovery triggered for $entity after connection restored',
      metadata: {
        'app': appName,
        'entity': entity,
        'operation': 'auto_recovery',
        ...?metadata,
      },
    );
  }

  /// Log de resolução de conflito
  void logConflictResolution({
    required String entity,
    required String strategy,
    required String resolution,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      level: LogLevel.warning,
      category: SyncLogCategory.sync,
      message: 'Conflict resolved for $entity using $strategy: $resolution',
      metadata: {
        'app': appName,
        'entity': entity,
        'operation': 'conflict_resolution',
        'strategy': strategy,
        'resolution': resolution,
        ...?metadata,
      },
    );
  }

  /// Log genérico de informação
  void logInfo({
    required String message,
    SyncLogCategory category = SyncLogCategory.sync,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      level: LogLevel.info,
      category: category,
      message: message,
      metadata: {'app': appName, ...?metadata},
    );
  }

  /// Log genérico de warning
  void logWarning({
    required String message,
    SyncLogCategory category = SyncLogCategory.sync,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      level: LogLevel.warning,
      category: category,
      message: message,
      metadata: {'app': appName, ...?metadata},
    );
  }

  /// Log genérico de erro
  void logError({
    required String message,
    SyncLogCategory category = SyncLogCategory.sync,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      level: LogLevel.error,
      category: category,
      message: message,
      metadata: {
        'app': appName,
        'error': error?.toString(),
        'stack_trace': stackTrace?.toString(),
        ...?metadata,
      },
    );
  }

  void _log({
    required LogLevel level,
    required SyncLogCategory category,
    required String message,
    Map<String, dynamic>? metadata,
  }) {
    if (!enableDebugLogs && level == LogLevel.debug) {
      return;
    }
    final metadataStr = metadata != null && metadata.isNotEmpty
        ? ' | ${metadata.entries.map((e) => '${e.key}=${e.value}').join(', ')}'
        : '';
    developer.log(
      '$message$metadataStr',
      name: '${appName.toUpperCase()}:${category.name.toUpperCase()}',
      level: _levelToInt(level),
      time: DateTime.now(),
    );
    if (kDebugMode) {
      final emoji = _levelToEmoji(level);
      final categoryEmoji = _categoryToEmoji(category);
      debugPrint('$emoji $categoryEmoji [$appName] $message$metadataStr');
    }
  }

  /// Converte LogLevel para int (para developer.log)
  int _levelToInt(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }

  /// Converte LogLevel para emoji
  String _levelToEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }

  /// Converte LogCategory para emoji
  String _categoryToEmoji(SyncLogCategory category) {
    switch (category) {
      case SyncLogCategory.sync:
        return '🔄';
      case SyncLogCategory.network:
        return '🌐';
      case SyncLogCategory.storage:
        return '💾';
      case SyncLogCategory.conflict:
        return '⚔️';
      case SyncLogCategory.performance:
        return '⚡';
    }
  }
}

/// Níveis de log
enum LogLevel { debug, info, warning, error }

/// Categorias de log específicas para sincronização
enum SyncLogCategory { sync, network, storage, conflict, performance }
