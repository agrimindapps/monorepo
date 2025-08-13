// Dart imports:
import 'dart:async';

// Project imports:
import '../exceptions/repository_exceptions.dart';
import '../logging/repository_logger.dart';
import '../retry/retry_mechanism.dart';

/// Mixin para facilitar integração de error handling consistente nos repositories
mixin RepositoryErrorHandlingMixin {
  /// Nome do repository para logging e error tracking
  String get repositoryName;

  /// Logger específico do repository
  late final RepositoryLogger _logger =
      RepositoryLogManager.instance.getLogger(repositoryName);

  /// Retry mechanism para operações de network
  late final RetryMechanism _retryMechanism =
      RetryManager.instance.createMechanism(repositoryName: repositoryName);

  /// Getter para acesso ao logger
  RepositoryLogger get logger => _logger;

  /// Getter para acesso ao retry mechanism
  RetryMechanism get retryMechanism => _retryMechanism;

  /// Executa operação com error handling completo
  Future<T> executeWithErrorHandling<T>({
    required Future<T> Function() operation,
    required String operationName,
    Map<String, dynamic> context = const {},
    bool enableRetry = false,
    String retryConfigName = 'network',
  }) async {
    try {
      if (enableRetry) {
        return await _retryMechanism.execute<T>(
          operation: operation,
          operationName: operationName,
          context: context,
        );
      } else {
        return await _loggedOperation<T>(operation, operationName, context);
      }
    } on RepositoryException {
      // RepositoryExceptions já estão bem formatadas, só repassar
      rethrow;
    } catch (exception, stackTrace) {
      // Converter exceptions genéricas para RepositoryException
      final repositoryException = _convertToRepositoryException(
        exception,
        operationName,
        context,
      );

      _logger.logException(repositoryException, stackTrace: stackTrace);
      throw repositoryException;
    }
  }

  /// Executa operação com timeout e retry
  Future<T> executeWithTimeoutAndRetry<T>({
    required Future<T> Function() operation,
    required String operationName,
    required Duration timeout,
    Map<String, dynamic> context = const {},
    String retryConfigName = 'network',
  }) async {
    try {
      return await _retryMechanism.executeWithTimeout<T>(
        operation: operation,
        operationName: operationName,
        timeout: timeout,
        context: context,
      );
    } on RepositoryException {
      rethrow;
    } catch (exception, stackTrace) {
      final repositoryException = _convertToRepositoryException(
        exception,
        operationName,
        context,
      );

      _logger.logException(repositoryException, stackTrace: stackTrace);
      throw repositoryException;
    }
  }

  /// Executa operação CRUD básica com logging
  Future<T> executeCrudOperation<T>({
    required Future<T> Function() operation,
    required String operationType, // 'create', 'read', 'update', 'delete'
    String? entityId,
    String? entityType,
    Map<String, dynamic> additionalContext = const {},
  }) async {
    final context = RepositoryLogUtils.crudContext(
      entityId: entityId,
      entityType: entityType,
      additionalData: additionalContext,
    );

    return executeWithErrorHandling<T>(
      operation: operation,
      operationName: operationType,
      context: context,
      enableRetry: _shouldRetryForOperation(operationType),
    );
  }

  /// Executa operação batch com error handling especializado
  Future<List<T>> executeBatchOperation<T, I>({
    required List<I> items,
    required Future<T> Function(I) itemOperation,
    required String operationType,
    int chunkSize = 50,
    Duration? delayBetweenChunks,
    bool continueOnError = false,
    Map<String, dynamic> additionalContext = const {},
  }) async {
    if (items.isEmpty) return [];

    final context = RepositoryLogUtils.batchContext(
      totalItems: items.length,
      chunkSize: chunkSize,
      batchId: DateTime.now().millisecondsSinceEpoch.toString(),
      additionalData: additionalContext,
    );

    _logger.info(
      'Starting batch $operationType',
      data: context,
    );

    final results = <T>[];
    final errors = <RepositoryException>[];
    int successCount = 0;
    int failureCount = 0;

    try {
      // Processar em chunks
      for (int i = 0; i < items.length; i += chunkSize) {
        final chunk = items.skip(i).take(chunkSize).toList();

        _logger.debug(
          'Processing chunk ${(i ~/ chunkSize) + 1}',
          data: {
            'chunk_start': i,
            'chunk_size': chunk.length,
            'total_processed': i,
            ...context,
          },
        );

        // Processar items do chunk
        for (int j = 0; j < chunk.length; j++) {
          final item = chunk[j];
          final itemIndex = i + j;

          try {
            final result = await itemOperation(item);
            results.add(result);
            successCount++;
          } catch (exception) {
            failureCount++;

            final repositoryException = exception is RepositoryException
                ? exception
                : _convertToRepositoryException(
                    exception,
                    operationType,
                    {
                      'item_index': itemIndex,
                      'item': item.toString(),
                      ...context,
                    },
                  );

            errors.add(repositoryException);
            _logger.warning(
              'Failed to process item $itemIndex in batch $operationType',
              data: {
                'item_index': itemIndex,
                'success_count': successCount,
                'failure_count': failureCount,
                ...context,
              },
              exception: repositoryException,
            );

            if (!continueOnError) {
              break;
            }
          }
        }

        // Delay entre chunks se especificado
        if (delayBetweenChunks != null && i + chunkSize < items.length) {
          await Future.delayed(delayBetweenChunks);
        }

        // Se não continuar em erro e houve falha, parar
        if (!continueOnError && errors.isNotEmpty) {
          break;
        }
      }

      // Log resultado final
      if (errors.isEmpty) {
        _logger.info(
          'Completed batch $operationType successfully',
          data: {
            'success_count': successCount,
            'failure_count': failureCount,
            ...context,
          },
        );
      } else if (successCount > 0) {
        _logger.warning(
          'Completed batch $operationType with partial failures',
          data: {
            'success_count': successCount,
            'failure_count': failureCount,
            'error_count': errors.length,
            ...context,
          },
        );
      }

      // Se houve erros e não deve continuar, lançar BatchOperationException
      if (errors.isNotEmpty &&
          (!continueOnError || failureCount == items.length)) {
        throw BatchOperationException(
          repository: repositoryName,
          operation: operationType,
          totalItems: items.length,
          successfulItems: successCount,
          failedItems: failureCount,
          individualErrors: errors,
          context: context,
        );
      }

      return results;
    } catch (exception, stackTrace) {
      if (exception is BatchOperationException) {
        _logger.logException(exception, stackTrace: stackTrace);
        rethrow;
      }

      // Erro inesperado durante processamento batch
      final batchException = BatchOperationException(
        repository: repositoryName,
        operation: operationType,
        totalItems: items.length,
        successfulItems: successCount,
        failedItems: failureCount,
        individualErrors: errors,
        cause: exception is Exception
            ? exception
            : Exception(exception.toString()),
        context: context,
      );

      _logger.logException(batchException, stackTrace: stackTrace);
      throw batchException;
    }
  }

  /// Converte exception genérica para RepositoryException apropriada
  RepositoryException _convertToRepositoryException(
    dynamic exception,
    String operation,
    Map<String, dynamic> context,
  ) {
    // Se já é RepositoryException, retornar como está
    if (exception is RepositoryException) {
      return exception;
    }

    final exceptionString = exception.toString().toLowerCase();

    // TimeoutException
    if (exception is TimeoutException || exceptionString.contains('timeout')) {
      return TimeoutException(
        repository: repositoryName,
        operation: operation,
        timeoutDuration: const Duration(seconds: 30), // Default timeout
        cause: exception is Exception ? exception : null,
        context: context,
      );
    }

    // Network/connectivity errors
    if (exceptionString.contains('network') ||
        exceptionString.contains('connection') ||
        exceptionString.contains('socket') ||
        exceptionString.contains('host')) {
      return NetworkException(
        repository: repositoryName,
        operation: operation,
        message: exception.toString(),
        isRetryable: true,
        cause: exception is Exception ? exception : null,
        context: context,
      );
    }

    // State errors (repository not initialized, etc.)
    if (exceptionString.contains('state') ||
        exceptionString.contains('initialized') ||
        exceptionString.contains('closed')) {
      return InvalidStateException(
        repository: repositoryName,
        operation: operation,
        currentState: 'unknown',
        expectedState: 'initialized',
        cause: exception is Exception ? exception : null,
        context: context,
      );
    }

    // Generic data access error
    return DataAccessException(
      repository: repositoryName,
      operation: operation,
      message: exception.toString(),
      cause: exception is Exception ? exception : null,
      context: context,
    );
  }

  /// Executa operação com logging básico
  Future<T> _loggedOperation<T>(
    Future<T> Function() operation,
    String operationName,
    Map<String, dynamic> context,
  ) async {
    return _logger.logOperation<T>(operationName, operation, context: context);
  }

  /// Determina se operação deve usar retry baseado no tipo
  bool _shouldRetryForOperation(String operationType) {
    // Operações de leitura podem ser retentadas
    if (operationType.contains('read') ||
        operationType.contains('find') ||
        operationType.contains('get')) {
      return true;
    }

    // Sync operations devem ser retentadas
    if (operationType.contains('sync')) {
      return true;
    }

    // Operações de escrita mais cuidadosas com retry
    return false;
  }

  /// Utility para buscar item em lista de forma segura
  T? findInListSafely<T>(
    List<T> list,
    bool Function(T) predicate,
    String operationName, {
    Map<String, dynamic> context = const {},
  }) {
    try {
      return list.firstWhere(predicate);
    } on StateError {
      // StateError é lançado por firstWhere quando não encontra
      // Este é comportamento esperado, não é erro que deve ser logado como exception
      _logger.debug(
        'No item found in $operationName',
        data: {
          'list_size': list.length,
          'operation': operationName,
          ...context,
        },
      );
      return null;
    } catch (exception, stackTrace) {
      // Outros erros são inesperados e devem ser logados
      final repositoryException = DataAccessException(
        repository: repositoryName,
        operation: operationName,
        message: 'Unexpected error while searching in list: $exception',
        cause: exception is Exception ? exception : null,
        context: {
          'list_size': list.length,
          ...context,
        },
      );

      _logger.logException(repositoryException, stackTrace: stackTrace);
      throw repositoryException;
    }
  }

  /// Utility para validar estado de inicialização
  void ensureInitialized(String operationName) {
    // Esta implementação assume que o repository tem um campo _isInitialized
    // Pode ser sobrescrita por repositories específicos se necessário
  }
}
