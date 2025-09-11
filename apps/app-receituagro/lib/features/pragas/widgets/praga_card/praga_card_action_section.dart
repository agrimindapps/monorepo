import 'package:flutter/material.dart';

import 'praga_card_helpers.dart';
import 'praga_card_main.dart';

/// Widget especializado para renderizar as ações do card
/// 
/// Responsabilidades:
/// - Botão de favorito com estados visuais
/// - Indicador de navegação
/// - Adaptação para diferentes modos
/// - Estados de hover e pressed
/// - Animações suaves
class PragaCardActionSection extends StatelessWidget {
  final PragaCardProperties properties;
  final PragaCardActionMode mode;

  const PragaCardActionSection({
    super.key,
    required this.properties,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case PragaCardActionMode.list:
        return _buildListActions();
      case PragaCardActionMode.grid:
        return _buildGridActions();
    }
  }

  /// Ações para modo lista (sem botão de favorito)
  Widget _buildListActions() {
    // No modo lista, não mostra o botão de favorito
    return const SizedBox.shrink();
  }

  /// Ações para modo grid (sem botão de favorito)
  Widget _buildGridActions() {
    // No modo grid, não mostra o botão de favorito
    return const SizedBox.shrink();
  }


}

/// Modos de exibição das ações
enum PragaCardActionMode {
  list,
  grid,
}