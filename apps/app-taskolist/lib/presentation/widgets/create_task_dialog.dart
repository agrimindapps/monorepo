import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/task_entity.dart';
import '../providers/auth_providers.dart';
import '../providers/task_providers.dart';

class CreateTaskDialog extends ConsumerStatefulWidget {
  const CreateTaskDialog({super.key});

  @override
  ConsumerState<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends ConsumerState<CreateTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createTask() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = ref.read(authNotifierProvider).value;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado')),
        );
        return;
      }

      try {
        const uuid = Uuid();
        // Criar a task usando o notifier
        await ref.read(taskNotifierProvider.notifier).createTask(
          TaskEntity(
            id: uuid.v4(),
            title: _titleController.text,
            description: _descriptionController.text.isEmpty 
              ? null 
              : _descriptionController.text,
            listId: 'default', // Por enquanto usar lista padrão
            createdById: currentUser.id,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao criar tarefa: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createTask,
          child: const Text('Create'),
        ),
      ],
    );
  }
}