import 'package:flutter/material.dart';
import '../../domain/entities/task.dart' as task_entity;

class TasksListView extends StatelessWidget {
  final List<task_entity.Task> tasks;
  final Function(String taskId) onTaskComplete;
  final Function(task_entity.Task task) onTaskTap;

  const TasksListView({
    super.key,
    required this.tasks,
    required this.onTaskComplete,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskListItem(
            task: task,
            onComplete: () => onTaskComplete(task.id),
            onTap: () => onTaskTap(task),
          );
        },
      ),
    );
  }
}

class TaskListItem extends StatelessWidget {
  final task_entity.Task task;
  final VoidCallback onComplete;
  final VoidCallback onTap;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.status == task_entity.TaskStatus.pending)
                GestureDetector(
                  onTap: onComplete,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getPriorityColor(task.priority),
                        width: 2,
                      ),
                    ),
                    child:
                        task.status == task_entity.TaskStatus.completed
                            ? Icon(
                              Icons.check,
                              size: 16,
                              color: _getPriorityColor(task.priority),
                            )
                            : null,
                  ),
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                ),

              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration:
                            task.status == task_entity.TaskStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                        color:
                            task.status == task_entity.TaskStatus.completed
                                ? theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                )
                                : null,
                      ),
                    ),

                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.local_florist,
                          size: 16,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            task.type.displayName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              task.isOverdue
                                  ? Icons.warning
                                  : task.isDueToday
                                  ? Icons.today
                                  : Icons.schedule,
                              size: 16,
                              color:
                                  task.isOverdue
                                      ? Colors.red
                                      : task.isDueToday
                                      ? Colors.orange
                                      : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(task.dueDate),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    task.isOverdue
                                        ? Colors.red
                                        : task.isDueToday
                                        ? Colors.orange
                                        : theme.colorScheme.onSurface
                                            .withValues(alpha: 0.7),
                                fontWeight:
                                    task.isOverdue || task.isDueToday
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(
                              task.priority,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getPriorityColor(
                                task.priority,
                              ).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            task.priority.displayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getPriorityColor(task.priority),
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(task_entity.TaskPriority priority) {
    switch (priority) {
      case task_entity.TaskPriority.urgent:
        return Colors.red.shade700;
      case task_entity.TaskPriority.high:
        return Colors.orange.shade600;
      case task_entity.TaskPriority.medium:
        return Colors.blue.shade600;
      case task_entity.TaskPriority.low:
        return Colors.green.shade600;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Hoje';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Amanhã';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Ontem';
    } else {
      final difference = taskDate.difference(today).inDays;
      if (difference > 0 && difference <= 7) {
        return 'Em $difference dias';
      } else if (difference < 0 && difference >= -7) {
        return '${-difference} dias atrás';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }
}
