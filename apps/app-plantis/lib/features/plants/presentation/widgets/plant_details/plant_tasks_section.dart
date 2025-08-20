import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/plant.dart';
import '../../../domain/entities/plant_task.dart';
import '../../providers/plant_task_provider.dart';
import '../../../../core/theme/colors.dart';

/// Widget responsável por exibir e gerenciar as tarefas da planta
class PlantTasksSection extends StatelessWidget {
  final Plant plant;

  const PlantTasksSection({
    super.key,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantTaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final tasks = taskProvider.getTasksForPlant(plant.id);
        
        if (tasks.isEmpty) {
          return _buildEmptyTasksState(context);
        }

        return _buildTasksList(context, tasks, taskProvider);
      },
    );
  }

  Widget _buildEmptyTasksState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
          ? const Color(0xFF2C2C2E)
          : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.task_alt_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Gerar tarefas iniciais
            },
            icon: const Icon(Icons.add_task),
            label: const Text('Gerar tarefas'),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, List<PlantTask> tasks, PlantTaskProvider taskProvider) {
    final theme = Theme.of(context);
    
    // Organizar tarefas por status
    final overdueTasks = tasks.where((task) => task.isOverdue).toList();
    final upcomingTasks = tasks.where((task) => task.isDueToday || task.isDueSoon).toList();
    final pendingTasks = tasks.where((task) => !task.isCompleted && !task.isOverdue && !task.isDueToday && !task.isDueSoon).toList();
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumo das tarefas
        _buildTaskSummaryCards(context, overdueTasks, upcomingTasks, pendingTasks),
        
        const SizedBox(height: 24),
        
        // Tarefas em atraso
        if (overdueTasks.isNotEmpty) ...[
          _buildTaskSection(
            context,
            title: 'Tarefas em atraso',
            tasks: overdueTasks,
            color: Colors.red,
            taskProvider: taskProvider,
          ),
          const SizedBox(height: 24),
        ],
        
        // Tarefas para hoje/próximas
        if (upcomingTasks.isNotEmpty) ...[
          _buildTaskSection(
            context,
            title: 'Tarefas próximas',
            tasks: upcomingTasks,
            color: Colors.orange,
            taskProvider: taskProvider,
          ),
          const SizedBox(height: 24),
        ],
        
        // Tarefas pendentes
        if (pendingTasks.isNotEmpty) ...[
          _buildTaskSection(
            context,
            title: 'Tarefas pendentes',
            tasks: pendingTasks,
            color: Colors.blue,
            taskProvider: taskProvider,
          ),
          const SizedBox(height: 24),
        ],
        
        // Tarefas concluídas (últimas 5)
        if (completedTasks.isNotEmpty) ...[
          _buildTaskSection(
            context,
            title: 'Tarefas concluídas',
            tasks: completedTasks.take(5).toList(),
            color: Colors.green,
            taskProvider: taskProvider,
            isCompleted: true,
          ),
        ],
      ],
    );
  }

  Widget _buildTaskSummaryCards(
    BuildContext context,
    List<PlantTask> overdueTasks,
    List<PlantTask> upcomingTasks,
    List<PlantTask> pendingTasks,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            title: 'Em atraso',
            count: '${overdueTasks.length}',
            color: Colors.red,
            icon: Icons.warning_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: 'Próximas',
            count: '${upcomingTasks.length}',
            color: Colors.orange,
            icon: Icons.schedule_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: 'Pendentes',
            count: '${pendingTasks.length}',
            color: Colors.blue,
            icon: Icons.pending_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSection(
    BuildContext context, {
    required String title,
    required List<PlantTask> tasks,
    required Color color,
    required PlantTaskProvider taskProvider,
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
        ...tasks.map((task) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildTaskCard(context, task, taskProvider),
        )),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, PlantTask task, PlantTaskProvider taskProvider) {
    final theme = Theme.of(context);
    final color = _getTaskColor(task);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
          ? const Color(0xFF2C2C2E)
          : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isCompleted 
            ? Colors.green.withOpacity(0.3)
            : color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox ou ícone de status
          GestureDetector(
            onTap: () => taskProvider.toggleTaskCompletion(plant.id, task.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: task.isCompleted ? Colors.green : Colors.transparent,
                border: Border.all(
                  color: task.isCompleted ? Colors.green : color,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: task.isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Ícone da tarefa
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTaskIcon(task.type),
              color: color,
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
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: task.isCompleted 
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
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
          
          // Menu de ações
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurfaceVariant,
              size: 18,
            ),
            onSelected: (action) => _handleTaskAction(context, action, task, taskProvider),
            itemBuilder: (context) => [
              if (!task.isCompleted)
                const PopupMenuItem(
                  value: 'complete',
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline),
                    title: Text('Marcar como concluída'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Editar'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Excluir', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTaskColor(PlantTask task) {
    if (task.isCompleted) return Colors.green;
    if (task.isOverdue) return Colors.red;
    if (task.isDueToday) return Colors.orange;
    if (task.isDueSoon) return Colors.amber;
    return Colors.blue;
  }

  IconData _getTaskIcon(TaskType type) {
    switch (type) {
      case TaskType.watering:
        return Icons.water_drop;
      case TaskType.fertilizing:
        return Icons.grass;
      case TaskType.pruning:
        return Icons.content_cut;
      case TaskType.sunlightCheck:
        return Icons.wb_sunny;
      case TaskType.pestInspection:
        return Icons.bug_report;
      case TaskType.replanting:
        return Icons.change_circle;
      default:
        return Icons.task_alt;
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return '${-difference} dia${-difference != 1 ? 's' : ''} em atraso';
    } else if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Amanhã';
    } else if (difference <= 7) {
      return 'Em $difference dias';
    } else {
      return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
    }
  }

  void _handleTaskAction(BuildContext context, String action, PlantTask task, PlantTaskProvider taskProvider) {
    switch (action) {
      case 'complete':
        taskProvider.toggleTaskCompletion(plant.id, task.id);
        break;
      case 'edit':
        // TODO: Implementar edição de tarefa
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edição de tarefa em desenvolvimento')),
        );
        break;
      case 'delete':
        _confirmDeleteTask(context, task, taskProvider);
        break;
    }
  }

  void _confirmDeleteTask(BuildContext context, PlantTask task, PlantTaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: Text('Tem certeza que deseja excluir a tarefa "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              taskProvider.deleteTask(plant.id, task.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tarefa excluída'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}