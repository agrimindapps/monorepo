// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/realtime_task_controller.dart';
import '../dependency_injection.dart';
import '../models/task_model.dart';
import '../services/id_generation_service.dart';

/// Widget de exemplo mostrando como usar o RealtimeController na UI
///
/// Este widget demonstra:
/// - Como usar Provider pattern para state management
/// - Como usar Consumer<> para reatividade
/// - Como chamar métodos do controller
/// - Como lidar com estados de loading/error
class TaskListWidget extends StatelessWidget {
  final String listId;

  const TaskListWidget({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          // Indicador de status online/offline
          Obx(() {
            final taskController = Get.find<RealtimeTaskController>();
            return Icon(
              taskController.isOnline ? Icons.cloud_done : Icons.cloud_off,
              color: taskController.isOnline ? Colors.green : Colors.orange,
            );
          }),

          // Contador de tasks
          Obx(() {
            final taskController = Get.find<RealtimeTaskController>();
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Text('${taskController.items.length}'),
                backgroundColor: Colors.blue.shade100,
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Indicador de loading
          Obx(() {
            final taskController = Get.find<RealtimeTaskController>();
            return taskController.isLoading
                ? const LinearProgressIndicator()
                : const SizedBox.shrink();
          }),

          // Estatísticas rápidas
          Obx(() {
            final taskController = Get.find<RealtimeTaskController>();
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Pendentes', taskController.pendingTasksCount,
                      Colors.orange),
                  _buildStatCard('Completas',
                      taskController.completedTasksCount, Colors.green),
                  _buildStatCard('Favoritas',
                      taskController.starredTasks.length, Colors.amber),
                  _buildStatCard(
                      'Hoje', taskController.todayTasks.length, Colors.blue),
                ],
              ),
            );
          }),

          // Lista de tasks
          Expanded(
            child: StreamBuilder<List<Task>>(
              // Usar stream do repository filtrado
              stream: DependencyContainer.instance.taskRepository.tasksStream
                  .map((tasks) => tasks.where((task) => task.listId == listId).toList()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red.shade300),
                            const SizedBox(height: 16),
                            Text('Erro: ${snapshot.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => Get.find<RealtimeTaskController>().forcSync(),
                              child: const Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      );
                    }

                    final tasks = snapshot.data ?? [];

                    if (tasks.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.task_alt, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Nenhuma task encontrada'),
                            Text(
                              'Toque no + para criar sua primeira task',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => await Get.find<RealtimeTaskController>().forcSync(),
                      child: ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskTile(
                            task: task,
                            onToggleComplete: () =>
                                Get.find<RealtimeTaskController>().toggleTaskComplete(task.id),
                            onToggleStar: () =>
                                Get.find<RealtimeTaskController>().toggleTaskStar(task.id),
                            onEdit: () =>
                                _showEditDialog(context, task, Get.find<RealtimeTaskController>()),
                            onDelete: () => _showDeleteDialog(
                                context, task, Get.find<RealtimeTaskController>()),
                          );
                        },
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, Get.find<RealtimeTaskController>()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(
      BuildContext context, RealtimeTaskController controller) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration:
                  const InputDecoration(labelText: 'Descrição (opcional)'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;

              // Usar IDGenerationService para geração segura de ID
              final idService = IDGenerationService();
              final secureTaskId = idService.generateTaskId();

              final task = Task(
                id: secureTaskId,
                title: title,
                description: descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim(),
                listId: listId,
                createdById:
                    'current_user_id', // Obter do TodoistAuthController
                createdAt: DateTime.now().millisecondsSinceEpoch,
                updatedAt: DateTime.now().millisecondsSinceEpoch,
              );

              await controller.createTask(task);

              Navigator.of(context).pop();
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, Task task, RealtimeTaskController controller) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;

              final updatedTask = task.copyWith(
                title: title,
                description: descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim(),
                updatedAt: DateTime.now().millisecondsSinceEpoch,
              );
              await controller.updateTask(task.id, updatedTask);

              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, Task task, RealtimeTaskController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Task'),
        content: Text('Tem certeza que deseja deletar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteTask(task.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }
}

/// Widget de tile individual para cada task
class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onToggleStar;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onToggleStar,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggleComplete(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: task.description != null
            ? Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador de prioridade
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),

            // Botão de favorito
            IconButton(
              icon: Icon(
                task.isStarred ? Icons.star : Icons.star_border,
                color: task.isStarred ? Colors.amber : null,
              ),
              onPressed: onToggleStar,
            ),

            // Menu de ações
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Deletar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return Colors.red;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.medium:
        return Colors.yellow;
      case TaskPriority.low:
        return Colors.green;
    }
  }
}
