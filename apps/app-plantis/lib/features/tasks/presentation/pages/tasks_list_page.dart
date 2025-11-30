import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/providers/plants_providers.dart';
import '../../../../core/theme/accessibility_tokens.dart';
import '../../../../core/theme/plantis_colors.dart';
import '../../../../shared/widgets/base_page_scaffold.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../domain/entities/task.dart' as task_entity;
import '../notifiers/tasks_notifier.dart';
import '../providers/tasks_state.dart';
import '../widgets/empty_tasks_widget.dart';
import '../widgets/task_completion_dialog.dart';
import '../widgets/tasks_error_boundary.dart';

class TasksListPage extends ConsumerStatefulWidget {
  const TasksListPage({super.key});

  @override
  ConsumerState<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends ConsumerState<TasksListPage> {
  static const List<String> _weekdays = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  static const List<String> _months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];
  final Map<String, String> _dateFormattingCache = <String, String>{};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(tasksNotifierProvider.notifier).loadTasks();
      ref
          .read(tasksNotifierProvider.notifier)
          .filterTasks(TasksFilterType.today);
    });
  }

  @override
  void dispose() {
    _dateFormattingCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TasksErrorBoundary(
      onRetry: () {},
      child: BasePageScaffold(
        body: ResponsiveLayout(
          child: Column(
            children: [
              _buildHeader(context),
              _buildSimpleFilters(context),

              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildTasksAsyncContent(),
                    ), // Padding
                  ), // ConstrainedBox
                ), // Center
              ), // Expanded
            ],
          ), // Column
        ), // ResponsiveLayout
      ), // BasePageScaffold
    ); // TasksErrorBoundary
  }

  Widget _buildHeader(BuildContext context) {
    final tasksAsync = ref.watch(tasksNotifierProvider);
    final tasksCount = tasksAsync.maybeWhen(
      data: (state) => state.allTasks.length,
      orElse: () => 0,
    );
    return PlantisHeader(
      title: 'Minhas Tarefas',
      subtitle: '$tasksCount tarefas cadastradas',
      leading: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.task_alt, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildTasksAsyncContent() {
    final tasksAsync = ref.watch(tasksNotifierProvider);
    return tasksAsync.when(
      data: (tasksState) {
        return RefreshIndicator(
          onRefresh: () => ref.read(tasksNotifierProvider.notifier).loadTasks(),
          child: Stack(
            children: [
              _buildTasksList(tasksState),
              if (tasksState.activeOperations.isNotEmpty)
                _buildOperationOverlay(tasksState),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando tarefas...'),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(tasksNotifierProvider.notifier).loadTasks(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleFilters(BuildContext context) {
    final tasksAsync = ref.watch(tasksNotifierProvider);
    return tasksAsync.when(
      data: (TasksState tasksState) => _buildFiltersContent(tasksState, ref),
      loading: () => const SizedBox.shrink(),
      error: (Object error, StackTrace stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildFiltersContent(TasksState tasksState, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (tasksState.overdueTasks > 0) ...[
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Atrasadas'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tasksState.overdueTasks}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                selected: tasksState.currentFilter == TasksFilterType.overdue,
                onSelected: (selected) {
                  ref
                      .read(tasksNotifierProvider.notifier)
                      .filterTasks(TasksFilterType.overdue);
                },
                selectedColor: Colors.red.withValues(alpha: 0.2),
                checkmarkColor: Colors.red,
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                labelStyle: TextStyle(
                  color: tasksState.currentFilter == TasksFilterType.overdue
                      ? Colors.red[700]
                      : Colors.grey[700],
                  fontSize: 16,
                  fontWeight:
                      tasksState.currentFilter == TasksFilterType.overdue
                          ? FontWeight.w600
                          : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
            ],
            FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Hoje'),
                  if (tasksState.todayTasks > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: PlantisColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tasksState.todayTasks}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: tasksState.currentFilter == TasksFilterType.today,
              onSelected: (selected) {
                ref
                    .read(tasksNotifierProvider.notifier)
                    .filterTasks(TasksFilterType.today);
              },
              selectedColor: PlantisColors.primary.withValues(alpha: 0.2),
              checkmarkColor: PlantisColors.primary,
              backgroundColor: PlantisColors.primary.withValues(alpha: 0.1),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              labelStyle: TextStyle(
                color: tasksState.currentFilter == TasksFilterType.today
                    ? PlantisColors.primary
                    : Colors.grey[700],
                fontSize: 16,
                fontWeight: tasksState.currentFilter == TasksFilterType.today
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Próxima'),
                  if (tasksState.upcomingTasksCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: PlantisColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tasksState.upcomingTasksCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: tasksState.currentFilter == TasksFilterType.upcoming,
              onSelected: (selected) {
                ref
                    .read(tasksNotifierProvider.notifier)
                    .filterTasks(TasksFilterType.upcoming);
              },
              selectedColor: PlantisColors.primary.withValues(alpha: 0.2),
              checkmarkColor: PlantisColors.primary,
              backgroundColor: PlantisColors.primary.withValues(alpha: 0.1),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              labelStyle: TextStyle(
                color: tasksState.currentFilter == TasksFilterType.upcoming
                    ? PlantisColors.primary
                    : Colors.grey[700],
                fontSize: 16,
                fontWeight: tasksState.currentFilter == TasksFilterType.upcoming
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Futuras'),
                  if (tasksState.allFutureTasksCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: PlantisColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tasksState.allFutureTasksCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: tasksState.currentFilter == TasksFilterType.allFuture,
              onSelected: (selected) {
                ref
                    .read(tasksNotifierProvider.notifier)
                    .filterTasks(TasksFilterType.allFuture);
              },
              selectedColor: PlantisColors.primary.withValues(alpha: 0.2),
              checkmarkColor: PlantisColors.primary,
              backgroundColor: PlantisColors.primary.withValues(alpha: 0.1),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              labelStyle: TextStyle(
                color: tasksState.currentFilter == TasksFilterType.allFuture
                    ? PlantisColors.primary
                    : Colors.grey[700],
                fontSize: 16,
                fontWeight:
                    tasksState.currentFilter == TasksFilterType.allFuture
                        ? FontWeight.w600
                        : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(TasksState tasksState) {
    if (tasksState.filteredTasks.isEmpty) {
      return EmptyTasksWidget(
        filterType: tasksState.currentFilter,
        onAddTask: () {},
      );
    }
    final groupedTasks = _groupTasksByDate(tasksState.filteredTasks);
    final shouldShowViewAllButton =
        tasksState.currentFilter == TasksFilterType.upcoming &&
            tasksState.allTasks.length > tasksState.filteredTasks.length;

    return CustomScrollView(
      slivers: [
        SliverList.builder(
          itemCount: groupedTasks.length + (shouldShowViewAllButton ? 1 : 0),
          itemBuilder: (context, index) {
            if (shouldShowViewAllButton && index == groupedTasks.length) {
              return _buildViewAllButton();
            }
            final dateGroup = groupedTasks[index];
            return _buildDateGroup(dateGroup);
          },
        ),
      ],
    );
  }

  List<MapEntry<String, List<task_entity.Task>>> _groupTasksByDate(
    List<task_entity.Task> tasks,
  ) {
    final Map<String, List<task_entity.Task>> grouped = {};

    for (final task in tasks) {
      final dateKey = _getDateKey(task.dueDate);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(task);
    }

    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        final dateA = DateTime.parse(a.key);
        final dateB = DateTime.parse(b.key);
        return dateA.compareTo(dateB);
      });
    return sortedEntries;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildDateGroup(MapEntry<String, List<task_entity.Task>> dateGroup) {
    final theme = Theme.of(context);
    final date = DateTime.parse(dateGroup.key);
    return Column(
      key: ValueKey(dateGroup.key),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: const BoxDecoration(
                  color: PlantisColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatDateHeader(date),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ...dateGroup.value.map((task) => _buildTaskCard(task)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTaskCard(task_entity.Task task) {
    final theme = Theme.of(context);
    final tasksAsync = ref.watch(tasksNotifierProvider);
    final isLoading = tasksAsync.maybeWhen(
      data: (TasksState state) =>
          state.individualTaskOperations.containsKey(task.id),
      orElse: () => false,
    );
    final plantsAsync = ref.watch(plantsNotifierProvider);
    String plantName = 'Carregando...';
    String? plantImageUrl;

    plantsAsync.maybeWhen(
      data: (PlantsState plantsState) {
        try {
          final plant = plantsState.allPlants.firstWhere(
            (p) => p.id == task.plantId,
          );
          plantName = plant.name;
          plantImageUrl =
              plant.imageUrls.isNotEmpty ? plant.imageUrls.first : null;
        } catch (e) {
          plantName = 'Planta não encontrada';
        }
      },
      orElse: () {},
    );

    return _buildTaskCardContent(
      task,
      plantName,
      plantImageUrl,
      isLoading,
      theme,
      ref,
    );
  }

  Widget _buildTaskCardContent(
    task_entity.Task task,
    String plantName,
    String? plantImageUrl,
    bool isLoading,
    ThemeData theme,
    WidgetRef ref,
  ) {
    return Semantics(
      label: 'Tarefa: ${task.title} para $plantName',
      hint: isLoading
          ? 'Tarefa sendo processada'
          : 'Toque duas vezes para marcar como concluída',
      button: true,
      enabled: !isLoading,
      onTap: isLoading
          ? null
          : () => _showTaskCompletionDialog(context, task, plantName, ref),
      child: PlantisCard(
        key: ValueKey(task.id),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        onTap: isLoading
            ? null
            : () {
                AccessibilityTokens.performHapticFeedback('light');
                _showTaskCompletionDialog(context, task, plantName, ref);
              },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PlantisColors.primary.withValues(alpha: 0.1),
                border: Border.all(
                  color: PlantisColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: plantImageUrl != null
                    ? Image.network(
                        plantImageUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.local_florist,
                            color: PlantisColors.primary.withValues(
                              alpha: 0.6,
                            ),
                            size: 24,
                          );
                        },
                      )
                    : Icon(
                        Icons.local_florist,
                        color: PlantisColors.primary.withValues(alpha: 0.6),
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: isLoading ? 0.6 : 1.0,
                      ),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plantName,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox.shrink(),
                  if (isLoading) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Processando...',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () => _showTaskCompletionDialog(
                        context,
                        task,
                        plantName,
                        ref,
                      ),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: PlantisColors.primary, width: 2),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(2),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            PlantisColors.primary,
                          ),
                        ),
                      )
                    : const SizedBox(), // Círculo vazio = tarefa pendente
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTaskCompletionDialog(
    BuildContext context,
    task_entity.Task task,
    String plantName,
    WidgetRef ref,
  ) async {
    final result = await TaskCompletionDialog.show(
      context: context,
      task: task,
      plantName: plantName,
    );

    if (result != null && context.mounted) {
      try {
        await ref.read(tasksNotifierProvider.notifier).completeTask(task.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tarefa "${task.title}" concluída com sucesso!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao concluir tarefa. Tente novamente.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  String _formatDateHeader(DateTime date) {
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
      final cacheKey = '${date.year}-${date.month}-${date.day}-${date.weekday}';

      if (_dateFormattingCache.containsKey(cacheKey)) {
        return _dateFormattingCache[cacheKey]!;
      }

      final weekday = _weekdays[date.weekday - 1];
      final day = date.day;
      final month = _months[date.month - 1];

      final formatted = '$weekday, $day de $month';
      _dateFormattingCache[cacheKey] = formatted;

      return formatted;
    }
  }

  Widget _buildViewAllButton() {
    final theme = Theme.of(context);
    final tasksAsync = ref.watch(tasksNotifierProvider);
    final remainingTasks = tasksAsync.maybeWhen(
      data: (TasksState state) =>
          state.allTasks.length - state.filteredTasks.length,
      orElse: () => 0,
    );
    return _buildViewAllButtonContent(remainingTasks, theme, ref);
  }

  Widget _buildViewAllButtonContent(
    int remainingTasks,
    ThemeData theme,
    WidgetRef ref,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            ref
                .read(tasksNotifierProvider.notifier)
                .filterTasks(TasksFilterType.allFuture);
          },
          icon: const Icon(Icons.calendar_month),
          label: Text('Ver todas as tarefas futuras (+$remainingTasks)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: PlantisColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperationOverlay(TasksState tasksState) {
    final theme = Theme.of(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                tasksState.currentOperationMessage?.toString() ??
                    'Processando...',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
