import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../features/tasks/domain/task_entity.dart';
import '../../features/tasks/presentation/providers/task_notifier.dart';
import 'create_subtask_dialog.dart';

class SubtaskListWidget extends ConsumerWidget {
  final String parentTaskId;

  const SubtaskListWidget({super.key, required this.parentTaskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtasksState = ref.watch(subtasksProvider(parentTaskId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Subtarefas',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showCreateSubtaskDialog(context, parentTaskId),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Adicionar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        subtasksState.when(
          loading:
              () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
          error:
              (error, stackTrace) => Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Erro ao carregar subtarefas: $error'),
                      ),
                    ],
                  ),
                ),
              ),
          data: (subtasks) {
            if (subtasks.isEmpty) {
              return Card(
                color: Colors.grey[50],
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.checklist, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Nenhuma subtarefa adicionada'),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children:
                  subtasks.map((subtask) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        dense: true,
                        leading: Checkbox(
                          value: subtask.status == TaskStatus.completed,
                          onChanged: (value) {
                            final newStatus =
                                value == true
                                    ? TaskStatus.completed
                                    : TaskStatus.pending;
                            final updatedSubtask = subtask.copyWith(
                              status: newStatus,
                              updatedAt: DateTime.now(),
                            );
                            ref
                                .read(taskNotifierProvider.notifier)
                                .updateSubtask(updatedSubtask);
                          },
                        ),
                        title: Text(
                          subtask.title,
                          style: TextStyle(
                            decoration:
                                subtask.status == TaskStatus.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                            fontSize: 14,
                          ),
                        ),
                        subtitle:
                            subtask.description != null
                                ? Text(
                                  subtask.description!,
                                  style: const TextStyle(fontSize: 12),
                                )
                                : null,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditSubtaskDialog(context, subtask);
                            } else if (value == 'delete') {
                              _deleteSubtask(context, ref, subtask);
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 16),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Excluir',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showCreateSubtaskDialog(BuildContext context, String parentTaskId) {
    showDialog<dynamic>(
      context: context,
      builder: (context) => CreateSubtaskDialog(parentTaskId: parentTaskId),
    );
  }

  void _showEditSubtaskDialog(BuildContext context, TaskEntity subtask) {
    showDialog<dynamic>(
      context: context,
      builder:
          (context) => CreateSubtaskDialog(
            parentTaskId: subtask.parentTaskId!,
            editingSubtask: subtask,
          ),
    );
  }

  Future<void> _deleteSubtask(
    BuildContext context,
    WidgetRef ref,
    TaskEntity subtask,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Excluir Subtarefa'),
            content: Text('Tem certeza que deseja excluir "${subtask.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(taskNotifierProvider.notifier)
            .deleteSubtask(subtask.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subtarefa excluída com sucesso!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir subtarefa: $e')),
          );
        }
      }
    }
  }
}
