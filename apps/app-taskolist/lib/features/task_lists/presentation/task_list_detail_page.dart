import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/task_list_colors.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../tasks/domain/task_entity.dart';
import '../../tasks/domain/task_list_entity.dart';
import '../../tasks/presentation/pages/create_edit_task_page.dart';
import '../../tasks/presentation/pages/task_detail_page.dart';
import '../../tasks/presentation/providers/task_notifier.dart';
import '../../tasks/presentation/widgets/task_list_item.dart';
import 'create_edit_task_list_page.dart';

class TaskListDetailPage extends ConsumerStatefulWidget {
  final TaskListEntity taskList;

  const TaskListDetailPage({super.key, required this.taskList});

  @override
  ConsumerState<TaskListDetailPage> createState() => _TaskListDetailPageState();
}

class _TaskListDetailPageState extends ConsumerState<TaskListDetailPage> {
  String _filterStatus = 'all'; // all, active, completed

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(
      tasksStreamProvider(TasksStreamParams(listId: widget.taskList.id)),
    );
    final color = TaskListColors.fromHex(widget.taskList.color);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskList.title),
        elevation: 0,
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Todas')),
              const PopupMenuItem(value: 'active', child: Text('Ativas')),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Concluídas'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) =>
                      CreateEditTaskListPage(taskList: widget.taskList),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com informações da lista
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.taskList.description?.isNotEmpty ?? false) ...[
                  Text(
                    widget.taskList.description!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: color),
                  ),
                  const SizedBox(height: 12),
                ],
                tasksAsync.when(
                  data: (allTasks) {
                    final tasks = allTasks
                        .where((task) => task.listId == widget.taskList.id)
                        .toList();
                    final completed = tasks
                        .where((task) => task.isCompleted)
                        .length;
                    final total = tasks.length;

                    return Row(
                      children: [
                        Icon(Icons.task_alt, size: 18, color: color),
                        const SizedBox(width: 8),
                        Text(
                          '$completed de $total tarefas',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        if (widget.taskList.isShared) ...[
                          const SizedBox(width: 16),
                          Icon(Icons.people_outline, size: 18, color: color),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.taskList.memberIds.length + 1} membros',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Lista de tarefas
          Expanded(
            child: tasksAsync.when(
              data: (allTasks) {
                var tasks = allTasks
                    .where((task) => task.listId == widget.taskList.id)
                    .toList();

                // Aplicar filtro
                if (_filterStatus == 'active') {
                  tasks = tasks.where((task) => !task.isCompleted).toList();
                } else if (_filterStatus == 'completed') {
                  tasks = tasks.where((task) => task.isCompleted).toList();
                }

                if (tasks.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.checklist,
                    title: _getEmptyTitle(),
                    message: _getEmptyMessage(),
                    actionLabel: 'Adicionar tarefa',
                    onAction: () => _navigateToCreateTask(context),
                  );
                }

                // Separar por status
                final activeTasks = tasks
                    .where((task) => !task.isCompleted)
                    .toList();
                final completedTasks = tasks
                    .where((task) => task.isCompleted)
                    .toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (activeTasks.isNotEmpty) ...[
                      ...activeTasks.map(
                        (task) => TaskListItem(
                          task: task,
                          onTap: () => _navigateToTaskDetail(context, task),
                        ),
                      ),
                    ],
                    if (completedTasks.isNotEmpty) ...[
                      if (activeTasks.isNotEmpty) const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 20,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Concluídas',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      ...completedTasks.map(
                        (task) => Opacity(
                          opacity: 0.6,
                          child: TaskListItem(
                            task: task,
                            onTap: () => _navigateToTaskDetail(context, task),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 80),
                  ],
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar tarefas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTask(context),
        backgroundColor: color,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getEmptyTitle() {
    switch (_filterStatus) {
      case 'active':
        return 'Nenhuma tarefa ativa';
      case 'completed':
        return 'Nenhuma tarefa concluída';
      default:
        return 'Nenhuma tarefa nesta lista';
    }
  }

  String _getEmptyMessage() {
    switch (_filterStatus) {
      case 'active':
        return 'Todas as tarefas foram concluídas!';
      case 'completed':
        return 'Ainda não há tarefas concluídas';
      default:
        return 'Adicione sua primeira tarefa para começar';
    }
  }

  void _navigateToCreateTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            CreateEditTaskPage(taskListId: widget.taskList.id),
      ),
    );
  }

  void _navigateToTaskDetail(BuildContext context, TaskEntity task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => TaskDetailPage(task: task)),
    );
  }
}
