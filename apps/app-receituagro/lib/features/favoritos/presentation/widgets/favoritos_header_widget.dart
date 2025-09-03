import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../../domain/entities/favorito_entity.dart';
import '../providers/favoritos_riverpod_provider.dart';

/// Widget especializado para o header da página de favoritos
/// 
/// Responsabilidades:
/// - Exibir título da página
/// - Mostrar contadores de favoritos
/// - Design moderno e responsivo
/// - Suporte a temas claro/escuro
class FavoritosHeaderWidget extends StatelessWidget {
  final FavoritosState favoritosState;
  final bool isDark;

  const FavoritosHeaderWidget({
    super.key,
    required this.favoritosState,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final totalFavoritos = _getTotalFavoritos();
    
    return ModernHeaderWidget(
      title: 'Favoritos',
      subtitle: totalFavoritos > 0 
          ? '$totalFavoritos ${totalFavoritos == 1 ? 'item salvo' : 'itens salvos'}'
          : 'Nenhum item salvo ainda',
      leftIcon: FontAwesomeIcons.heart,
      isDark: isDark,
      showBackButton: false,
      showActions: totalFavoritos > 0,
      additionalActions: totalFavoritos > 0 ? [_buildStatsChip()] : null,
    );
  }

  /// Calcula o total de favoritos
  int _getTotalFavoritos() {
    return favoritosState.getCountForType(TipoFavorito.defensivo) +
           favoritosState.getCountForType(TipoFavorito.praga) +
           favoritosState.getCountForType(TipoFavorito.diagnostico);
  }

  /// Constrói chip com estatísticas
  Widget _buildStatsChip() {
    final defensivos = favoritosState.getCountForType(TipoFavorito.defensivo);
    final pragas = favoritosState.getCountForType(TipoFavorito.praga);
    final diagnosticos = favoritosState.getCountForType(TipoFavorito.diagnostico);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (defensivos > 0) ...[
            _buildStatItem(
              icon: FontAwesomeIcons.shield,
              count: defensivos,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
          ],
          if (pragas > 0) ...[
            _buildStatItem(
              icon: FontAwesomeIcons.bug,
              count: pragas,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
          ],
          if (diagnosticos > 0)
            _buildStatItem(
              icon: FontAwesomeIcons.stethoscope,
              count: diagnosticos,
              color: Colors.green,
            ),
        ],
      ),
    );
  }

  /// Constrói item de estatística
  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(
          icon,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}