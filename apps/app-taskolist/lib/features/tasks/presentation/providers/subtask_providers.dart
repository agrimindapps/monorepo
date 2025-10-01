import 'package:core/core.dart' hide getIt;

import '../../../../core/di/injection.dart' as di;
import '../../domain/task_entity.dart';
import '../../domain/get_subtasks.dart';
import 'task_providers.dart';

// Provider para buscar subtasks de uma tarefa específica
final subtasksProvider = FutureProvider.family<List<TaskEntity>, String>((ref, parentTaskId) async {
  final getSubtasks = di.getIt<GetSubtasks>();
  
  final result = await getSubtasks(GetSubtasksParams(parentTaskId: parentTaskId));
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (subtasks) => subtasks,
  );
});

// Provider para notifier de subtasks (reutiliza o TaskNotifier)
final subtaskNotifierProvider = taskNotifierProvider;