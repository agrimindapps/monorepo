import 'package:flutter/material.dart';

import 'praga_card_action_section.dart';
import 'praga_card_content_section.dart';
import 'praga_card_helpers.dart';
import 'praga_card_image_section.dart';
import 'praga_card_main.dart';

/// Widget específico para modo lista horizontal
/// 
/// Responsabilidades:
/// - Layout horizontal otimizado
/// - Altura padrão de 120px
/// - Imagem 80x80 à esquerda
/// - Conteúdo centralizado expandido
/// - Ações à direita
class PragaCardListMode extends StatelessWidget {
  final PragaCardProperties properties;

  const PragaCardListMode({
    super.key,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: properties.isDarkMode ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: PragaCardHelpers.getCardColor(properties.isDarkMode),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: properties.onTap,
        child: Container(
          height: properties.customHeight ?? 120,
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Seção de imagem
              PragaCardImageSection(
                properties: properties,
                mode: PragaCardImageMode.list,
                width: 80,
                height: 80,
              ),
              
              const SizedBox(width: 16),
              
              // Conteúdo principal expandido
              Expanded(
                child: PragaCardContentSection(
                  properties: properties,
                  mode: PragaCardContentMode.list,
                ),
              ),
              
              // Seção de ações
              PragaCardActionSection(
                properties: properties,
                mode: PragaCardActionMode.list,
              ),
            ],
          ),
        ),
      ),
    );
  }
}