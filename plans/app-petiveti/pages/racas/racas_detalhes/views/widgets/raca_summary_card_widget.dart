// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/raca_detalhes_model.dart';
import '../../utils/racas_detalhes_helpers.dart';

class RacaSummaryCardWidget extends StatelessWidget {
  final RacaDetalhes raca;

  const RacaSummaryCardWidget({
    super.key,
    required this.raca,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: RacasDetalhesHelpers.getCardMargin(),
      decoration: RacasDetalhesHelpers.getCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: RacasDetalhesHelpers.getCardPadding(),
            child: RacasDetalhesHelpers.buildSectionHeader('Visão Geral', 'info'),
          ),
          const Divider(height: 1),
          Padding(
            padding: RacasDetalhesHelpers.getCardPadding(),
            child: Column(
              children: [
                RacasDetalhesHelpers.buildInfoRow(
                  'Origem',
                  raca.origem,
                  RacasDetalhesHelpers.getSectionIcon('origem'),
                ),
                RacasDetalhesHelpers.buildInfoRow(
                  'Altura',
                  raca.altura,
                  RacasDetalhesHelpers.getSectionIcon('altura'),
                ),
                RacasDetalhesHelpers.buildInfoRow(
                  'Peso',
                  raca.peso,
                  RacasDetalhesHelpers.getSectionIcon('peso'),
                ),
                RacasDetalhesHelpers.buildInfoRow(
                  'Expectativa de Vida',
                  raca.expectativaVida,
                  RacasDetalhesHelpers.getSectionIcon('expectativa'),
                ),
                RacasDetalhesHelpers.buildInfoRow(
                  'Grupo',
                  raca.grupo,
                  RacasDetalhesHelpers.getSectionIcon('grupo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
