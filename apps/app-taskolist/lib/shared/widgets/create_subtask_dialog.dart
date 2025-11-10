import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';

import '../../features/tasks/domain/task_entity.dart';
import '../../features/tasks/presentation/providers/task_notifier.dart';
import '../providers/auth_providers.dart';

class CreateSubtaskDialog extends ConsumerStatefulWidget {
  final String parentTaskId;
  final TaskEntity? editingSubtask;

  const CreateSubtaskDialog({
    super.key,
    required this.parentTaskId,
    this.editingSubtask,
  });

  @override
  ConsumerState<CreateSubtaskDialog> createState() =>
      _CreateSubtaskDialogState();
}

class _CreateSubtaskDialogState extends ConsumerState<CreateSubtaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.editingSubtask?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.editingSubtask?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.editingSubtask != null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(authNotifierProvider).value;
    if (currentUser == null) {
      _showError('Usuário não autenticado');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        final updatedSubtask = widget.editingSubtask!.copyWith(
          title: _titleController.text.trim(),
          description:
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
          updatedAt: DateTime.now(),
        );

        await ref
            .read(taskNotifierProvider.notifier)
            .updateSubtask(updatedSubtask);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subtarefa atualizada com sucesso!')),
          );
        }
      } else {
        final newSubtask = TaskEntity(
          id: FirebaseFirestore.instance.collection('_').doc().id,
          title: _titleController.text.trim(),
          description:
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
          listId: 'default',
          createdById: currentUser.id,
          parentTaskId: widget.parentTaskId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await ref
            .read(taskNotifierProvider.notifier)
            .createSubtask(newSubtask);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subtarefa criada com sucesso!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(
          'Erro ao ${_isEditing ? 'atualizar' : 'criar'} subtarefa: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Editar Subtarefa' : 'Nova Subtarefa'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, insira um título';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(_isEditing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }
}
