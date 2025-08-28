import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/plant.dart';
import '../../../domain/entities/plant_task.dart';
import '../../providers/plant_task_provider.dart';

/// Widget responsável por exibir e gerenciar as tarefas da planta
class PlantTasksSection extends StatefulWidget {
  final Plant plant;

  const PlantTasksSection({super.key, required this.plant});

  @override
  State<PlantTasksSection> createState() => _PlantTasksSectionState();
}

class _PlantTasksSectionState extends State<PlantTasksSection> {
  bool _showAllCompletedTasks = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantTaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = taskProvider.getTasksForPlant(widget.plant.id);

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
        color:
            theme.brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
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

  Widget _buildTasksList(
    BuildContext context,
    List<PlantTask> tasks,
    PlantTaskProvider taskProvider,
  ) {
    // Organizar tarefas por status
    final overdueTasks = tasks.where((task) => task.isOverdue).toList();
    final upcomingTasks =
        tasks.where((task) => task.isDueToday || task.isDueSoon).toList();
    final pendingTasks =
        tasks
            .where(
              (task) =>
                  !task.isCompleted &&
                  !task.isOverdue &&
                  !task.isDueToday &&
                  !task.isDueSoon,
            )
            .toList();
    final completedTasks = tasks.where((task) => task.isCompleted).toList();
    
    // Ordenar tarefas concluídas por data de conclusão (mais recente primeiro)
    completedTasks.sort((a, b) => (b.completedDate ?? DateTime(1970)).compareTo(a.completedDate ?? DateTime(1970)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumo das tarefas
        _buildTaskSummaryCards(
          context,
          overdueTasks,
          upcomingTasks,
          pendingTasks,
        ),

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

        // Tarefas concluídas agrupadas por data
        if (completedTasks.isNotEmpty) ...[
          _buildCompletedTasksSection(
            context,
            completedTasks,
            taskProvider,
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
        ...tasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildTaskCard(context, task, taskProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    PlantTask task,
    PlantTaskProvider taskProvider,
  ) {
    final theme = Theme.of(context);
    final color = _getTaskColor(task);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              task.isCompleted
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
      child: Row(
        children: [
          // Checkbox ou ícone de status
          GestureDetector(
            onTap: () => taskProvider.toggleTaskCompletion(widget.plant.id, task.id),
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
              child:
                  task.isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
            ),
          ),

          const SizedBox(width: 16),

          // Ícone da tarefa
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getTaskIcon(task.type), color: color, size: 20),
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
                    color:
                        task.isCompleted
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
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
            onSelected:
                (action) =>
                    _handleTaskAction(context, action, task, taskProvider),
            itemBuilder:
                (context) => [
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
                      title: Text(
                        'Excluir',
                        style: TextStyle(color: Colors.red),
                      ),
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

  void _handleTaskAction(
    BuildContext context,
    String action,
    PlantTask task,
    PlantTaskProvider taskProvider,
  ) {
    switch (action) {
      case 'complete':
        taskProvider.toggleTaskCompletion(widget.plant.id, task.id);
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

  void _confirmDeleteTask(
    BuildContext context,
    PlantTask task,
    PlantTaskProvider taskProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Excluir tarefa'),
            content: Text(
              'Tem certeza que deseja excluir a tarefa "${task.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  taskProvider.deleteTask(widget.plant.id, task.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tarefa excluída'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }

  /// Seção de tarefas concluídas agrupadas por data com opção de carregar todas
  Widget _buildCompletedTasksSection(
    BuildContext context,
    List<PlantTask> completedTasks,
    PlantTaskProvider taskProvider,
  ) {
    final theme = Theme.of(context);
    
    // Determinar quantas tarefas mostrar
    final tasksToShow = _showAllCompletedTasks 
        ? completedTasks 
        : completedTasks.take(15).toList();
    
    // Agrupar tarefas por data de conclusão
    final groupedTasks = <String, List<PlantTask>>{};
    
    for (final task in tasksToShow) {
      final completedDate = task.completedDate;
      if (completedDate != null) {
        final dateKey = _formatDateKey(completedDate);
        groupedTasks.putIfAbsent(dateKey, () => []).add(task);
      }
    }
    
    // Ordenar as chaves de data (mais recente primeiro)
    final sortedDateKeys = groupedTasks.keys.toList()
      ..sort((a, b) => _compareDateKeys(a, b));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da seção
        Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Tarefas concluídas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${completedTasks.length} tarefa${completedTasks.length != 1 ? 's' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Tarefas agrupadas por data
        ...sortedDateKeys.map((dateKey) {
          final dayTasks = groupedTasks[dateKey]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do grupo de data
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateKey,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${dayTasks.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tarefas do dia
              ...dayTasks.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 16),
                child: _buildCompletedTaskCard(context, task, taskProvider),
              )),
              
              const SizedBox(height: 16),
            ],
          );
        }),
        
        // Botão para carregar todas as tarefas
        if (!_showAllCompletedTasks && completedTasks.length > 15) ...[
          const SizedBox(height: 8),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showAllCompletedTasks = true;
                });
              },
              icon: const Icon(Icons.expand_more),
              label: Text(
                'Ver todas (${completedTasks.length - 15} mais)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: BorderSide(color: Colors.green.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
        
        // Botão para mostrar menos (se estiver mostrando todas)
        if (_showAllCompletedTasks && completedTasks.length > 15) ...[
          const SizedBox(height: 8),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showAllCompletedTasks = false;
                });
              },
              icon: const Icon(Icons.expand_less),
              label: const Text('Mostrar menos'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: BorderSide(color: Colors.green.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Card otimizado para tarefas concluídas
  Widget _buildCompletedTaskCard(
    BuildContext context,
    PlantTask task,
    PlantTaskProvider taskProvider,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2C2C2E)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Ícone de concluído
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.check, 
              color: Colors.white, 
              size: 12,
            ),
          ),

          const SizedBox(width: 12),

          // Ícone da tarefa
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getTaskIcon(task.type), 
              color: Colors.green, 
              size: 16,
            ),
          ),

          const SizedBox(width: 12),

          // Informações da tarefa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                if (task.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                
                // Horário de conclusão
                if (task.completedDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCompletedTime(task.completedDate!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Formatar chave de data para agrupamento
  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Hoje';
    } else if (taskDate == yesterday) {
      return 'Ontem';
    } else {
      final months = [
        'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
        'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
      ];
      
      if (date.year == now.year) {
        return '${date.day} de ${months[date.month - 1]}';
      } else {
        return '${date.day} ${months[date.month - 1]} ${date.year}';
      }
    }
  }

  /// Comparar chaves de data para ordenação (mais recente primeiro)
  int _compareDateKeys(String a, String b) {
    // Hoje sempre primeiro
    if (a == 'Hoje') return -1;
    if (b == 'Hoje') return 1;
    
    // Ontem vem depois de hoje
    if (a == 'Ontem') return -1;
    if (b == 'Ontem') return 1;
    
    // Para outras datas, comparar alfabeticamente reverso (aproximação)
    return b.compareTo(a);
  }

  /// Formatar horário de conclusão
  String _formatCompletedTime(DateTime completedDate) {
    return '${completedDate.hour.toString().padLeft(2, '0')}:${completedDate.minute.toString().padLeft(2, '0')}';
  }
}
