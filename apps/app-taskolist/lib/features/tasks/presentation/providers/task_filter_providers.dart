import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/auth_providers.dart';
import '../../domain/get_tasks.dart';
import '../../domain/task_entity.dart';
import '../../providers/task_providers.dart';

part 'task_filter_providers.g.dart';

/// Tipos de filtros inteligentes para o drawer
enum TaskFilterType {
  all,
  starred,
  planned,
  myDay,
  overdue,
  completed,
}

/// Notifier para o filtro atual selecionado
@riverpod
class CurrentTaskFilter extends _$CurrentTaskFilter {
  @override
  TaskFilterType build() => TaskFilterType.all;

  void setFilter(TaskFilterType filter) {
    state = filter;
  }
}

/// Provider que conta tarefas baseado no tipo de filtro
@riverpod
Future<int> filteredTaskCount(Ref ref, TaskFilterType filterType) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return 0;

  final getTasks = ref.watch(getTasksProvider);
  final result = await getTasks(GetTasksParams(userId: user.id));
  
  return result.fold(
    (failure) => 0,
    (tasks) {
      switch (filterType) {
        case TaskFilterType.all:
          return tasks.where((t) => t.status != TaskStatus.completed).length;
        case TaskFilterType.starred:
          return tasks.where((t) => t.isStarred && t.status != TaskStatus.completed).length;
        case TaskFilterType.planned:
          return tasks.where((t) => t.dueDate != null && t.status != TaskStatus.completed).length;
        case TaskFilterType.myDay:
          final today = DateTime.now();
          return tasks.where((t) {
            if (t.status == TaskStatus.completed) return false;
            if (t.dueDate == null) return false;
            return t.dueDate!.year == today.year &&
                   t.dueDate!.month == today.month &&
                   t.dueDate!.day == today.day;
          }).length;
        case TaskFilterType.overdue:
          final now = DateTime.now();
          return tasks.where((t) {
            if (t.status == TaskStatus.completed) return false;
            if (t.dueDate == null) return false;
            return t.dueDate!.isBefore(now);
          }).length;
        case TaskFilterType.completed:
          return tasks.where((t) => t.status == TaskStatus.completed).length;
      }
    },
  );
}

/// Provider que retorna as tarefas filtradas
@riverpod
Future<List<TaskEntity>> filteredTasks(Ref ref, TaskFilterType filterType) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];

  final getTasks = ref.watch(getTasksProvider);
  final result = await getTasks(GetTasksParams(userId: user.id));
  
  return result.fold(
    (failure) => <TaskEntity>[],
    (tasks) {
      switch (filterType) {
        case TaskFilterType.all:
          return tasks.where((t) => t.status != TaskStatus.completed).toList();
        case TaskFilterType.starred:
          return tasks.where((t) => t.isStarred && t.status != TaskStatus.completed).toList();
        case TaskFilterType.planned:
          return tasks.where((t) => t.dueDate != null && t.status != TaskStatus.completed).toList();
        case TaskFilterType.myDay:
          final today = DateTime.now();
          return tasks.where((t) {
            if (t.status == TaskStatus.completed) return false;
            if (t.dueDate == null) return false;
            return t.dueDate!.year == today.year &&
                   t.dueDate!.month == today.month &&
                   t.dueDate!.day == today.day;
          }).toList();
        case TaskFilterType.overdue:
          final now = DateTime.now();
          return tasks.where((t) {
            if (t.status == TaskStatus.completed) return false;
            if (t.dueDate == null) return false;
            return t.dueDate!.isBefore(now);
          }).toList();
        case TaskFilterType.completed:
          return tasks.where((t) => t.status == TaskStatus.completed).toList();
      }
    },
  );
}
