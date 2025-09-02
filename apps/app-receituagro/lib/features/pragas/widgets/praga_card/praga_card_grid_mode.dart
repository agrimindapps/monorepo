import 'package:flutter/material.dart';

import 'praga_card_main.dart';
import 'praga_card_helpers.dart';
import 'praga_card_image_section.dart';
import 'praga_card_content_section.dart';
import 'praga_card_action_section.dart';

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
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: properties.isDarkMode ? 6 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: PragaCardHelpers.getCardColor(properties.isDarkMode),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: properties.onTap,
        child: SizedBox(
          width: properties.customWidth ?? 180,
          height: properties.customHeight ?? 220,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Seção de imagem (topo)
                  Expanded(
                    flex: 3,
                    child: PragaCardImageSection(
                      properties: properties,
                      mode: PragaCardImageMode.grid,
                      height: 120,
                    ),
                  ),
                  
                  // Conteúdo (parte inferior)
                  Expanded(
                    flex: 2,
                    child: PragaCardContentSection(
                      properties: properties,
                      mode: PragaCardContentMode.grid,
                    ),
                  ),
                ],
              ),
              
              // Botão de favorito flutuante
              PragaCardActionSection(
                properties: properties,
                mode: PragaCardActionMode.grid,
              ),
            ],
          ),
        ),
      ),
    );
  }
}