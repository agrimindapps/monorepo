import '../services/logging_service.dart';

/// Mixin to provide consistent logging functionality across all repositories
mixin LoggableRepositoryMixin {
  LoggingService get _logger => LoggingService.instance;

  /// Log the start of a repository operation
  Future<void> logOperationStart({
    required String context,
    required String operation,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    await _logger.logInfo(
      context: context,
      operation: operation,
      message: 'Starting $message',
      metadata: metadata,
    );
  }

  /// Log successful completion of a repository operation
  Future<void> logOperationSuccess({
    required String context,
    required String operation,
    required String message,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    await _logger.logInfo(
      context: context,
      operation: operation,
      message: 'Successfully completed $message',
      metadata: metadata,
      duration: duration,
    );
  }

  /// Log a repository operation failure
  Future<void> logOperationError({
    required String context,
    required String operation,
    required String message,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    await _logger.logError(
      context: context,
      operation: operation,
      message: 'Failed to $message',
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
      duration: duration,
    );
  }

  /// Log validation failure
  Future<void> logValidationError({
    required String context,
    required String message,
    required dynamic error,
    Map<String, dynamic>? metadata,
  }) async {
    await _logger.logError(
      context: context,
      operation: 'validate',
      message: 'Validation failed: $message',
      error: error,
      metadata: metadata,
    );
  }

  /// Log data synchronization start
  Future<void> logSyncStart({
    required String context,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    await _logger.logInfo(
      context: context,
      operation: 'sync',
      message: 'Starting sync: $message',
      metadata: metadata,
    );
  }

  /// Log successful data synchronization
  Future<void> logSyncSuccess({
    required String context,
    required String message,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    await _logger.logInfo(
      context: context,
      operation: 'sync',
      message: 'Successfully synced: $message',
      metadata: metadata,
      duration: duration,
    );
  }

  /// Log data synchronization failure
  Future<void> logSyncError({
    required String context,
    required String message,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    await _logger.logError(
      context: context,
      operation: 'sync',
      message: 'Failed to sync: $message',
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
      duration: duration,
    );
  }

  /// Log a timed repository operation
  Future<T> logTimedOperation<T>({
    required String context,
    required String operation,
    required String message,
    required Future<T> Function() operationFunction,
    Map<String, dynamic>? metadata,
  }) async {
    return await _logger.logTimedOperation<T>(
      context: context,
      operation: operation,
      message: message,
      operationFunction: operationFunction,
      metadata: metadata,
    );
  }

  /// Create metadata map with common repository information
  Map<String, dynamic> createMetadata({
    String? entityId,
    String? entityType,
    int? count,
    Map<String, dynamic>? additional,
  }) {
    final metadata = <String, dynamic>{};

    if (entityId != null) metadata['entity_id'] = entityId;
    if (entityType != null) metadata['entity_type'] = entityType;
    if (count != null) metadata['count'] = count;
    if (additional != null) metadata.addAll(additional);

    return metadata;
  }

  /// Log CRUD operation with standardized format
  Future<void> logCrudOperation({
    required String context,
    required String operation,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? metadata,
  }) async {
    final operationName = operation.toUpperCase();
    final message =
        '$operationName $entityType${entityId != null ? ' (ID: $entityId)' : ''}';

    await _logger.logInfo(
      context: context,
      operation: operation,
      message: message,
      metadata: createMetadata(
        entityId: entityId,
        entityType: entityType,
        additional: metadata,
      ),
    );
  }

  /// Log batch operation
  Future<void> logBatchOperation({
    required String context,
    required String operation,
    required String entityType,
    required int count,
    Map<String, dynamic>? metadata,
  }) async {
    final operationName = operation.toUpperCase();
    final message = 'Batch $operationName $count $entityType records';

    await _logger.logInfo(
      context: context,
      operation: operation,
      message: message,
      metadata: createMetadata(
        entityType: entityType,
        count: count,
        additional: metadata,
      ),
    );
  }

  /// Log local storage operation
  Future<void> logLocalStorageOperation({
    required String context,
    required String operation,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    await _logger.logInfo(
      context: 'storage',
      operation: operation,
      message: 'Local storage: $message',
      metadata: {'original_context': context, ...?metadata},
    );
  }

  /// Log remote storage operation
  Future<void> logRemoteStorageOperation({
    required String context,
    required String operation,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    await _logger.logInfo(
      context: 'network',
      operation: operation,
      message: 'Remote storage: $message',
      metadata: {'original_context': context, ...?metadata},
    );
  }
}
