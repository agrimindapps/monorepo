import 'dart:async';

/// Mixin para implementar exclusão otimista com suporte a undo
///
/// Este mixin gerencia a lógica de delete otimista:
/// 1. Remove da UI imediatamente (UX rápida)
/// 2. Armazena em cache por 5 segundos
/// 3. Permite restauração via undo
/// 4. Executa delete permanente após timeout
///
/// Uso típico em um Notifier Riverpod:
/// ```dart
/// @riverpod
/// class AnimalsNotifier extends _$AnimalsNotifier
///     with OptimisticDeleteMixin<AnimalEntity> {
///
///   @override
///   String getItemId(AnimalEntity item) => item.id;
///
///   @override
///   Future<void> performDelete(String id) async {
///     final result = await ref.read(deleteAnimalProvider)(DeleteAnimalParams(id: id));
///     result.fold(
///       (failure) => throw Exception(failure.message),
///       (_) => {},
///     );
///   }
///
///   @override
///   Future<void> performRestore(AnimalEntity item) async {
///     // Re-adiciona o item ao estado
///     state = AsyncValue.data([...state.value ?? [], item]);
///   }
///
///   // Método de delete público que usa o mixin
///   Future<void> deleteAnimal(AnimalEntity animal) async {
///     // Remove da UI otimisticamente
///     final newList = (state.value ?? []).where((a) => a.id != animal.id).toList();
///     state = AsyncValue.data(newList);
///
///     // Agenda delete permanente com possibilidade de undo
///     await removeOptimistic(animal);
///   }
///
///   // Método de restore público
///   Future<void> restoreAnimal(String id) async {
///     await restoreItem(id);
///   }
/// }
/// ```
mixin OptimisticDeleteMixin<T> {
  /// Cache de itens removidos para possível restauração
  final Map<String, _DeletedItem<T>> _deletedItems = {};

  /// Timers para exclusão permanente
  final Map<String, Timer> _deleteTimers = {};

  /// Duração padrão antes da exclusão permanente (5 segundos)
  /// Pode ser sobrescrito para customizar o timeout
  Duration get undoDuration => const Duration(seconds: 5);

  /// Retorna o ID único do item
  /// Deve ser implementado pela classe que usa o mixin
  String getItemId(T item);

  /// Executa a exclusão permanente no repositório/backend
  /// Deve ser implementado pela classe que usa o mixin
  Future<void> performDelete(String id);

  /// Restaura o item no repositório/estado
  /// Deve ser implementado pela classe que usa o mixin
  Future<void> performRestore(T item);

  /// Remove um item otimisticamente (da UI imediatamente)
  ///
  /// O item é armazenado em cache para possível restauração.
  /// Após [undoDuration], a exclusão é efetivada permanentemente.
  ///
  /// Chamado automaticamente pelo SwipeToDeleteWrapper.
  Future<void> removeOptimistic(T item) async {
    final id = getItemId(item);

    // Cancela timer anterior se existir (caso de swipe duplo)
    _deleteTimers[id]?.cancel();

    // Armazena o item para possível restauração
    _deletedItems[id] = _DeletedItem(
      item: item,
      deletedAt: DateTime.now(),
    );

    // Agenda exclusão permanente após timeout
    _deleteTimers[id] = Timer(undoDuration, () {
      _confirmDelete(id);
    });
  }

  /// Restaura um item que foi removido otimisticamente
  ///
  /// Cancela a exclusão permanente e restaura o item ao estado.
  /// Chamado quando o usuário clica em "DESFAZER" no SnackBar.
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

  /// Confirma a exclusão permanente no backend
  ///
  /// Chamado automaticamente após o timeout de [undoDuration].
  /// Não deve ser chamado manualmente.
  Future<void> _confirmDelete(String id) async {
    _deleteTimers.remove(id);
    _deletedItems.remove(id);

    try {
      await performDelete(id);
    } catch (e) {
      // Log error mas não propaga - item já foi removido da UI
      // ignore: avoid_print
      print('[OptimisticDelete] Erro ao confirmar delete: $e');
    }
  }

  /// Força a exclusão permanente de todos os itens pendentes
  ///
  /// Útil ao fazer logout ou limpar dados.
  Future<void> flushPendingDeletes() async {
    final ids = List<String>.from(_deleteTimers.keys);
    for (final id in ids) {
      _deleteTimers[id]?.cancel();
      await _confirmDelete(id);
    }
  }

  /// Cancela todas as exclusões pendentes e restaura os itens
  ///
  /// Útil em cenários de erro ou cancelamento de operação em batch.
  Future<void> cancelAllPendingDeletes() async {
    final ids = List<String>.from(_deleteTimers.keys);
    for (final id in ids) {
      await restoreItem(id);
    }
  }

  /// Verifica se um item está pendente de exclusão
  ///
  /// Útil para mostrar estados intermediários na UI (ex: opacity reduzida).
  bool isPendingDelete(String id) => _deletedItems.containsKey(id);

  /// Retorna o número de itens pendentes de exclusão
  int get pendingDeleteCount => _deletedItems.length;

  /// Limpa os recursos do mixin (chamar no dispose do notifier)
  ///
  /// IMPORTANTE: Sempre chame isso no dispose para evitar memory leaks.
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
