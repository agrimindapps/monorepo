import 'package:core/core.dart' hide getIt, Column;

import '../../features/tasks/domain/get_tasks.dart';
import '../../features/tasks/domain/task_entity.dart';
import '../../features/tasks/domain/update_task.dart';
import '../../infrastructure/services/notification_service.dart';
import '../di/injection.dart' as di;

/// Provider para UpdateTask use case
final updateTaskProvider = Provider<UpdateTask>((ref) {
  return di.getIt<UpdateTask>();
});

/// Provider para GetTasks use case
final getTasksUseCaseProvider = Provider<GetTasks>((ref) {
  return di.getIt<GetTasks>();
});

/// Provider simplificado para tasks (usando FutureProvider)
final tasksProvider = FutureProvider<List<TaskEntity>>((ref) async {
  final getTasks = ref.read(getTasksUseCaseProvider);
  final result = await getTasks(const GetTasksParams());

  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (tasks) => tasks,
  );
});

/// Provider para NotificationService
final notificationServiceProvider = Provider<TaskManagerNotificationService>((ref) {
  return di.getIt<TaskManagerNotificationService>();
});
