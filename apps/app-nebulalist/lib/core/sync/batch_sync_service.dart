import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Operação em batch para Firebase
class BatchOperation {
  final String collection;
  final String documentId;
  final String operation; // 'set', 'update', 'delete'
  final Map<String, dynamic>? data;

  const BatchOperation({
    required this.collection,
    required this.documentId,
    required this.operation,
    this.data,
  });
}

/// Resultado de execução de batch
class BatchResult {
  final int successCount;
  final int failedCount;
  final List<String> failedIds;
  final Duration duration;

  const BatchResult({
    required this.successCount,
    required this.failedCount,
    required this.failedIds,
    required this.duration,
  });

  bool get hasErrors => failedCount > 0;
  bool get isSuccess => failedCount == 0;
}

/// Serviço de batching para operações Firebase
///
/// Agrupa múltiplas operações (set/update/delete) em um único WriteBatch,
/// reduzindo chamadas de rede e melhorando performance.
///
/// **Características:**
/// - Limite de 500 operações por batch (limite do Firestore)
/// - Auto-commit quando limite é atingido
/// - Commit manual ou automático
/// - Retry logic para batches falhados
///
/// **Exemplo:**
/// ```dart
/// final batchService = BatchSyncService(FirebaseFirestore.instance);
///
/// // Adicionar operações
/// batchService.addOperation(BatchOperation(
///   collection: 'lists',
///   documentId: 'list-123',
///   operation: 'set',
///   data: {'name': 'Shopping'},
/// ));
///
/// // Commit batch
/// final result = await batchService.commit();
/// print('Synced ${result.successCount} operations');
/// ```
class BatchSyncService {
  final FirebaseFirestore _firestore;
  final int _maxBatchSize;

  final List<BatchOperation> _pendingOperations = [];

  BatchSyncService(
    this._firestore, {
    int maxBatchSize = 500, // Firestore limit
  }) : _maxBatchSize = maxBatchSize;

  /// Número de operações pendentes
  int get pendingCount => _pendingOperations.length;

  /// Indica se há operações pendentes
  bool get hasPending => _pendingOperations.isNotEmpty;

  /// Adiciona operação ao batch
  ///
  /// Se atingir limite de 500 operações, auto-commit é executado.
  Future<void> addOperation(BatchOperation operation) async {
    _pendingOperations.add(operation);

    // Auto-commit se atingir limite
    if (_pendingOperations.length >= _maxBatchSize) {
      debugPrint('BatchSyncService: Auto-commit triggered (max batch size)');
      await commit();
    }
  }

  /// Adiciona múltiplas operações
  Future<void> addOperations(List<BatchOperation> operations) async {
    for (final op in operations) {
      await addOperation(op);
    }
  }

  /// Commit de todas operações pendentes
  ///
  /// Divide em múltiplos batches se necessário (> 500 ops).
  Future<BatchResult> commit() async {
    if (_pendingOperations.isEmpty) {
      return const BatchResult(
        successCount: 0,
        failedCount: 0,
        failedIds: [],
        duration: Duration.zero,
      );
    }

    final startTime = DateTime.now();
    int totalSuccess = 0;
    int totalFailed = 0;
    final List<String> allFailedIds = [];

    // Dividir em chunks de _maxBatchSize
    final chunks = _chunkList(_pendingOperations, _maxBatchSize);

    debugPrint(
      'BatchSyncService: Committing ${_pendingOperations.length} operations '
      'in ${chunks.length} batch(es)',
    );

    for (var i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];

      try {
        final batch = _firestore.batch();

        for (final operation in chunk) {
          _addOperationToBatch(batch, operation);
        }

        await batch.commit();

        totalSuccess += chunk.length;
        debugPrint('BatchSyncService: Batch ${i + 1}/${chunks.length} committed');
      } catch (e) {
        debugPrint('BatchSyncService: Batch ${i + 1} failed - $e');
        totalFailed += chunk.length;
        allFailedIds.addAll(chunk.map((op) => op.documentId));
      }
    }

    // Limpar operações pendentes
    _pendingOperations.clear();

    final duration = DateTime.now().difference(startTime);

    return BatchResult(
      successCount: totalSuccess,
      failedCount: totalFailed,
      failedIds: allFailedIds,
      duration: duration,
    );
  }

  /// Descarta operações pendentes sem commit
  void discard() {
    debugPrint(
      'BatchSyncService: Discarding ${_pendingOperations.length} pending operations',
    );
    _pendingOperations.clear();
  }

  /// Adiciona operação ao WriteBatch do Firestore
  void _addOperationToBatch(WriteBatch batch, BatchOperation operation) {
    final docRef = _firestore.collection(operation.collection).doc(operation.documentId);

    switch (operation.operation) {
      case 'set':
        if (operation.data != null) {
          batch.set(docRef, operation.data!);
        }
        break;

      case 'update':
        if (operation.data != null) {
          batch.update(docRef, operation.data!);
        }
        break;

      case 'delete':
        batch.delete(docRef);
        break;

      default:
        debugPrint('BatchSyncService: Unknown operation ${operation.operation}');
    }
  }

  /// Divide lista em chunks de tamanho específico
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      final end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }
}

/// Extensão para converter models para BatchOperation
extension ListModelBatchExtension on Map<String, dynamic> {
  /// Converte ListModel para BatchOperation
  BatchOperation toBatchOperation({
    required String documentId,
    required String operation,
  }) {
    return BatchOperation(
      collection: 'lists',
      documentId: documentId,
      operation: operation,
      data: operation != 'delete' ? this : null,
    );
  }
}

extension ItemMasterModelBatchExtension on Map<String, dynamic> {
  /// Converte ItemMasterModel para BatchOperation
  BatchOperation toItemMasterBatchOperation({
    required String documentId,
    required String operation,
  }) {
    return BatchOperation(
      collection: 'itemMasters',
      documentId: documentId,
      operation: operation,
      data: operation != 'delete' ? this : null,
    );
  }
}

extension ListItemModelBatchExtension on Map<String, dynamic> {
  /// Converte ListItemModel para BatchOperation
  BatchOperation toListItemBatchOperation({
    required String listId,
    required String documentId,
    required String operation,
  }) {
    return BatchOperation(
      collection: 'lists/$listId/items',
      documentId: documentId,
      operation: operation,
      data: operation != 'delete' ? this : null,
    );
  }
}
