import 'package:flutter/material.dart';

/// Empty state widget shown when a list has no items
class ListItemsEmptyState extends StatelessWidget {
  final VoidCallback? onAddItems;

  const ListItemsEmptyState({
    super.key,
    this.onAddItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_shopping_cart_outlined,
              size: 120,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum item nesta lista',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Adicione itens do seu banco para começar',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            if (onAddItems != null)
              FilledButton.icon(
                onPressed: onAddItems,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Itens'),
              )
            else
              Icon(
                Icons.arrow_downward,
                size: 48,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }
}
