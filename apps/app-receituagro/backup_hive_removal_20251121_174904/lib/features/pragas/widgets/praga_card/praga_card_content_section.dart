import 'package:flutter/material.dart';

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
    }
  }

  /// Conteúdo para modo lista (vertical stack)
  Widget _buildListContent() {
    final nomesSecundarios = properties.praga.nomesSecundarios;
    final hasNomesSecundarios = nomesSecundarios.isNotEmpty;
    final nomesSecundariosText = hasNomesSecundarios
        ? nomesSecundarios.map((n) => n.trim()).join(', ')
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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

        if (hasNomesSecundarios) ...[
          const SizedBox(height: 2),
          Text(
            nomesSecundariosText,
            style: TextStyle(
              fontSize: 11,
              color: PragaCardHelpers.getTextColor(properties.isDarkMode, isSecondary: true),
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 2),
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
    final nomesSecundarios = properties.praga.nomesSecundarios;
    final hasNomesSecundarios = nomesSecundarios.isNotEmpty;
    final nomesSecundariosText = hasNomesSecundarios
        ? nomesSecundarios.map((n) => n.trim()).join(', ')
        : '';

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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

          if (hasNomesSecundarios) ...[
            const SizedBox(height: 2),
            Text(
              nomesSecundariosText,
              style: TextStyle(
                fontSize: 10,
                color: PragaCardHelpers.getTextColor(properties.isDarkMode, isSecondary: true),
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 2),
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

}

/// Modos de exibição do conteúdo
enum PragaCardContentMode {
  list,
  grid,
}
