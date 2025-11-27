import 'package:core/core.dart' hide Column;

import '../../features/tasks/domain/get_tasks.dart';
import '../../features/tasks/domain/task_entity.dart';
import '../../features/tasks/domain/update_task.dart';
import '../../features/tasks/providers/task_providers.dart';
import 'core_providers.dart';

/// Provider simplificado para tasks (usando FutureProvider)
final tasksProvider = FutureProvider<List<TaskEntity>>((ref) async {
  final getTasks = ref.read(getTasksProvider);
  final result = await getTasks(const GetTasksParams());

  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (tasks) => tasks,
  );
});

/// Provider para UpdateTask (backward compatibility)
final updateTaskUseCaseProvider = Provider<UpdateTask>((ref) {
  return ref.watch(updateTaskProvider);
});
