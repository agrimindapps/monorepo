// Flutter imports:
import 'package:flutter/material.dart';

/// Enum para definir diferentes tipos de agrupamento de tarefas
enum TaskGrouping {
  none,
  date,
  priority,
  status,
  tags,
}

/// Extension para fornecer propriedades e métodos adicionais ao TaskGrouping
extension TaskGroupingExtension on TaskGrouping {
  String get title {
    switch (this) {
      case TaskGrouping.none:
        return 'Sem Agrupamento';
      case TaskGrouping.date:
        return 'Agrupar por Data';
      case TaskGrouping.priority:
        return 'Agrupar por Prioridade';
      case TaskGrouping.status:
        return 'Agrupar por Status';
      case TaskGrouping.tags:
        return 'Agrupar por Tags';
    }
  }

  String get shortTitle {
    switch (this) {
      case TaskGrouping.none:
        return 'Lista';
      case TaskGrouping.date:
        return 'Data';
      case TaskGrouping.priority:
        return 'Prioridade';
      case TaskGrouping.status:
        return 'Status';
      case TaskGrouping.tags:
        return 'Tags';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskGrouping.none:
        return Icons.list;
      case TaskGrouping.date:
        return Icons.date_range;
      case TaskGrouping.priority:
        return Icons.flag;
      case TaskGrouping.status:
        return Icons.check_circle_outline;
      case TaskGrouping.tags:
        return Icons.label_outline;
    }
  }
}

class TaskGroup {
  final String id;
  final String title;
  final String subtitle;
  final IconData? icon;
  final Color? color;
  final List<dynamic> tasks; // dynamic para suportar Task ou outros tipos
  final int sortOrder;

  TaskGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    this.icon,
    this.color,
    required this.tasks,
    this.sortOrder = 0,
  });

  TaskGroup copyWith({
    String? id,
    String? title,
    String? subtitle,
    IconData? icon,
    Color? color,
    List<dynamic>? tasks,
    int? sortOrder,
  }) {
    return TaskGroup(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      tasks: tasks ?? this.tasks,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
