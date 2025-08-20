import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/task_filter.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_providers.dart';

class TaskListWidget extends ConsumerWidget {
  final Function(TaskEntity)? onTaskTap;
  final TaskFilter taskFilter;
  final String? selectedTag;

  const TaskListWidget({
    super.key,
    this.onTaskTap,
    this.taskFilter = TaskFilter.all,
    this.selectedTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(taskNotifierProvider);

    return tasksState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Erro ao carregar tarefas'),
            const SizedBox(height: 8),
            Text(error.toString(), style: TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(taskNotifierProvider),
              child: Text('Tentar novamente'),
            ),
          ],
        ),
      ),
      data: (tasks) {
        // Aplicar filtros
        final filteredTasks = _filterTasks(tasks);
        
        if (filteredTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 48, color: Colors.grey),
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

        return ListView.builder(
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Checkbox(
                  value: task.status == TaskStatus.completed,
                  onChanged: (value) {
                    final newStatus = value == true 
                      ? TaskStatus.completed 
                      : TaskStatus.pending;
                    final updatedTask = task.copyWith(
                      status: newStatus,
                      updatedAt: DateTime.now(),
                    );
                    ref.read(taskNotifierProvider.notifier).updateTask(updatedTask);
                  },
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.status == TaskStatus.completed
                      ? TextDecoration.lineThrough
                      : null,
                  ),
                ),
                subtitle: task.description != null 
                  ? Text(task.description!)
                  : null,
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
          },
        );
      },
    );
  }

  List<TaskEntity> _filterTasks(List<TaskEntity> tasks) {
    List<TaskEntity> filtered = List.from(tasks);

    // Filtrar por tag primeiro (se especificada)
    if (selectedTag != null && selectedTag!.isNotEmpty) {
      filtered = filtered.where((task) => task.tags.contains(selectedTag!)).toList();
    }

    // Aplicar filtro de tipo
    switch (taskFilter) {
      case TaskFilter.all:
        // Não aplicar filtro adicional
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
}