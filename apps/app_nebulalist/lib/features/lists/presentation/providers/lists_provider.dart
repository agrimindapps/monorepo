import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/providers/services_providers.dart';
import '../../domain/entities/list_entity.dart';
import '../../domain/usecases/check_list_limit_usecase.dart';
import '../../domain/usecases/create_list_usecase.dart';
import '../../domain/usecases/delete_list_usecase.dart';
import '../../domain/usecases/get_lists_usecase.dart';
import '../../domain/usecases/update_list_usecase.dart';

part 'lists_provider.g.dart';

/// Provider for use cases (dependencies)
@riverpod
GetListsUseCase getListsUseCase(GetListsUseCaseRef ref) {
  return di.getIt<GetListsUseCase>();
}

@riverpod
CreateListUseCase createListUseCase(CreateListUseCaseRef ref) {
  return di.getIt<CreateListUseCase>();
}

@riverpod
UpdateListUseCase updateListUseCase(UpdateListUseCaseRef ref) {
  return di.getIt<UpdateListUseCase>();
}

@riverpod
DeleteListUseCase deleteListUseCase(DeleteListUseCaseRef ref) {
  return di.getIt<DeleteListUseCase>();
}

@riverpod
CheckListLimitUseCase checkListLimitUseCase(CheckListLimitUseCaseRef ref) {
  return di.getIt<CheckListLimitUseCase>();
}

/// Main Lists Notifier with Riverpod code generation
/// Manages lists state with AsyncValue for loading/error/data states
@riverpod
class ListsNotifier extends _$ListsNotifier {
  @override
  Future<List<ListEntity>> build() async {
    // Load initial lists
    final result = await ref.read(getListsUseCaseProvider).call();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (lists) => lists,
    );
  }

  /// Create a new list
  Future<void> createList({
    required String name,
    String description = '',
    List<String> tags = const [],
    String category = 'outros',
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await ref.read(createListUseCaseProvider).call(
            name: name,
            description: description,
            tags: tags,
            category: category,
          );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (createdList) async {
          // Track analytics (fire-and-forget)
          ref.read(appAnalyticsServiceProvider).logListCreated(
                listId: createdList.id,
                category: category,
              );

          // Reload lists after creation
          final getResult = await ref.read(getListsUseCaseProvider).call();
          return getResult.fold(
            (failure) => throw Exception(failure.message),
            (lists) => lists,
          );
        },
      );
    });
  }

  /// Update an existing list
  Future<void> updateList(ListEntity list) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await ref.read(updateListUseCaseProvider).call(list);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (updatedList) {
          // Track analytics (fire-and-forget)
          ref.read(appAnalyticsServiceProvider).logListUpdated(
                listId: updatedList.id,
              );

          // Update list in current state
          final currentLists = state.value ?? [];
          return currentLists.map((l) {
            return l.id == updatedList.id ? updatedList : l;
          }).toList();
        },
      );
    });
  }

  /// Delete a list (soft delete - archive)
  Future<void> deleteList(String listId, {bool hardDelete = false}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(deleteListUseCaseProvider)
          .call(listId, hardDelete: hardDelete);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) {
          // Track analytics (fire-and-forget)
          ref.read(appAnalyticsServiceProvider).logListDeleted(
                listId: listId,
                hardDelete: hardDelete,
              );

          // Remove from current state
          final currentLists = state.value ?? [];
          return currentLists.where((l) => l.id != listId).toList();
        },
      );
    });
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(ListEntity list) async {
    final updatedList = ListEntity(
      id: list.id,
      name: list.name,
      ownerId: list.ownerId,
      description: list.description,
      tags: list.tags,
      category: list.category,
      isFavorite: !list.isFavorite,
      isArchived: list.isArchived,
      createdAt: list.createdAt,
      updatedAt: DateTime.now(),
      shareToken: list.shareToken,
      isShared: list.isShared,
      archivedAt: list.archivedAt,
      itemCount: list.itemCount,
      completedCount: list.completedCount,
    );

    // Track analytics before updating (fire-and-forget)
    ref.read(appAnalyticsServiceProvider).logListFavorited(
          listId: list.id,
          isFavorite: updatedList.isFavorite,
        );

    await updateList(updatedList);
  }

  /// Refresh lists
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Provider for filtered lists (favorites only)
@riverpod
List<ListEntity> favoriteLists(FavoriteListsRef ref) {
  final listsAsync = ref.watch(listsNotifierProvider);

  return listsAsync.when(
    data: (lists) => lists.where((l) => l.isFavorite).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for lists count
@riverpod
int listsCount(ListsCountRef ref) {
  final listsAsync = ref.watch(listsNotifierProvider);

  return listsAsync.when(
    data: (lists) => lists.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider to check if can create list (free tier limit)
@riverpod
Future<bool> canCreateList(CanCreateListRef ref) async {
  final result = await ref.read(checkListLimitUseCaseProvider).call();

  return result.fold(
    (failure) => false,
    (canCreate) => canCreate,
  );
}
