import 'package:flutter/material.dart';
import '../../domain/task_entity.dart';

class TaskListItem extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;

  const TaskListItem({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) {
            // Handle in parent or through a callback
          },
        ),
        title: Text(
          task.title,
          style: task.isCompleted
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: task.description != null
            ? Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: task.dueDate != null
            ? Icon(
                Icons.calendar_today,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
      ),
    );
  }
}
