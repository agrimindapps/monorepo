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

class TasksListPage extends StatefulWidget {
  const TasksListPage({super.key});

  @override
  State<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends State<TasksListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    // Carregar tarefas ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasksProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TasksAppBar(tabController: _tabController),
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

          return Column(
            children: [
              // Dashboard com estatísticas
              const TasksDashboard(),
              
              // Conteúdo principal com tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTabContent(provider, TasksFilterType.all),
                    _buildTabContent(provider, TasksFilterType.today),
                    _buildTabContent(provider, TasksFilterType.overdue),
                    _buildTabContent(provider, TasksFilterType.upcoming),
                    _buildTabContent(provider, TasksFilterType.completed),
                    _buildPlantTasksTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: const TasksFab(),
    );
  }

  Widget _buildTabContent(TasksProvider provider, TasksFilterType filter) {
    // Aplicar filtro se necessário
    if (provider.currentFilter != filter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.setFilter(filter);
      });
    }

    final tasks = provider.filteredTasks;

    if (tasks.isEmpty && !provider.isLoading) {
      return EmptyTasksWidget(
        filterType: filter,
        onAddTask: () => _showAddTaskDialog(context),
      );
    }

    return TasksListView(
      tasks: tasks,
      onTaskComplete: (taskId) => provider.completeTask(taskId),
      onTaskTap: (task) => _showTaskDetails(context, task),
    );
  }

  Widget _buildPlantTasksTab(TasksProvider provider) {
    // TODO: Implementar seleção de planta específica
    return const Center(
      child: Text(
        'Selecione uma planta para ver suas tarefas',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
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