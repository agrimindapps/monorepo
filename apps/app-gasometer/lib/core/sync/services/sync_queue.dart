import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../models/sync_queue_item.dart';

@singleton
class SyncQueue {
  static const String _syncQueueBoxName = 'sync_queue';
  
  Box<SyncQueueItem>? _syncQueueBox;
  
  final StreamController<List<SyncQueueItem>> _queueController = 
      StreamController<List<SyncQueueItem>>.broadcast();
  
  Stream<List<SyncQueueItem>> get queueStream => _queueController.stream;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _syncQueueBox = await Hive.openBox<SyncQueueItem>(_syncQueueBoxName);
      _isInitialized = true;
      _notifyQueueUpdated();
      debugPrint('✅ SyncQueue inicializado com ${_syncQueueBox!.length} items');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar SyncQueue: $e');
      rethrow;
    }
  }

  /// Adiciona item na fila de sincronização
  Future<void> addToQueue({
    required String modelType, 
    required String operation, 
    required Map<String, dynamic> data,
    String? userId,
    int priority = 0,
  }) async {
    await _ensureInitialized();

    final queueItem = SyncQueueItem(
      id: const Uuid().v4(),
      modelType: modelType,
      operation: operation.toLowerCase(),
      data: data,
      userId: userId ?? '',
      priority: priority,
    );

    await _syncQueueBox!.add(queueItem);
    _notifyQueueUpdated();
    
    debugPrint('📝 Adicionado à fila: $modelType.$operation (ID: ${queueItem.id})');
  }

  /// Obtém todos os itens pendentes de sincronização
  List<SyncQueueItem> getPendingItems() {
    if (!_isInitialized || _syncQueueBox == null) return [];
    
    final pendingItems = _syncQueueBox!.values
        .where((item) => !item.isSynced && item.shouldRetry && item.isRetryDue)
        .toList();

    // Ordena por prioridade e timestamp
    pendingItems.sort((a, b) {
      final priorityComparison = b.calculatedPriority.compareTo(a.calculatedPriority);
      return priorityComparison != 0 
        ? priorityComparison 
        : a.timestamp.compareTo(b.timestamp);
    });

    return pendingItems;
  }

  /// Obtém todos os itens da fila (incluindo sincronizados)
  List<SyncQueueItem> getAllItems() {
    if (!_isInitialized || _syncQueueBox == null) return [];
    return _syncQueueBox!.values.toList();
  }

  /// Obtém itens por tipo de modelo
  List<SyncQueueItem> getItemsByModelType(String modelType) {
    return getPendingItems()
        .where((item) => item.modelType == modelType)
        .toList();
  }

  /// Obtém itens por usuário
  List<SyncQueueItem> getItemsByUserId(String userId) {
    return getPendingItems()
        .where((item) => item.userId == userId)
        .toList();
  }

  /// Marca item como sincronizado
  Future<void> markItemAsSynced(String itemId) async {
    await _ensureInitialized();

    final item = _getItemById(itemId);
    if (item == null) {
      debugPrint('⚠️ Item não encontrado para marcar como sincronizado: $itemId');
      return;
    }
    
    item.isSynced = true;
    item.lastRetryAt = DateTime.now();
    item.errorMessage = null;
    await item.save();
    
    _notifyQueueUpdated();
    debugPrint('✅ Item marcado como sincronizado: ${item.modelType}.${item.operation}');
  }

  /// Incrementa contador de tentativas
  Future<void> incrementRetryCount(String itemId, [String? errorMessage]) async {
    await _ensureInitialized();

    final item = _getItemById(itemId);
    if (item == null) {
      debugPrint('⚠️ Item não encontrado para incrementar retry: $itemId');
      return;
    }
    
    item.retryCount++;
    item.lastRetryAt = DateTime.now();
    item.errorMessage = errorMessage;
    await item.save();
    
    _notifyQueueUpdated();
    debugPrint('🔄 Retry incrementado para: ${item.modelType}.${item.operation} (${item.retryCount}/3)');
  }

  /// Remove item da fila
  Future<void> removeItem(String itemId) async {
    await _ensureInitialized();

    final item = _getItemById(itemId);
    if (item == null) {
      debugPrint('⚠️ Item não encontrado para remoção: $itemId');
      return;
    }

    await item.delete();
    _notifyQueueUpdated();
    debugPrint('🗑️ Item removido da fila: ${item.modelType}.${item.operation}');
  }

  /// Limpa itens já sincronizados
  Future<void> clearSyncedItems() async {
    await _ensureInitialized();
    
    final syncedItems = _syncQueueBox!.values
        .where((item) => item.isSynced)
        .toList();
    
    int removedCount = 0;
    for (var item in syncedItems) {
      await item.delete();
      removedCount++;
    }
    
    if (removedCount > 0) {
      _notifyQueueUpdated();
      debugPrint('🧹 $removedCount itens sincronizados removidos da fila');
    }
  }

  /// Limpa itens que excederam tentativas
  Future<void> clearFailedItems() async {
    await _ensureInitialized();
    
    final failedItems = _syncQueueBox!.values
        .where((item) => !item.shouldRetry)
        .toList();
    
    int removedCount = 0;
    for (var item in failedItems) {
      await item.delete();
      removedCount++;
    }
    
    if (removedCount > 0) {
      _notifyQueueUpdated();
      debugPrint('❌ $removedCount itens com falha removidos da fila');
    }
  }

  /// Limpa todos os itens da fila
  Future<void> clearAllItems() async {
    await _ensureInitialized();
    
    final itemCount = _syncQueueBox!.length;
    await _syncQueueBox!.clear();
    
    _notifyQueueUpdated();
    debugPrint('🗑️ Todos os $itemCount itens removidos da fila');
  }

  /// Obtém estatísticas da fila
  Map<String, dynamic> getQueueStats() {
    if (!_isInitialized || _syncQueueBox == null) {
      return {
        'total': 0,
        'pending': 0,
        'synced': 0,
        'failed': 0,
        'retrying': 0,
      };
    }

    final allItems = _syncQueueBox!.values.toList();
    final pending = allItems.where((item) => !item.isSynced && item.shouldRetry).length;
    final synced = allItems.where((item) => item.isSynced).length;
    final failed = allItems.where((item) => !item.shouldRetry).length;
    final retrying = allItems.where((item) => item.retryCount > 0 && !item.isSynced).length;

    return {
      'total': allItems.length,
      'pending': pending,
      'synced': synced,
      'failed': failed,
      'retrying': retrying,
    };
  }

  // Métodos privados

  SyncQueueItem? _getItemById(String itemId) {
    if (!_isInitialized || _syncQueueBox == null) return null;
    
    try {
      return _syncQueueBox!.values.firstWhere(
        (item) => item.id == itemId,
      );
    } catch (e) {
      return null;
    }
  }

  void _notifyQueueUpdated() {
    if (_queueController.isClosed) return;
    _queueController.add(getPendingItems());
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Dispose de recursos
  Future<void> dispose() async {
    await _queueController.close();
    await _syncQueueBox?.close();
    _isInitialized = false;
    debugPrint('♻️ SyncQueue dispose');
  }
}