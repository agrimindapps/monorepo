import 'dart:async';

import 'package:flutter/foundation.dart';

/// Serviço de fila de sincronização para suporte offline
/// Versão simplificada usando memória para armazenamento temporário
class TaskManagerSyncQueueService {
  final List<SyncQueueItem> _queue = [];
  
  final StreamController<List<SyncQueueItem>> _queueController = 
      StreamController<List<SyncQueueItem>>.broadcast();

  bool _isProcessing = false;

  /// Stream da fila de sincronização
  Stream<List<SyncQueueItem>> get queueStream => _queueController.stream;

  /// Inicializar o serviço
  Future<void> initialize() async {
    // Emitir estado inicial
    _emitQueueState();
    
    if (kDebugMode) {
      debugPrint('🔄 TaskManagerSyncQueueService: Inicializado');
    }
  }

  /// Adicionar item à fila de sincronização
  Future<void> enqueue(SyncQueueItem item) async {
    try {
      _queue.add(item);
      _emitQueueState();
      
      if (kDebugMode) {
        debugPrint('🔄 SyncQueue: Adicionado item ${item.type.name} - ${item.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SyncQueue: Erro ao adicionar item: $e');
      }
      throw Exception('Failed to enqueue sync item: $e');
    }
  }

  /// Adicionar tarefa à fila
  Future<void> enqueueTaskOperation({
    required String taskId,
    required SyncOperationType operation,
    required Map<String, dynamic> data,
    int priority = 5,
  }) async {
    final item = SyncQueueItem(
      id: 'task_${operation.name}_$taskId',
      type: SyncQueueType.task,
      operation: operation,
      data: data,
      priority: priority,
      timestamp: DateTime.now(),
      retryCount: 0,
    );
    
    await enqueue(item);
  }

  /// Processar a fila (sincronizar itens pendentes)
  Future<void> processQueue() async {
    if (_isProcessing) {
      if (kDebugMode) {
        debugPrint('🔄 SyncQueue: Já está processando a fila');
      }
      return;
    }

    _isProcessing = true;
    
    try {
      final items = List<SyncQueueItem>.from(_queue)
        ..sort((SyncQueueItem a, SyncQueueItem b) {
          // Ordenar por prioridade (menor número = maior prioridade) e depois por timestamp
          final priorityComparison = a.priority.compareTo(b.priority);
          if (priorityComparison != 0) return priorityComparison;
          return a.timestamp.compareTo(b.timestamp);
        });

      if (items.isEmpty) {
        if (kDebugMode) {
          debugPrint('🔄 SyncQueue: Fila vazia, nada para processar');
        }
        return;
      }

      if (kDebugMode) {
        debugPrint('🔄 SyncQueue: Processando ${items.length} itens');
      }

      for (final item in items) {
        try {
          await _processItem(item);
        } catch (e) {
          await _handleItemError(item, e);
        }
      }
    } finally {
      _isProcessing = false;
      _emitQueueState();
    }
  }

  /// Processar um item específico
  Future<void> _processItem(SyncQueueItem item) async {
    if (kDebugMode) {
      debugPrint('🔄 SyncQueue: Processando ${item.type.name} ${item.operation.name} - ${item.id}');
    }

    // TODO: Implementar processamento real baseado no tipo e operação
    // Por agora, simulamos o processamento
    await Future<void>.delayed(const Duration(milliseconds: 500));
    
    // Simular sucesso na maioria dos casos
    if (item.retryCount < 3) {
      // Remover item processado com sucesso
      _queue.removeWhere((queueItem) => queueItem.id == item.id);
      
      if (kDebugMode) {
        debugPrint('✅ SyncQueue: Item processado com sucesso - ${item.id}');
      }
    } else {
      throw Exception('Max retries exceeded');
    }
  }

  /// Lidar com erro no processamento de item
  Future<void> _handleItemError(SyncQueueItem item, dynamic error) async {
    if (kDebugMode) {
      debugPrint('❌ SyncQueue: Erro ao processar ${item.id}: $error');
    }

    if (item.retryCount >= 3) {
      // Máximo de tentativas atingido, remover
      _queue.removeWhere((queueItem) => queueItem.id == item.id);
      
      if (kDebugMode) {
        debugPrint('❌ SyncQueue: Item removido após máximo de tentativas - ${item.id}');
      }
    } else {
      // Incrementar contador de tentativas
      final index = _queue.indexWhere((queueItem) => queueItem.id == item.id);
      if (index != -1) {
        _queue[index] = item.copyWith(
          retryCount: item.retryCount + 1,
          lastError: error.toString(),
        );
      }
    }
  }

  /// Obter todos os itens na fila
  List<SyncQueueItem> getAllItems() {
    return List.from(_queue);
  }

  /// Limpar a fila
  Future<void> clear() async {
    _queue.clear();
    _emitQueueState();
    
    if (kDebugMode) {
      debugPrint('🔄 SyncQueue: Fila limpa');
    }
  }

  /// Emitir estado atual da fila
  void _emitQueueState() {
    if (!_queueController.isClosed) {
      _queueController.add(List.from(_queue));
    }
  }

  /// Cleanup
  Future<void> dispose() async {
    await _queueController.close();
  }
}

/// Item da fila de sincronização
class SyncQueueItem {
  final String id;
  final SyncQueueType type;
  final SyncOperationType operation;
  final Map<String, dynamic> data;
  final int priority;
  final DateTime timestamp;
  final int retryCount;
  final String? lastError;

  const SyncQueueItem({
    required this.id,
    required this.type,
    required this.operation,
    required this.data,
    required this.priority,
    required this.timestamp,
    required this.retryCount,
    this.lastError,
  });

  SyncQueueItem copyWith({
    String? id,
    SyncQueueType? type,
    SyncOperationType? operation,
    Map<String, dynamic>? data,
    int? priority,
    DateTime? timestamp,
    int? retryCount,
    String? lastError,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      type: type ?? this.type,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'operation': operation.name,
      'data': data,
      'priority': priority,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
      'lastError': lastError,
    };
  }
}

/// Tipos de itens na fila de sincronização
enum SyncQueueType {
  task,
  project,
  settings,
  user,
}

/// Tipos de operações de sincronização
enum SyncOperationType {
  create,
  update,
  delete,
  reorder,
}