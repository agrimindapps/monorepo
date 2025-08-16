import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tasks_provider.dart';

class TasksAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<TasksFilterType>? onFilterChanged;

  const TasksAppBar({
    super.key,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF000000) : theme.colorScheme.surface,
      elevation: 0,
      title: Consumer<TasksProvider>(
        builder: (context, provider, child) {
          return Row(
            children: [
              Text(
                'Tarefas',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              // Badge with total tasks
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.secondary),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.totalTasks} tarefas',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          color: isDark ? const Color(0xFF000000) : theme.colorScheme.surface,
          padding: const EdgeInsets.only(left: 20, bottom: 16),
          child: Row(
            children: [
              Consumer<TasksProvider>(
                builder: (context, provider, child) {
                  return Row(
                    children: [
                      // Para hoje button
                      _FilterButton(
                        text: 'Para hoje',
                        isSelected: provider.currentFilter == TasksFilterType.today,
                        onTap: () => _handleFilterChange(context, TasksFilterType.today),
                      ),
                      const SizedBox(width: 16),
                      // Próximas button
                      _FilterButton(
                        text: 'Próximas ${provider.upcomingTasksCount}',
                        isSelected: provider.currentFilter == TasksFilterType.upcoming,
                        onTap: () => _handleFilterChange(context, TasksFilterType.upcoming),
                        showBadge: true,
                        badgeCount: provider.upcomingTasksCount,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFilterChange(BuildContext context, TasksFilterType filter) {
    context.read<TasksProvider>().setFilter(filter);
    onFilterChanged?.call(filter);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 70);
}

class _FilterButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showBadge;
  final int badgeCount;

  const _FilterButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.showBadge = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.black : theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showBadge && badgeCount > 0 && isSelected) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}