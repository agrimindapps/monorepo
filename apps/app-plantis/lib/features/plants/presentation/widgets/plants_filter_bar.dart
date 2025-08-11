import 'package:flutter/material.dart';
import '../../domain/entities/space.dart';
import '../../../../core/theme/colors.dart';

class PlantsFilterBar extends StatelessWidget {
  final List<Space> spaces;
  final String? selectedSpaceId;
  final ValueChanged<String?> onSpaceFilterChanged;

  const PlantsFilterBar({
    super.key,
    required this.spaces,
    this.selectedSpaceId,
    required this.onSpaceFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (spaces.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: spaces.length + 1, // +1 para "Todos"
        itemBuilder: (context, index) {
          if (index == 0) {
            // Filtro "Todos"
            return _FilterChip(
              label: 'Todos',
              isSelected: selectedSpaceId == null,
              onTap: () => onSpaceFilterChanged(null),
              icon: Icons.apps,
            );
          }
          
          final space = spaces[index - 1];
          return _FilterChip(
            label: space.name,
            isSelected: selectedSpaceId == space.id,
            onTap: () => onSpaceFilterChanged(space.id),
            icon: _getSpaceIcon(space.lightCondition),
          );
        },
      ),
    );
  }

  IconData _getSpaceIcon(String? lightCondition) {
    switch (lightCondition?.toLowerCase()) {
      case 'high':
        return Icons.wb_sunny;
      case 'medium':
        return Icons.wb_cloudy;
      case 'low':
        return Icons.nights_stay;
      default:
        return Icons.location_on;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected 
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.primary,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
            fontWeight: isSelected 
                ? FontWeight.bold 
                : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        checkmarkColor: theme.colorScheme.onPrimary,
        side: BorderSide(
          color: isSelected 
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}