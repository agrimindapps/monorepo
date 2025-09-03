import 'package:flutter/material.dart';

import 'praga_card_action_section.dart';
import 'praga_card_content_section.dart';
import 'praga_card_helpers.dart';
import 'praga_card_image_section.dart';
import 'praga_card_main.dart';

/// Widget específico para modo compacto
/// 
/// Responsabilidades:
/// - Layout horizontal muito compacto
/// - Altura reduzida (70px)
/// - Imagem pequena 48x48
/// - Conteúdo minimalista
/// - Ações compactas
class PragaCardCompactMode extends StatelessWidget {
  final PragaCardProperties properties;

  const PragaCardCompactMode({
    super.key,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      elevation: properties.isDarkMode ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: PragaCardHelpers.getCardColor(properties.isDarkMode),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: properties.onTap,
        child: Container(
          height: properties.customHeight ?? 70,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Seção de imagem compacta
              PragaCardImageSection(
                properties: properties,
                mode: PragaCardImageMode.compact,
                width: 48,
                height: 48,
              ),
              
              const SizedBox(width: 12),
              
              // Conteúdo principal expandido
              Expanded(
                child: PragaCardContentSection(
                  properties: properties,
                  mode: PragaCardContentMode.compact,
                ),
              ),
              
              // Seção de ações compacta
              PragaCardActionSection(
                properties: properties,
                mode: PragaCardActionMode.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}