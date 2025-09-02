import 'package:flutter/material.dart';

import 'praga_card_main.dart';
import 'praga_card_helpers.dart';
import 'praga_card_image_section.dart';
import 'praga_card_content_section.dart';
import 'praga_card_action_section.dart';

/// Widget específico para modo featured (destaque)
/// 
/// Responsabilidades:
/// - Layout vertical premium
/// - Imagem grande com altura expandida
/// - Conteúdo rico com mais detalhes
/// - Elevação aumentada para destaque
/// - Botão de favorito flutuante estilizado
class PragaCardFeaturedMode extends StatelessWidget {
  final PragaCardProperties properties;

  const PragaCardFeaturedMode({
    super.key,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: properties.isDarkMode ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: PragaCardHelpers.getCardColor(properties.isDarkMode),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: properties.onTap,
        child: SizedBox(
          width: properties.customWidth ?? double.infinity,
          height: properties.customHeight ?? 280,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Seção de imagem (maior para destaque)
                  Expanded(
                    flex: 5,
                    child: PragaCardImageSection(
                      properties: properties,
                      mode: PragaCardImageMode.featured,
                      height: 160,
                    ),
                  ),
                  
                  // Conteúdo detalhado
                  Expanded(
                    flex: 3,
                    child: PragaCardContentSection(
                      properties: properties,
                      mode: PragaCardContentMode.featured,
                    ),
                  ),
                ],
              ),
              
              // Botão de favorito flutuante estilizado
              PragaCardActionSection(
                properties: properties,
                mode: PragaCardActionMode.featured,
              ),
              
              // Badge de destaque opcional
              if (properties.showTypeIcon)
                Positioned(
                  top: 16,
                  left: 16,
                  child: _buildFeaturedBadge(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói badge de destaque para featured mode
  Widget _buildFeaturedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: Colors.white,
            size: 12,
          ),
          SizedBox(width: 4),
          Text(
            'DESTAQUE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}