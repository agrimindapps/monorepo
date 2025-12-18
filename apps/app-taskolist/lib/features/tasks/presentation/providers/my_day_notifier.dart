import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/analytics_service.dart';
import '../../domain/add_task_to_my_day.dart';
import '../../domain/clear_my_day.dart';
import '../../domain/get_my_day_suggestions.dart';
import '../../domain/get_my_day_tasks.dart';
import '../../domain/my_day_task_entity.dart';
import '../../domain/remove_task_from_my_day.dart';
import '../../domain/task_entity.dart';
import '../../domain/watch_my_day_tasks.dart';
import '../../providers/my_day_providers.dart';

part 'my_day_notifier.g.dart';

@riverpod
class MyDayNotifier extends _$MyDayNotifier {
  @override
  Future<List<MyDayTaskEntity>> build(String userId) async {
    final getMyDayTasks = ref.read(getMyDayTasksProvider);
    final result = await getMyDayTasks(GetMyDayTasksParams(userId: userId));

    return result.fold(
      (failure) => throw Exception(failure.message),
      (tasks) => tasks,
    );
  }

  Future<void> addTask(String taskId, {String source = 'manual'}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final userId = state.value?.firstOrNull?.userId ?? '';
      final addTaskToMyDay = ref.read(addTaskToMyDayProvider);
      final result = await addTaskToMyDay(
        AddTaskToMyDayParams(taskId: taskId, userId: userId),
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) async {
          // Log analytics
          final analytics = ref.read(analyticsServiceProvider);
          await analytics.logMyDayTaskAdded(taskId: taskId, source: source);

          // Recarrega a lista
          final getMyDayTasks = ref.read(getMyDayTasksProvider);
          final tasksResult = await getMyDayTasks(
            GetMyDayTasksParams(userId: userId),
          );
          return tasksResult.fold(
            (failure) => throw Exception(failure.message),
            (tasks) => tasks,
          );
        },
      );
    });
  }

  Future<void> removeTask(String taskId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final userId = state.value?.firstOrNull?.userId ?? '';
      final removeTaskFromMyDay = ref.read(removeTaskFromMyDayProvider);
      final result = await removeTaskFromMyDay(
        RemoveTaskFromMyDayParams(taskId: taskId),
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) {
          // Log analytics
          final analytics = ref.read(analyticsServiceProvider);
          analytics.logMyDayTaskRemoved(taskId: taskId);

          final currentTasks = state.value ?? [];
          return currentTasks.where((t) => t.taskId != taskId).toList();
        },
      );
    });
  }

  Future<void> clearAll() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final userId = state.value?.firstOrNull?.userId ?? '';
      final taskCount = state.value?.length ?? 0;
      
      final clearMyDay = ref.read(clearMyDayProvider);
      final result = await clearMyDay(ClearMyDayParams(userId: userId));

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) {
          // Log analytics
          final analytics = ref.read(analyticsServiceProvider);
          analytics.logMyDayCleared(taskCount: taskCount);

          return <MyDayTaskEntity>[];
        },
      );
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final userId = state.value?.firstOrNull?.userId ?? '';
      final getMyDayTasks = ref.read(getMyDayTasksProvider);
      final result = await getMyDayTasks(GetMyDayTasksParams(userId: userId));

      // Log analytics
      final analytics = ref.read(analyticsServiceProvider);
      await analytics.logMyDayRefreshed();

      return result.fold(
        (failure) => throw Exception(failure.message),
        (tasks) => tasks,
      );
    });
  }
}

/// Stream provider para Meu Dia
@riverpod
Stream<List<MyDayTaskEntity>> myDayStream(Ref ref, String userId) {
  final watchMyDayTasks = ref.watch(watchMyDayTasksProvider);
  return watchMyDayTasks(WatchMyDayTasksParams(userId: userId));
}

/// Provider para sugestões do Meu Dia
@riverpod
Future<List<TaskEntity>> myDaySuggestions(Ref ref, String userId) async {
  final getMyDaySuggestions = ref.watch(getMyDaySuggestionsProvider);
  final result = await getMyDaySuggestions(
    GetMyDaySuggestionsParams(userId: userId),
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (suggestions) => suggestions,
  );
}
