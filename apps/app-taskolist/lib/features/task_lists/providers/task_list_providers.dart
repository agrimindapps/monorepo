import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/auth_providers.dart';
import '../../tasks/data/task_list_firebase_datasource.dart';
import '../../tasks/data/task_list_firebase_datasource_impl.dart';
import '../../tasks/data/task_list_repository_impl.dart';
import '../../tasks/domain/task_list_entity.dart';
import '../../tasks/domain/task_list_repository.dart';

part 'task_list_providers.g.dart';

// ============================================================================
// DATASOURCES
// ============================================================================

@riverpod
TaskListFirebaseDatasource taskListFirebaseDatasource(
  TaskListFirebaseDatasourceRef ref,
) {
  final userId = ref.watch(currentUserIdProvider);
  return TaskListFirebaseDatasourceImpl(
    firestore: FirebaseFirestore.instance,
    userId: userId ?? '',
  );
}

// ============================================================================
// REPOSITORIES
// ============================================================================

@riverpod
TaskListRepository taskListRepository(TaskListRepositoryRef ref) {
  return TaskListRepositoryImpl(
    remoteDatasource: ref.watch(taskListFirebaseDatasourceProvider),
  );
}

// ============================================================================
// USE CASES / BUSINESS LOGIC
// ============================================================================

/// Stream de todas as listas ativas do usuário (não arquivadas)
@riverpod
Stream<List<TaskListEntity>> taskLists(TaskListsRef ref) {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(taskListRepositoryProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  return repository.watchTaskLists(
    userId: userId,
    isArchived: false,
  );
}

/// Stream de listas arquivadas
@riverpod
Stream<List<TaskListEntity>> archivedTaskLists(ArchivedTaskListsRef ref) {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(taskListRepositoryProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  return repository.watchTaskLists(
    userId: userId,
    isArchived: true,
  );
}

/// Busca uma lista específica por ID
@riverpod
Future<TaskListEntity?> taskListById(
  TaskListByIdRef ref,
  String listId,
) async {
  final repository = ref.watch(taskListRepositoryProvider);
  final result = await repository.getTaskList(listId);

  return result.fold(
    (failure) => null,
    (taskList) => taskList,
  );
}

/// Cria uma nova lista de tarefas
@riverpod
class CreateTaskList extends _$CreateTaskList {
  @override
  FutureOr<void> build() {}

  Future<String?> call(TaskListEntity taskList) async {
    state = const AsyncLoading();

    final repository = ref.read(taskListRepositoryProvider);
    final result = await repository.createTaskList(taskList);

    state = await AsyncValue.guard(() async {
      result.fold(
        (failure) => throw failure,
        (id) => id,
      );
    });

    return result.fold(
      (failure) => null,
      (id) => id,
    );
  }
}

/// Atualiza uma lista existente
@riverpod
class UpdateTaskList extends _$UpdateTaskList {
  @override
  FutureOr<void> build() {}

  Future<bool> call(TaskListEntity taskList) async {
    state = const AsyncLoading();

    final repository = ref.read(taskListRepositoryProvider);
    final result = await repository.updateTaskList(taskList);

    state = await AsyncValue.guard(() async {
      result.fold(
        (failure) => throw failure,
        (_) => _,
      );
    });

    return result.isRight();
  }
}

/// Deleta uma lista
@riverpod
class DeleteTaskList extends _$DeleteTaskList {
  @override
  FutureOr<void> build() {}

  Future<bool> call(String listId) async {
    state = const AsyncLoading();

    final repository = ref.read(taskListRepositoryProvider);
    final result = await repository.deleteTaskList(listId);

    state = await AsyncValue.guard(() async {
      result.fold(
        (failure) => throw failure,
        (_) => _,
      );
    });

    return result.isRight();
  }
}

/// Compartilha uma lista com outros usuários
@riverpod
class ShareTaskList extends _$ShareTaskList {
  @override
  FutureOr<void> build() {}

  Future<bool> call(String listId, List<String> memberIds) async {
    state = const AsyncLoading();

    final repository = ref.read(taskListRepositoryProvider);
    final result = await repository.shareTaskList(listId, memberIds);

    state = await AsyncValue.guard(() async {
      result.fold(
        (failure) => throw failure,
        (_) => _,
      );
    });

    return result.isRight();
  }
}

/// Arquiva uma lista
@riverpod
class ArchiveTaskList extends _$ArchiveTaskList {
  @override
  FutureOr<void> build() {}

  Future<bool> call(String listId) async {
    state = const AsyncLoading();

    final repository = ref.read(taskListRepositoryProvider);
    final result = await repository.archiveTaskList(listId);

    state = await AsyncValue.guard(() async {
      result.fold(
        (failure) => throw failure,
        (_) => _,
      );
    });

    return result.isRight();
  }
}
