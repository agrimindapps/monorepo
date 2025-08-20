// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/racas_seletor_controller.dart';
import '../../models/especie_seletor_model.dart';
import '../../utils/racas_seletor_constants.dart';
import '../../utils/racas_seletor_helpers.dart';
import 'especie_fallback_widget.dart';

class EspecieCardWidget extends StatelessWidget {
  final EspecieSeletor especie;
  final RacasSeletorController controller;

  const EspecieCardWidget({
    super.key,
    required this.especie,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: RacasSeletorConstants.getHeroTag(especie.nome),
      child: Card(
        elevation: RacasSeletorConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: RacasSeletorHelpers.getCardBorderRadius(),
        ),
        child: InkWell(
          onTap: () => controller.navigateToEspecieRacas(context, especie),
          onLongPress: () => controller.showEspecieInfo(context, especie),
          borderRadius: RacasSeletorHelpers.getCardBorderRadius(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImage(context),
              _buildInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Expanded(
      flex: RacasSeletorConstants.imageFlexValue,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: RacasSeletorHelpers.getImageBorderRadius(),
            child: Image.asset(
              especie.imagem,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return EspecieFallbackWidget(especie: especie);
              },
            ),
          ),
          if (especie.hasRacas) _buildBadge(),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: RacasSeletorHelpers.buildBadge(especie.racasText),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Expanded(
      flex: RacasSeletorConstants.infoFlexValue,
      child: Padding(
        padding: RacasSeletorHelpers.getCardPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  especie.icone,
                  size: 16,
                  color: RacasSeletorHelpers.getSpeciesColor(especie.nome),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    especie.nome,
                    style: RacasSeletorHelpers.getCardTitleStyle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                especie.descricao,
                style: RacasSeletorHelpers.getCardDescriptionStyle(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
