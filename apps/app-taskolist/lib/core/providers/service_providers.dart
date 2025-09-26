import 'package:core/core.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/update_task.dart';
import '../../infrastructure/services/notification_service.dart';
import '../di/injection_container.dart' as di;

/// Provider para UpdateTask use case
final updateTaskProvider = Provider<UpdateTask>((ref) {
  return di.sl<UpdateTask>();
});

/// Provider para GetTasks use case  
final getTasksProvider = Provider<GetTasks>((ref) {
  return di.sl<GetTasks>();
});

/// Provider simplificado para tasks (usando FutureProvider)
final tasksProvider = FutureProvider<List<TaskEntity>>((ref) async {
  final getTasks = ref.read(getTasksProvider);
  final result = await getTasks(const GetTasksParams());
  
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (tasks) => tasks,
  );
});

/// Provider para NotificationService
final notificationServiceProvider = Provider<TaskManagerNotificationService>((ref) {
  return di.sl<TaskManagerNotificationService>();
});