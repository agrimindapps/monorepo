// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/racas_detalhes_controller.dart';
import '../../models/raca_detalhes_model.dart';
import '../../utils/racas_detalhes_constants.dart';
import '../../utils/racas_detalhes_helpers.dart';

class VeterinaryConsultModal extends StatelessWidget {
  final RacaDetalhes raca;
  final RacasDetalhesController controller;

  const VeterinaryConsultModal({
    super.key,
    required this.raca,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: RacasDetalhesConstants.modalInitialSize,
      maxChildSize: RacasDetalhesConstants.modalMaxSize,
      minChildSize: RacasDetalhesConstants.modalMinSize,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(RacasDetalhesConstants.borderRadius),
            ),
          ),
          child: Column(
            children: [
              _buildHandle(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: RacasDetalhesHelpers.getCardPadding(),
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 24),
                    _buildConsultSection(
                      'Vacinação Recomendada',
                      raca.consultaInfo.vacinacao,
                      'vacinacao',
                    ),
                    _buildConsultSection(
                      'Cuidados Específicos da Raça',
                      raca.consultaInfo.cuidadosEspecificos,
                      'cuidados_especificos',
                    ),
                    _buildConsultSection(
                      'Sinais de Alerta',
                      raca.consultaInfo.sinaisAlerta,
                      'sinais_alerta',
                    ),
                    const SizedBox(height: 20),
                    _buildShareButton(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      width: RacasDetalhesConstants.modalHandleWidth,
      height: RacasDetalhesConstants.modalHandleHeight,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Consulta Rápida - ${raca.nome}',
      style: RacasDetalhesConstants.modalTitleStyle,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildConsultSection(String title, String content, String sectionKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: RacasDetalhesHelpers.getSmallBorderRadius(),
      ),
      child: ExpansionTile(
        leading: Icon(
          RacasDetalhesHelpers.getSectionIcon(sectionKey),
          color: RacasDetalhesHelpers.getSectionIconColor(sectionKey),
        ),
        title: Text(
          title,
          style: RacasDetalhesConstants.modalSectionTitleStyle,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: RacasDetalhesConstants.modalContentStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => controller.shareVeterinaryInfo(context),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: RacasDetalhesHelpers.getSmallBorderRadius(),
        ),
      ),
      child: const Text('Compartilhar Informações'),
    );
  }
}
