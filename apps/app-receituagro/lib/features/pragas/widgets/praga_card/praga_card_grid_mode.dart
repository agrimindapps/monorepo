import 'package:flutter/material.dart';

import 'praga_card_content_section.dart';
import 'praga_card_helpers.dart';
import 'praga_card_image_section.dart';
import 'praga_card_main.dart';

/// Widget específico para modo grid vertical
/// 
/// Responsabilidades:
/// - Layout vertical com imagem no topo
/// - Aspect ratio controlado
/// - Imagem full width com overlay
/// - Conteúdo na parte inferior
/// - Botão de favorito flutuante
class PragaCardGridMode extends StatelessWidget {
  final PragaCardProperties properties;

  const PragaCardGridMode({
    super.key,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220, // Define altura fixa maior para o card
      child: Card(
        margin: EdgeInsets.zero,
        elevation: properties.isDarkMode ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: PragaCardHelpers.getCardColor(properties.isDarkMode),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: properties.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seção de imagem (topo) - mais espaço para a imagem
              Expanded(
                flex: 7,
                child: PragaCardImageSection(
                  properties: properties,
                  mode: PragaCardImageMode.grid,
                  height: 140,
                ),
              ),
              
              // Conteúdo (parte inferior) - menos espaço para texto
              Expanded(
                flex: 3,
                child: PragaCardContentSection(
                  properties: properties,
                  mode: PragaCardContentMode.grid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}