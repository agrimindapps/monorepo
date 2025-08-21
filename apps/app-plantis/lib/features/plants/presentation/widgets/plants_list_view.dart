import 'package:flutter/material.dart';
import '../../domain/entities/plant.dart';
import 'plant_list_tile.dart';

class PlantsListView extends StatelessWidget {
  final List<Plant> plants;
  final ScrollController? scrollController;

  const PlantsListView({
    super.key,
    required this.plants,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        return PlantListTile(plant: plant, key: ValueKey(plant.id));
      },
    );
  }
}
