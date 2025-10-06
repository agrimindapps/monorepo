import 'package:flutter/material.dart';

import '../constants/favoritos_design_tokens.dart';
import '../data/favorito_praga_model.dart';

class PragaFavoritoListItem extends StatelessWidget {
  final FavoritoPragaModel praga;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const PragaFavoritoListItem({
    super.key,
    required this.praga,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(FavoritosDesignTokens.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(FavoritosDesignTokens.borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FavoritosDesignTokens.borderRadius),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: FavoritosDesignTokens.pragasColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    FavoritosDesignTokens.pragasIcon,
                    color: FavoritosDesignTokens.pragasColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        praga.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (praga.displaySecondaryName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          praga.displaySecondaryName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: FavoritosDesignTokens.pragasColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          praga.displayType,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: FavoritosDesignTokens.pragasColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    if (onRemove != null)
                      IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                        onPressed: onRemove,
                        tooltip: 'Remover dos favoritos',
                      ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
