import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_navigation_provider.dart';
import '../../../../core/widgets/praga_image_widget.dart';
import '../../domain/entities/favorito_entity.dart';
import '../providers/favoritos_provider_simplified.dart';

/// Widget especializado para aba de Pragas favoritas
/// Gerencia listagem e ações específicas para pragas
class FavoritosPragasTabWidget extends StatelessWidget {
  final FavoritosProviderSimplified provider;
  final VoidCallback onReload;

  const FavoritosPragasTabWidget({
    super.key,
    required this.provider,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return _buildTabContent(
      context: context,
      provider: provider,
      viewState: provider.getViewStateForType(TipoFavorito.praga),
      emptyMessage: provider.getEmptyMessageForType(TipoFavorito.praga),
      items: provider.pragas,
      itemBuilder: (praga) => _buildPragaItem(context, praga, provider),
      isDark: isDark,
    );
  }

  Widget _buildTabContent<T extends FavoritoEntity>({
    required BuildContext context,
    required FavoritosProviderSimplified provider,
    required FavoritosViewState viewState,
    required String emptyMessage,
    required List<T> items,
    required Widget Function(T) itemBuilder,
    required bool isDark,
  }) {
    switch (viewState) {
      case FavoritosViewState.loading:
        return const Center(child: CircularProgressIndicator());
      
      case FavoritosViewState.error:
        return _buildErrorState(context, provider, isDark);
      
      case FavoritosViewState.empty:
        return _buildEmptyState(context, emptyMessage, isDark);
      
      case FavoritosViewState.loaded:
        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadAllFavoritos();
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == items.length) {
                return const SizedBox(height: 80);
              }
              return itemBuilder(items[index]);
            },
          ),
        );
      
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPragaItem(
    BuildContext context, 
    FavoritoPragaEntity praga, 
    FavoritosProviderSimplified provider
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => _navigateToPragaDetails(context, praga),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              ),
              child: PragaImageWidget(
                nomeCientifico: praga.nomeCientifico,
                width: 32,
                height: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    praga.nomeComum,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (praga.nomeCientifico.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      praga.nomeCientifico,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (praga.tipo.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      praga.tipo,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () async {
                await provider.toggleFavorito(TipoFavorito.praga, praga.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    FavoritosProviderSimplified provider,
    bool isDark,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark ? Colors.red.shade400 : Colors.red.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar pragas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          if (provider.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String emptyMessage,
    bool isDark,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 64,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPragaDetails(BuildContext context, FavoritoPragaEntity praga) {
    final navigationProvider = Provider.of<AppNavigationProvider>(context, listen: false);
    navigationProvider.navigateToDetalhePraga(
      pragaName: praga.nomeComum,
      pragaScientificName: praga.nomeCientifico,
    );
  }
}