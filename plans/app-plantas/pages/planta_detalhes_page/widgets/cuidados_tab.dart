// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/planta_detalhes_controller.dart';
import 'configuracoes_section_widget.dart';

/// Widget especializado para a aba de Cuidados
/// Responsável pela apresentação e configuração dos cuidados da planta
class CuidadosTab extends StatelessWidget {
  final PlantaDetalhesController controller;

  const CuidadosTab({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        8.0,
        8.0,
        8.0,
        24.0,
      ),
      child: Column(
        children: [
          ConfiguracoesSectionWidget(
            controller: controller,
            configuracoes: const {},
          ),
        ],
      ),
    );
  }
}
