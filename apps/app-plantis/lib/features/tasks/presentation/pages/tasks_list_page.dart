import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tasks_provider.dart';
import '../../domain/entities/task.dart' as task_entity;
import '../widgets/tasks_dashboard.dart';
import '../widgets/tasks_list_view.dart';
import '../widgets/tasks_app_bar.dart';
import '../widgets/tasks_fab.dart';
import '../widgets/tasks_loading_widget.dart';
import '../widgets/tasks_error_widget.dart';
import '../widgets/empty_tasks_widget.dart';

class TaskDateGroup {
  final String dateKey;
  final List<task_entity.Task> tasks;

  TaskDateGroup({
    required this.dateKey,
    required this.tasks,
  });

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
    
    // Carregar tarefas ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasksProvider>().loadTasks();
      // Definir filtro padrão como "Para hoje"
      context.read<TasksProvider>().setFilter(TasksFilterType.today);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : theme.colorScheme.surface,
      appBar: const TasksAppBar(),
      body: Consumer<TasksProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const TasksLoadingWidget();
          }

          if (provider.hasError) {
            return TasksErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.loadTasks(),
            );
          }

          return _buildTasksList(provider);
        },
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

    return grouped.entries.map((entry) => TaskDateGroup(
      dateKey: entry.key,
      tasks: entry.value,
    )).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildDateGroup(TaskDateGroup dateGroup) {
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
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Ícone da tarefa
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTaskIcon(task.type),
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // Informações da tarefa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.plantName,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Botão de check
          GestureDetector(
            onTap: () => context.read<TasksProvider>().completeTask(task.id),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
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
        'Domingo'
      ];
      final months = [
        'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
        'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
      ];
      
      final weekday = weekdays[date.weekday - 1];
      final day = date.day;
      final month = months[date.month - 1];
      
      return '$weekday, $day de $month';
    }
  }


  void _showAddTaskDialog(BuildContext context) {
    // TODO: Implementar dialog/página de criação de tarefa
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulário de criação de tarefa em desenvolvimento'),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, task_entity.Task task) {
    // TODO: Implementar página de detalhes da tarefa
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Planta: ${task.plantName}'),
            Text('Tipo: ${task.type.displayName}'),
            Text('Prioridade: ${task.priority.displayName}'),
            Text('Vencimento: ${_formatDate(task.dueDate)}'),
            if (task.description?.isNotEmpty == true)
              Text('Descrição: ${task.description}'),
          ],
        ),
        actions: [
          if (task.status == task_entity.TaskStatus.pending)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<TasksProvider>().completeTask(task.id);
              },
              child: const Text('Marcar como Concluída'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

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