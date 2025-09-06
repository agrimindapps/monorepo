import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'praga_card_helpers.dart';
import 'praga_card_main.dart';

/// Widget especializado para renderizar o conteúdo textual do card
/// 
/// Responsabilidades:
/// - Nome formatado da praga
/// - Nome científico (itálico)
/// - Chip de tipo com ícone
/// - Adaptação para diferentes modos
/// - Suporte a temas claro/escuro
class PragaCardContentSection extends StatelessWidget {
  final PragaCardProperties properties;
  final PragaCardContentMode mode;

  const PragaCardContentSection({
    super.key,
    required this.properties,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case PragaCardContentMode.list:
        return _buildListContent();
      case PragaCardContentMode.grid:
        return _buildGridContent();
      case PragaCardContentMode.compact:
        return _buildCompactContent();
      case PragaCardContentMode.featured:
        return _buildFeaturedContent();
    }
  }

  /// Conteúdo para modo lista (vertical stack)
  Widget _buildListContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Nome principal
        Text(
          properties.praga.nomeFormatado,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: PragaCardHelpers.getTextColor(properties.isDarkMode),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // Nome científico
        if (properties.praga.nomeCientifico.isNotEmpty)
          Text(
            properties.praga.nomeCientifico,
            style: TextStyle(
              fontSize: 14,
              color: PragaCardHelpers.getTextColor(properties.isDarkMode, isSecondary: true),
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  /// Conteúdo para modo grid (texto embaixo da imagem)
  Widget _buildGridContent() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nome principal
          Text(
            properties.praga.nomeFormatado,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: PragaCardHelpers.getTextColor(properties.isDarkMode),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          // Nome científico (igual ao mockup)
          if (properties.praga.nomeCientifico.isNotEmpty)
            Text(
              properties.praga.nomeCientifico,
              style: TextStyle(
                fontSize: 12,
                color: PragaCardHelpers.getTextColor(properties.isDarkMode, isSecondary: true),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  /// Conteúdo para modo compacto (nome + tipo inline)
  Widget _buildCompactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Nome principal
        Text(
          properties.praga.nomeFormatado,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: PragaCardHelpers.getTextColor(properties.isDarkMode),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 2),
        
        // Tipo com ícone inline
        Row(
          children: [
            FaIcon(
              PragaCardHelpers.getTypeIcon(properties.praga.tipoPraga),
              size: 12,
              color: PragaCardHelpers.getTypeColor(properties.praga.tipoPraga),
            ),
            const SizedBox(width: 6),
            Text(
              PragaCardHelpers.getTypeText(properties.praga.tipoPraga),
              style: TextStyle(
                fontSize: 12,
                color: PragaCardHelpers.getTextColor(properties.isDarkMode, isSecondary: true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Conteúdo para modo featured (destaque com chip)
  Widget _buildFeaturedContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome principal maior
          Text(
            properties.praga.nomeFormatado,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: PragaCardHelpers.getTextColor(properties.isDarkMode),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 6),
          
          // Nome científico
          if (properties.praga.nomeCientifico.isNotEmpty) ...[
            Text(
              properties.praga.nomeCientifico,
              style: TextStyle(
                fontSize: 14,
                color: PragaCardHelpers.getTextColor(properties.isDarkMode, isSecondary: true),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          
          // Chip de tipo destacado
          Row(
            children: [
              _buildTypeChip(isCompact: false),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói o chip do tipo de praga
  Widget _buildTypeChip({required bool isCompact}) {
    final typeColor = PragaCardHelpers.getTypeColor(properties.praga.tipoPraga);
    final typeIcon = PragaCardHelpers.getTypeIcon(properties.praga.tipoPraga);
    final typeText = PragaCardHelpers.getTypeText(properties.praga.tipoPraga);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            typeIcon,
            size: isCompact ? 10 : 14,
            color: typeColor,
          ),
          SizedBox(width: isCompact ? 3 : 6),
          Text(
            typeText,
            style: TextStyle(
              fontSize: isCompact ? 10 : 13,
              fontWeight: FontWeight.w600,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modos de exibição do conteúdo
enum PragaCardContentMode {
  list,
  grid,
  compact,
  featured,
}