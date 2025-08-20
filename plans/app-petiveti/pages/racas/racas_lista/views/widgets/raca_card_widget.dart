// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/racas_lista_controller.dart';
import '../../models/raca_model.dart';
import '../../utils/racas_lista_constants.dart';
import '../../utils/racas_lista_helpers.dart';

class RacaCardWidget extends StatelessWidget {
  final Raca raca;
  final RacasListaController controller;

  const RacaCardWidget({
    super.key,
    required this.raca,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.isRacaSelected(raca.nome);

    return Card(
      margin: RacasListaHelpers.getCardMargin(),
      shape: RoundedRectangleBorder(
        borderRadius: RacasListaHelpers.getDefaultBorderRadius(),
        side: isSelected
            ? const BorderSide(
                color: RacasListaConstants.selectedBorderColor,
                width: 2,
              )
            : BorderSide.none,
      ),
      elevation: isSelected ? 4 : 2,
      child: InkWell(
        onLongPress: () => _handleLongPress(context),
        onTap: () => controller.navigateToRacaDetalhes(context, raca),
        borderRadius: RacasListaHelpers.getDefaultBorderRadius(),
        child: Row(
          children: [
            _buildImage(),
            _buildInfo(),
            _buildArrowIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final isSelected = controller.isRacaSelected(raca.nome);

    return Stack(
      children: [
        RacasListaHelpers.buildHeroImage(
          imagePath: raca.imagem,
          heroTag: 'raca_image_${raca.nome}',
          errorWidget: Container(
            width: RacasListaConstants.listItemImageWidth,
            height: RacasListaConstants.listItemHeight,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(RacasListaConstants.cardBorderRadius),
                bottomLeft: Radius.circular(RacasListaConstants.cardBorderRadius),
              ),
            ),
            child: const Icon(Icons.pets, color: Colors.grey),
          ),
        ),
        if (isSelected)
          Positioned(
            top: 8,
            right: 8,
            child: RacasListaHelpers.buildSelectionIndicator(),
          ),
      ],
    );
  }

  Widget _buildInfo() {
    return Expanded(
      child: Padding(
        padding: RacasListaHelpers.getCardPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              raca.nome,
              style: RacasListaConstants.racaNomeListStyle,
            ),
            const SizedBox(height: 8),
            RacasListaHelpers.buildInfoRow(
              icon: Icons.public,
              label: 'Origem',
              value: raca.origem,
            ),
            const SizedBox(height: 8),
            RacasListaHelpers.buildInfoRowExpanded(
              icon: Icons.psychology,
              text: 'Temperamento: ${raca.temperamento}',
            ),
            const SizedBox(height: 8),
            RacasListaHelpers.buildBadgesWrap(raca.getBadges()),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowIcon() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey[400],
        size: 18,
      ),
    );
  }

  void _handleLongPress(BuildContext context) {
    if (controller.isRacaSelected(raca.nome)) {
      controller.toggleRacaSelection(raca.nome);
    } else {
      if (controller.canSelectMoreRacas()) {
        controller.toggleRacaSelection(raca.nome);
      } else {
        controller.showMaxSelectionMessage(context);
      }
    }
  }
}
