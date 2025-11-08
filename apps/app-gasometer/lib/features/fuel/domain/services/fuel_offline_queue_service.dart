import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../entities/fuel_record_entity.dart';

/// Service especializado para gerenciamento de fila offline de combustível
/// Aplica SRP (Single Responsibility Principle) - responsável apenas por gerenciar offline queue
@lazySingleton
class FuelOfflineQueueService {
  static const String _boxName = 'fuel_offline_queue';
  static const String _queueKey = 'pending_records';

  Box<dynamic>? _offlineQueueBox;

  /// Carrega registros pendentes do Hive
  Future<List<FuelRecordEntity>> loadPendingRecords() async {
    try {
      _offlineQueueBox ??= await Hive.openBox(_boxName);
      final data = _offlineQueueBox?.get(_queueKey) as List?;

      if (data != null && data.isNotEmpty) {
        final pendingRecords = data
            .map(
              (json) => FuelRecordEntity.fromFirebaseMap(
                json as Map<String, dynamic>,
              ),
            )
            .toList();

        if (kDebugMode) {
          debugPrint(
            '🚗 Carregados ${pendingRecords.length} registros pendentes do Hive',
          );
        }

        return pendingRecords;
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao carregar fila offline: $e');
      }
      return [];
    }
  }

  /// Adiciona registro à fila offline
  Future<void> addToQueue(FuelRecordEntity record) async {
    try {
      _offlineQueueBox ??= await Hive.openBox(_boxName);

      final currentQueue = await loadPendingRecords();
      final updatedQueue = [...currentQueue, record];

      await _saveQueue(updatedQueue);

      if (kDebugMode) {
        debugPrint('🚗 Registro adicionado à fila offline: ${record.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao adicionar à fila offline: $e');
      }
    }
  }

  /// Remove registro da fila offline
  Future<void> removeFromQueue(String recordId) async {
    try {
      final currentQueue = await loadPendingRecords();
      final updatedQueue =
          currentQueue.where((record) => record.id != recordId).toList();

      await _saveQueue(updatedQueue);

      if (kDebugMode) {
        debugPrint('🚗 Registro removido da fila offline: $recordId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao remover da fila offline: $e');
      }
    }
  }

  /// Salva fila completa de registros pendentes
  Future<void> _saveQueue(List<FuelRecordEntity> records) async {
    try {
      _offlineQueueBox ??= await Hive.openBox(_boxName);

      final data = records.map((r) => r.toFirebaseMap()).toList();
      await _offlineQueueBox?.put(_queueKey, data);

      if (kDebugMode) {
        debugPrint('🚗 Fila offline salva: ${data.length} registros');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao salvar fila offline: $e');
      }
    }
  }

  /// Limpa toda a fila offline
  Future<void> clearQueue() async {
    try {
      _offlineQueueBox ??= await Hive.openBox(_boxName);
      await _offlineQueueBox?.delete(_queueKey);

      if (kDebugMode) {
        debugPrint('🚗 Fila offline limpa');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao limpar fila offline: $e');
      }
    }
  }

  /// Obtém quantidade de registros pendentes
  Future<int> getPendingCount() async {
    final pendingRecords = await loadPendingRecords();
    return pendingRecords.length;
  }

  /// Verifica se há registros pendentes
  Future<bool> hasPendingRecords() async {
    final count = await getPendingCount();
    return count > 0;
  }

  /// Atualiza fila com lista de registros
  Future<void> updateQueue(List<FuelRecordEntity> records) async {
    await _saveQueue(records);
  }

  /// Fecha box do Hive
  Future<void> close() async {
    try {
      await _offlineQueueBox?.close();
      _offlineQueueBox = null;

      if (kDebugMode) {
        debugPrint('🚗 Box offline fechado');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao fechar box offline: $e');
      }
    }
  }

  /// Obtém registro específico da fila
  Future<FuelRecordEntity?> getRecordFromQueue(String recordId) async {
    try {
      final queue = await loadPendingRecords();
      return queue.firstWhere(
        (record) => record.id == recordId,
        orElse: () => throw StateError('Record not found'),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Registro não encontrado na fila: $recordId');
      }
      return null;
    }
  }

  /// Remove múltiplos registros da fila
  Future<void> removeMultipleFromQueue(List<String> recordIds) async {
    try {
      final currentQueue = await loadPendingRecords();
      final updatedQueue = currentQueue
          .where((record) => !recordIds.contains(record.id))
          .toList();

      await _saveQueue(updatedQueue);

      if (kDebugMode) {
        debugPrint(
          '🚗 ${recordIds.length} registros removidos da fila offline',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao remover múltiplos da fila offline: $e');
      }
    }
  }

  /// Obtém registros mais antigos da fila (para sync prioritário)
  Future<List<FuelRecordEntity>> getOldestPendingRecords({int limit = 10}) async {
    final queue = await loadPendingRecords();

    final sortedQueue = List<FuelRecordEntity>.from(queue)
      ..sort((a, b) {
        // Handle nullable createdAt
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return a.createdAt!.compareTo(b.createdAt!);
      });

    return sortedQueue.take(limit).toList();
  }
}
