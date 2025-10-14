import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../core/enums/task_filter.dart';
import '../../features/tasks/domain/task_entity.dart';
import '../../features/tasks/presentation/providers/task_notifier.dart';

class TaskListWidget extends ConsumerWidget {
  final void Function(TaskEntity)? onTaskTap;
  final TaskFilter taskFilter;
  final String? selectedTag;
  final bool enableReorder;

  const TaskListWidget({
    super.key,
    this.onTaskTap,
    this.taskFilter = TaskFilter.all,
    this.selectedTag,
    this.enableReorder = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(taskNotifierProvider);

    return tasksState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text('Erro ao carregar tarefas'),
                const SizedBox(height: 8),
                Text(error.toString(), style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(taskNotifierProvider),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
      data: (tasks) {
        final filteredTasks = _filterTasks(tasks);

        if (filteredTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.task_alt, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  tasks.isEmpty
                      ? 'Nenhuma tarefa encontrada'
                      : 'Nenhuma tarefa corresponde aos filtros',
                ),
                Text(
                  tasks.isEmpty
                      ? 'Toque no + para criar sua primeira tarefa'
                      : 'Tente ajustar os filtros no menu lateral',
                ),
              ],
            ),
          );
        }

        return enableReorder
            ? ReorderableListView.builder(
              itemCount: filteredTasks.length,
              onReorder:
                  (oldIndex, newIndex) =>
                      _onReorder(ref, filteredTasks, oldIndex, newIndex),
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return _buildTaskCard(context, ref, task, index);
              },
            )
            : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return _buildTaskCard(context, ref, task, index);
              },
            );
      },
    );
  }

  List<TaskEntity> _filterTasks(List<TaskEntity> tasks) {
    List<TaskEntity> filtered = List.from(tasks);
    if (selectedTag != null && selectedTag!.isNotEmpty) {
      filtered =
          filtered.where((task) => task.tags.contains(selectedTag)).toList();
    }
    switch (taskFilter) {
      case TaskFilter.all:
        break;
      case TaskFilter.today:
        filtered = filtered.where((task) => task.isDueToday).toList();
        break;
      case TaskFilter.overdue:
        filtered = filtered.where((task) => task.isOverdue).toList();
        break;
      case TaskFilter.starred:
        filtered = filtered.where((task) => task.isStarred).toList();
        break;
      case TaskFilter.week:
        filtered = filtered.where((task) => task.isDueThisWeek).toList();
        break;
    }

    return filtered;
  }

  Widget _buildTaskCard(
    BuildContext context,
    WidgetRef ref,
    TaskEntity task,
    int index,
  ) {
    return Card(
      key: ValueKey(task.id), // Key necessária para ReorderableListView
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (enableReorder) Icon(Icons.drag_handle, color: Colors.grey[400]),
            Checkbox(
              value: task.status == TaskStatus.completed,
              onChanged: (value) {
                final newStatus =
                    value == true ? TaskStatus.completed : TaskStatus.pending;
                final updatedTask = task.copyWith(
                  status: newStatus,
                  updatedAt: DateTime.now(),
                );
                ref.read(taskNotifierProvider.notifier).updateTask(updatedTask);
              },
            ),
          ],
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration:
                task.status == TaskStatus.completed
                    ? TextDecoration.lineThrough
                    : null,
          ),
        ),
        subtitle: task.description != null ? Text(task.description!) : null,
        trailing: IconButton(
          icon: Icon(
            task.isStarred ? Icons.star : Icons.star_border,
            color: task.isStarred ? Colors.amber : null,
          ),
          onPressed: () {
            final updatedTask = task.copyWith(
              isStarred: !task.isStarred,
              updatedAt: DateTime.now(),
            );
            ref.read(taskNotifierProvider.notifier).updateTask(updatedTask);
          },
        ),
        onTap: () {
          if (onTaskTap != null) {
            onTaskTap!(task);
          }
        },
      ),
    );
  }

  void _onReorder(
    WidgetRef ref,
    List<TaskEntity> tasks,
    int oldIndex,
    int newIndex,
  ) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final reorderedTasks = List<TaskEntity>.from(tasks);
    final movedTask = reorderedTasks.removeAt(oldIndex);
    reorderedTasks.insert(newIndex, movedTask);
    final taskIds = reorderedTasks.map((task) => task.id).toList();
    ref.read(taskNotifierProvider.notifier).reorderTasks(taskIds);
  }
}
