import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../domain/create_task.dart';
import '../../domain/recurrence_entity.dart';
import '../../domain/task_entity.dart';
import '../../domain/update_task.dart';
import '../../providers/task_providers.dart';

class CreateEditTaskPage extends ConsumerStatefulWidget {
  final TaskEntity? task;
  final String? taskListId;

  const CreateEditTaskPage({super.key, this.task, this.taskListId});

  @override
  ConsumerState<CreateEditTaskPage> createState() => _CreateEditTaskPageState();
}

class _CreateEditTaskPageState extends ConsumerState<CreateEditTaskPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskPriority _selectedPriority;
  late bool _isStarred;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
    _descriptionController = TextEditingController(
      text: widget.task?.description,
    );
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _isStarred = widget.task?.isStarred ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um título para a tarefa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final task = TaskEntity(
      id: widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      priority: _selectedPriority,
      isStarred: _isStarred,
      listId: widget.taskListId ?? widget.task?.listId ?? '',
      createdById: widget.task?.createdById ?? '',
      assignedToId: widget.task?.assignedToId,
      status: widget.task?.status ?? TaskStatus.pending,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      dueDate: widget.task?.dueDate,
      reminderDate: widget.task?.reminderDate,
      position: widget.task?.position ?? 0,
      tags: widget.task?.tags ?? const [],
      parentTaskId: widget.task?.parentTaskId,
      notes: widget.task?.notes,
      recurrence: widget.task?.recurrence ?? const RecurrencePattern(),
    );

    try {
      if (isEditing) {
        final updateTask = ref.read(updateTaskProvider);
        final result = await updateTask(UpdateTaskParams(task: task));

        result.fold((failure) => throw Exception(failure.message), (_) {});
      } else {
        final createTask = ref.read(createTaskProvider);
        final result = await createTask(CreateTaskParams(task: task));

        result.fold((failure) => throw Exception(failure.message), (_) {});
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Tarefa atualizada com sucesso!'
                : 'Tarefa criada com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar tarefa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Digite o título da tarefa',
                border: OutlineInputBorder(),
              ),
              autofocus: !isEditing,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Descrição
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Adicione mais detalhes (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Prioridade
            Text('Prioridade', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<TaskPriority>(
              segments: const [
                ButtonSegment(
                  value: TaskPriority.low,
                  label: Text('Baixa'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: TaskPriority.medium,
                  label: Text('Média'),
                  icon: Icon(Icons.remove),
                ),
                ButtonSegment(
                  value: TaskPriority.high,
                  label: Text('Alta'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_selectedPriority},
              onSelectionChanged: (Set<TaskPriority> newSelection) {
                setState(() {
                  _selectedPriority = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),

            // Estrelado
            SwitchListTile(
              title: const Text('Tarefa importante'),
              subtitle: const Text('Adicionar aos favoritos'),
              value: _isStarred,
              onChanged: (value) {
                setState(() {
                  _isStarred = value;
                });
              },
              secondary: Icon(
                _isStarred ? Icons.star : Icons.star_outline,
                color: _isStarred
                    ? Colors.amber
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
