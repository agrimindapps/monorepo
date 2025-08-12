// Dart imports:
import 'dart:async';
import 'dart:collection';

// Project imports:
import '../models/conflict_resolution.dart';
import '../models/task_model.dart';

/// Serviço para gerenciar operações batch thread-safe
/// Implementa locking mechanism e queue para serializar operações concorrentes
class BatchOperationService {
  static final BatchOperationService _instance = BatchOperationService._internal();
  factory BatchOperationService() => _instance;
  BatchOperationService._internal();

  // Lock para operações batch concorrentes
  final Map<String, Completer<void>> _operationLocks = {};
  
  // Queue de operações pendentes
  final Map<String, List<_PendingOperation>> _pendingOperations = {};
  
  // Retry configuration
  static const int _maxRetryAttempts = 3;
  static const Duration _baseRetryDelay = Duration(milliseconds: 100);

  /// Executar operação batch de forma thread-safe
  Future<BatchOperationResult> executeBatchOperation<T>(
    String operationId,
    List<T> items,
    Future<ConflictResolutionOutcome> Function(T item) operation, {
    bool useTransactions = true,
    int? maxConcurrency,
  }) async {
    // Aguardar lock da operação
    await _acquireLock(operationId);

    try {
      _logOperation('BATCH_OPERATION_START', {
        'operationId': operationId,
        'itemCount': items.length,
        'useTransactions': useTransactions,
      });

      final results = <String, ConflictResolutionOutcome>{};
      final succeeded = <T>[];
      final failed = <T>[];

      if (useTransactions) {
        // Executar em transação atômica
        return await _executeInTransaction(operationId, items, operation);
      } else {
        // Executar com controle de concorrência
        final result = await _executeWithConcurrencyControl(
          operationId, items, operation, maxConcurrency ?? 5
        );
        return result;
      }
    } finally {
      _releaseLock(operationId);
    }
  }

  /// Executar operações em transação atômica
  Future<BatchOperationResult> _executeInTransaction<T>(
    String operationId,
    List<T> items,
    Future<ConflictResolutionOutcome> Function(T item) operation,
  ) async {
    final results = <String, ConflictResolutionOutcome>{};
    final succeeded = <T>[];
    final failed = <T>[];
    final rollbackOperations = <Future<void> Function()>[];

    try {
      for (final item in items) {
        try {
          final itemId = _getItemId(item);
          final result = await _executeWithRetry(() => operation(item));
          results[itemId] = result;

          if (result.isSuccess) {
            succeeded.add(result.resolvedTask as T? ?? item);
            // Adicionar operação de rollback se necessário
            rollbackOperations.add(() => _rollbackOperation(item));
          } else {
            failed.add(item);
          }
        } catch (e) {
          failed.add(item);
          final itemId = _getItemId(item);
          results[itemId] = ConflictResolutionOutcome(
            result: ConflictResolutionResult.rejected,
            appliedStrategy: ConflictResolutionStrategy.rejectOperation,
            message: 'Transaction error: $e',
          );
        }
      }

      // Se alguma operação falhou em transação, fazer rollback
      if (failed.isNotEmpty && rollbackOperations.isNotEmpty) {
        await _performRollback(rollbackOperations);
        // Marcar todas como failed
        succeeded.clear();
        failed.addAll(succeeded);
      }

    } catch (e) {
      // Erro crítico, fazer rollback completo
      await _performRollback(rollbackOperations);
      _logOperation('TRANSACTION_ROLLBACK', {
        'operationId': operationId,
        'error': e.toString(),
      });
      rethrow;
    }

    return BatchOperationResult(
      totalTasks: items.length,
      succeededTasks: succeeded.cast<Task>(),
      failedTasks: failed.cast<Task>(),
      results: results,
    );
  }

  /// Executar com controle de concorrência limitada
  Future<BatchOperationResult> _executeWithConcurrencyControl<T>(
    String operationId,
    List<T> items,
    Future<ConflictResolutionOutcome> Function(T item) operation,
    int maxConcurrency,
  ) async {
    final results = <String, ConflictResolutionOutcome>{};
    final succeeded = <T>[];
    final failed = <T>[];
    
    // Semáforo para controlar concorrência
    final semaphore = Semaphore(maxConcurrency);
    
    final futures = items.map((item) async {
      await semaphore.acquire();
      
      try {
        final itemId = _getItemId(item);
        final result = await _executeWithRetry(() => operation(item));
        
        // Thread-safe addition to results
        synchronized(() {
          results[itemId] = result;
          if (result.isSuccess) {
            succeeded.add(result.resolvedTask as T? ?? item);
          } else {
            failed.add(item);
          }
        });
        
      } catch (e) {
        final itemId = _getItemId(item);
        synchronized(() {
          failed.add(item);
          results[itemId] = ConflictResolutionOutcome(
            result: ConflictResolutionResult.rejected,
            appliedStrategy: ConflictResolutionStrategy.rejectOperation,
            message: 'Concurrency error: $e',
          );
        });
      } finally {
        semaphore.release();
      }
    });

    await Future.wait(futures);

    return BatchOperationResult(
      totalTasks: items.length,
      succeededTasks: succeeded.cast<Task>(),
      failedTasks: failed.cast<Task>(),
      results: results,
    );
  }

  /// Executar operação com retry e exponential backoff
  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    var attempts = 0;
    var delay = _baseRetryDelay;

    while (attempts < _maxRetryAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= _maxRetryAttempts) {
          rethrow;
        }

        _logOperation('RETRY_ATTEMPT', {
          'attempt': attempts,
          'delay': delay.inMilliseconds,
          'error': e.toString(),
        });

        await Future.delayed(delay);
        delay = Duration(milliseconds: (delay.inMilliseconds * 1.5).round());
      }
    }

    throw Exception('Max retry attempts exceeded');
  }

  /// Obter ID do item para tracking
  String _getItemId<T>(T item) {
    if (item is Task) return item.id;
    if (item is Map && item.containsKey('id')) return item['id'].toString();
    return item.hashCode.toString();
  }

  /// Adquirir lock para operação
  Future<void> _acquireLock(String operationId) async {
    while (_operationLocks.containsKey(operationId)) {
      await _operationLocks[operationId]!.future;
    }
    _operationLocks[operationId] = Completer<void>();
  }

  /// Liberar lock da operação
  void _releaseLock(String operationId) {
    final completer = _operationLocks.remove(operationId);
    completer?.complete();
  }

  /// Executar função de forma sincronizada
  T synchronized<T>(T Function() operation) {
    // Implementação simples de sincronização
    return operation();
  }

  /// Realizar rollback de operações
  Future<void> _performRollback(List<Future<void> Function()> rollbackOperations) async {
    for (final rollback in rollbackOperations.reversed) {
      try {
        await rollback();
      } catch (e) {
        _logOperation('ROLLBACK_ERROR', {'error': e.toString()});
      }
    }
  }

  /// Rollback específico por item (implementação específica por tipo)
  Future<void> _rollbackOperation<T>(T item) async {
    // Implementação específica de rollback seria feita aqui
    // Para Tasks, seria reverter a última operação
    _logOperation('ROLLBACK_ITEM', {'itemId': _getItemId(item)});
  }

  /// Log de operações (apenas em debug)
  void _logOperation(String event, Map<String, dynamic> details) {
    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
    if (isDebug) {
      print('BatchOperationService: $event - $details');
    }
  }

  /// Limpar recursos
  void dispose() {
    _operationLocks.clear();
    _pendingOperations.clear();
  }

  /// Obter estatísticas de operações
  Map<String, dynamic> getStats() {
    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
    if (!isDebug) {
      return {'message': 'Stats only available in debug mode'};
    }

    return {
      'active_locks': _operationLocks.length,
      'pending_operations': _pendingOperations.length,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Classe para gerenciar operações pendentes
class _PendingOperation {
  final String id;
  final DateTime timestamp;
  final Future<void> operation;

  _PendingOperation({
    required this.id,
    required this.timestamp,
    required this.operation,
  });
}

/// Semáforo para controle de concorrência
class Semaphore {
  int _permits;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  Semaphore(this._permits);

  Future<void> acquire() async {
    if (_permits > 0) {
      _permits--;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _permits++;
    }
  }
}

