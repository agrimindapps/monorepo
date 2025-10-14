import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/tasks_providers.dart';
import '../../core/constants/tasks_constants.dart';

class TasksDashboard extends ConsumerWidget {
  const TasksDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasksAsync = ref.watch(tasksNotifierProvider);

    return tasksAsync.maybeWhen(
      data: (tasksState) {
        final taskStats = {
          'totalTasks': tasksState.totalTasks,
          'pendingTasks': tasksState.pendingTasks,
          'todayTasks': tasksState.todayTasks,
          'overdueTasks': tasksState.overdueTasks,
          'completedTasks': tasksState.completedTasks,
        };
        return Container(
          padding: const EdgeInsets.all(TasksConstants.dashboardPadding),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.1),
                blurRadius: TasksConstants.dashboardShadowBlurRadius,
                offset: const Offset(0, TasksConstants.dashboardShadowOffset),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: AppStrings.totalLabel,
                      value: taskStats['totalTasks']!,
                      icon: Icons.list_alt,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: TasksConstants.statCardRowSpacing),
                  Expanded(
                    child: _StatCard(
                      title: AppStrings.pendingLabel,
                      value: taskStats['pendingTasks']!,
                      icon: Icons.schedule,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: TasksConstants.statCardRowSpacing),
                  Expanded(
                    child: _StatCard(
                      title: AppStrings.todayLabel,
                      value: taskStats['todayTasks']!,
                      icon: Icons.today,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: TasksConstants.statCardRowSpacing),
                  Expanded(
                    child: _StatCard(
                      title: AppStrings.overdueLabel,
                      value: taskStats['overdueTasks']!,
                      icon: Icons.warning,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: TasksConstants.dashboardVerticalSpacing),
              _ProgressBar(
                completed: taskStats['completedTasks']!,
                total: taskStats['totalTasks']!,
                theme: theme,
              ),
            ],
          ),
        );
      },
      orElse: () => Container(
        padding: const EdgeInsets.all(TasksConstants.dashboardPadding),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(TasksConstants.statCardPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: TasksConstants.statCardIconSize),
          const SizedBox(height: TasksConstants.statCardSmallSpacing),
          Text(
            value.toString(),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int completed;
  final int total;
  final ThemeData theme;

  const _ProgressBar({
    required this.completed,
    required this.total,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    final percentage = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.overallProgress,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$completed de $total tarefas ($percentage%)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: TasksConstants.progressSectionSpacing),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressColor(percentage, theme),
          ),
          minHeight: TasksConstants.progressBarHeight,
          borderRadius: BorderRadius.circular(
            TasksConstants.progressBarBorderRadius,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(int percentage, ThemeData theme) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else if (percentage >= 25) {
      return theme.colorScheme.primary;
    } else {
      return Colors.red;
    }
  }
}
