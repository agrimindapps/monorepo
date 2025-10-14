import 'dart:async';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';

import '../../domain/entities/base_sync_entity.dart';
import '../../shared/utils/failure.dart';
import 'sync_coordinator.dart';

/// Handler para gerenciamento de erros e conflitos de sincronização
///
/// Responsabilidades:
/// - Error mapping
/// - Conflict resolution
/// - Error logging
/// - Retry strategies
class SyncErrorHandler {
  final SyncCoordinator _coordinator;

  SyncErrorHandler({
    required SyncCoordinator coordinator,
  }) : _coordinator = coordinator;

  /// Resolve um conflito de sincronização
  Future<Either<Failure, void>> resolveConflict<T extends BaseSyncEntity>(
    String appName,
    String id,
    T resolution,
  ) async {
    try {
      final repository = _coordinator.getRepository<T>(appName);
      if (repository == null) {
        return Left(
          NotFoundFailure(
            'No sync repository found for ${T.toString()} in $appName',
          ),
        );
      }

      // Incrementa versão e marca como dirty para forçar sync
      final resolvedItem = resolution.incrementVersion().markAsDirty() as T;

      developer.log(
        'Resolving conflict for item $id (version: ${resolvedItem.version})',
        name: 'SyncErrorHandler',
      );

      final result = await repository.resolveConflict(id, resolvedItem);

      if (result.isRight()) {
        developer.log(
          'Conflict resolved successfully for $id',
          name: 'SyncErrorHandler',
        );
      }

      return result;
    } catch (e) {
      return Left(CacheFailure('Error resolving conflict: $e'));
    }
  }

  /// Obtém items em conflito de uma entidade
  Future<Either<Failure, List<T>>> getConflictedItems<T extends BaseSyncEntity>(
    String appName,
  ) async {
    try {
      final repository = _coordinator.getRepository<T>(appName);
      if (repository == null) {
        return Left(
          NotFoundFailure(
            'No sync repository found for ${T.toString()} in $appName',
          ),
        );
      }

      return await repository.getConflictedItems();
    } catch (e) {
      return Left(CacheFailure('Error getting conflicted items: $e'));
    }
  }

  /// Mapeia exceções para Failures apropriados
  Failure mapException(Object exception, [StackTrace? stackTrace]) {
    developer.log(
      'Mapping exception: $exception',
      name: 'SyncErrorHandler',
      error: exception,
      stackTrace: stackTrace,
    );

    if (exception is TypeError) {
      return CacheFailure('Type error during sync: ${exception.toString()}');
    }

    if (exception is FormatException) {
      return CacheFailure('Format error during sync: ${exception.message}');
    }

    if (exception is TimeoutException) {
      return NetworkFailure('Sync timeout: ${exception.message}');
    }

    if (exception.toString().contains('network')) {
      return NetworkFailure('Network error: ${exception.toString()}');
    }

    if (exception.toString().contains('permission')) {
      return AuthFailure('Permission denied: ${exception.toString()}');
    }

    // Fallback genérico
    return SyncFailure('Sync error: ${exception.toString()}');
  }

  /// Verifica se um erro é recuperável
  bool isRecoverableError(Failure failure) {
    // Erros de rede são recuperáveis (pode tentar novamente)
    if (failure is NetworkFailure) return true;

    // Erros de timeout são recuperáveis
    if (failure is SyncFailure &&
        failure.message.toLowerCase().contains('timeout')) {
      return true;
    }

    // Cache errors podem ser recuperáveis
    if (failure is CacheFailure) return true;

    // Erros de autenticação e validação não são recuperáveis
    if (failure is AuthFailure) return false;
    if (failure is ValidationFailure) return false;

    // Por padrão, assume não recuperável
    return false;
  }

  /// Sugere estratégia de retry baseada no tipo de erro
  Duration? suggestRetryDelay(Failure failure, int attemptNumber) {
    if (!isRecoverableError(failure)) {
      return null; // Não retry
    }

    // Backoff exponencial
    const baseDelay = Duration(seconds: 2);
    final multiplier = attemptNumber * attemptNumber; // 1, 4, 9, 16...
    final delay = baseDelay * multiplier;

    // Máximo de 2 minutos
    return delay > const Duration(minutes: 2)
        ? const Duration(minutes: 2)
        : delay;
  }

  /// Loga um erro de sincronização
  void logSyncError({
    required String appName,
    required String operation,
    required Failure failure,
    String? entityId,
  }) {
    developer.log(
      'Sync error in $appName: $operation failed',
      name: 'SyncErrorHandler',
      error: failure,
    );

    // Em produção, poderia enviar para analytics/crashlytics
    // analytics.logEvent('sync_error', {
    //   'app': appName,
    //   'operation': operation,
    //   'error_type': failure.runtimeType.toString(),
    //   'error_message': failure.message,
    //   'entity_id': entityId,
    // });
  }

  /// Obtém informações de debug sobre erros
  Map<String, dynamic> getDebugInfo() {
    return {
      'error_handler': 'active',
      'coordinator_apps': _coordinator.registeredApps.length,
    };
  }
}
