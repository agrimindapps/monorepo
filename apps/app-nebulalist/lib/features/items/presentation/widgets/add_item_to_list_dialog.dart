import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/item_master_entity.dart';
import '../../domain/entities/list_item_entity.dart' as entities;
import '../providers/item_masters_provider.dart';
import '../providers/list_items_provider.dart';

/// Dialog for adding items from the ItemMaster bank to a list
/// Shows grid of available ItemMasters with search, then quantity/priority inputs
class AddItemToListDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final String listId;

  const AddItemToListDialog({
    super.key,
    required this.ref,
    required this.listId,
  });

  @override
  ConsumerState<AddItemToListDialog> createState() =>
      _AddItemToListDialogState();
}

class _AddItemToListDialogState extends ConsumerState<AddItemToListDialog> {
  ItemMasterEntity? _selectedItem;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final TextEditingController _notesController = TextEditingController();
  entities.Priority _selectedPriority = entities.Priority.normal;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_selectedItem == null) {
      // Step 1: Select ItemMaster
      return _buildItemSelectionDialog(theme);
    } else {
      // Step 2: Configure quantity and priority
      return _buildItemConfigurationDialog(theme);
    }
  }

  /// Build item selection dialog (step 1)
  Widget _buildItemSelectionDialog(ThemeData theme) {
    final itemsAsync = ref.watch(itemMastersProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 700,
        ),
        child: Column(
          children: [
            // Header
            AppBar(
              title: const Text('Selecionar Item'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar itens...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            // Items grid
            Expanded(
              child: itemsAsync.when(
                data: (items) {
                  final filteredItems = _filterItems(items);

                  if (filteredItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            items.isEmpty
                                ? Icons.inventory_2_outlined
                                : Icons.search_off,
                            size: 80,
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            items.isEmpty
                                ? 'Nenhum item cadastrado'
                                : 'Nenhum item encontrado',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            items.isEmpty
                                ? 'Crie itens na aba Itens primeiro'
                                : 'Tente ajustar a busca',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _buildItemCard(item, theme);
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Text('Erro: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build item card for selection
  Widget _buildItemCard(ItemMasterEntity item, ThemeData theme) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedItem = item;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Icon(
                _getCategoryIcon(item.category),
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),

              // Name
              Expanded(
                child: Text(
                  item.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 4),

              // Category
              Text(
                item.category,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build item configuration dialog (step 2)
  Widget _buildItemConfigurationDialog(ThemeData theme) {
    return AlertDialog(
      title: const Text('Configurar Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected item info
            Card(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(_selectedItem!.category),
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedItem!.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _selectedItem!.category,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          _selectedItem = null;
                          _searchQuery = '';
                        });
                      },
                      tooltip: 'Trocar item',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quantity field
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                hintText: 'Ex: 2, 1kg, 500ml',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_basket),
              ),
              maxLength: 20,
            ),

            const SizedBox(height: 16),

            // Priority dropdown
            DropdownButtonFormField<entities.Priority>(
              initialValue: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Prioridade',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: entities.Priority.values.map((priority) {
                return DropdownMenuItem<entities.Priority>(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(
                        _getPriorityIcon(priority),
                        size: 20,
                        color: _getPriorityColor(priority),
                      ),
                      const SizedBox(width: 12),
                      Text(priority.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Notes field
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Ex: Comprar na promoção',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLength: 200,
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  setState(() {
                    _selectedItem = null;
                    _searchQuery = '';
                  });
                },
          child: const Text('Voltar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _addItemToList,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Adicionar'),
        ),
      ],
    );
  }

  /// Filter items by search query
  List<ItemMasterEntity> _filterItems(List<ItemMasterEntity> items) {
    if (_searchQuery.isEmpty) return items;

    return items.where((item) {
      final nameLower = item.name.toLowerCase();
      final descLower = item.description.toLowerCase();
      final categoryLower = item.category.toLowerCase();

      return nameLower.contains(_searchQuery) ||
          descLower.contains(_searchQuery) ||
          categoryLower.contains(_searchQuery);
    }).toList();
  }

  /// Add item to list
  Future<void> _addItemToList() async {
    if (_selectedItem == null) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(listItemsProvider(widget.listId).notifier).addItemToList(
            itemMasterId: _selectedItem!.id,
            quantity: _quantityController.text.trim(),
            priority: _selectedPriority,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedItem!.name} adicionado à lista'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar item: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Get icon for category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'compras':
        return Icons.shopping_cart;
      case 'mercado':
        return Icons.local_grocery_store;
      case 'farmacia':
        return Icons.local_pharmacy;
      case 'higiene':
        return Icons.soap;
      case 'limpeza':
        return Icons.cleaning_services;
      case 'trabalho':
        return Icons.work;
      case 'lazer':
        return Icons.sports_esports;
      default:
        return Icons.inventory_2;
    }
  }

  /// Get icon for priority
  IconData _getPriorityIcon(entities.Priority priority) {
    switch (priority) {
      case entities.Priority.urgent:
        return Icons.priority_high;
      case entities.Priority.high:
        return Icons.arrow_upward;
      case entities.Priority.normal:
        return Icons.remove;
      case entities.Priority.low:
        return Icons.arrow_downward;
    }
  }

  /// Get color for priority
  Color _getPriorityColor(entities.Priority priority) {
    switch (priority) {
      case entities.Priority.urgent:
        return const Color(0xFFF44336); // Red
      case entities.Priority.high:
        return const Color(0xFFFF9800); // Orange
      case entities.Priority.normal:
        return const Color(0xFF9E9E9E); // Grey
      case entities.Priority.low:
        return const Color(0xFF4CAF50); // Green
    }
  }
}
