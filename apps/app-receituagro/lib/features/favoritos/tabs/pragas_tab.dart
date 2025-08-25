import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/favoritos_design_tokens.dart';
import '../controller/favoritos_controller.dart';
import '../models/favorito_praga_model.dart';
import '../models/view_mode.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/praga_favorito_list_item.dart';

class PragasTab extends StatelessWidget {
  final FavoritosController controller;

  const PragasTab({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritosController>(
      builder: (context, controller, _) {
      final data = controller.favoritosData;
      final items = data.pragasFiltered;
      final hasSearch = controller.hasActiveSearch(1);
      final viewMode = controller.getViewModeForTab(1);

      if (items.isEmpty) {
        return EmptyStateWidget(
          tabIndex: 1,
          hasSearch: hasSearch,
          onClearSearch: hasSearch ? () => controller.clearSearch(1) : null,
        );
      }

      if (viewMode == ViewMode.list) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final praga = items[index];
            return PragaFavoritoListItem(
              praga: praga,
              onTap: () => controller.goToPragaDetails(praga),
              onRemove: () => controller.removeFavoritoPraga(praga),
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
          final praga = items[index];
          return _PragaGridItem(
            praga: praga,
            onTap: () => controller.goToPragaDetails(praga),
            onRemove: () => controller.removeFavoritoPraga(praga),
          );
        },
      );
      },
    );
  }
}

class _PragaGridItem extends StatelessWidget {
  final FavoritoPragaModel praga;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _PragaGridItem({
    required this.praga,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DecoratedBox(
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
                        color: FavoritosDesignTokens.pragasColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        FavoritosDesignTokens.pragasIcon,
                        color: FavoritosDesignTokens.pragasColor,
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
                        praga.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (praga.displaySecondaryName.isNotEmpty)
                        Text(
                          praga.displaySecondaryName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: FavoritosDesignTokens.pragasColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          praga.displayType,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: FavoritosDesignTokens.pragasColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
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