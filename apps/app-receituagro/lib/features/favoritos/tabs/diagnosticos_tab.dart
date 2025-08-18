import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/favoritos_controller.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/diagnostico_favorito_list_item.dart';
import '../models/view_mode.dart';
import '../constants/favoritos_design_tokens.dart';

class DiagnosticosTab extends StatelessWidget {
  final FavoritosController controller;

  const DiagnosticosTab({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritosController>(
      builder: (context, controller, _) {
      final data = controller.favoritosData;
      final items = data.diagnosticosFiltered;
      final hasSearch = controller.hasActiveSearch(2);
      final viewMode = controller.getViewModeForTab(2);

      if (items.isEmpty) {
        return EmptyStateWidget(
          tabIndex: 2,
          hasSearch: hasSearch,
          onClearSearch: hasSearch ? () => controller.clearSearch(2) : null,
        );
      }

      if (viewMode == ViewMode.list) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final diagnostico = items[index];
            return DiagnosticoFavoritoListItem(
              diagnostico: diagnostico,
              onTap: () => controller.goToDiagnosticoDetails(diagnostico),
              onRemove: () => controller.removeFavoritoDiagnostico(diagnostico),
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
          final diagnostico = items[index];
          return _DiagnosticoGridItem(
            diagnostico: diagnostico,
            onTap: () => controller.goToDiagnosticoDetails(diagnostico),
            onRemove: () => controller.removeFavoritoDiagnostico(diagnostico),
          );
        },
      );
      },
    );
  }
}

class _DiagnosticoGridItem extends StatelessWidget {
  final dynamic diagnostico;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _DiagnosticoGridItem({
    required this.diagnostico,
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
                        color: FavoritosDesignTokens.diagnosticosColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        FavoritosDesignTokens.diagnosticosIcon,
                        color: FavoritosDesignTokens.diagnosticosColor,
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
                        diagnostico.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (diagnostico.displayCultura.isNotEmpty)
                        Text(
                          diagnostico.displayCultura,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const Spacer(),
                      if (diagnostico.displayCategoria.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: FavoritosDesignTokens.diagnosticosColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            diagnostico.displayCategoria,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: FavoritosDesignTokens.diagnosticosColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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