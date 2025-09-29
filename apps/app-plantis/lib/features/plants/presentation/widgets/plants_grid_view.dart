import 'package:flutter/material.dart';
import '../../domain/entities/plant.dart';
import 'plant_card.dart';

class PlantsGridView extends StatelessWidget {
  final List<Plant> plants;
  final ScrollController? scrollController;

  const PlantsGridView({
    super.key,
    required this.plants,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75, // Ajuste conforme necessário
      ),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        return PlantCard(plant: plant, key: ValueKey(plant.id));
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Responsivo baseado no tamanho da tela
    if (width < 600) {
      return 2; // Telefones
    } else if (width < 900) {
      return 3; // Tablets pequenos
    } else if (width < 1200) {
      return 4; // Tablets grandes
    } else {
      return 5; // Desktop
    }
  }
}
