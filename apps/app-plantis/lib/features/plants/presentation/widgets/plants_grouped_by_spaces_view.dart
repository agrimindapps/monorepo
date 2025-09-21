import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/plant.dart';
import '../providers/plants_provider.dart';
import '../providers/spaces_provider.dart';
import 'plant_card.dart';
import 'plant_list_tile.dart';
import 'space_header_widget.dart';

class PlantsGroupedBySpacesView extends StatefulWidget {
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
  State<PlantsGroupedBySpacesView> createState() =>
      _PlantsGroupedBySpacesViewState();
}

class _PlantsGroupedBySpacesViewState extends State<PlantsGroupedBySpacesView> {
  late SpacesProvider _spacesProvider;

  @override
  void initState() {
    super.initState();
    _spacesProvider = di.sl<SpacesProvider>();

    // Carregar espaços se ainda não estiverem carregados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_spacesProvider.spaces.isEmpty) {
        _spacesProvider.loadSpaces();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _spacesProvider,
      child: Consumer<SpacesProvider>(
        builder: (context, spacesProvider, child) {
          return ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            itemCount: widget.groupedPlants.length,
            itemBuilder: (context, index) {
              final entry = widget.groupedPlants.entries.elementAt(index);
              final spaceId = entry.key;
              final plants = entry.value;

              return _buildSpaceSection(
                context,
                spaceId,
                plants,
                spacesProvider,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSpaceSection(
    BuildContext context,
    String? spaceId,
    List<Plant> plants,
    SpacesProvider spacesProvider,
  ) {
    final spaceName = _getSpaceName(spaceId, spacesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Space header
        SpaceHeaderWidget(
          spaceId: spaceId,
          spaceName: spaceName,
          plantCount: plants.length,
          onEdit: () {
            // Refresh plants list after space name change
            final plantsProvider = context.read<PlantsProvider>();
            plantsProvider.loadPlants();
          },
        ),

        const SizedBox(height: 8),

        // Plants grid/list for this space
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

    return AlignedGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisCount: _getCrossAxisCount(context),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        return PlantCard(plant: plant, key: ValueKey(plant.id));
      },
    );
  }

  String _getSpaceName(String? spaceId, SpacesProvider spacesProvider) {
    if (spaceId == null) {
      return 'Sem espaço definido';
    }

    // Try to find space in loaded spaces
    try {
      final space = spacesProvider.spaces.firstWhere((s) => s.id == spaceId);
      return space.displayName;
    } catch (e) {
      // Space not found in loaded spaces, return a fallback
      return 'Espaço desconhecido';
    }
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Usar a mesma lógica responsiva do PlantsGridView original
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
