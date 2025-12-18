import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../features/tasks/domain/task_entity.dart';
import '../../features/tasks/presentation/providers/task_notifier.dart';
import 'create_subtask_dialog.dart';
import 'quick_add_subtask_field.dart';

class SubtaskListWidget extends ConsumerWidget {
  final String parentTaskId;

  const SubtaskListWidget({super.key, required this.parentTaskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtasksState = ref.watch<AsyncValue<List<TaskEntity>>>(subtasksProvider(parentTaskId));

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
              (Object error, StackTrace stackTrace) => Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Erro ao carregar subtarefas: $error',
                          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          data: (List<TaskEntity> subtasks) {
            return Column(
              children: [
                if (subtasks.isEmpty)
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.checklist, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            'Nenhuma subtarefa adicionada',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...subtasks.map((TaskEntity subtask) {
                    return Dismissible(
                      key: Key(subtask.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await _showDeleteConfirmation(context, subtask);
                      },
                      onDismissed: (direction) {
                        _deleteSubtask(context, ref, subtask, confirmed: true);
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          dense: true,
                          leading: Checkbox(
                            value: subtask.status == TaskStatus.completed,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              final newStatus =
                                  value == true
                                      ? TaskStatus.completed
                                      : TaskStatus.pending;
                              final updatedSubtask = subtask.copyWith(
                                status: newStatus,
                                updatedAt: DateTime.now(),
                              );
                              ref
                                  .read(taskProvider.notifier)
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
                                          color: AppColors.error,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Excluir',
                                          style: TextStyle(color: AppColors.error),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                // Quick Add Field
                QuickAddSubtaskField(parentTaskId: parentTaskId),
              ],
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

  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    TaskEntity subtask,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Excluir Subtarefa'),
                content: Text(
                  'Tem certeza que deseja excluir "${subtask.title}"?',
                ),
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
        ) ??
        false;
  }

  Future<void> _deleteSubtask(
    BuildContext context,
    WidgetRef ref,
    TaskEntity subtask, {
    bool confirmed = false,
  }) async {
    if (!confirmed) {
      final shouldDelete = await _showDeleteConfirmation(context, subtask);
      if (!shouldDelete) return;
    }

    if (context.mounted) {
      try {
        await ref.read(taskProvider.notifier).deleteSubtask(subtask.id);
        HapticFeedback.mediumImpact();
        if (context.mounted && !confirmed) {
          // Only show snackbar if not dismissed (dismissible handles its own removal)
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
