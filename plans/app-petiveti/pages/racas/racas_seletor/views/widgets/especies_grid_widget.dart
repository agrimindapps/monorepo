// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/racas_seletor_controller.dart';
import '../../models/especie_seletor_model.dart';
import '../../utils/racas_seletor_helpers.dart';
import 'especie_card_widget.dart';

class EspeciesGridWidget extends StatelessWidget {
  final List<EspecieSeletor> especies;
  final RacasSeletorController controller;

  const EspeciesGridWidget({
    super.key,
    required this.especies,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (especies.isEmpty) {
      return _buildEmptyState(context);
    }

    return Padding(
      padding: RacasSeletorHelpers.getGridPadding(),
      child: GridView.builder(
        gridDelegate: RacasSeletorHelpers.getResponsiveGridDelegate(context),
        itemCount: especies.length,
        itemBuilder: (context, index) {
          final especie = especies[index];
          return AnimatedContainer(
            duration: RacasSeletorHelpers.getAnimationDuration(),
            curve: Curves.easeInOut,
            child: EspecieCardWidget(
              especie: especie,
              controller: controller,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma espécie encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente recarregar a página',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.recarregar,
            icon: const Icon(Icons.refresh),
            label: const Text('Recarregar'),
          ),
        ],
      ),
    );
  }
}
