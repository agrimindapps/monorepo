// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/racas_lista_controller.dart';
import '../../utils/racas_lista_constants.dart';
import '../../utils/racas_lista_helpers.dart';

class EmptyStateWidget extends StatelessWidget {
  final RacasListaController controller;

  const EmptyStateWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RacasListaHelpers.buildEmptyStateIcon(),
          const SizedBox(height: 16),
          Text(
            'Nenhuma raça encontrada',
            style: RacasListaConstants.emptyStateTitle.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente modificar sua pesquisa ou filtros',
            style: RacasListaConstants.emptyStateSubtitle.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Limpar filtros'),
            onPressed: controller.clearAllFilters,
          ),
        ],
      ),
    );
  }
}
