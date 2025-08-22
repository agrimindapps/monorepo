import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection_container.dart' as di;
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/get_subtasks.dart';
import '../providers/task_providers.dart';

// Provider para buscar subtasks de uma tarefa específica
final subtasksProvider = FutureProvider.family<List<TaskEntity>, String>((ref, parentTaskId) async {
  final getSubtasks = di.sl<GetSubtasks>();
  
  final result = await getSubtasks(GetSubtasksParams(parentTaskId: parentTaskId));
  
  return result.fold(
    (failure) => throw failure,
    (subtasks) => subtasks,
  );
});

// Provider para notifier de subtasks (reutiliza o TaskNotifier)
final subtaskNotifierProvider = taskNotifierProvider;