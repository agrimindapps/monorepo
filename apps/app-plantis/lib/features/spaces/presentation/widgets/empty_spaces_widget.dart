import 'package:flutter/material.dart';

class EmptySpacesWidget extends StatelessWidget {
  final bool isSearching;
  final VoidCallback? onAddSpace;
  final VoidCallback? onClearSearch;

  const EmptySpacesWidget({
    super.key,
    this.isSearching = false,
    this.onAddSpace,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? Icons.search_off : Icons.home_work_outlined,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              isSearching ? 'Nenhum espaço encontrado' : 'Nenhum espaço criado',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              isSearching
                  ? 'Tente buscar por outro termo ou limpe a busca para ver todos os espaços.'
                  : 'Organize suas plantas criando espaços como sala, varanda, jardim, etc.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            if (isSearching) ...[
              OutlinedButton.icon(
                onPressed: onClearSearch,
                icon: const Icon(Icons.clear),
                label: const Text('Limpar busca'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onAddSpace,
                icon: const Icon(Icons.add),
                label: const Text('Criar espaço'),
              ),
            ] else ...[
              FilledButton.icon(
                onPressed: onAddSpace,
                icon: const Icon(Icons.add),
                label: const Text('Criar primeiro espaço'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}