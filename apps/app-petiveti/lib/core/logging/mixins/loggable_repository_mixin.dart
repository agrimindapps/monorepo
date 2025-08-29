import '../entities/log_entry.dart';
import '../services/logging_service.dart';

/// Mixin to provide consistent logging functionality across all repositories
mixin LoggableRepositoryMixin {
  LoggingService get _logger => LoggingService.instance;

  /// Log the start of a repository operation
  Future<void> logOperationStart({
    required LogCategory category,
    required LogOperation operation,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    await _logger.logInfo(
      category: category,
      operation: operation,
      message: 'Starting $message',
      metadata: metadata,
    );
  }

  /// Log successful completion of a repository operation
  Future<void> logOperationSuccess({
    required LogCategory category,
    required LogOperation operation,
    required String message,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    await _logger.logInfo(
      category: category,
      operation: operation,
      message: 'Successfully completed $message',
      metadata: metadata,
      duration: duration,
    );
  }

  /// Log a repository operation failure
  Future<void> logOperationError({
    required LogCategory category,
    required LogOperation operation,
    required String message,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    await _logger.logError(
      category: category,
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
    required LogCategory category,
    required String message,
    required dynamic error,
    Map<String, dynamic>? metadata,
  }) async {
    await _logger.logError(
      category: category,
      operation: LogOperation.validate,
      message: 'Validation failed: $message',
      error: error,
      metadata: metadata,
    );
  }

  /// Log data synchronization start
  Future<void> logSyncStart({
    required LogCategory category,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    await _logger.logInfo(
      category: category,
      operation: LogOperation.sync,
      message: 'Starting sync: $message',
      metadata: metadata,
    );
  }

  /// Log successful data synchronization
  Future<void> logSyncSuccess({
    required LogCategory category,
    required String message,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    await _logger.logInfo(
      category: category,
      operation: LogOperation.sync,
      message: 'Successfully synced: $message',
      metadata: metadata,
      duration: duration,
    );
  }

  /// Log data synchronization failure
  Future<void> logSyncError({
    required LogCategory category,
    required String message,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    await _logger.logError(
      category: category,
      operation: LogOperation.sync,
      message: 'Failed to sync: $message',
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
      duration: duration,
    );
  }

  /// Log a timed repository operation
  Future<T> logTimedOperation<T>({
    required LogCategory category,
    required LogOperation operation,
    required String message,
    required Future<T> Function() operationFunction,
    Map<String, dynamic>? metadata,
  }) async {
    return await _logger.logTimedOperation<T>(
      category: category,
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
    required LogCategory category,
    required LogOperation operation,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? metadata,
  }) async {
    final operationName = operation.name.toUpperCase();
    final message = '$operationName $entityType${entityId != null ? ' (ID: $entityId)' : ''}';

    await _logger.logInfo(
      category: category,
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
    required LogCategory category,
    required LogOperation operation,
    required String entityType,
    required int count,
    Map<String, dynamic>? metadata,
  }) async {
    final operationName = operation.name.toUpperCase();
    final message = 'Batch $operationName $count $entityType records';

    await _logger.logInfo(
      category: category,
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
    required LogCategory category,
    required LogOperation operation,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    await _logger.logInfo(
      category: LogCategory.storage,
      operation: operation,
      message: 'Local storage: $message',
      metadata: {
        'original_category': category.name,
        ...?metadata,
      },
    );
  }

  /// Log remote storage operation
  Future<void> logRemoteStorageOperation({
    required LogCategory category,
    required LogOperation operation,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    await _logger.logInfo(
      category: LogCategory.network,
      operation: operation,
      message: 'Remote storage: $message',
      metadata: {
        'original_category': category.name,
        ...?metadata,
      },
    );
  }
}