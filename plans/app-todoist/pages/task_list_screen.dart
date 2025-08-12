// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants/todoist_colors.dart';
import '../controllers/auth_controller.dart';
import '../dependency_injection.dart';
import '../models/72_task_list.dart';
import '../models/task_model.dart';
import '../widgets/create_task_dialog.dart';
import '../widgets/task_detail_side_panel.dart';
import '../widgets/task_widget.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  final TaskList taskList;

  const TaskListScreen({super.key, required this.taskList});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _sortBy = 'created';
  bool _showCompleted = true;
  bool _showOnlyStarred = false;
  final _addTaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // RealtimeController gerencia automaticamente o carregamento
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: TodoistColors.backgroundColor,
          appBar: AppBar(
            title: Text(widget.taskList.title),
            backgroundColor: TodoistColors.secondaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    if (value == 'toggle_completed') {
                      _showCompleted = !_showCompleted;
                    } else if (value == 'toggle_starred') {
                      _showOnlyStarred = !_showOnlyStarred;
                    } else {
                      _sortBy = value;
                    }
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle_completed',
                    child: Row(
                      children: [
                        Icon(_showCompleted
                            ? Icons.visibility_off
                            : Icons.visibility),
                        const SizedBox(width: 8),
                        Text(_showCompleted
                            ? 'Ocultar concluídas'
                            : 'Mostrar concluídas'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_starred',
                    child: Row(
                      children: [
                        Icon(_showOnlyStarred ? Icons.star : Icons.star_border),
                        const SizedBox(width: 8),
                        Text(_showOnlyStarred
                            ? 'Mostrar todas'
                            : 'Apenas favoritas'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'created',
                    child: Text('Ordenar por criação'),
                  ),
                  const PopupMenuItem(
                    value: 'priority',
                    child: Text('Ordenar por prioridade'),
                  ),
                  const PopupMenuItem(
                    value: 'due_date',
                    child: Text('Ordenar por vencimento'),
                  ),
                ],
              ),
            ],
          ),
          body: StreamBuilder<List<Task>>(
            stream: DependencyContainer.instance.taskRepository.tasksStream
                .map((tasks) => tasks.where((task) => task.listId == widget.taskList.id).toList()),
            builder: (context, snapshot) {
              return _buildTaskList(context, snapshot);
            },
          ),
        ));
  }

  @override
  void dispose() {
    _addTaskController.dispose();
    super.dispose();
  }

  Widget _buildTaskList(
      BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar tarefas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${snapshot.error}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final allTasks = snapshot.data ?? [];
    final filteredTasks = _filterAndSortTasks(allTasks);

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              allTasks.isEmpty
                  ? 'Nenhuma tarefa ainda'
                  : 'Nenhuma tarefa encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              allTasks.isEmpty
                  ? 'Adicione sua primeira tarefa!'
                  : 'Ajuste os filtros para ver outras tarefas',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      color: Colors.white,
      child: Column(
        children: [
          // Campo de input para adicionar tarefa
          _buildAddTaskInput(),
          // Separador
          Container(
            height: 0.5,
            color: const Color(0xFFE1E1E1),
          ),
          // Lista de tarefas
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: filteredTasks.length,
              separatorBuilder: (context, index) => Container(
                height: 0.5,
                margin: const EdgeInsets.only(left: 52),
                color: const Color(0xFFE1E1E1),
              ),
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return TaskWidget(
                  task: task,
                  onTap: () => _openTaskSidePanel(context, task),
                  onCompletedChanged: (value) {
                    DependencyContainer.instance.taskController
                        .toggleTaskComplete(task.id);
                  },
                  onStarToggle: () {
                    DependencyContainer.instance.taskController
                        .toggleTaskStar(task.id);
                  },
                  onEdit: () => _editTask(context, task),
                  onDelete: () => _deleteTask(context, task),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTaskInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Placeholder para checkbox (ícone +)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFCCCCCC),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.add,
              size: 16,
              color: Color(0xFFCCCCCC),
            ),
          ),

          const SizedBox(width: 12),

          // Campo de input
          Expanded(
            child: TextField(
              controller: _addTaskController,
              decoration: const InputDecoration(
                hintText: 'Add an item',
                hintStyle: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2C2C2C),
              ),
              onSubmitted: (value) => _addQuickTask(value),
            ),
          ),
        ],
      ),
    );
  }

  void _addQuickTask(String title) {
    if (title.trim().isEmpty) return;

    final authController = Get.find<TodoistAuthController>();
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;

    final task = Task(
      id: 'task_$nowMs',
      title: title.trim(),
      listId: widget.taskList.id,
      createdById: authController.currentUser?.id ?? 'anonymous',
      createdAt: nowMs,
      updatedAt: nowMs,
    );

    // Criar tarefa usando o provider apropriado
    _createTaskQuick(task);

    // Limpar o campo
    _addTaskController.clear();
  }

  void _createTaskQuick(Task task) async {
    await DependencyContainer.instance.taskController.createTask(task);
  }

  void _openTaskSidePanel(BuildContext context, Task task) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.centerRight,
            child: Material(
              type: MaterialType.transparency,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height,
                child: TaskDetailSidePanel(task: task),
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }

  List<Task> _filterAndSortTasks(List<Task> tasks) {
    var filtered = tasks.where((task) {
      if (!_showCompleted && task.isCompleted) return false;
      if (_showOnlyStarred && !task.isStarred) return false;
      return true;
    }).toList();

    switch (_sortBy) {
      case 'priority':
        filtered.sort((a, b) {
          final priorityOrder = {
            TaskPriority.urgent: 0,
            TaskPriority.high: 1,
            TaskPriority.medium: 2,
            TaskPriority.low: 3,
          };
          return priorityOrder[a.priority]!
              .compareTo(priorityOrder[b.priority]!);
        });
        break;
      case 'due_date':
        filtered.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case 'created':
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
  }

  void _navigateToTaskDetail(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );
  }

  void _createTask(BuildContext context) async {
    final authController = Get.find<TodoistAuthController>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final taskController = DependencyContainer.instance.taskController;

    final task = await showDialog<Task>(
      context: context,
      builder: (context) => CreateTaskDialog(
        listId: widget.taskList.id,
        userId: authController.currentUser?.id ?? 'anonymous',
      ),
    );

    if (task != null) {
      try {
        await taskController.createTask(task);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Tarefa criada com sucesso!')),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Erro ao criar tarefa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editTask(BuildContext context, Task task) async {
    final authController = Get.find<TodoistAuthController>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final taskController = DependencyContainer.instance.taskController;

    final editedTask = await showDialog<Task>(
      context: context,
      builder: (context) => CreateTaskDialog(
        listId: widget.taskList.id,
        userId: authController.currentUser?.id ?? 'anonymous',
        editingTask: task,
      ),
    );

    if (editedTask != null) {
      try {
        await taskController.updateTask(editedTask.id, editedTask);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Tarefa atualizada com sucesso!')),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar tarefa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteTask(BuildContext context, Task task) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final taskController = DependencyContainer.instance.taskController;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content:
            Text('Tem certeza que deseja excluir a tarefa "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await taskController.deleteTask(task.id);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Tarefa excluída com sucesso!')),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir tarefa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
