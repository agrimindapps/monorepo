import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/plantis_colors.dart';
import '../../../../tasks/domain/entities/task.dart';
import '../../../../tasks/presentation/notifiers/tasks_notifier.dart';
import '../../../../tasks/presentation/widgets/task_completion_dialog.dart';
import '../../../domain/entities/plant.dart';
import '../../providers/plant_tasks_unified_provider.dart';

/// Widget responsável por exibir e gerenciar as tarefas da planta
/// usando o sistema unificado de Task (features/tasks/)
class PlantTasksSection extends ConsumerStatefulWidget {
  final Plant plant;

  const PlantTasksSection({super.key, required this.plant});

  @override
  ConsumerState<PlantTasksSection> createState() => _PlantTasksSectionState();
}

class _PlantTasksSectionState extends ConsumerState<PlantTasksSection> {
  bool _showAllCompletedTasks = false;

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(plantTasksUnifiedProvider(widget.plant.id));

    if (tasks.isEmpty) {
      return _buildEmptyTasksState(context);
    }

    return _buildTasksList(context, tasks);
  }

  Widget _buildEmptyTasksState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFFFFFFF), // Branco puro
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.task_alt_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma tarefa criada',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Configure os intervalos de cuidados para gerar tarefas automaticamente.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, List<Task> tasks) {
    final overdueTasks = tasks.where((task) => task.isOverdue).toList();
    final upcomingTasks =
        tasks
            .where(
              (task) =>
                  task.status == TaskStatus.pending &&
                  !task.isOverdue &&
                  (task.isDueToday || task.isDueTomorrow),
            )
            .toList();
    final pendingTasks =
        tasks
            .where(
              (task) =>
                  task.status == TaskStatus.pending &&
                  !task.isOverdue &&
                  !task.isDueToday &&
                  !task.isDueTomorrow,
            )
            .toList();
    final completedTasks =
        tasks.where((task) => task.status == TaskStatus.completed).toList();

    overdueTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    upcomingTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    pendingTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    completedTasks.sort(
      (a, b) => (b.completedAt ?? DateTime(1970)).compareTo(
        a.completedAt ?? DateTime(1970),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overdueTasks.isNotEmpty) ...[
          _buildTaskSection(
            context,
            title: 'Tarefas em atraso',
            tasks: overdueTasks,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
        ],
        if (upcomingTasks.isNotEmpty) ...[
          _buildTaskSection(
            context,
            title: 'Tarefas próximas',
            tasks: upcomingTasks,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
        ],
        if (pendingTasks.isNotEmpty) ...[
          _buildTaskSection(
            context,
            title: 'Tarefas pendentes',
            tasks: pendingTasks,
            color: PlantisColors.primary,
          ),
          const SizedBox(height: 24),
        ],
        if (completedTasks.isNotEmpty) ...[
          _buildCompletedTasksExpandableSection(context, completedTasks),
        ],
      ],
    );
  }

  Widget _buildTaskSection(
    BuildContext context, {
    required String title,
    required List<Task> tasks,
    required Color color,
    bool isCompleted = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle_outline : Icons.list_alt,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${tasks.length} tarefa${tasks.length != 1 ? 's' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildTaskCard(context, task),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    final theme = Theme.of(context);
    final color = _getTaskColor(task);
    final isCompleted = task.status == TaskStatus.completed;

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCompleted
                  ? Colors.green.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap:
            isCompleted
                ? null
                : () => _showTaskCompletionDialog(context, task),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getTaskIcon(task.type), color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            isCompleted
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSurface,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDueDate(task.dueDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTaskColor(Task task) {
    if (task.status == TaskStatus.completed) return Colors.green;
    if (task.isOverdue) return Colors.red;
    if (task.isDueToday) return Colors.amber;
    if (task.isDueTomorrow) return Colors.orange;
    return PlantisColors.primary;
  }

  IconData _getTaskIcon(TaskType type) {
    switch (type) {
      case TaskType.watering:
        return Icons.water_drop;
      case TaskType.fertilizing:
        return Icons.grass;
      case TaskType.pruning:
        return Icons.content_cut;
      case TaskType.sunlight:
        return Icons.wb_sunny;
      case TaskType.shade:
        return Icons.cloud;
      case TaskType.pestInspection:
        return Icons.bug_report;
      case TaskType.repotting:
        return Icons.change_circle;
      case TaskType.cleaning:
        return Icons.cleaning_services;
      case TaskType.spraying:
        return Icons.shower;
      case TaskType.custom:
        return Icons.task_alt;
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final day = dueDate.day.toString().padLeft(2, '0');
    final month = dueDate.month.toString().padLeft(2, '0');
    final year = dueDate.year.toString();
    return '$day/$month/$year';
  }

  /// Seção expansível de tarefas concluídas
  Widget _buildCompletedTasksExpandableSection(
    BuildContext context,
    List<Task> completedTasks,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showAllCompletedTasks = !_showAllCompletedTasks;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  theme.brightness == Brightness.dark
                      ? const Color(0xFF2C2C2E)
                      : const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PlantisColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlantisColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: PlantisColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Histórico de cuidados',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${completedTasks.length} tarefa${completedTasks.length != 1 ? 's' : ''} concluída${completedTasks.length != 1 ? 's' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _showAllCompletedTasks ? 0.5 : 0.0,
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: PlantisColors.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child:
              _showAllCompletedTasks
                  ? Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildTaskSection(
                        context,
                        title: 'Tarefas concluídas',
                        tasks: completedTasks,
                        color: Colors.green,
                        isCompleted: true,
                      ),
                    ],
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Exibe dialog de conclusão de tarefa
  Future<void> _showTaskCompletionDialog(
    BuildContext context,
    Task task,
  ) async {
    try {
      final result = await TaskCompletionDialog.show(
        context: context,
        task: task,
        plantName: widget.plant.name,
      );

      if (result != null && context.mounted) {
        final tasksNotifier = ref.read(tasksNotifierProvider.notifier);
        final success = await tasksNotifier.completeTask(
          task.id,
          notes: result.notes,
          nextDueDate: result.nextDueDate,
        );

        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tarefa "${task.title}" concluída!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao concluir tarefa: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
