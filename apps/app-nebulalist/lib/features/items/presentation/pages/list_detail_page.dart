import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/services_providers.dart';
import '../../../lists/presentation/providers/lists_provider.dart';
import '../providers/item_masters_provider.dart';
import '../providers/list_items_provider.dart';
import '../widgets/add_item_to_list_dialog.dart';
import '../widgets/list_item_tile.dart';
import '../widgets/list_items_empty_state.dart';

/// Page showing list details and its items
/// Displays list header with stats and list items with actions
class ListDetailPage extends ConsumerWidget {
  final String listId;

  const ListDetailPage({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final listsAsync = ref.watch(listsProvider);
    final listItemsAsync = ref.watch(listItemsProvider(listId));
    final itemMastersAsync = ref.watch(itemMastersProvider);

    return Scaffold(
      appBar: AppBar(
        title: listsAsync.when(
          data: (lists) {
            final list = lists.firstWhere(
              (l) => l.id == listId,
              orElse: () => lists.first,
            );
            return Text(list.name);
          },
          loading: () => const Text('Carregando...'),
          error: (_, __) => const Text('Lista'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareList(context, ref),
            tooltip: 'Compartilhar',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(listItemsProvider(listId));
              ref.invalidate(listsProvider);
            },
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // List header with stats
          listsAsync.when(
            data: (lists) {
              final list = lists.firstWhere(
                (l) => l.id == listId,
                orElse: () => lists.first,
              );

              final totalItems = list.itemCount;
              final completedItems = list.completedCount;
              final completionPercent = totalItems > 0
                  ? (completedItems / totalItems * 100).toInt()
                  : 0;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    if (list.description.isNotEmpty) ...[
                      Text(
                        list.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Stats row
                    Row(
                      children: [
                        // Completion stats
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$completedItems/$totalItems concluídos',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Completion percentage
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$completionPercent%',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalItems > 0 ? completedItems / totalItems : 0,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),

          // List items
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(listItemsProvider(listId));
              },
              child: listItemsAsync.when(
                data: (listItems) {
                  if (listItems.isEmpty) {
                    return ListItemsEmptyState(
                      onAddItems: () => _showAddItemsDialog(context, ref),
                    );
                  }

                  return itemMastersAsync.when(
                    data: (itemMasters) {
                      // Create a map for quick lookup
                      final itemMastersMap = {
                        for (var item in itemMasters) item.id: item,
                      };

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: listItems.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final listItem = listItems[index];
                          final itemMaster =
                              itemMastersMap[listItem.itemMasterId];

                          return ListItemTile(
                            listItem: listItem,
                            itemMaster: itemMaster,
                            onToggleComplete: () {
                              ref
                                  .read(
                                      listItemsProvider(listId).notifier)
                                  .toggleCompletion(listItem.id);
                            },
                            onDelete: () {
                              ref
                                  .read(
                                      listItemsProvider(listId).notifier)
                                  .removeItem(listItem.id);
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, _) => Center(
                      child: Text('Erro ao carregar itens: $error'),
                    ),
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
                          ref.invalidate(listItemsProvider(listId));
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
        onPressed: () => _showAddItemsDialog(context, ref),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Adicionar Itens'),
      ),
    );
  }

  /// Show dialog to add items to list
  Future<void> _showAddItemsDialog(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => AddItemToListDialog(
        ref: ref,
        listId: listId,
      ),
    );
  }

  /// Share list with formatted text
  Future<void> _shareList(BuildContext context, WidgetRef ref) async {
    try {
      final listsAsync = ref.read(listsProvider);
      final listItemsAsync = ref.read(listItemsProvider(listId));
      final itemMastersAsync = ref.read(itemMastersProvider);

      await listsAsync.when(
        data: (lists) async {
          final list = lists.firstWhere(
            (l) => l.id == listId,
            orElse: () => lists.first,
          );

          // Get item names if available
          List<String>? itemNames;
          listItemsAsync.whenData((listItems) async {
            itemMastersAsync.whenData((itemMasters) {
              final itemMastersMap = {
                for (var item in itemMasters) item.id: item,
              };

              itemNames = listItems
                  .map((listItem) {
                    final master = itemMastersMap[listItem.itemMasterId];
                    return master?.name ?? 'Item';
                  })
                  .toList();
            });
          });

          // Call share service
          final shareService = ref.read(shareServiceProvider);
          await shareService.shareList(
            listName: list.name,
            description: list.description,
            totalItems: list.itemCount,
            completedItems: list.completedCount,
            itemNames: itemNames,
          );

          // Track share event
          await ref.read(appAnalyticsServiceProvider).logListShared(
                listId: list.id,
              );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lista compartilhada com sucesso'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        loading: () {},
        error: (error, _) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao compartilhar: $error'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
