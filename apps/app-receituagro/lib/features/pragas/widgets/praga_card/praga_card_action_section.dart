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
      case PragaCardActionMode.compact:
        return _buildCompactActions();
      case PragaCardActionMode.featured:
        return _buildFeaturedActions();
    }
  }

  /// Ações para modo lista (vertical stack)
  Widget _buildListActions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botão de favorito
        if (properties.showFavoriteButton && properties.onFavoriteToggle != null)
          _buildStandardFavoriteButton(),
        
        const SizedBox(height: 8),
        
        // Indicador de navegação
        Icon(
          Icons.chevron_right_rounded,
          color: PragaCardHelpers.getIconColor(properties.isDarkMode),
          size: 24,
        ),
      ],
    );
  }

  /// Ações para modo grid (floating favorite)
  Widget _buildGridActions() {
    if (!properties.showFavoriteButton || properties.onFavoriteToggle == null) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      top: 8,
      right: 8,
      child: _buildFloatingFavoriteButton(),
    );
  }

  /// Ações para modo compacto (apenas favorito pequeno)
  Widget _buildCompactActions() {
    if (!properties.showFavoriteButton || properties.onFavoriteToggle == null) {
      return const SizedBox.shrink();
    }
    
    return _buildCompactFavoriteButton();
  }

  /// Ações para modo featured (floating bottom right)
  Widget _buildFeaturedActions() {
    if (!properties.showFavoriteButton || properties.onFavoriteToggle == null) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      bottom: 16,
      right: 16,
      child: _buildFloatingFavoriteButton(),
    );
  }

  /// Botão de favorito padrão para modo lista
  Widget _buildStandardFavoriteButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: properties.isFavorite 
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          properties.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: properties.isFavorite ? Colors.red : Colors.grey.shade500,
          size: 20,
        ),
        onPressed: properties.onFavoriteToggle,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }

  /// Botão de favorito flutuante para grid/featured
  Widget _buildFloatingFavoriteButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: properties.isFavorite 
            ? Colors.red.withValues(alpha: 0.9)
            : Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          properties.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
          size: 18,
        ),
        onPressed: properties.onFavoriteToggle,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }

  /// Botão de favorito compacto
  Widget _buildCompactFavoriteButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: properties.isFavorite 
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        icon: Icon(
          properties.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: properties.isFavorite ? Colors.red : Colors.grey.shade500,
          size: 16,
        ),
        onPressed: properties.onFavoriteToggle,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          minWidth: 28,
          minHeight: 28,
        ),
      ),
    );
  }
}

/// Modos de exibição das ações
enum PragaCardActionMode {
  list,
  grid,
  compact,
  featured,
}