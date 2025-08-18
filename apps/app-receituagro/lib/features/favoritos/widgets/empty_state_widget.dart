import 'package:flutter/material.dart';
import '../constants/favoritos_design_tokens.dart';

class EmptyStateWidget extends StatelessWidget {
  final int tabIndex;
  final bool hasSearch;
  final VoidCallback? onClearSearch;

  const EmptyStateWidget({
    super.key,
    required this.tabIndex,
    this.hasSearch = false,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabColor = FavoritosDesignTokens.getColorForTab(tabIndex);
    final tabName = FavoritosDesignTokens.getTabName(tabIndex);
    final tabIcon = FavoritosDesignTokens.getIconForTab(tabIndex);

    return Container(
      padding: FavoritosDesignTokens.defaultPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: tabColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tabIcon,
              size: 40,
              color: tabColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            hasSearch 
              ? 'Nenhum resultado encontrado'
              : 'Nenhum $tabName favoritado',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
              ? 'Tente ajustar sua busca'
              : 'Comece explorando e salvando seus ${tabName.toLowerCase()} favoritos',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (hasSearch && onClearSearch != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onClearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Limpar busca'),
              style: TextButton.styleFrom(
                foregroundColor: tabColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}