import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task.dart' as task_entity;
import '../providers/tasks_provider.dart';
import '../providers/tasks_state.dart';
import '../widgets/empty_tasks_widget.dart';
import '../widgets/task_completion_dialog.dart';
import '../widgets/task_creation_dialog.dart';
import '../widgets/tasks_app_bar.dart';
import '../widgets/tasks_error_boundary.dart';
import '../widgets/tasks_error_widget.dart';
import '../widgets/tasks_fab.dart';
import '../widgets/tasks_loading_widget.dart';

class TaskDateGroup {
  final String dateKey;
  final List<task_entity.Task> tasks;

  TaskDateGroup({required this.dateKey, required this.tasks});

  DateTime get date {
    final parts = dateKey.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}

class TasksListPage extends StatefulWidget {
  const TasksListPage({super.key});

  @override
  State<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends State<TasksListPage> {
  @override
  void initState() {
    super.initState();

    // Load tasks on initialization with delay to ensure auth is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasksProvider>().loadTasks();
      // Set default filter to "Today"
      context.read<TasksProvider>().setFilter(TasksFilterType.today);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TasksErrorBoundary(
      onRetry: () {
        final provider = context.read<TasksProvider>();
        provider.clearError();
        provider.loadTasks();
      },
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF000000) : theme.colorScheme.surface,
        appBar: const TasksAppBar(),
        body: Consumer<TasksProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.allTasks.isEmpty) {
              return const TasksLoadingWidget();
            }

            if (provider.hasError) {
              return TasksErrorWidget(
                message: provider.errorMessage!,
                onRetry: () => provider.loadTasks(),
              );
            }

            return RefreshIndicator(
              onRefresh: provider.refresh,
              child: Stack(
                children: [
                  _buildTasksList(provider),
                  // Operation feedback overlay
                  if (provider.hasActiveOperations || provider.currentOperationMessage != null)
                    _buildOperationOverlay(provider),
                ],
              ),
            );
          },
        ),
        floatingActionButton: const TasksFab(),
      ),
    );
  }

  Widget _buildTasksList(TasksProvider provider) {
    final tasks = provider.filteredTasks;

    if (tasks.isEmpty && !provider.isLoading) {
      return EmptyTasksWidget(
        filterType: provider.currentFilter,
        onAddTask: () => _showAddTaskDialog(context),
      );
    }

    // Agrupar tarefas por data
    final groupedTasks = _groupTasksByDate(tasks);

    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: groupedTasks.length,
      itemBuilder: (context, index) {
        final dateGroup = groupedTasks[index];
        return _buildDateGroup(dateGroup);
      },
    );
  }

  List<TaskDateGroup> _groupTasksByDate(List<task_entity.Task> tasks) {
    final Map<String, List<task_entity.Task>> grouped = {};

    for (final task in tasks) {
      final dateKey = _getDateKey(task.dueDate);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(task);
    }

    return grouped.entries
        .map((entry) => TaskDateGroup(dateKey: entry.key, tasks: entry.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildDateGroup(TaskDateGroup dateGroup) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da data
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatDateHeader(dateGroup.date),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Lista de tarefas desta data
        ...dateGroup.tasks.map((task) => _buildTaskCard(task)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTaskCard(task_entity.Task task) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<TasksProvider>(
      builder: (context, provider, child) {
        final isLoading = provider.isTaskOperationLoading(task.id);
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDark
                    ? const Color(0xFF1C1C1E)
                    : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: isLoading 
                ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              // Ícone da tarefa ou loading
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isLoading 
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: isLoading 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Icon(_getTaskIcon(task.type), color: Colors.black, size: 20),
              ),
              const SizedBox(width: 16),
              // Task information
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
                    const SizedBox(height: 4),
                    Text(
                      task.plantName,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                    if (isLoading) ...[
                      const SizedBox(height: 4),
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
              // Check button
              GestureDetector(
                onTap: isLoading ? null : () => _showTaskCompletionDialog(context, task),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLoading 
                        ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                        : theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check, 
                    color: isLoading ? Colors.grey : Colors.black, 
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showTaskCompletionDialog(BuildContext context, task_entity.Task task) async {
    final result = await TaskCompletionDialog.show(
      context: context,
      task: task,
    );

    if (result != null && context.mounted) {
      // Use the completion date and notes from the dialog
      final success = await context.read<TasksProvider>().completeTask(
        task.id, 
        notes: result.notes,
      );
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tarefa "${task.title}" marcada como concluída!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  IconData _getTaskIcon(task_entity.TaskType type) {
    switch (type) {
      case task_entity.TaskType.watering:
        return Icons.water_drop;
      case task_entity.TaskType.fertilizing:
        return Icons.eco;
      case task_entity.TaskType.pruning:
        return Icons.content_cut;
      case task_entity.TaskType.pestInspection:
        return Icons.search;
      case task_entity.TaskType.repotting:
        return Icons.grass;
      default:
        return Icons.task_alt;
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
      final weekdays = [
        'Segunda-feira',
        'Terça-feira',
        'Quarta-feira',
        'Quinta-feira',
        'Sexta-feira',
        'Sábado',
        'Domingo',
      ];
      final months = [
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

      final weekday = weekdays[date.weekday - 1];
      final day = date.day;
      final month = months[date.month - 1];

      return '$weekday, $day de $month';
    }
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final result = await TaskCreationDialog.show(context: context);
    
    if (result != null && context.mounted) {
      // Create task entity from the form data
      final task = task_entity.Task(
        id: '', // Will be generated by the repository
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        title: result.title,
        description: result.description,
        plantId: result.plantId,
        plantName: result.plantName,
        type: result.type,
        priority: result.priority,
        dueDate: result.dueDate,
      );

      // Add the task using the provider
      final success = await context.read<TasksProvider>().addTask(task);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tarefa "${result.title}" criada com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao criar tarefa. Tente novamente.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildOperationOverlay(TasksProvider provider) {
    final theme = Theme.of(context);
    
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                provider.currentOperationMessage ?? 'Processando...',
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

  // ignore: unused_element
  String _formatDate(DateTime date) {
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
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
