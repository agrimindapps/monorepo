// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/planta_detalhes_controller.dart';
import 'comentarios_section_widget.dart';

/// Widget especializado para a aba de Comentários
/// Responsável pela apresentação e gerenciamento dos comentários da planta
class ComentariosTab extends StatelessWidget {
  final PlantaDetalhesController controller;

  const ComentariosTab({
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
          ComentariosSectionWidget(
            controller: controller,
            comentarios: controller.comentariosOrdenados,
            temComentarios: controller.temComentarios,
          ),
        ],
      ),
    );
  }
}
