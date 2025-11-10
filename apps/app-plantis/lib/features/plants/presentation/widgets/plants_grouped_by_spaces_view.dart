import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/providers/plants_providers.dart';
import '../../../../core/providers/spaces_providers.dart';
import '../../domain/entities/plant.dart';
import 'plant_card.dart';
import 'plant_list_tile.dart';
import 'space_header_widget.dart';

class PlantsGroupedBySpacesView extends ConsumerStatefulWidget {
  final Map<String?, List<Plant>> groupedPlants;
  final ScrollController? scrollController;
  final bool useGridLayout;

  const PlantsGroupedBySpacesView({
    super.key,
    required this.groupedPlants,
    this.scrollController,
    this.useGridLayout = true,
  });

  @override
  ConsumerState<PlantsGroupedBySpacesView> createState() =>
      _PlantsGroupedBySpacesViewState();
}

class _PlantsGroupedBySpacesViewState
    extends ConsumerState<PlantsGroupedBySpacesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final spacesAsync = ref.read(spacesNotifierProvider);
      final isEmpty = spacesAsync.maybeWhen(
        data: (state) => state.allSpaces.isEmpty,
        orElse: () => true,
      );

      if (isEmpty) {
        ref.read(spacesNotifierProvider.notifier).loadSpaces();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacesAsync = ref.watch(spacesNotifierProvider);

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      itemCount: widget.groupedPlants.length,
      itemBuilder: (context, index) {
        final entry = widget.groupedPlants.entries.elementAt(index);
        final spaceId = entry.key;
        final plants = entry.value;

        return spacesAsync.maybeWhen(
          data: (spacesState) => _buildSpaceSection(
            context,
            spaceId,
            plants,
            spacesState,
          ),
          orElse: () => _buildSpaceSection(
            context,
            spaceId,
            plants,
            null,
          ),
        );
      },
    );
  }

  Widget _buildSpaceSection(
    BuildContext context,
    String? spaceId,
    List<Plant> plants,
    SpacesState? spacesState,
  ) {
    final spaceName = _getSpaceName(spaceId, spacesState);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SpaceHeaderWidget(
          spaceId: spaceId,
          spaceName: spaceName,
          plantCount: plants.length,
          onEdit: () {
            ref.read(plantsNotifierProvider.notifier).refreshPlants();
          },
        ),

        const SizedBox(height: 8),
        widget.useGridLayout
            ? _buildPlantsGrid(context, plants)
            : _buildPlantsList(context, plants),

        const SizedBox(height: 24), // Space between sections
      ],
    );
  }

  Widget _buildPlantsList(BuildContext context, List<Plant> plants) {
    if (plants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Center(
          child: Text(
            'Nenhuma planta neste espaço',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        return PlantListTile(plant: plant, key: ValueKey(plant.id));
      },
    );
  }

  Widget _buildPlantsGrid(BuildContext context, List<Plant> plants) {
    if (plants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Center(
          child: Text(
            'Nenhuma planta neste espaço',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
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

  String _getSpaceName(String? spaceId, SpacesState? spacesState) {
    if (spaceId == null) {
      return 'Sem espaço definido';
    }

    if (spacesState == null) {
      return 'Espaço desconhecido';
    }
    try {
      final space = spacesState.allSpaces.firstWhere((s) => s.id == spaceId);
      return space.displayName;
    } catch (e) {
      return 'Espaço desconhecido';
    }
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
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
