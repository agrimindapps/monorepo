// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/raca_detalhes_model.dart';
import '../../utils/racas_detalhes_helpers.dart';

class RacaCaracteristicasWidget extends StatelessWidget {
  final RacaDetalhes raca;

  const RacaCaracteristicasWidget({
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
            child: RacasDetalhesHelpers.buildSectionHeader('Características', 'caracteristicas'),
          ),
          Padding(
            padding: RacasDetalhesHelpers.getCardPadding(),
            child: Column(
              children: raca.caracteristicas.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${entry.value}/5',
                            style: TextStyle(
                              color: RacasDetalhesHelpers.getCharacteristicColor(entry.value),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      RacasDetalhesHelpers.buildCharacteristicBar(context, entry.value),
                      const SizedBox(height: 2),
                      Text(
                        RacasDetalhesHelpers.formatCharacteristicValue(entry.value),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
