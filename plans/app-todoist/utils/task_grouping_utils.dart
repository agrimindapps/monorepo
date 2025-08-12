// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../constants/timeout_constants.dart';
import '../models/task_grouping.dart';
import '../models/task_model.dart';

class TaskGroupingUtils {
  static List<TaskGroup> groupTasks(List<Task> tasks, TaskGrouping grouping) {
    switch (grouping) {
      case TaskGrouping.none:
        return [
          TaskGroup(
            id: 'all',
            title: 'Todas as Tarefas',
            subtitle: '${tasks.length} tarefa${tasks.length != 1 ? 's' : ''}',
            tasks: tasks,
          ),
        ];
      case TaskGrouping.date:
        return _groupByDate(tasks);
      case TaskGrouping.priority:
        return _groupByPriority(tasks);
      case TaskGrouping.status:
        return _groupByStatus(tasks);
      case TaskGrouping.tags:
        return _groupByTags(tasks);
    }
  }

  static List<TaskGroup> _groupByDate(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(TimeoutConstants.oneDay);
    final weekFromNow = today.add(TimeoutConstants.oneWeek);

    final Map<String, List<Task>> groups = {
      'overdue': [],
      'today': [],
      'tomorrow': [],
      'this_week': [],
      'later': [],
      'no_date': [],
    };

    for (final task in tasks) {
      if (task.dueDate == null) {
        groups['no_date']!.add(task);
      } else {
        final dueDate = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );

        if (dueDate.isBefore(today)) {
          groups['overdue']!.add(task);
        } else if (dueDate.isAtSameMomentAs(today)) {
          groups['today']!.add(task);
        } else if (dueDate.isAtSameMomentAs(tomorrow)) {
          groups['tomorrow']!.add(task);
        } else if (dueDate.isBefore(weekFromNow)) {
          groups['this_week']!.add(task);
        } else {
          groups['later']!.add(task);
        }
      }
    }

    final result = <TaskGroup>[];

    if (groups['overdue']!.isNotEmpty) {
      result.add(TaskGroup(
        id: 'overdue',
        title: 'Vencidas',
        subtitle:
            '${groups['overdue']!.length} tarefa${groups['overdue']!.length != 1 ? 's' : ''}',
        icon: Icons.schedule,
        color: Colors.red,
        tasks: groups['overdue']!,
        sortOrder: 0,
      ));
    }

    if (groups['today']!.isNotEmpty) {
      result.add(TaskGroup(
        id: 'today',
        title: 'Hoje',
        subtitle: DateFormat('EEEE, d MMM', 'pt_BR').format(today),
        icon: Icons.today,
        color: const Color(0xFF4CAF50),
        tasks: groups['today']!,
        sortOrder: 1,
      ));
    }

    if (groups['tomorrow']!.isNotEmpty) {
      result.add(TaskGroup(
        id: 'tomorrow',
        title: 'Amanhã',
        subtitle: DateFormat('EEEE, d MMM', 'pt_BR').format(tomorrow),
        icon: Icons.today_outlined,
        color: const Color(0xFF2196F3),
        tasks: groups['tomorrow']!,
        sortOrder: 2,
      ));
    }

    if (groups['this_week']!.isNotEmpty) {
      result.add(TaskGroup(
        id: 'this_week',
        title: 'Esta Semana',
        subtitle:
            '${groups['this_week']!.length} tarefa${groups['this_week']!.length != 1 ? 's' : ''}',
        icon: Icons.date_range,
        color: const Color(0xFF3A5998),
        tasks: groups['this_week']!,
        sortOrder: 3,
      ));
    }

    if (groups['later']!.isNotEmpty) {
      result.add(TaskGroup(
        id: 'later',
        title: 'Mais Tarde',
        subtitle:
            '${groups['later']!.length} tarefa${groups['later']!.length != 1 ? 's' : ''}',
        icon: Icons.schedule_send,
        color: const Color(0xFF666666),
        tasks: groups['later']!,
        sortOrder: 4,
      ));
    }

    if (groups['no_date']!.isNotEmpty) {
      result.add(TaskGroup(
        id: 'no_date',
        title: 'Sem Data',
        subtitle:
            '${groups['no_date']!.length} tarefa${groups['no_date']!.length != 1 ? 's' : ''}',
        icon: Icons.event_busy,
        color: const Color(0xFF999999),
        tasks: groups['no_date']!,
        sortOrder: 5,
      ));
    }

    return result;
  }

  static List<TaskGroup> _groupByPriority(List<Task> tasks) {
    final Map<TaskPriority, List<Task>> groups = {
      TaskPriority.urgent: [],
      TaskPriority.high: [],
      TaskPriority.medium: [],
      TaskPriority.low: [],
    };

    for (final task in tasks) {
      groups[task.priority]!.add(task);
    }

    final result = <TaskGroup>[];

    if (groups[TaskPriority.urgent]!.isNotEmpty) {
      result.add(TaskGroup(
        id: 'urgent',
        title: 'Urgente',
        subtitle:
            '${groups[TaskPriority.urgent]!.length} tarefa${groups[TaskPriority.urgent]!.length != 1 ? 's' : ''}',
        icon: Icons.priority_high,
        color: Colors.red,
        tasks: groups[TaskPriority.urgent]!,
        sortOrder: 0,
      ));
    }

    if (groups[TaskPriority.high]!.isNotEmpty) {
      result.add(TaskGroup(
        id: 'high',
        title: 'Alta',
        subtitle:
            '${groups[TaskPriority.high]!.length} tarefa${groups[TaskPriority.high]!.length != 1 ? 's' : ''}',
        icon: Icons.flag,
        color: Colors.orange,
        tasks: groups[TaskPriority.high]!,
        sortOrder: 1,
      ));
    }

    if (groups[TaskPriority.medium]!.isNotEmpty) {
      result.add(TaskGroup(
        id: 'medium',
        title: 'Média',
        subtitle:
            '${groups[TaskPriority.medium]!.length} tarefa${groups[TaskPriority.medium]!.length != 1 ? 's' : ''}',
        icon: Icons.flag,
        color: Colors.yellow[700],
        tasks: groups[TaskPriority.medium]!,
        sortOrder: 2,
      ));
    }

    if (groups[TaskPriority.low]!.isNotEmpty) {
      result.add(TaskGroup(
        id: 'low',
        title: 'Baixa',
        subtitle:
            '${groups[TaskPriority.low]!.length} tarefa${groups[TaskPriority.low]!.length != 1 ? 's' : ''}',
        icon: Icons.flag,
        color: Colors.green,
        tasks: groups[TaskPriority.low]!,
        sortOrder: 3,
      ));
    }

    return result;
  }

  static List<TaskGroup> _groupByStatus(List<Task> tasks) {
    final Map<String, List<Task>> groups = {
      'pending': [],
      'completed': [],
      'starred': [],
    };

    for (final task in tasks) {
      if (task.isStarred) {
        groups['starred']!.add(task);
      } else if (task.isCompleted) {
        groups['completed']!.add(task);
      } else {
        groups['pending']!.add(task);
      }
    }

    final result = <TaskGroup>[];

    if (groups['starred']!.isNotEmpty) {
      result.add(TaskGroup(
        id: 'starred',
        title: 'Favoritas',
        subtitle:
            '${groups['starred']!.length} tarefa${groups['starred']!.length != 1 ? 's' : ''}',
        icon: Icons.star,
        color: const Color(0xFFFFB84D),
        tasks: groups['starred']!,
        sortOrder: 0,
      ));
    }

    if (groups['pending']!.isNotEmpty) {
      result.add(TaskGroup(
        id: 'pending',
        title: 'Pendentes',
        subtitle:
            '${groups['pending']!.length} tarefa${groups['pending']!.length != 1 ? 's' : ''}',
        icon: Icons.radio_button_unchecked,
        color: const Color(0xFF2196F3),
        tasks: groups['pending']!,
        sortOrder: 1,
      ));
    }

    if (groups['completed']!.isNotEmpty) {
      result.add(TaskGroup(
        id: 'completed',
        title: 'Concluídas',
        subtitle:
            '${groups['completed']!.length} tarefa${groups['completed']!.length != 1 ? 's' : ''}',
        icon: Icons.check_circle_outline,
        color: const Color(0xFF4CAF50),
        tasks: groups['completed']!,
        sortOrder: 2,
      ));
    }

    return result;
  }

  static List<TaskGroup> _groupByTags(List<Task> tasks) {
    final Map<String, List<Task>> groups = {};
    final List<Task> noTagTasks = [];

    for (final task in tasks) {
      if (task.tags.isEmpty) {
        noTagTasks.add(task);
      } else {
        for (final tag in task.tags) {
          groups[tag] ??= [];
          groups[tag]!.add(task);
        }
      }
    }

    final result = <TaskGroup>[];
    final sortedTags = groups.keys.toList()..sort();

    for (int i = 0; i < sortedTags.length; i++) {
      final tag = sortedTags[i];
      result.add(TaskGroup(
        id: 'tag_$tag',
        title: tag,
        subtitle:
            '${groups[tag]!.length} tarefa${groups[tag]!.length != 1 ? 's' : ''}',
        icon: Icons.label,
        color: _getTagColor(i),
        tasks: groups[tag]!,
        sortOrder: i,
      ));
    }

    if (noTagTasks.isNotEmpty) {
      result.add(TaskGroup(
        id: 'no_tags',
        title: 'Sem Tags',
        subtitle:
            '${noTagTasks.length} tarefa${noTagTasks.length != 1 ? 's' : ''}',
        icon: Icons.label_off,
        color: const Color(0xFF999999),
        tasks: noTagTasks,
        sortOrder: sortedTags.length,
      ));
    }

    return result;
  }

  static Color _getTagColor(int index) {
    final colors = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFF44336), // Red
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFFEB3B), // Yellow
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFFE91E63), // Pink
    ];
    return colors[index % colors.length];
  }
}
