import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/item_master_entity.dart';
import '../providers/item_masters_provider.dart';
import '../widgets/create_item_master_dialog.dart';
import '../widgets/item_master_card.dart';
import '../widgets/item_master_empty_state.dart';

/// Page displaying the user's ItemMaster bank
/// Shows grid of reusable items with search and category filters
class ItemsBankPage extends ConsumerStatefulWidget {
  const ItemsBankPage({super.key});

  @override
  ConsumerState<ItemsBankPage> createState() => _ItemsBankPageState();
}

class _ItemsBankPageState extends ConsumerState<ItemsBankPage> {
  String _searchQuery = '';
  String _selectedCategory = 'todos';
  final TextEditingController _searchController = TextEditingController();

  // Available categories
  static const List<Map<String, dynamic>> _categories = [
    {'id': 'todos', 'label': 'Todos', 'icon': Icons.apps},
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemMastersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
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
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['id'];

                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.onSecondaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 4),
                      Text(category['label'] as String),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category['id'] as String;
                    });
                  },
                  selectedColor: theme.colorScheme.secondaryContainer,
                );
              },
            ),
          ),

          // Items grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(itemMastersProvider);
              },
              child: itemsAsync.when(
                data: (items) {
                  // Apply filters
                  final filteredItems = _filterItems(items);

                  if (filteredItems.isEmpty) {
                    if (items.isEmpty) {
                      return const ItemMasterEmptyState();
                    } else {
                      // No results for current filters
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: theme.colorScheme.primary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum item encontrado',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tente ajustar os filtros',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive columns: 2 on mobile, 3+ on tablet
                      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return ItemMasterCard(
                            itemMaster: item,
                            onTap: () {
                              // TODO: Navigate to item detail or show bottom sheet
                              _showItemDetail(item);
                            },
                            onEdit: () => _showEditDialog(item),
                            onDelete: () => _showDeleteConfirmation(item),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar itens',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.invalidate(itemMastersProvider);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Novo Item'),
      ),
    );
  }

  /// Filter items by search query and category
  List<ItemMasterEntity> _filterItems(List<ItemMasterEntity> items) {
    var filtered = items;

    // Filter by category
    if (_selectedCategory != 'todos') {
      filtered = filtered
          .where((item) => item.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final nameLower = item.name.toLowerCase();
        final descLower = item.description.toLowerCase();
        final tagsLower = item.tags.map((t) => t.toLowerCase()).join(' ');

        return nameLower.contains(_searchQuery) ||
            descLower.contains(_searchQuery) ||
            tagsLower.contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  /// Show create item dialog
  Future<void> _showCreateDialog() async {
    await showDialog(
      context: context,
      builder: (context) => CreateItemMasterDialog(ref: ref),
    );
  }

  /// Show edit item dialog
  Future<void> _showEditDialog(ItemMasterEntity item) async {
    await showDialog(
      context: context,
      builder: (context) => CreateItemMasterDialog(
        ref: ref,
        existingItem: item,
      ),
    );
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(ItemMasterEntity item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Item'),
        content: Text(
          'Tem certeza que deseja remover "${item.name}"?\n\nEste item será removido de todas as listas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(itemMastersProvider.notifier)
            .deleteItemMaster(item.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item removido com sucesso'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao remover item: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  /// Show item detail bottom sheet
  void _showItemDetail(ItemMasterEntity item) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditDialog(item);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Category badge
                Chip(
                  label: Text(item.category),
                  avatar: Icon(
                    _getCategoryIcon(item.category),
                    size: 16,
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                if (item.description.isNotEmpty) ...[
                  Text(
                    'Descrição',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(item.description),
                  const SizedBox(height: 16),
                ],

                // Usage stats
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${item.usageCount}x',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Usado',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (item.hasPrice)
                          Column(
                            children: [
                              Text(
                                'R\$ ${item.estimatedPrice!.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Estimado',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

                // Tags
                if (item.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Tags',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: item.tags
                        .map((tag) => Chip(
                              label: Text(tag),
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// Get icon for category
  IconData _getCategoryIcon(String category) {
    final found = _categories.firstWhere(
      (c) => c['id'] == category,
      orElse: () => _categories.last,
    );
    return found['icon'] as IconData;
  }
}
