import 'package:flutter/material.dart';
import '../models/favorito_defensivo_model.dart';
import '../constants/favoritos_design_tokens.dart';

class DefensivoFavoritoListItem extends StatelessWidget {
  final FavoritoDefensivoModel defensivo;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const DefensivoFavoritoListItem({
    super.key,
    required this.defensivo,
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
            color: Colors.black.withOpacity(0.05),
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
                    color: FavoritosDesignTokens.defensivosColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: FavoritosDesignTokens.defensivosColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        defensivo.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        defensivo.displayIngredient,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (defensivo.displayClass.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          defensivo.displayClass,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: FavoritosDesignTokens.defensivosColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
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