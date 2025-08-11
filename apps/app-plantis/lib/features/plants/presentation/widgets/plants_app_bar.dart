import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../providers/plants_provider.dart';

class PlantsAppBar extends StatelessWidget {
  final int plantsCount;
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onViewModeChanged;
  final SortBy sortBy;
  final ValueChanged<SortBy> onSortChanged;

  const PlantsAppBar({
    super.key,
    required this.plantsCount,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.sortBy,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Título e contador
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minhas Plantas',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PlantisColors.primary,
                  ),
                ),
                Text(
                  plantsCount == 1 
                      ? '$plantsCount planta' 
                      : '$plantsCount plantas',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Botões de ação
          Row(
            children: [
              // Menu de ordenação
              PopupMenuButton<SortBy>(
                icon: Icon(
                  Icons.sort,
                  color: theme.colorScheme.primary,
                ),
                tooltip: 'Ordenar',
                onSelected: onSortChanged,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: SortBy.newest,
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 20,
                          color: sortBy == SortBy.newest 
                              ? theme.colorScheme.primary 
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Mais recentes',
                          style: TextStyle(
                            color: sortBy == SortBy.newest 
                                ? theme.colorScheme.primary 
                                : null,
                            fontWeight: sortBy == SortBy.newest 
                                ? FontWeight.bold 
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: SortBy.oldest,
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 20,
                          color: sortBy == SortBy.oldest 
                              ? theme.colorScheme.primary 
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Mais antigas',
                          style: TextStyle(
                            color: sortBy == SortBy.oldest 
                                ? theme.colorScheme.primary 
                                : null,
                            fontWeight: sortBy == SortBy.oldest 
                                ? FontWeight.bold 
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: SortBy.name,
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort_by_alpha,
                          size: 20,
                          color: sortBy == SortBy.name 
                              ? theme.colorScheme.primary 
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Nome A-Z',
                          style: TextStyle(
                            color: sortBy == SortBy.name 
                                ? theme.colorScheme.primary 
                                : null,
                            fontWeight: sortBy == SortBy.name 
                                ? FontWeight.bold 
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: SortBy.species,
                    child: Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 20,
                          color: sortBy == SortBy.species 
                              ? theme.colorScheme.primary 
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Espécie',
                          style: TextStyle(
                            color: sortBy == SortBy.species 
                                ? theme.colorScheme.primary 
                                : null,
                            fontWeight: sortBy == SortBy.species 
                                ? FontWeight.bold 
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 8),
              
              // Toggle de visualização
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ViewModeButton(
                      icon: Icons.grid_view,
                      isSelected: viewMode == ViewMode.grid,
                      onTap: () => onViewModeChanged(ViewMode.grid),
                      tooltip: 'Visualização em grade',
                    ),
                    _ViewModeButton(
                      icon: Icons.view_list,
                      isSelected: viewMode == ViewMode.list,
                      onTap: () => onViewModeChanged(ViewMode.list),
                      tooltip: 'Visualização em lista',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String tooltip;

  const _ViewModeButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.primary 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected 
                ? theme.colorScheme.onPrimary 
                : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}