import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/favorito_entity.dart';
import '../notifiers/favoritos_notifier.dart';

/// Widget especializado para aba de Defensivos favoritos
/// Gerencia listagem e ações específicas para defensivos
class FavoritosDefensivosTabWidget extends ConsumerWidget {
  final VoidCallback onReload;

  const FavoritosDefensivosTabWidget({super.key, required this.onReload});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritosState = ref.watch(favoritosProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Usar novo padrão com getFavoritosByTipo
    final defensivos = favoritosState
        .getFavoritosByTipo<FavoritoDefensivoEntity>(TipoFavorito.defensivo);

    return _buildTabContent(
      context: context,
      ref: ref,
      favoritosState: favoritosState,
      viewState: favoritosState.getViewStateForType(TipoFavorito.defensivo),
      emptyMessage: favoritosState.getEmptyMessageForType(
        TipoFavorito.defensivo,
      ),
      items: defensivos,
      itemBuilder: (defensivo) => _buildDefensivoItem(context, ref, defensivo),
      isDark: isDark,
    );
  }

  Widget _buildTabContent<T extends FavoritoEntity>({
    required BuildContext context,
    required WidgetRef ref,
    required FavoritosState favoritosState,
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
        return _buildErrorState(context, favoritosState, isDark);

      case FavoritosViewState.empty:
        return _buildEmptyState(context, emptyMessage, isDark);

      case FavoritosViewState.loaded:
        return RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(favoritosProvider.notifier)
                .loadAllFavoritos();
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.1),
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
                          indent: 64,
                          endIndent: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
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

  Widget _buildDefensivoItem(
    BuildContext context,
    WidgetRef ref,
    FavoritoDefensivoEntity defensivo,
  ) {
    return Dismissible(
      key: Key('favorito_defensivo_${defensivo.id}'),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(),
      confirmDismiss: (direction) async {
        return await _showRemoveDialog(context, defensivo.nomeComum);
      },
      onDismissed: (direction) async {
        await _removeFavorito(context, ref, defensivo);
      },
      child: ListTile(
        onTap: () => _navigateToDefensivoDetails(context, ref, defensivo),
        leading: Container(
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
        title: Text(
          defensivo.nomeComum,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle:
            defensivo.ingredienteAtivo.isNotEmpty ||
                defensivo.fabricante?.isNotEmpty == true
            ? Text(
                [
                  if (defensivo.ingredienteAtivo.isNotEmpty)
                    defensivo.ingredienteAtivo,
                  if (defensivo.fabricante?.isNotEmpty == true)
                    defensivo.fabricante!,
                ].join(' • '),
                maxLines: 2,
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
    WidgetRef ref,
    FavoritoDefensivoEntity defensivo,
  ) async {
    try {
      await ref
          .read(favoritosProvider.notifier)
          .toggleFavorito(TipoFavorito.defensivo, defensivo.id);
    } catch (e) {}
  }

  Widget _buildErrorState(
    BuildContext context,
    FavoritosState favoritosState,
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
          if (favoritosState.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              favoritosState.errorMessage!,
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
    WidgetRef ref,
    FavoritoDefensivoEntity defensivo,
  ) {
    final navigationService = ref.read(navigationServiceProvider);
    navigationService.navigateToDetalheDefensivo(
      defensivoName: defensivo.displayName,
      extraData: {'fabricante': defensivo.fabricante},
    );
  }
}
