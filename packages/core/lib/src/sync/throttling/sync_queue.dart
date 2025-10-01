import 'dart:async';
import 'dart:collection';

import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../interfaces/i_sync_service.dart';

/// Prioridade de uma operação de sync
enum SyncPriority {
  low(0),
  normal(1),
  high(2),
  critical(3);

  final int value;
  const SyncPriority(this.value);
}

/// Item na fila de sincronização
class SyncQueueItem {
  final String serviceId;
  final String displayName;
  final Future<Either<Failure, ServiceSyncResult>> Function() syncOperation;
  final SyncPriority priority;
  final DateTime enqueuedAt;
  final Duration? timeout;

  SyncQueueItem({
    required this.serviceId,
    required this.displayName,
    required this.syncOperation,
    this.priority = SyncPriority.normal,
    DateTime? enqueuedAt,
    this.timeout,
  }) : enqueuedAt = enqueuedAt ?? DateTime.now();

  /// Compara prioridade para ordenação na fila
  int compareTo(SyncQueueItem other) {
    // Maior prioridade primeiro
    final priorityComparison = other.priority.value.compareTo(priority.value);
    if (priorityComparison != 0) return priorityComparison;

    // Se mesma prioridade, FIFO (primeiro enfileirado primeiro)
    return enqueuedAt.compareTo(other.enqueuedAt);
  }
}

/// Fila de sincronização com prioridades
/// Gerencia múltiplas requisições de sync evitando concorrência
class SyncQueue {
  /// Fila de itens pendentes
  final Queue<SyncQueueItem> _queue = Queue<SyncQueueItem>();

  /// Item atualmente em execução
  SyncQueueItem? _currentItem;

  /// Se está processando a fila
  bool _isProcessing = false;

  /// Máximo de items na fila (previne memory leak)
  final int maxQueueSize;

  /// Stream de eventos da fila
  final StreamController<SyncQueueEvent> _eventController =
      StreamController<SyncQueueEvent>.broadcast();

  Stream<SyncQueueEvent> get events => _eventController.stream;

  SyncQueue({
    this.maxQueueSize = 100,
  });

  /// Adiciona item à fila com prioridade
  bool enqueue(SyncQueueItem item) {
    // Verificar se já existe item para este service na fila
    final existingIndex = _queue
        .toList()
        .indexWhere((queueItem) => queueItem.serviceId == item.serviceId);

    if (existingIndex != -1) {
      // Substituir item existente se nova prioridade for maior
      final existing = _queue.elementAt(existingIndex);
      if (item.priority.value > existing.priority.value) {
        _queue.remove(existing);
        _addToQueue(item);
        _eventController.add(SyncQueueEvent.itemUpdated(item));
        return true;
      } else {
        // Ignorar item de menor prioridade
        _eventController.add(SyncQueueEvent.itemIgnored(item));
        return false;
      }
    }

    // Verificar limite de tamanho da fila
    if (_queue.length >= maxQueueSize) {
      _eventController.add(SyncQueueEvent.queueFull(item));
      return false;
    }

    // Adicionar novo item
    _addToQueue(item);
    _eventController.add(SyncQueueEvent.itemEnqueued(item));

    // Iniciar processamento se não estiver rodando
    if (!_isProcessing) {
      _processQueue();
    }

    return true;
  }

  /// Adiciona item mantendo ordem de prioridade
  void _addToQueue(SyncQueueItem item) {
    final list = _queue.toList();
    list.add(item);
    list.sort((a, b) => a.compareTo(b));

    _queue.clear();
    _queue.addAll(list);
  }

  /// Processa fila de sync
  Future<void> _processQueue() async {
    if (_isProcessing) return;

    _isProcessing = true;
    _eventController.add(SyncQueueEvent.processingStarted());

    try {
      while (_queue.isNotEmpty) {
        _currentItem = _queue.removeFirst();
        _eventController.add(SyncQueueEvent.itemStarted(_currentItem!));

        try {
          // Executar sync com timeout se especificado
          final result = _currentItem!.timeout != null
              ? await _currentItem!.syncOperation()
                  .timeout(_currentItem!.timeout!)
              : await _currentItem!.syncOperation();

          result.fold(
            (failure) {
              _eventController.add(
                SyncQueueEvent.itemFailed(_currentItem!, failure),
              );
            },
            (syncResult) {
              _eventController.add(
                SyncQueueEvent.itemCompleted(_currentItem!, syncResult),
              );
            },
          );
        } on TimeoutException catch (e) {
          _eventController.add(
            SyncQueueEvent.itemFailed(
              _currentItem!,
              SyncFailure('Sync timeout: ${e.message}'),
            ),
          );
        } catch (e) {
          _eventController.add(
            SyncQueueEvent.itemFailed(
              _currentItem!,
              SyncFailure('Sync error: $e'),
            ),
          );
        }

        _currentItem = null;
      }
    } finally {
      _isProcessing = false;
      _eventController.add(SyncQueueEvent.processingCompleted());
    }
  }

  /// Obtém tamanho atual da fila
  int get queueSize => _queue.length;

  /// Verifica se fila está vazia
  bool get isEmpty => _queue.isEmpty;

  /// Verifica se está processando
  bool get isProcessing => _isProcessing;

  /// Obtém item atual em execução
  SyncQueueItem? get currentItem => _currentItem;

  /// Limpa a fila (não cancela item em execução)
  void clear() {
    _queue.clear();
    _eventController.add(SyncQueueEvent.queueCleared());
  }

  /// Obtém estatísticas da fila
  SyncQueueStats getStats() {
    final itemsByPriority = <SyncPriority, int>{};
    for (final item in _queue) {
      itemsByPriority[item.priority] =
          (itemsByPriority[item.priority] ?? 0) + 1;
    }

    return SyncQueueStats(
      queueSize: _queue.length,
      isProcessing: _isProcessing,
      currentItem: _currentItem?.displayName,
      itemsByPriority: itemsByPriority,
      oldestItemAge: _queue.isEmpty
          ? null
          : DateTime.now().difference(_queue.first.enqueuedAt),
    );
  }

  /// Dispose resources
  Future<void> dispose() async {
    clear();
    await _eventController.close();
  }
}

/// Evento da fila de sincronização
class SyncQueueEvent {
  final SyncQueueEventType type;
  final SyncQueueItem? item;
  final ServiceSyncResult? result;
  final Failure? failure;

  SyncQueueEvent._({
    required this.type,
    this.item,
    this.result,
    this.failure,
  });

  factory SyncQueueEvent.itemEnqueued(SyncQueueItem item) =>
      SyncQueueEvent._(type: SyncQueueEventType.itemEnqueued, item: item);

  factory SyncQueueEvent.itemUpdated(SyncQueueItem item) =>
      SyncQueueEvent._(type: SyncQueueEventType.itemUpdated, item: item);

  factory SyncQueueEvent.itemIgnored(SyncQueueItem item) =>
      SyncQueueEvent._(type: SyncQueueEventType.itemIgnored, item: item);

  factory SyncQueueEvent.queueFull(SyncQueueItem item) =>
      SyncQueueEvent._(type: SyncQueueEventType.queueFull, item: item);

  factory SyncQueueEvent.itemStarted(SyncQueueItem item) =>
      SyncQueueEvent._(type: SyncQueueEventType.itemStarted, item: item);

  factory SyncQueueEvent.itemCompleted(
    SyncQueueItem item,
    ServiceSyncResult result,
  ) =>
      SyncQueueEvent._(
        type: SyncQueueEventType.itemCompleted,
        item: item,
        result: result,
      );

  factory SyncQueueEvent.itemFailed(SyncQueueItem item, Failure failure) =>
      SyncQueueEvent._(
        type: SyncQueueEventType.itemFailed,
        item: item,
        failure: failure,
      );

  factory SyncQueueEvent.processingStarted() =>
      SyncQueueEvent._(type: SyncQueueEventType.processingStarted);

  factory SyncQueueEvent.processingCompleted() =>
      SyncQueueEvent._(type: SyncQueueEventType.processingCompleted);

  factory SyncQueueEvent.queueCleared() =>
      SyncQueueEvent._(type: SyncQueueEventType.queueCleared);
}

/// Tipos de eventos da fila
enum SyncQueueEventType {
  itemEnqueued,
  itemUpdated,
  itemIgnored,
  queueFull,
  itemStarted,
  itemCompleted,
  itemFailed,
  processingStarted,
  processingCompleted,
  queueCleared,
}

/// Estatísticas da fila de sync
class SyncQueueStats {
  final int queueSize;
  final bool isProcessing;
  final String? currentItem;
  final Map<SyncPriority, int> itemsByPriority;
  final Duration? oldestItemAge;

  SyncQueueStats({
    required this.queueSize,
    required this.isProcessing,
    required this.currentItem,
    required this.itemsByPriority,
    required this.oldestItemAge,
  });

  Map<String, dynamic> toJson() {
    return {
      'queue_size': queueSize,
      'is_processing': isProcessing,
      'current_item': currentItem,
      'items_by_priority': itemsByPriority.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'oldest_item_age_seconds': oldestItemAge?.inSeconds,
    };
  }

  @override
  String toString() {
    return 'SyncQueueStats(queueSize: $queueSize, '
        'isProcessing: $isProcessing, '
        'currentItem: $currentItem, '
        'itemsByPriority: $itemsByPriority, '
        'oldestItemAge: ${oldestItemAge?.inSeconds}s)';
  }
}
