import 'package:flutter/material.dart';

import '../../features/tasks/presentation/providers/tasks_state.dart';
import '../localization/app_strings.dart';

/// Configuration for different empty state scenarios
class EmptyStateConfig {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final bool showButton;
  final EmptyStateStyle style;

  const EmptyStateConfig({
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
    this.showButton = true,
    this.style = EmptyStateStyle.illustration,
  });
}

/// Different visual styles for empty states
enum EmptyStateStyle {
  /// Shows icon inside a circular container (for tasks)
  illustration,
  /// Shows large standalone icon (for plants)
  icon,
}

/// Consolidated empty state widget that can be used across the app
/// Replaces both EmptyPlantsWidget and EmptyTasksWidget
class EmptyStateWidget extends StatelessWidget {
  final EmptyStateConfig config;
  final EdgeInsets padding;
  final double iconSize;
  final double? containerSize;

  const EmptyStateWidget({
    super.key,
    required this.config,
    this.padding = const EdgeInsets.all(32),
    this.iconSize = 48,
    this.containerSize,
  });

  /// Factory constructor for plant empty states
  factory EmptyStateWidget.plants({
    Key? key,
    bool isSearching = false,
    String searchQuery = '',
    VoidCallback? onClearSearch,
    VoidCallback? onAddPlant,
  }) {
    if (isSearching) {
      return EmptyStateWidget(
        key: key,
        config: EmptyStateConfig(
          icon: Icons.search_off,
          title: 'Nenhuma planta encontrada',
          description: 'Não encontramos nenhuma planta com "$searchQuery".\nTente usar outros termos.',
          buttonText: 'Limpar busca',
          onButtonPressed: onClearSearch,
          showButton: onClearSearch != null,
          style: EmptyStateStyle.illustration,
        ),
        padding: const EdgeInsets.all(24),
      );
    }

    return EmptyStateWidget(
      key: key,
      config: EmptyStateConfig(
        icon: Icons.eco_outlined,
        title: 'Nenhuma planta cadastrada',
        description: 'Adicione sua primeira planta para começar a cuidar\ndela com o Grow',
        buttonText: 'Adicionar primeira planta',
        onButtonPressed: onAddPlant,
        showButton: onAddPlant != null,
        style: EmptyStateStyle.icon,
      ),
      padding: const EdgeInsets.all(32),
      iconSize: 120,
    );
  }

  /// Factory constructor for task empty states
  factory EmptyStateWidget.tasks({
    Key? key,
    required TasksFilterType filterType,
    required VoidCallback onAddTask,
  }) {
    final config = _getTaskEmptyStateConfig(filterType, onAddTask);
    
    return EmptyStateWidget(
      key: key,
      config: config,
      padding: const EdgeInsets.all(32), // TasksConstants.emptyStatePadding
      containerSize: 120, // TasksConstants.emptyStateIllustrationSize
    );
  }

  static EmptyStateConfig _getTaskEmptyStateConfig(TasksFilterType filterType, VoidCallback onAddTask) {
    switch (filterType) {
      case TasksFilterType.all:
        return const EmptyStateConfig(
          icon: Icons.task_alt,
          title: AppStrings.noTasksFound,
          description: AppStrings.noTasksFoundDescription,
          showButton: false,
        );

      case TasksFilterType.today:
        return const EmptyStateConfig(
          icon: Icons.today,
          title: AppStrings.noTasksToday,
          description: AppStrings.noTasksTodayDescription,
          showButton: false,
        );

      case TasksFilterType.overdue:
        return const EmptyStateConfig(
          icon: Icons.check_circle,
          title: AppStrings.noOverdueTasks,
          description: AppStrings.noOverdueTasksDescription,
          showButton: false,
        );

      case TasksFilterType.upcoming:
        return const EmptyStateConfig(
          icon: Icons.schedule,
          title: 'Nenhuma tarefa próxima',
          description: 'Você não tem tarefas pendentes para os próximos 15 dias.\nParabéns! Você está em dia com seus cuidados.',
          showButton: false,
        );

      case TasksFilterType.allFuture:
        return const EmptyStateConfig(
          icon: Icons.calendar_month,
          title: 'Nenhuma tarefa futura programada',
          description: 'Não há tarefas pendentes programadas para o futuro.\nTodas as suas plantas estão com os cuidados em dia!',
          showButton: false,
        );

      case TasksFilterType.completed:
        return const EmptyStateConfig(
          icon: Icons.history,
          title: AppStrings.noCompletedTasks,
          description: AppStrings.noCompletedTasksDescription,
          showButton: false,
        );

      case TasksFilterType.byPlant:
        return EmptyStateConfig(
          icon: Icons.local_florist,
          title: AppStrings.noTasksForThisPlant,
          description: AppStrings.noTasksForThisPlantDescription,
          buttonText: AppStrings.addNewTaskButton,
          onButtonPressed: onAddTask,
          showButton: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon/Illustration
            _buildIcon(context, theme),

            SizedBox(height: config.style == EmptyStateStyle.illustration ? 24 : 32),

            // Title
            _buildTitle(theme),

            const SizedBox(height: 12),

            // Description
            _buildDescription(theme),

            if (config.showButton && config.onButtonPressed != null) ...[
              SizedBox(height: config.style == EmptyStateStyle.illustration ? 32 : 48),
              _buildActionButton(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, ThemeData theme) {
    switch (config.style) {
      case EmptyStateStyle.illustration:
        return Container(
          width: containerSize ?? 120,
          height: containerSize ?? 120,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            config.icon,
            color: theme.colorScheme.primary,
            size: 60,
          ),
        );

      case EmptyStateStyle.icon:
        return Icon(
          config.icon,
          size: iconSize,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        );
    }
  }

  Widget _buildTitle(ThemeData theme) {
    switch (config.style) {
      case EmptyStateStyle.illustration:
        return Text(
          config.title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        );

      case EmptyStateStyle.icon:
        return Text(
          config.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        );
    }
  }

  Widget _buildDescription(ThemeData theme) {
    if (config.description.contains('"')) {
      // Rich text for search results with bold search term
      final parts = config.description.split('"');
      if (parts.length >= 3) {
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            children: [
              TextSpan(text: parts[0]),
              TextSpan(
                text: '"${parts[1]}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (parts.length > 2) TextSpan(text: parts[2]),
            ],
          ),
        );
      }
    }

    // Regular description text
    return Text(
      config.description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    switch (config.style) {
      case EmptyStateStyle.illustration:
        if (config.buttonText == 'Limpar busca') {
          // Outlined button for clear search
          return OutlinedButton.icon(
            onPressed: config.onButtonPressed,
            icon: const Icon(Icons.clear),
            label: Text(config.buttonText!),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(color: theme.colorScheme.primary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        
        // Regular elevated button for tasks
        return ElevatedButton.icon(
          onPressed: config.onButtonPressed,
          icon: const Icon(Icons.add),
          label: Text(config.buttonText!),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        );

      case EmptyStateStyle.icon:
        // Large elevated button for plants
        return ElevatedButton.icon(
          onPressed: config.onButtonPressed,
          icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
          label: Text(config.buttonText!),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
    }
  }
}

