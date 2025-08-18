import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/favoritos_controller.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/defensivo_favorito_list_item.dart';
import '../models/view_mode.dart';

class DefensivosTab extends StatelessWidget {
  final FavoritosController controller;

  const DefensivosTab({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritosController>(
      builder: (context, controller, _) {
        final data = controller.favoritosData;
        final items = data.defensivosFiltered;
        final hasSearch = controller.hasActiveSearch(0);
        final viewMode = controller.getViewModeForTab(0);

        if (items.isEmpty) {
          return EmptyStateWidget(
            tabIndex: 0,
            hasSearch: hasSearch,
            onClearSearch: hasSearch ? () => controller.clearSearch(0) : null,
          );
        }

      if (viewMode == ViewMode.list) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final defensivo = items[index];
            return DefensivoFavoritoListItem(
              defensivo: defensivo,
              onTap: () => controller.goToDefensivoDetails(defensivo),
              onRemove: () => controller.removeFavoritoDefensivo(defensivo),
            );
          },
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final defensivo = items[index];
          return _DefensivoGridItem(
            defensivo: defensivo,
            onTap: () => controller.goToDefensivoDetails(defensivo),
            onRemove: () => controller.removeFavoritoDefensivo(defensivo),
          );
        },
      );
      },
    );
  }
}

class _DefensivoGridItem extends StatelessWidget {
  final dynamic defensivo;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _DefensivoGridItem({
    required this.defensivo,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Colors.green,
                        size: 18,
                      ),
                    ),
                    const Spacer(),
                    if (onRemove != null)
                      InkWell(
                        onTap: onRemove,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red.shade400,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        defensivo.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        defensivo.displayIngredient,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}