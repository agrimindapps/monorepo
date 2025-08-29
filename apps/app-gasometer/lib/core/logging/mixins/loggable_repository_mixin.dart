import 'package:flutter/foundation.dart';
import '../entities/log_entry.dart';
import '../services/logging_service.dart';

/// Mixin para adicionar logging automático a repositories
/// Facilitates centralized logging for all CRUD operations
mixin LoggableRepositoryMixin {
  LoggingService get loggingService;
  String get repositoryCategory;

  /// Log para início de operação de create
  Future<void> logCreateStart({
    required String entityType,
    required String entityId,
    Map<String, dynamic>? metadata,
  }) async {
    await loggingService.logOperationStart(
      category: repositoryCategory,
      operation: LogOperation.create,
      message: 'Starting $entityType creation (ID: $entityId)',
      metadata: {
        '${entityType.toLowerCase()}_id': entityId,
        ...?metadata,
      },
    );
  }

  /// Log para sucesso de operação de create
  Future<void> logCreateSuccess({
    required String entityType,
    required String entityId,
    bool synced = false,
    Map<String, dynamic>? metadata,
  }) async {
    await loggingService.logOperationSuccess(
      category: repositoryCategory,
      operation: LogOperation.create,
      message: '$entityType creation completed successfully',
      metadata: {
        '${entityType.toLowerCase()}_id': entityId,
        'synced': synced,
        ...?metadata,
      },
    );
  }

  /// Log para início de operação de update
  Future<void> logUpdateStart({
    required String entityType,
    required String entityId,
    Map<String, dynamic>? metadata,
  }) async {
    await loggingService.logOperationStart(
      category: repositoryCategory,
      operation: LogOperation.update,
      message: 'Starting $entityType update (ID: $entityId)',
      metadata: {
        '${entityType.toLowerCase()}_id': entityId,
        ...?metadata,
      },
    );
  }

  /// Log para sucesso de operação de update
  Future<void> logUpdateSuccess({
    required String entityType,
    required String entityId,
    bool synced = false,
    Map<String, dynamic>? metadata,
  }) async {
    await loggingService.logOperationSuccess(
      category: repositoryCategory,
      operation: LogOperation.update,
      message: '$entityType update completed successfully',
      metadata: {
        '${entityType.toLowerCase()}_id': entityId,
        'synced': synced,
        ...?metadata,
      },
    );
  }

  /// Log para início de operação de delete
  Future<void> logDeleteStart({
    required String entityType,
    required String entityId,
    Map<String, dynamic>? metadata,
  }) async {
    await loggingService.logOperationStart(
      category: repositoryCategory,
      operation: LogOperation.delete,
      message: 'Starting $entityType deletion (ID: $entityId)',
      metadata: {
        '${entityType.toLowerCase()}_id': entityId,
        ...?metadata,
      },
    );
  }

  /// Log para sucesso de operação de delete
  Future<void> logDeleteSuccess({
    required String entityType,
    required String entityId,
    bool synced = false,
    Map<String, dynamic>? metadata,
  }) async {
    await loggingService.logOperationSuccess(
      category: repositoryCategory,
      operation: LogOperation.delete,
      message: '$entityType deletion completed successfully',
      metadata: {
        '${entityType.toLowerCase()}_id': entityId,
        'synced': synced,
        ...?metadata,
      },
    );
  }

  /// Log para operação de erro
  Future<void> logOperationError({
    required String operation,
    required String entityType,
    required String entityId,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) async {
    await loggingService.logOperationError(
      category: repositoryCategory,
      operation: operation,
      message: '$entityType $operation failed',
      error: error,
      stackTrace: stackTrace,
      metadata: {
        '${entityType.toLowerCase()}_id': entityId,
        ...?metadata,
      },
    );
  }

  /// Log para local storage
  Future<void> logLocalStorage({
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? metadata,
  }) async {
    await loggingService.logInfo(
      category: repositoryCategory,
      message: '$entityType $action in local storage',
      metadata: {
        '${entityType.toLowerCase()}_id': entityId,
        'storage': 'local',
        ...?metadata,
      },
    );
  }

  /// Log para remote sync
  Future<void> logRemoteSync({
    required String action,
    required String entityType,
    required String entityId,
    bool success = true,
    String? error,
    Map<String, dynamic>? metadata,
  }) async {
    if (success) {
      await loggingService.logInfo(
        category: repositoryCategory,
        message: '$entityType $action synced to remote storage',
        metadata: {
          '${entityType.toLowerCase()}_id': entityId,
          'storage': 'remote',
          ...?metadata,
        },
      );
    } else {
      await loggingService.logOperationWarning(
        category: repositoryCategory,
        operation: LogOperation.sync,
        message: 'Failed to sync $entityType $action to remote',
        metadata: {
          '${entityType.toLowerCase()}_id': entityId,
          'error': error,
          ...?metadata,
        },
      );
    }
  }

  /// Log para validação
  Future<void> logValidation({
    required String entityType,
    required String entityId,
    bool success = true,
    String? error,
    Map<String, dynamic>? metadata,
  }) async {
    if (success) {
      await loggingService.logInfo(
        category: repositoryCategory,
        message: '$entityType validation passed',
        metadata: {
          '${entityType.toLowerCase()}_id': entityId,
          ...?metadata,
        },
      );
    } else {
      await loggingService.logOperationWarning(
        category: repositoryCategory,
        operation: LogOperation.validate,
        message: '$entityType validation failed',
        metadata: {
          '${entityType.toLowerCase()}_id': entityId,
          'validation_error': error,
          ...?metadata,
        },
      );
    }
  }

  /// Log para operações offline
  Future<void> logOfflineOperation({
    required String operation,
    required String entityType,
    required String entityId,
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    await loggingService.logInfo(
      category: repositoryCategory,
      message: '$entityType $operation saved offline',
      metadata: {
        '${entityType.toLowerCase()}_id': entityId,
        'offline': true,
        'reason': reason ?? 'no_connection',
        ...?metadata,
      },
    );
  }

  /// Helper para wrap operations with logging
  Future<T> withLogging<T>({
    required String operation,
    required String entityType,
    required String entityId,
    required Future<T> Function() operationFunc,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Log start
      await loggingService.logOperationStart(
        category: repositoryCategory,
        operation: operation,
        message: 'Starting $entityType $operation (ID: $entityId)',
        metadata: {
          '${entityType.toLowerCase()}_id': entityId,
          ...?metadata,
        },
      );

      // Execute operation
      final result = await operationFunc();

      // Log success
      await loggingService.logOperationSuccess(
        category: repositoryCategory,
        operation: operation,
        message: '$entityType $operation completed successfully',
        metadata: {
          '${entityType.toLowerCase()}_id': entityId,
          ...?metadata,
        },
      );

      return result;
    } catch (error, stackTrace) {
      // Log error
      await loggingService.logOperationError(
        category: repositoryCategory,
        operation: operation,
        message: '$entityType $operation failed',
        error: error,
        stackTrace: stackTrace,
        metadata: {
          '${entityType.toLowerCase()}_id': entityId,
          ...?metadata,
        },
      );

      rethrow;
    }
  }
}