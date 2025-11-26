import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../domain/entities/item_master_entity.dart';

/// Main ItemMasters Notifier with pure Riverpod
/// Manages ItemMaster bank state with AsyncValue
class ItemMastersNotifier
    extends AutoDisposeAsyncNotifier<List<ItemMasterEntity>> {
  @override
  Future<List<ItemMasterEntity>> build() async {
    // Load initial ItemMasters (sorted by usage count)
    final result = await ref.read(getItemMastersUseCaseProvider).call();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (items) => items,
    );
  }

  /// Create a new ItemMaster
  Future<void> createItemMaster({
    required String name,
    String description = '',
    List<String> tags = const [],
    String category = 'outros',
    double? estimatedPrice,
    String? preferredBrand,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final itemMaster = ItemMasterEntity(
        id: '', // Will be set by use case
        ownerId: '', // Will be set by use case
        name: name,
        description: description,
        tags: tags,
        category: category,
        estimatedPrice: estimatedPrice,
        preferredBrand: preferredBrand,
        usageCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result =
          await ref.read(createItemMasterUseCaseProvider).call(itemMaster);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (createdItem) async {
          // Track analytics (fire-and-forget)
          ref.read(appAnalyticsServiceProvider).logItemMasterCreated(
                itemId: createdItem.id,
                category: category,
              );

          // Reload ItemMasters after creation
          final getResult =
              await ref.read(getItemMastersUseCaseProvider).call();
          return getResult.fold(
            (failure) => throw Exception(failure.message),
            (items) => items,
          );
        },
      );
    });
  }

  /// Update an existing ItemMaster
  Future<void> updateItemMaster(ItemMasterEntity itemMaster) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result =
          await ref.read(updateItemMasterUseCaseProvider).call(itemMaster);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (updatedItem) {
          // Track analytics (fire-and-forget)
          ref.read(appAnalyticsServiceProvider).logItemMasterUpdated(
                itemId: updatedItem.id,
              );

          // Update item in current state
          final currentItems = state.value ?? [];
          return currentItems.map((item) {
            return item.id == updatedItem.id ? updatedItem : item;
          }).toList();
        },
      );
    });
  }

  /// Delete an ItemMaster
  Future<void> deleteItemMaster(String id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await ref.read(deleteItemMasterUseCaseProvider).call(id);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) {
          // Track analytics (fire-and-forget)
          ref.read(appAnalyticsServiceProvider).logItemMasterDeleted(
                itemId: id,
              );

          // Remove from current state
          final currentItems = state.value ?? [];
          return currentItems.where((item) => item.id != id).toList();
        },
      );
    });
  }

  /// Refresh ItemMasters
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Main item masters provider
final itemMastersProvider =
    AutoDisposeAsyncNotifierProvider<ItemMastersNotifier, List<ItemMasterEntity>>(
  ItemMastersNotifier.new,
);

/// Provider for ItemMasters count
final itemMastersCountProvider = Provider.autoDispose<int>((ref) {
  final itemsAsync = ref.watch(itemMastersProvider);

  return itemsAsync.when(
    data: (items) => items.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider to check if can create ItemMaster (free tier limit)
final canCreateItemMasterProvider = FutureProvider.autoDispose<bool>((ref) async {
  final result = await ref.read(checkItemLimitUseCaseProvider).call();

  return result.fold(
    (failure) => false,
    (canCreate) => canCreate,
  );
});

/// Provider for ItemMasters by category
final itemMastersByCategoryProvider = Provider.autoDispose
    .family<List<ItemMasterEntity>, String>((ref, category) {
  final itemsAsync = ref.watch(itemMastersProvider);

  return itemsAsync.when(
    data: (items) => items.where((item) => item.category == category).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
