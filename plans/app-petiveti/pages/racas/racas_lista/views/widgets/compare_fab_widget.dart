// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/racas_lista_controller.dart';

class CompareFabWidget extends StatelessWidget {
  final RacasListaController controller;

  const CompareFabWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.selectedRacas.isEmpty) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      label: Text(
        'Comparar (${controller.selectedRacas.length})',
      ),
      icon: const Icon(Icons.compare),
      onPressed: () => controller.showCompareOptions(context),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
