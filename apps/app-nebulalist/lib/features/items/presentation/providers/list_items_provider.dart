import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../domain/entities/list_item_entity.dart' as entities;

part 'list_items_provider.g.dart';

/// Main ListItems Notifier with pure Riverpod
/// Manages list items for a specific list
@riverpod
class ListItemsNotifier extends _$ListItemsNotifier {
  late String _listId;
  
  @override
  Future<List<entities.ListItemEntity>> build(String listId) async {
    _listId = listId;
    // Load items for specific list
    final result = await ref.read(getListItemsUseCaseProvider).call(listId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (items) => items,
    );
  }

  /// Add an item to the list
  Future<void> addItemToList({
    required String itemMasterId,
    String quantity = '1',
    entities.Priority priority = entities.Priority.normal,
    String? notes,
  }) async {
    final currentListId = state.value?.firstOrNull?.listId ?? _listId;
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final listItem = entities.ListItemEntity(
        id: '', // Will be set by use case
        listId: currentListId, // The listId from build parameter
        itemMasterId: itemMasterId,
        quantity: quantity,
        priority: priority,
        notes: notes,
        order: 0, // Will be set by use case
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result =
          await ref.read(addItemToListUseCaseProvider).call(listItem);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) async {
          // Reload list items
          final getResult =
              await ref.read(getListItemsUseCaseProvider).call(currentListId);
          return getResult.fold(
            (failure) => throw Exception(failure.message),
            (items) => items,
          );
        },
      );
    });
  }

  /// Update a list item
  Future<void> updateListItem(entities.ListItemEntity item) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await ref.read(updateListItemUseCaseProvider).call(item);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (updatedItem) {
          // Update item in current state
          final currentItems = state.value ?? [];
          return currentItems.map((i) {
            return i.id == updatedItem.id ? updatedItem : i;
          }).toList();
        },
      );
    });
  }

  /// Toggle item completion
  Future<void> toggleCompletion(String itemId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result =
          await ref.read(toggleItemCompletionUseCaseProvider).call(itemId);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (updatedItem) {
          // Update item in current state
          final currentItems = state.value ?? [];
          return currentItems.map((i) {
            return i.id == updatedItem.id ? updatedItem : i;
          }).toList();
        },
      );
    });
  }

  /// Remove item from list
  Future<void> removeItem(String itemId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result =
          await ref.read(removeItemFromListUseCaseProvider).call(itemId);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) {
          // Remove from current state
          final currentItems = state.value ?? [];
          return currentItems.where((i) => i.id != itemId).toList();
        },
      );
    });
  }

  /// Refresh list items
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Provider for pending items count
final pendingItemsCountProvider =
    Provider.autoDispose.family<int, String>((ref, listId) {
  final itemsAsync = ref.watch(listItemsProvider(listId));

  return itemsAsync.when(
    data: (items) => items.where((item) => !item.isCompleted).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for completed items count
final completedItemsCountProvider =
    Provider.autoDispose.family<int, String>((ref, listId) {
  final itemsAsync = ref.watch(listItemsProvider(listId));

  return itemsAsync.when(
    data: (items) => items.where((item) => item.isCompleted).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for high priority items
final highPriorityItemsProvider = Provider.autoDispose
    .family<List<entities.ListItemEntity>, String>((ref, listId) {
  final itemsAsync = ref.watch(listItemsProvider(listId));

  return itemsAsync.when(
    data: (items) => items
        .where((item) =>
            item.priority == entities.Priority.high ||
            item.priority == entities.Priority.urgent)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
