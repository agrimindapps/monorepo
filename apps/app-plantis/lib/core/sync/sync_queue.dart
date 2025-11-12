import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../database/plantis_database.dart' as db;
import '../data/models/sync_queue_item.dart';
import 'sync_queue_drift_service.dart';

/// ADAPTER PATTERN - Mantém interface antiga mas delega para Drift
///
/// Este adapter permite migração gradual de código que usa a interface
/// antiga baseada em Hive para a nova implementação Drift.
///
/// ⚠️ DEPRECATED: Use SyncQueueDriftService diretamente para código novo
@singleton
class SyncQueue {
  final SyncQueueDriftService _driftService;
  final StreamController<List<SyncQueueItem>> _queueController =
      StreamController<List<SyncQueueItem>>.broadcast();

  Stream<List<SyncQueueItem>> get queueStream => _queueController.stream;

  SyncQueue(this._driftService);

  /// Inicializa o watcher de fila
  Future<void> initialize() async {
    // Iniciar watch no Drift service
    _driftService.startWatching();

    // Converter stream Drift para formato antigo
    _driftService.queueStream.listen((driftItems) {
      final oldFormatItems = driftItems.map(_convertToSyncQueueItem).toList();
      _queueController.add(oldFormatItems);
    });
  }

  /// Adicionar item à fila (interface antiga)
  void addToQueue({
    required String modelType,
    required String operation,
    required Map<String, dynamic> data,
  }) {
    // Gerar ID compatível com Firebase
    final id = FirebaseFirestore.instance.collection('_').doc().id;

    // Delegar para Drift service
    _driftService.enqueue(
      modelType: modelType,
      modelId: id,
      operation: operation,
      data: data,
    );
  }

  /// Obter itens pendentes (interface antiga)
  List<SyncQueueItem> getPendingItems() {
    // Interface síncrona - não ideal, mas mantém compatibilidade
    // Para código novo, use _driftService.getPendingItems() diretamente
    throw UnimplementedError(
      'Use getPendingItemsAsync() ou SyncQueueDriftService diretamente',
    );
  }

  /// Versão assíncrona de getPendingItems
  Future<List<SyncQueueItem>> getPendingItemsAsync() async {
    final driftItems = await _driftService.getPendingItems();
    return driftItems.map(_convertToSyncQueueItem).toList();
  }

  /// Marcar item como sincronizado (interface antiga)
  Future<void> markItemAsSynced(String itemId) async {
    // Converter string ID para int (Drift usa auto-increment)
    // Em produção, seria necessário manter mapeamento ID string -> int
    // Por simplicidade, assumimos que itemId pode ser parseado
    try {
      final id = int.parse(itemId);
      await _driftService.markAsSynced(id);
    } catch (e) {
      throw Exception('Invalid item ID: $itemId. Expected integer.');
    }
  }

  /// Incrementar contador de retry (interface antiga)
  Future<void> incrementRetryCount(String itemId) async {
    try {
      final id = int.parse(itemId);
      await _driftService.recordFailedAttempt(id, 'Retry attempt');
    } catch (e) {
      throw Exception('Invalid item ID: $itemId. Expected integer.');
    }
  }

  /// Limpar itens sincronizados
  Future<void> clearSyncedItems() async {
    await _driftService.cleanSyncedItems();
  }

  /// Limpar todos os itens
  Future<void> clearAllItems() async {
    await _driftService.clearAll();
  }

  /// Dispose - limpar recursos
  void dispose() {
    _driftService.stopWatching();
    _queueController.close();
  }

  // HELPERS - Conversão de formatos

  /// Converter PlantsSyncQueueData (Drift) para SyncQueueItem (Hive)
  SyncQueueItem _convertToSyncQueueItem(db.PlantsSyncQueueData driftItem) {
    Map<String, dynamic> data = {};
    if (driftItem.data.isNotEmpty) {
      try {
        data = jsonDecode(driftItem.data) as Map<String, dynamic>;
      } catch (e) {
        // Se falhar parse, manter vazio
      }
    }

    return SyncQueueItem(
      id: driftItem.id.toString(), // Converter int ID para string
      modelType: driftItem.modelType,
      operation: driftItem.operation,
      data: data,
      timestamp: driftItem.timestamp,
      retryCount: driftItem.attempts,
      isSynced: driftItem.isSynced,
    );
  }
}
