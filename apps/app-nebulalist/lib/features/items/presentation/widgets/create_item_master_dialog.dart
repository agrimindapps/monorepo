import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/item_master_entity.dart';
import '../providers/item_masters_provider.dart';

/// Dialog for creating or editing an ItemMaster
/// Allows user to set name, description, category, price estimate, and tags
class CreateItemMasterDialog extends ConsumerStatefulWidget {
  final ItemMasterEntity? existingItem;
  final WidgetRef ref;

  const CreateItemMasterDialog({
    super.key,
    this.existingItem,
    required this.ref,
  });

  @override
  ConsumerState<CreateItemMasterDialog> createState() =>
      _CreateItemMasterDialogState();
}

class _CreateItemMasterDialogState
    extends ConsumerState<CreateItemMasterDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _brandController;
  late TextEditingController _notesController;
  late TextEditingController _tagsController;
  late String _selectedCategory;
  bool _isLoading = false;

  // Available categories
  static const List<Map<String, dynamic>> _categories = [
    {'id': 'compras', 'label': 'Compras', 'icon': Icons.shopping_cart},
    {'id': 'mercado', 'label': 'Mercado', 'icon': Icons.local_grocery_store},
    {'id': 'farmacia', 'label': 'Farmácia', 'icon': Icons.local_pharmacy},
    {'id': 'higiene', 'label': 'Higiene', 'icon': Icons.soap},
    {'id': 'limpeza', 'label': 'Limpeza', 'icon': Icons.cleaning_services},
    {'id': 'trabalho', 'label': 'Trabalho', 'icon': Icons.work},
    {'id': 'lazer', 'label': 'Lazer', 'icon': Icons.sports_esports},
    {'id': 'outros', 'label': 'Outros', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingItem?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingItem?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.existingItem?.estimatedPrice?.toStringAsFixed(2) ?? '',
    );
    _brandController = TextEditingController(
      text: widget.existingItem?.preferredBrand ?? '',
    );
    _notesController = TextEditingController(
      text: widget.existingItem?.notes ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.existingItem?.tags.join(', ') ?? '',
    );
    _selectedCategory = widget.existingItem?.category ?? 'outros';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingItem != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Item' : 'Novo Item'),
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
                  labelText: 'Nome do item *',
                  hintText: 'Ex: Arroz integral',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                textCapitalization: TextCapitalization.words,
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (value.trim().isEmpty) {
                    return 'Nome deve ter pelo menos 1 caractere';
                  }
                  if (value.trim().length > 100) {
                    return 'Nome muito longo (máx. 100 caracteres)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'] as String,
                    child: Row(
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(category['label'] as String),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  hintText: 'Adicione detalhes sobre o item...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
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

              const SizedBox(height: 16),

              // Price estimate field
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço estimado (opcional)',
                  hintText: 'Ex: 15.90',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: 'R\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final price = double.tryParse(value);
                    if (price == null) {
                      return 'Preço inválido';
                    }
                    if (price < 0) {
                      return 'Preço não pode ser negativo';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Preferred brand field
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Marca preferida (opcional)',
                  hintText: 'Ex: Tio João',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                textCapitalization: TextCapitalization.words,
                maxLength: 100,
              ),

              const SizedBox(height: 16),

              // Tags field
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (opcional)',
                  hintText: 'Ex: integral, grão longo, 1kg',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_offer),
                  helperText: 'Separe as tags por vírgula',
                ),
                textCapitalization: TextCapitalization.words,
                maxLength: 200,
              ),

              const SizedBox(height: 8),

              // Info text
              Text(
                isEditing
                    ? 'Alterações serão salvas automaticamente'
                    : 'Este item ficará disponível no seu banco para reutilizar',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
          onPressed: _isLoading ? null : _saveItem,
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

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(itemMastersProvider.notifier);

      // Parse tags
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      // Parse price
      final priceText = _priceController.text.trim();
      final estimatedPrice =
          priceText.isNotEmpty ? double.tryParse(priceText) : null;

      if (widget.existingItem != null) {
        // Update existing item
        final updatedItem = ItemMasterEntity(
          id: widget.existingItem!.id,
          ownerId: widget.existingItem!.ownerId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          tags: tags,
          category: _selectedCategory,
          photoUrl: widget.existingItem!.photoUrl,
          estimatedPrice: estimatedPrice,
          preferredBrand: _brandController.text.trim().isEmpty
              ? null
              : _brandController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          usageCount: widget.existingItem!.usageCount,
          createdAt: widget.existingItem!.createdAt,
          updatedAt: DateTime.now(),
        );

        await notifier.updateItemMaster(updatedItem);
      } else {
        // Create new item
        await notifier.createItemMaster(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          tags: tags,
          category: _selectedCategory,
          estimatedPrice: estimatedPrice,
          preferredBrand: _brandController.text.trim().isEmpty
              ? null
              : _brandController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingItem != null
                  ? 'Item atualizado com sucesso'
                  : 'Item criado com sucesso',
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
