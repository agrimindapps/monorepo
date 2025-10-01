import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
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
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: PragaCardHelpers.getCardColor(properties.isDarkMode),
        borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
        boxShadow: [
          BoxShadow(
            color: properties.isDarkMode 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            blurRadius: ReceitaAgroElevation.card,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
          onTap: properties.onTap,
          child: Container(
            height: properties.customHeight ?? 80,
            padding: const EdgeInsets.symmetric(
              horizontal: ReceitaAgroSpacing.sm,
              vertical: ReceitaAgroSpacing.xs,
            ),
            child: Row(
              children: [
                // Seção de imagem compacta
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.button),
                    boxShadow: [
                      BoxShadow(
                        color: properties.isDarkMode 
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: PragaCardImageSection(
                    properties: properties,
                    mode: PragaCardImageMode.list,
                    width: 64,
                    height: 64,
                  ),
                ),
                
                const SizedBox(width: ReceitaAgroSpacing.sm),
                
                // Conteúdo principal expandido
                Expanded(
                  child: PragaCardContentSection(
                    properties: properties,
                    mode: PragaCardContentMode.list,
                  ),
                ),
                
                const SizedBox(width: ReceitaAgroSpacing.sm),
                
                // Seção de ações
                PragaCardActionSection(
                  properties: properties,
                  mode: PragaCardActionMode.list,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}