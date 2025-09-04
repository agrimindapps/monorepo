import 'package:flutter/material.dart';

import '../../domain/entities/favorito_entity.dart';
import '../providers/favoritos_riverpod_provider.dart';
import 'favoritos_empty_state_widget.dart';
import 'favoritos_error_state_widget.dart';
import 'favoritos_item_widget.dart';

/// Widget responsável pelo conteúdo de cada tab
/// 
/// Responsabilidades:
/// - Gerenciar estados de loading/error/empty/loaded
/// - Exibir lista de favoritos
/// - Pull to refresh
/// - Remoção de itens
/// - Suporte a diferentes tipos de favoritos
class FavoritosTabContentWidget extends StatelessWidget {
  final String tipo;
  final List<FavoritoEntity> items;
  final FavoritosViewState viewState;
  final String emptyMessage;
  final String? errorMessage;
  final bool isDark;
  final VoidCallback onRefresh;
  final Function(FavoritoEntity) onRemove;

  const FavoritosTabContentWidget({
    super.key,
    required this.tipo,
    required this.items,
    required this.viewState,
    required this.emptyMessage,
    this.errorMessage,
    required this.isDark,
    required this.onRefresh,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    switch (viewState) {
      case FavoritosViewState.loading:
        return _buildLoadingState();
      
      case FavoritosViewState.error:
        return FavoritosErrorStateWidget(
          errorMessage: errorMessage,
          onRetry: onRefresh,
          isDark: isDark,
        );
      
      case FavoritosViewState.empty:
        return FavoritosEmptyStateWidget(
          message: emptyMessage,
          tipo: tipo,
          isDark: isDark,
        );
      
      case FavoritosViewState.loaded:
        return _buildLoadedState();
    }
  }

  /// Constrói o estado de loading
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: _getTypeColor(),
          ),
          const SizedBox(height: 16),
          Text(
            'Carregando favoritos...',
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o estado carregado
  Widget _buildLoadedState() {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: _getTypeColor(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return FavoritosItemWidget(
            favorito: item,
            tipo: tipo,
            isDark: isDark,
            onRemove: () => onRemove(item),
          );
        },
      ),
    );
  }

  /// Retorna a cor baseada no tipo
  Color _getTypeColor() {
    switch (tipo) {
      case TipoFavorito.defensivo:
        return Colors.blue;
      case TipoFavorito.praga:
        return Colors.red;
      case TipoFavorito.diagnostico:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}