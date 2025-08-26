import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/tasks_state.dart';

/// Legacy wrapper for EmptyTasksWidget - now uses consolidated EmptyStateWidget
/// Kept for backward compatibility during transition
class EmptyTasksWidget extends StatelessWidget {
  final TasksFilterType filterType;
  final VoidCallback onAddTask;

  const EmptyTasksWidget({
    super.key,
    required this.filterType,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget.tasks(
      filterType: filterType,
      onAddTask: onAddTask,
    );
  }
}
