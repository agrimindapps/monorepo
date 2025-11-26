import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/injection.dart' as di;
import '../../domain/entities/list_item_entity.dart' as entities;
import '../../domain/usecases/add_item_to_list_usecase.dart';
import '../../domain/usecases/get_list_items_usecase.dart';
import '../../domain/usecases/remove_item_from_list_usecase.dart';
import '../../domain/usecases/toggle_item_completion_usecase.dart';
import '../../domain/usecases/update_list_item_usecase.dart';

part 'list_items_provider.g.dart';

/// Provider for use cases (dependencies)
@riverpod
GetListItemsUseCase getListItemsUseCase(Ref ref) {
  return di.getIt<GetListItemsUseCase>();
}

@riverpod
AddItemToListUseCase addItemToListUseCase(Ref ref) {
  return di.getIt<AddItemToListUseCase>();
}

@riverpod
UpdateListItemUseCase updateListItemUseCase(Ref ref) {
  return di.getIt<UpdateListItemUseCase>();
}

@riverpod
RemoveItemFromListUseCase removeItemFromListUseCase(Ref ref) {
  return di.getIt<RemoveItemFromListUseCase>();
}

@riverpod
ToggleItemCompletionUseCase toggleItemCompletionUseCase(Ref ref) {
  return di.getIt<ToggleItemCompletionUseCase>();
}

/// Main ListItems Notifier with Riverpod code generation
/// Manages list items for a specific list
@riverpod
class ListItemsNotifier extends _$ListItemsNotifier {
  @override
  Future<List<entities.ListItemEntity>> build(String listId) async {
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
    final currentListId = state.value?.first.listId ?? listId;
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
      final result =
          await ref.read(updateListItemUseCaseProvider).call(item);

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
@riverpod
int pendingItemsCount(Ref ref, String listId) {
  final itemsAsync = ref.watch(listItemsProvider(listId));

  return itemsAsync.when(
    data: (items) => items.where((item) => !item.isCompleted).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider for completed items count
@riverpod
int completedItemsCount(Ref ref, String listId) {
  final itemsAsync = ref.watch(listItemsProvider(listId));

  return itemsAsync.when(
    data: (items) => items.where((item) => item.isCompleted).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider for high priority items
@riverpod
List<entities.ListItemEntity> highPriorityItems(
  Ref ref,
  String listId,
) {
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
}
