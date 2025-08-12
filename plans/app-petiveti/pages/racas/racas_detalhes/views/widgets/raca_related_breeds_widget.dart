// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/racas_detalhes_controller.dart';
import '../../models/raca_detalhes_model.dart';
import '../../utils/racas_detalhes_constants.dart';
import '../../utils/racas_detalhes_helpers.dart';

class RacaRelatedBreedsWidget extends StatelessWidget {
  final RacaDetalhes raca;
  final RacasDetalhesController controller;

  const RacaRelatedBreedsWidget({
    super.key,
    required this.raca,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (raca.racasRelacionadas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Icon(
                RacasDetalhesHelpers.getSectionIcon('relacionadas'),
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              const Text(
                'Raças Relacionadas',
                style: RacasDetalhesConstants.galleryTitleStyle,
              ),
            ],
          ),
        ),
        SizedBox(
          height: RacasDetalhesConstants.galleryHeight,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: raca.racasRelacionadas.length,
            itemBuilder: (context, index) {
              final racaRelacionada = raca.racasRelacionadas[index];
              return RacasDetalhesHelpers.buildRelatedBreedItem(
                racaRelacionada.nome,
                racaRelacionada.imagem,
                () => controller.navigateToRelatedBreed(context, racaRelacionada),
              );
            },
          ),
        ),
      ],
    );
  }
}
