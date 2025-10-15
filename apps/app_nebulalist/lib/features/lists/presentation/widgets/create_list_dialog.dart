import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';
import '../../domain/entities/list_entity.dart';
import '../providers/lists_provider.dart';

/// Dialog for creating or editing a list
/// Uses ConsumerStatefulWidget for local form state + Riverpod
class CreateListDialog extends ConsumerStatefulWidget {
  final ListEntity? existingList;
  final WidgetRef ref;

  const CreateListDialog({
    super.key,
    this.existingList,
    required this.ref,
  });

  @override
  ConsumerState<CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends ConsumerState<CreateListDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingList?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingList?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingList != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Lista' : 'Nova Lista'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da lista *',
                  hintText: 'Ex: Compras do mês',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  hintText: 'Adicione uma descrição...',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 500,
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return 'Descrição muito longa (máx. 500 caracteres)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),

              // Info text
              Text(
                isEditing
                    ? 'Alterações serão salvas automaticamente'
                    : 'Você pode adicionar itens depois de criar a lista',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveList,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(isEditing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }

  Future<void> _saveList() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(listsNotifierProvider.notifier);

      if (widget.existingList != null) {
        // Update existing list
        final updatedList = ListEntity(
          id: widget.existingList!.id,
          name: _nameController.text.trim(),
          ownerId: widget.existingList!.ownerId,
          description: _descriptionController.text.trim(),
          tags: widget.existingList!.tags,
          category: widget.existingList!.category,
          isFavorite: widget.existingList!.isFavorite,
          isArchived: widget.existingList!.isArchived,
          createdAt: widget.existingList!.createdAt,
          updatedAt: DateTime.now(),
          shareToken: widget.existingList!.shareToken,
          isShared: widget.existingList!.isShared,
          archivedAt: widget.existingList!.archivedAt,
          itemCount: widget.existingList!.itemCount,
          completedCount: widget.existingList!.completedCount,
        );

        await notifier.updateList(updatedList);
      } else {
        // Create new list
        await notifier.createList(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingList != null
                  ? 'Lista atualizada com sucesso'
                  : 'Lista criada com sucesso',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
