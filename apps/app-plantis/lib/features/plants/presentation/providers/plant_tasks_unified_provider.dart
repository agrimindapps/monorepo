import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/notifiers/tasks_notifier.dart';

/// Provider that returns tasks filtered by plantId from the unified Task system.
///
/// This replaces the old PlantTaskNotifier for plant details, ensuring
/// that the same tasks shown in TasksListPage are also shown in PlantDetailsView.
final plantTasksUnifiedProvider = Provider.family<List<Task>, String>((
  ref,
  plantId,
) {
  final tasksState = ref.watch(tasksNotifierProvider);

  return tasksState.when(
    data: (state) {
      return state.allTasks
          .where((Task task) => task.plantId == plantId && !task.isDeleted)
          .toList()
        ..sort((Task a, Task b) => a.dueDate.compareTo(b.dueDate));
    },
    loading: () => <Task>[],
    error: (_, __) => <Task>[],
  );
});

/// Provider that returns pending tasks count for a plant
final plantPendingTasksCountProvider = Provider.family<int, String>((
  ref,
  plantId,
) {
  final tasks = ref.watch(plantTasksUnifiedProvider(plantId));
  return tasks
      .where(
        (Task task) =>
            task.status == TaskStatus.pending ||
            task.status == TaskStatus.overdue,
      )
      .length;
});

/// Provider that returns completed tasks for a plant (for history)
final plantCompletedTasksProvider = Provider.family<List<Task>, String>((
  ref,
  plantId,
) {
  final tasks = ref.watch(plantTasksUnifiedProvider(plantId));
  return tasks
      .where((Task task) => task.status == TaskStatus.completed)
      .toList()
    ..sort(
      (Task a, Task b) =>
          (b.completedAt ?? b.dueDate).compareTo(a.completedAt ?? a.dueDate),
    );
});

/// Provider that returns pending tasks for a plant
final plantPendingTasksProvider = Provider.family<List<Task>, String>((
  ref,
  plantId,
) {
  final tasks = ref.watch(plantTasksUnifiedProvider(plantId));
  return tasks
      .where(
        (Task task) =>
            task.status == TaskStatus.pending ||
            task.status == TaskStatus.overdue,
      )
      .toList()
    ..sort((Task a, Task b) => a.dueDate.compareTo(b.dueDate));
});
