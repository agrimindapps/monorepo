// Dart imports:
import 'dart:async';

// Project imports:
import '../exceptions/repository_exceptions.dart';
import '../logging/repository_logger.dart';
import 'transaction_manager.dart';

/// Mixin para adicionar funcionalidades transacionais aos repositories
mixin TransactionalRepositoryMixin<T> {
  TransactionManager get _transactionManager => TransactionManager.instance;
  RepositoryLogger get _logger => RepositoryLogger(name: repositoryName);

  // Métodos abstratos que devem ser implementados pela classe que usa o mixin
  String get repositoryName;
  String getItemId(T item);
  Map<String, dynamic> Function(T) get toJson;
  Future<T?> findById(String id);
  void invalidateCache([String? pattern]);
  void onItemsCreatedBatch(List<String> ids, List<T> items);
  void onItemUpdated(String id, T item);
  void onItemDeleted(String id, T item);

  /// Criar múltiplos registros usando transação atômica
  Future<List<String>> createBatchTransactional(List<T> items) async {
    if (items.isEmpty) return [];

    final transactionId = _transactionManager
        .generateTransactionId('createBatch_$repositoryName');
    _logger.info(
        'Iniciando transação batch: $transactionId com ${items.length} itens');

    // Criar operações transacionais para cada item
    final operations = <TransactionOperation<String>>[];
    final createdIds = <String>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final operationId = '${transactionId}_create_$i';

      operations.add(TransactionOperation<String>(
        operationId: operationId,
        type: TransactionOperationType.create,
        entityType: T.toString(),
        entityId: getItemId(item),
        afterData: toJson(item),
        operation: () async {
          // Usar create interno sem invalidação de cache
          final id = await _executeCreateWithoutCacheInvalidation(item);
          createdIds.add(id);
          return id;
        },
        compensatingAction: () async {
          // Compensating action: deletar o item criado
          if (createdIds.length > i) {
            try {
              await _executeDeleteWithoutCacheInvalidation(createdIds[i]);
              _logger
                  .info('Compensating action: deletado item ${createdIds[i]}');
            } catch (e) {
              _logger.error(
                  'Falha na compensating action para item ${createdIds[i]}: $e');
            }
          }
        },
      ));
    }

    // Executar transação batch
    final result = await _transactionManager.executeBatchTransaction(
        transactionId, operations);

    if (result.success) {
      // Invalidar cache apenas uma vez após sucesso
      invalidateCache();

      // Executar hook de batch creation
      onItemsCreatedBatch(result.data!, items);

      _logger.info('Transação batch concluída com sucesso: $transactionId');
      return result.data!;
    } else {
      _logger.error('Transação batch falhou: ${result.error}');
      throw BatchTransactionException(
        'Falha na transação batch: ${result.error}',
        transactionId,
        -1,
        result.error,
        repository: repositoryName,
        operation: 'createBatchTransactional',
        totalOperations: operations.length,
      );
    }
  }

  /// Atualizar múltiplos registros usando transação atômica
  Future<void> updateBatchTransactional(Map<String, T> itemsMap) async {
    if (itemsMap.isEmpty) return;

    final transactionId = _transactionManager
        .generateTransactionId('updateBatch_$repositoryName');
    _logger.info(
        'Iniciando transação batch update: $transactionId com ${itemsMap.length} itens');

    final operations = <TransactionOperation<void>>[];
    final originalItems = <String, T>{};

    // Buscar dados originais para compensating actions
    for (final id in itemsMap.keys) {
      final originalItem = await findById(id);
      if (originalItem != null) {
        originalItems[id] = originalItem;
      }
    }

    int operationIndex = 0;
    for (final entry in itemsMap.entries) {
      final id = entry.key;
      final item = entry.value;
      final originalItem = originalItems[id];
      final operationId = '${transactionId}_update_${operationIndex++}';

      operations.add(TransactionOperation<void>(
        operationId: operationId,
        type: TransactionOperationType.update,
        entityType: T.toString(),
        entityId: id,
        beforeData: originalItem != null ? toJson(originalItem) : null,
        afterData: toJson(item),
        operation: () async {
          await _executeUpdateWithoutCacheInvalidation(id, item);
        },
        compensatingAction: () async {
          // Compensating action: restaurar dados originais
          final currentOriginalItem = originalItems[id];
          if (currentOriginalItem != null) {
            try {
              await _executeUpdateWithoutCacheInvalidation(
                  id, currentOriginalItem);
              _logger.info('Compensating action: restaurado item $id');
            } catch (e) {
              _logger.error('Falha na compensating action para item $id: $e');
            }
          }
        },
      ));
    }

    // Executar transação batch
    final result = await _transactionManager.executeBatchTransaction(
        transactionId, operations);

    if (result.success) {
      // Invalidar cache apenas uma vez após sucesso
      invalidateCache();

      // Executar hooks individuais
      for (final entry in itemsMap.entries) {
        onItemUpdated(entry.key, entry.value);
      }

      _logger
          .info('Transação batch update concluída com sucesso: $transactionId');
    } else {
      _logger.error('Transação batch update falhou: ${result.error}');
      throw BatchTransactionException(
        'Falha na transação batch update: ${result.error}',
        transactionId,
        -1,
        result.error,
        repository: repositoryName,
        operation: 'updateBatchTransactional',
        totalOperations: operations.length,
      );
    }
  }

  /// Deletar múltiplos registros usando transação atômica
  Future<void> deleteBatchTransactional(List<String> ids) async {
    if (ids.isEmpty) return;

    final transactionId = _transactionManager
        .generateTransactionId('deleteBatch_$repositoryName');
    _logger.info(
        'Iniciando transação batch delete: $transactionId com ${ids.length} itens');

    final operations = <TransactionOperation<void>>[];
    final originalItems = <String, T>{};

    // Buscar dados originais para compensating actions
    for (final id in ids) {
      final originalItem = await findById(id);
      if (originalItem != null) {
        originalItems[id] = originalItem;
      }
    }

    for (int i = 0; i < ids.length; i++) {
      final id = ids[i];
      final originalItem = originalItems[id];
      final operationId = '${transactionId}_delete_$i';

      operations.add(TransactionOperation<void>(
        operationId: operationId,
        type: TransactionOperationType.delete,
        entityType: T.toString(),
        entityId: id,
        beforeData: originalItem != null ? toJson(originalItem) : null,
        operation: () async {
          await _executeDeleteWithoutCacheInvalidation(id);
        },
        compensatingAction: () async {
          // Compensating action: recriar o item deletado
          final currentOriginalItem = originalItems[id];
          if (currentOriginalItem != null) {
            try {
              await _executeCreateWithoutCacheInvalidation(currentOriginalItem);
              _logger.info('Compensating action: recriado item $id');
            } catch (e) {
              _logger.error('Falha na compensating action para item $id: $e');
            }
          }
        },
      ));
    }

    // Executar transação batch
    final result = await _transactionManager.executeBatchTransaction(
        transactionId, operations);

    if (result.success) {
      // Invalidar cache apenas uma vez após sucesso
      invalidateCache();

      // Executar hooks individuais
      for (final entry in originalItems.entries) {
        onItemDeleted(entry.key, entry.value);
      }

      _logger
          .info('Transação batch delete concluída com sucesso: $transactionId');
    } else {
      _logger.error('Transação batch delete falhou: ${result.error}');
      throw BatchTransactionException(
        'Falha na transação batch delete: ${result.error}',
        transactionId,
        -1,
        result.error,
        repository: repositoryName,
        operation: 'deleteBatchTransactional',
        totalOperations: operations.length,
      );
    }
  }

  /// Operação transacional genérica (para operações complexas customizadas)
  Future<R> executeTransaction<R>(
    String operationName,
    TransactionOperationType operationType,
    Future<R> Function() operation, {
    CompensatingAction? compensatingAction,
    String? entityId,
    Map<String, dynamic>? beforeData,
    Map<String, dynamic>? afterData,
  }) async {
    final transactionId = _transactionManager
        .generateTransactionId('${operationName}_$repositoryName');

    final transactionOperation = TransactionOperation<R>(
      operationId: transactionId,
      type: operationType,
      entityType: T.toString(),
      entityId: entityId,
      beforeData: beforeData,
      afterData: afterData,
      operation: operation,
      compensatingAction: compensatingAction,
    );

    final result = await _transactionManager.executeTransaction(
        transactionId, transactionOperation);

    if (result.success) {
      return result.data!;
    } else {
      throw TransactionException(
        repository: repositoryName,
        operation: operationName,
        transactionId: transactionId,
        successfulOperations: 0,
        totalOperations: 1,
        message: 'Falha na transação: ${result.error}',
      );
    }
  }

  /// Obter histórico de transações deste repository
  List<TransactionEvent> getRepositoryTransactionHistory() {
    return _transactionManager
        .getAllEvents()
        .where((event) => event.entityType == T.toString())
        .toList();
  }

  /// Obter estatísticas de transações deste repository
  Map<String, dynamic> getTransactionStats() {
    final allEvents = _transactionManager.getAllEvents();
    final repositoryEvents =
        allEvents.where((event) => event.entityType == T.toString()).toList();

    final successfulTransactions = repositoryEvents
        .where((e) => !e.isCompensating)
        .map((e) => e.transactionId)
        .toSet()
        .length;

    final compensatingEvents =
        repositoryEvents.where((e) => e.isCompensating).length;

    final operationTypes = <String, int>{};
    for (final event in repositoryEvents) {
      final key = event.operationType.name;
      operationTypes[key] = (operationTypes[key] ?? 0) + 1;
    }

    return {
      'entityType': T.toString(),
      'totalEvents': repositoryEvents.length,
      'successfulTransactions': successfulTransactions,
      'compensatingEvents': compensatingEvents,
      'operationTypes': operationTypes,
    };
  }

  /// Limpar histórico de transações antigas deste repository
  void cleanupTransactionHistory({Duration maxAge = const Duration(days: 7)}) {
    _transactionManager.cleanupOldEvents(maxAge: maxAge);
  }

  // ===========================================
  // MÉTODOS AUXILIARES INTERNOS
  // ===========================================

  /// Métodos que devem ser implementados pela classe que usa o mixin
  Future<String> _executeCreateWithoutCacheInvalidation(T item);
  Future<void> _executeUpdateWithoutCacheInvalidation(String id, T item);
  Future<void> _executeDeleteWithoutCacheInvalidation(String id);
}
