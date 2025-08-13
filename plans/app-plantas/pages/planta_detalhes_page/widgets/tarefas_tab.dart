// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/planta_detalhes_controller.dart';
import 'tarefas_manager_widget.dart';

/// Widget especializado para a aba de Tarefas
/// Responsável pela apresentação e gerenciamento das tarefas da planta
class TarefasTab extends StatelessWidget {
  final PlantaDetalhesController controller;

  const TarefasTab({
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
          TarefasManagerWidget(
            controller: controller,
          ),
        ],
      ),
    );
  }
}
