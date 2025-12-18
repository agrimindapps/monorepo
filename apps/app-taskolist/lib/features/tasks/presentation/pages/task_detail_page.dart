import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/services/navigation_service.dart';
import '../../../../shared/widgets/subtask_list_widget.dart';
import '../../domain/task_entity.dart';
import '../providers/task_notifier.dart';

class TaskDetailPage extends ConsumerStatefulWidget {
  final TaskEntity task;
  final TaskDetailFocus? initialFocus;

  const TaskDetailPage({super.key, required this.task, this.initialFocus});

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskStatus _selectedStatus;
  late TaskPriority _selectedPriority;
  late bool _isStarred;
  String? _recurrenceRule;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );
    _selectedStatus = widget.task.status;
    _selectedPriority = widget.task.priority;
    _isStarred = widget.task.isStarred;
    // TODO: Implementar recurrence
    // _recurrenceRule = widget.task.recurrenceRule;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título não pode estar vazio')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        isStarred: _isStarred,
        // TODO: Implementar recurrence
        // recurrenceRule: _recurrenceRule,
        updatedAt: DateTime.now(),
      );

      await ref.read<TaskNotifier>(taskProvider.notifier).updateTask(updatedTask);

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarefa atualizada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar tarefa: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Excluir Tarefa'),
            content: const Text(
              'Tem certeza que deseja excluir esta tarefa? Esta ação não pode ser desfeita.',
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
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);

      try {
        await ref
            .read<TaskNotifier>(taskProvider.notifier)
            .deleteTask(widget.task.id);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa excluída com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir tarefa: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Tarefa' : 'Detalhes da Tarefa'),
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteTask,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isLoading ? null : _saveChanges,
            ),
          ],
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Título',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        hintText: 'Digite o título da tarefa',
                        border:
                            _isEditing
                                ? const OutlineInputBorder()
                                : InputBorder.none,
                        filled: !_isEditing,
                        fillColor: Colors.grey[100],
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        color: _isEditing ? null : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Descrição',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      enabled: _isEditing,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Digite a descrição da tarefa (opcional)',
                        border:
                            _isEditing
                                ? const OutlineInputBorder()
                                : InputBorder.none,
                        filled: !_isEditing,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TaskStatus>(
                      initialValue: _selectedStatus,
                      onChanged:
                          _isEditing
                              ? (status) {
                                if (status != null) {
                                  setState(() => _selectedStatus = status);
                                }
                              }
                              : null,
                      decoration: InputDecoration(
                        border:
                            _isEditing
                                ? const OutlineInputBorder()
                                : InputBorder.none,
                        filled: !_isEditing,
                        fillColor: Colors.grey[100],
                      ),
                      items:
                          TaskStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Row(
                                children: [
                                  Icon(
                                    status == TaskStatus.completed
                                        ? Icons.check_circle
                                        : status == TaskStatus.inProgress
                                        ? Icons.access_time
                                        : Icons.radio_button_unchecked,
                                    color:
                                        status == TaskStatus.completed
                                            ? Colors.green
                                            : status == TaskStatus.inProgress
                                            ? Colors.orange
                                            : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_getStatusName(status)),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Prioridade',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TaskPriority>(
                      initialValue: _selectedPriority,
                      onChanged:
                          _isEditing
                              ? (priority) {
                                if (priority != null) {
                                  setState(() => _selectedPriority = priority);
                                }
                              }
                              : null,
                      decoration: InputDecoration(
                        border:
                            _isEditing
                                ? const OutlineInputBorder()
                                : InputBorder.none,
                        filled: !_isEditing,
                        fillColor: Colors.grey[100],
                      ),
                      items:
                          TaskPriority.values.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.flag,
                                    color:
                                        priority == TaskPriority.urgent
                                            ? Colors.red
                                            : priority == TaskPriority.high
                                            ? Colors.orange
                                            : priority == TaskPriority.medium
                                            ? Colors.blue
                                            : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_getPriorityName(priority)),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),
                    CheckboxListTile(
                      title: const Text('Tarefa Favorita'),
                      subtitle: const Text('Marcar como importante'),
                      value: _isStarred,
                      onChanged:
                          _isEditing
                              ? (value) {
                                setState(() => _isStarred = value ?? false);
                              }
                              : null,
                      secondary: Icon(
                        _isStarred ? Icons.star : Icons.star_border,
                        color: _isStarred ? Colors.amber : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // TODO: Implementar RecurrenceSelector
                    // RecurrenceSelector(
                    //   currentRule: _recurrenceRule,
                    //   onChanged: _isEditing
                    //       ? (rule) {
                    //           setState(() => _recurrenceRule = rule);
                    //         }
                    //       : null,
                    // ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informações',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              'Criado em:',
                              _formatDate(widget.task.createdAt),
                            ),
                            _buildInfoRow(
                              'Atualizado em:',
                              _formatDate(widget.task.updatedAt),
                            ),
                            if (widget.task.dueDate != null)
                              _buildInfoRow(
                                'Vencimento:',
                                _formatDate(widget.task.dueDate!),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SubtaskListWidget(parentTaskId: widget.task.id),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusName(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pendente';
      case TaskStatus.inProgress:
        return 'Em Progresso';
      case TaskStatus.completed:
        return 'Concluída';
      case TaskStatus.cancelled:
        return 'Cancelada';
    }
  }

  String _getPriorityName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Baixa';
      case TaskPriority.medium:
        return 'Média';
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.urgent:
        return 'Urgente';
    }
  }
}
