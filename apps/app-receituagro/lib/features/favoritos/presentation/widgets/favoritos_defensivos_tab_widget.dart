import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_navigation_provider.dart';
import '../../domain/entities/favorito_entity.dart';
import '../providers/favoritos_provider_simplified.dart';

/// Widget especializado para aba de Defensivos favoritos
/// Gerencia listagem e ações específicas para defensivos
class FavoritosDefensivosTabWidget extends StatelessWidget {
  final FavoritosProviderSimplified provider;
  final VoidCallback onReload;

  const FavoritosDefensivosTabWidget({
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
      viewState: provider.getViewStateForType(TipoFavorito.defensivo),
      emptyMessage: provider.getEmptyMessageForType(TipoFavorito.defensivo),
      items: provider.defensivos,
      itemBuilder:
          (defensivo) => _buildDefensivoItem(context, defensivo, provider),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                separatorBuilder:
                    (context, index) => Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.4),
                    ),
                itemBuilder: (context, index) {
                  return itemBuilder(items[index]);
                },
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDefensivoItem(
    BuildContext context,
    FavoritoDefensivoEntity defensivo,
    FavoritosProviderSimplified provider,
  ) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('favorito_defensivo_${defensivo.id}'),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(),
      confirmDismiss: (direction) async {
        return await _showRemoveDialog(context, defensivo.nomeComum);
      },
      onDismissed: (direction) async {
        await _removeFavorito(context, provider, defensivo);
      },
      child: InkWell(
        onTap: () => _navigateToDefensivoDetails(context, defensivo),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  FontAwesomeIcons.shield,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      defensivo.nomeComum,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (defensivo.ingredienteAtivo.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        defensivo.ingredienteAtivo,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (defensivo.fabricante?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        defensivo.fabricante!,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o background do swipe (efeito de arrastar)
  Widget _buildSwipeBackground() {
    return Container(
      color: Colors.red.shade400,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text(
            'Excluir',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Mostra diálogo de confirmação para remoção
  Future<bool?> _showRemoveDialog(BuildContext context, String itemName) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text('Confirmar Remoção'),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
              children: [
                const TextSpan(text: 'Deseja remover '),
                TextSpan(
                  text: '"$itemName"',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' dos seus favoritos?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
  }

  /// Remove o favorito e mostra feedback
  Future<void> _removeFavorito(
    BuildContext context,
    FavoritosProviderSimplified provider,
    FavoritoDefensivoEntity defensivo,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    try {
      final success = await provider.toggleFavorito(
        TipoFavorito.defensivo,
        defensivo.id,
      );

      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('🗑️ ${defensivo.nomeComum} removido dos favoritos'),
            duration: const Duration(seconds: 2),
            backgroundColor: theme.colorScheme.primary,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('❌ Erro ao remover dos favoritos'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('❌ Erro inesperado ao remover favorito'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            'Erro ao carregar defensivos',
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

  void _navigateToDefensivoDetails(
    BuildContext context,
    FavoritoDefensivoEntity defensivo,
  ) {
    final navigationProvider = Provider.of<AppNavigationProvider>(
      context,
      listen: false,
    );
    navigationProvider.navigateToDetalheDefensivo(
      defensivoName: defensivo.displayName,
      fabricante: defensivo.fabricante,
    );
  }
}
