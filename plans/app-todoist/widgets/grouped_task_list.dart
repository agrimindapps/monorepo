// Flutter imports:
import 'package:flutter/material.dart';

import '../models/task_grouping.dart';
// Project imports:
import '../models/task_model.dart';
import '../widgets/task_widget.dart';

class GroupedTaskList extends StatelessWidget {
  final List<TaskGroup> groups;
  final Function(Task task) onTaskTap;
  final Function(String taskId, bool completed) onCompletedChanged;
  final Function(String taskId, bool starred) onStarToggle;

  const GroupedTaskList({
    super.key,
    required this.groups,
    required this.onTaskTap,
    required this.onCompletedChanged,
    required this.onStarToggle,
  });

  // Widgets const para performance
  static const Widget _spacerWidget = SizedBox(height: 24);
  
  static const Widget _emptyGroupsWidget = Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.task_alt,
          size: 64,
          color: Color(0xFFCCCCCC),
        ),
        SizedBox(height: 16),
        Text(
          'Nenhuma tarefa encontrada',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C2C2C),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Tente ajustar os filtros ou adicionar uma nova tarefa.',
          style: TextStyle(color: Color(0xFF666666)),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return _emptyGroupsWidget;
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];
        return _buildGroupSection(context, group, groupIndex);
      },
    );
  }

  Widget _buildGroupSection(
      BuildContext context, TaskGroup group, int groupIndex) {
    final tasks = group.tasks.cast<Task>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group Header
        _buildGroupHeader(group),

        // Tasks in this group
        ...tasks.map((task) {
          return TaskWidget(
            task: task,
            onTap: () => onTaskTap(task),
            onCompletedChanged: (value) =>
                onCompletedChanged(task.id, value ?? false),
            onStarToggle: () => onStarToggle(task.id, !task.isStarred),
          );
        }),

        // Add spacing between groups, but not after the last group
        if (groupIndex < groups.length - 1) _spacerWidget,
      ],
    );
  }

  Widget _buildGroupHeader(TaskGroup group) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: group.color?.withValues(alpha: 0.05) ?? Colors.grey[50],
        border: Border(
          left: BorderSide(
            color: group.color ?? Colors.grey[300]!,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          if (group.icon != null) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: group.color?.withValues(alpha: 0.1) ?? Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                group.icon,
                size: 16,
                color: group.color ?? Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: group.color?.withValues(alpha: 0.9) ??
                        const Color(0xFF2C2C2C),
                  ),
                ),
                if (group.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    group.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: group.color?.withValues(alpha: 0.7) ??
                          const Color(0xFF666666),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Task count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: group.color?.withValues(alpha: 0.1) ?? Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: group.color?.withValues(alpha: 0.3) ?? Colors.grey[300]!,
                width: 0.5,
              ),
            ),
            child: Text(
              '${group.tasks.length}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: group.color ?? Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
