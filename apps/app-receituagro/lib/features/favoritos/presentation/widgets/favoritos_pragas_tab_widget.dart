import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/receituagro_navigation_service.dart';
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
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      itemBuilder(items[index]),
                      if (index < items.length - 1)
                        Divider(
                          height: 1,
                          indent: 72,
                          endIndent: 16,
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                    ],
                  );
                },
              ),
            ),
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
    return Dismissible(
      key: Key('favorito_praga_${praga.id}'),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(),
      confirmDismiss: (direction) async {
        return await _showRemoveDialog(context, praga.nomeComum);
      },
      onDismissed: (direction) async {
        await _removeFavorito(context, provider, praga);
      },
      child: ListTile(
        onTap: () => _navigateToPragaDetails(context, praga),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PragaImageWidget(
              nomeCientifico: praga.nomeCientifico,
              width: 48,
              height: 48,
            ),
          ),
        ),
        title: Text(
          praga.nomeComum,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: praga.nomeCientifico.isNotEmpty
          ? Text(
              praga.nomeCientifico,
              style: const TextStyle(fontStyle: FontStyle.italic),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
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
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24,
              ),
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
    FavoritoPragaEntity praga,
  ) async {
    try {
      await provider.toggleFavorito(TipoFavorito.praga, praga.id);
      // Remover favorito sem feedback de SnackBar
    } catch (e) {
      // Erro silencioso
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
    final navigationService = GetIt.instance<ReceitaAgroNavigationService>();
    navigationService.navigateToDetalhePraga(
      pragaName: praga.nomeComum,
      pragaId: praga.id, // Use ID for better precision
      pragaScientificName: praga.nomeCientifico,
    );
  }
}