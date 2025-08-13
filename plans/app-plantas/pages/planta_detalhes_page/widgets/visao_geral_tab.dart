// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/planta_detalhes_controller.dart';
import 'info_card_widget.dart';

/// Widget especializado para a aba de Visão Geral
/// Responsável pela apresentação das informações gerais da planta
class VisaoGeralTab extends StatelessWidget {
  final PlantaDetalhesController controller;

  const VisaoGeralTab({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        9.0,
        8.0,
        8.0,
        24.0,
      ),
      child: Column(
        children: [
          InfoCardWidget(
            controller: controller,
            planta: controller.plantaAtual.value,
          ),
        ],
      ),
    );
  }
}
