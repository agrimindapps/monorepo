import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/isync_manager.dart';

/// Adapter que implementa ISyncManager usando UnifiedSyncManager do core
///
/// Este adapter permite que o AnimalRepository use UnifiedSyncManager
/// sem conhecer sua implementação diretamente (Dependency Inversion)
///
/// Responsabilidades:
/// - Traduzir chamadas de ISyncManager para UnifiedSyncManager
/// - Converter eventos entre os dois formatos
/// - Manter compatibilidade com a interface esperada pelo repository
class UnifiedSyncManagerAdapter implements ISyncManager {
  UnifiedSyncManagerAdapter(this._unifiedSyncManager, this._appName);

  final UnifiedSyncManager _unifiedSyncManager;
  final String _appName;

  @override
  Future<void> triggerBackgroundSync(String moduleName) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[UnifiedSyncManagerAdapter] Triggering background sync for $moduleName',
        );
      }
      // UnifiedSyncManager já faz sync em background automaticamente
      // quando dados são marcados como dirty
      // Não precisa fazer nada aqui - é passivo
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[UnifiedSyncManagerAdapter] Background sync trigger failed: $e',
        );
      }
      // Não propaga erro - background sync é best-effort
    }
  }

  @override
  Future<Either<Failure, void>> forceSync(String moduleName) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[UnifiedSyncManagerAdapter] Forcing sync for $moduleName',
        );
      }

      // Force sync de todas as entidades do app
      final result = await _unifiedSyncManager.forceSyncAll(_appName);

      return result.fold(
        (Failure failure) {
          if (kDebugMode) {
            debugPrint(
              '[UnifiedSyncManagerAdapter] Force sync failed: ${failure.message}',
            );
          }
          return Left<Failure, void>(failure);
        },
        (_) {
          if (kDebugMode) {
            debugPrint('[UnifiedSyncManagerAdapter] Force sync completed');
          }
          return const Right<Failure, void>(null);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[UnifiedSyncManagerAdapter] Force sync error: $e');
      }
      return Left(ServerFailure('Sync failed: $e'));
    }
  }

  @override
  bool get isSyncing {
    final status = _unifiedSyncManager.getAppSyncStatus(_appName);
    return status == SyncStatus.syncing;
  }

  @override
  Stream<SyncEvent> get syncEvents {
    // Converte eventos do UnifiedSyncManager para o formato ISyncManager
    return _unifiedSyncManager.syncEventStream
        .where((event) => event.appName == _appName)
        .map((event) => _convertToSyncEvent(event));
  }

  /// Converte AppSyncEvent para SyncEvent
  SyncEvent _convertToSyncEvent(AppSyncEvent event) {
    final type = _convertEventType(event.action);
    return SyncEvent(
      type: type,
      moduleName: _appName,
      message: event.error,
      timestamp: event.timestamp ?? DateTime.now(),
    );
  }

  /// Converte SyncAction para SyncEventType
  SyncEventType _convertEventType(SyncAction action) {
    switch (action) {
      case SyncAction.sync:
        return SyncEventType.started;
      case SyncAction.create:
      case SyncAction.update:
      case SyncAction.delete:
        return SyncEventType.completed;
      case SyncAction.error:
        return SyncEventType.failed;
      case SyncAction.conflict:
        return SyncEventType.paused;
    }
  }
}
