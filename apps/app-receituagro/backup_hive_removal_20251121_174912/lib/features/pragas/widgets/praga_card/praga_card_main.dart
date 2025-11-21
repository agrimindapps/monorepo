import 'package:flutter/material.dart';

import '../../domain/entities/praga_entity.dart';
import 'praga_card_grid_mode.dart';
import 'praga_card_list_mode.dart';

/// Widget principal otimizado para exibir cards de pragas
/// Performance máxima para listas com 1000+ itens
/// 
/// Características:
/// - Lazy loading de imagens
/// - Rendering otimizado com RepaintBoundary
/// - Múltiplos modos de visualização
/// - Integração com favoritos
/// - Suporte a temas
/// - Decomposição em micro-widgets para máxima performance
class PragaCardWidget extends StatelessWidget {
  final PragaEntity praga;
  final PragaCardMode mode;
  final bool isDarkMode;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final double? customWidth;
  final double? customHeight;
  final bool showFavoriteButton;
  final bool showTypeIcon;
  final bool enableImagePreloading;

  const PragaCardWidget({
    super.key,
    required this.praga,
    this.mode = PragaCardMode.list,
    this.isDarkMode = false,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteToggle,
    this.customWidth,
    this.customHeight,
    this.showFavoriteButton = true,
    this.showTypeIcon = true,
    this.enableImagePreloading = false,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _buildCardByMode(),
    );
  }

  /// Constrói o card baseado no modo selecionado
  Widget _buildCardByMode() {
    final cardProps = PragaCardProperties(
      praga: praga,
      isDarkMode: isDarkMode,
      isFavorite: isFavorite,
      onTap: onTap,
      onFavoriteToggle: onFavoriteToggle,
      customWidth: customWidth,
      customHeight: customHeight,
      showFavoriteButton: showFavoriteButton,
      showTypeIcon: showTypeIcon,
      enableImagePreloading: enableImagePreloading,
    );

    switch (mode) {
      case PragaCardMode.list:
        return PragaCardListMode(properties: cardProps);
      case PragaCardMode.grid:
        return PragaCardGridMode(properties: cardProps);
    }
  }
}

/// Propriedades compartilhadas entre todos os modos de card
class PragaCardProperties {
  final PragaEntity praga;
  final bool isDarkMode;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final double? customWidth;
  final double? customHeight;
  final bool showFavoriteButton;
  final bool showTypeIcon;
  final bool enableImagePreloading;

  const PragaCardProperties({
    required this.praga,
    required this.isDarkMode,
    required this.isFavorite,
    this.onTap,
    this.onFavoriteToggle,
    this.customWidth,
    this.customHeight,
    required this.showFavoriteButton,
    required this.showTypeIcon,
    required this.enableImagePreloading,
  });
}

/// Enumeration para os modos de visualização do card
enum PragaCardMode {
  /// Modo lista horizontal com detalhes completos
  list,
  
  /// Modo grid vertical com imagem em destaque
  grid,
}
