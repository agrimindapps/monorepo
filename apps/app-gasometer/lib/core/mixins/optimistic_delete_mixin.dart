import 'dart:async';

/// Mixin para implementar exclusão otimista com suporte a undo
///
/// Uso típico em um Notifier:
/// ```dart
/// class VehiclesNotifier extends _$VehiclesNotifier
///     with OptimisticDeleteMixin<VehicleEntity> {
///
///   @override
///   String getItemId(VehicleEntity item) => item.id;
///
///   @override
///   Future<void> performDelete(String id) async {
///     await repository.delete(id);
///   }
///
///   @override
///   Future<void> performRestore(VehicleEntity item) async {
///     await repository.save(item);
///   }
/// }
/// ```
mixin OptimisticDeleteMixin<T> {
  /// Cache de itens removidos para possível restauração
  final Map<String, _DeletedItem<T>> _deletedItems = {};

  /// Timers para exclusão permanente
  final Map<String, Timer> _deleteTimers = {};

  /// Duração padrão antes da exclusão permanente
  Duration get undoDuration => const Duration(seconds: 5);

  /// Retorna o ID do item
  String getItemId(T item);

  /// Executa a exclusão permanente no repositório
  Future<void> performDelete(String id);

  /// Restaura o item no repositório
  Future<void> performRestore(T item);

  /// Remove um item otimisticamente (da UI imediatamente)
  ///
  /// O item é armazenado em cache para possível restauração.
  /// Após [undoDuration], a exclusão é efetivada permanentemente.
  Future<void> removeOptimistic(T item) async {
    final id = getItemId(item);

    // Cancela timer anterior se existir
    _deleteTimers[id]?.cancel();

    // Armazena o item para possível restauração
    _deletedItems[id] = _DeletedItem(
      item: item,
      deletedAt: DateTime.now(),
    );

    // Agenda exclusão permanente
    _deleteTimers[id] = Timer(undoDuration, () {
      _confirmDelete(id);
    });
  }

  /// Restaura um item que foi removido otimisticamente
  Future<void> restoreItem(String id) async {
    // Cancela o timer de exclusão permanente
    _deleteTimers[id]?.cancel();
    _deleteTimers.remove(id);

    // Recupera o item do cache
    final deletedItem = _deletedItems.remove(id);
    if (deletedItem != null) {
      await performRestore(deletedItem.item);
    }
  }

  /// Confirma a exclusão permanente
  Future<void> _confirmDelete(String id) async {
    _deleteTimers.remove(id);
    _deletedItems.remove(id);

    try {
      await performDelete(id);
    } catch (e) {
      // Log error but don't throw - item already removed from UI
      // ignore: avoid_print
      print('[OptimisticDelete] Error confirming delete: $e');
    }
  }

  /// Força a exclusão permanente de todos os itens pendentes
  Future<void> flushPendingDeletes() async {
    final ids = List<String>.from(_deleteTimers.keys);
    for (final id in ids) {
      _deleteTimers[id]?.cancel();
      await _confirmDelete(id);
    }
  }

  /// Cancela todas as exclusões pendentes e restaura os itens
  Future<void> cancelAllPendingDeletes() async {
    final ids = List<String>.from(_deleteTimers.keys);
    for (final id in ids) {
      await restoreItem(id);
    }
  }

  /// Verifica se um item está pendente de exclusão
  bool isPendingDelete(String id) => _deletedItems.containsKey(id);

  /// Limpa os recursos do mixin (chamar no dispose)
  void disposeDeleteMixin() {
    for (final timer in _deleteTimers.values) {
      timer.cancel();
    }
    _deleteTimers.clear();
    _deletedItems.clear();
  }
}

/// Representa um item que foi removido mas ainda pode ser restaurado
class _DeletedItem<T> {
  _DeletedItem({
    required this.item,
    required this.deletedAt,
  });

  final T item;
  final DateTime deletedAt;
}
