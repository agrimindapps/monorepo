import 'package:flutter/material.dart';

/// Empty state widget for expense list
///
/// **SRP**: Única responsabilidade de mostrar estado vazio
class ExpenseEmptyState extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;

  const ExpenseEmptyState({
    super.key,
    this.hasActiveFilters = false,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasActiveFilters ? Icons.search_off : Icons.receipt_long_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            hasActiveFilters
                ? 'Nenhuma despesa encontrada'
                : 'Nenhuma despesa registrada',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasActiveFilters
                ? 'Tente ajustar os filtros de pesquisa'
                : 'Comece adicionando sua primeira despesa',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          if (hasActiveFilters && onClearFilters != null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear),
              label: const Text('Limpar Filtros'),
            ),
          ],
        ],
      ),
    );
  }
}
