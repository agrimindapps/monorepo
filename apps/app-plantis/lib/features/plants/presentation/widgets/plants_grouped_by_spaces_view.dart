import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/plant.dart';
import '../providers/plants_provider.dart';
import '../providers/spaces_provider.dart';
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
  State<PlantsGroupedBySpacesView> createState() => _PlantsGroupedBySpacesViewState();
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
            padding: const EdgeInsets.all(16),
            itemCount: widget.groupedPlants.length,
            itemBuilder: (context, index) {
              final entry = widget.groupedPlants.entries.elementAt(index);
              final spaceId = entry.key;
              final plants = entry.value;
              
              return _buildSpaceSection(context, spaceId, plants, spacesProvider);
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
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
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
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PlantListItemWidget(
            plant: plant,
            onTap: () => _onPlantTap(context, plant),
          ),
        );
      },
    );
  }

  Widget _buildPlantsGrid(BuildContext context, List<Plant> plants) {
    if (plants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate number of columns based on screen width
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: plants.length,
          itemBuilder: (context, index) {
            final plant = plants[index];
            return PlantCardWidget(
              plant: plant,
              onTap: () => _onPlantTap(context, plant),
            );
          },
        );
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

  int _calculateCrossAxisCount(double width) {
    if (width < 600) {
      return 2; // Mobile: 2 columns
    } else if (width < 900) {
      return 3; // Tablet: 3 columns
    } else {
      return 4; // Desktop: 4 columns
    }
  }

  void _onPlantTap(BuildContext context, Plant plant) {
    // Navigate to plant details or handle tap
    Navigator.of(context).pushNamed('/plant/${plant.id}');
  }
}

/// Simple plant list item widget for the grouped view
class PlantListItemWidget extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;

  const PlantListItemWidget({
    super.key,
    required this.plant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Plant image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: plant.hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          plant.primaryImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(theme),
                        ),
                      )
                    : _buildPlaceholder(theme),
              ),

              const SizedBox(width: 12),

              // Plant info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (plant.species?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        plant.species!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing icon
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.eco,
        color: theme.colorScheme.primary.withValues(alpha: 0.5),
        size: 30,
      ),
    );
  }
}

/// Simple plant card widget for the grouped view
class PlantCardWidget extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;

  const PlantCardWidget({
    super.key,
    required this.plant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plant image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                child: plant.hasImage
                    ? Image.network(
                        plant.primaryImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(theme),
                      )
                    : _buildPlaceholder(theme),
              ),
            ),
            
            // Plant info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Plant name
                    Text(
                      plant.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Plant species or age
                    Text(
                      plant.species?.isNotEmpty == true 
                          ? plant.species!
                          : '${plant.ageInDays} dias',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Icon(
        Icons.local_florist,
        size: 32,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}