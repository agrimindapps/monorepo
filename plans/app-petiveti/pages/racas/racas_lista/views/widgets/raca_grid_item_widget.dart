// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/racas_lista_controller.dart';
import '../../models/raca_model.dart';
import '../../utils/racas_lista_constants.dart';
import '../../utils/racas_lista_helpers.dart';

class RacaGridItemWidget extends StatelessWidget {
  final Raca raca;
  final RacasListaController controller;

  const RacaGridItemWidget({
    super.key,
    required this.raca,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.isRacaSelected(raca.nome);

    return Card(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImage(),
            _buildInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final isSelected = controller.isRacaSelected(raca.nome);

    return Stack(
      children: [
        Hero(
          tag: 'raca_image_grid_${raca.nome}',
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(RacasListaConstants.cardBorderRadius),
            ),
            child: Image.asset(
              raca.imagem,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.pets, color: Colors.grey),
                );
              },
            ),
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
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            raca.nome,
            style: RacasListaConstants.racaNomeGridStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            raca.origem,
            style: RacasListaConstants.racaOrigemStyle.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            raca.temperamento,
            style: RacasListaConstants.racaTemperamentoStyle.copyWith(
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
